import Foundation

/// Orchestrates: compute last completed week → de-dup → aggregate → AI (with
/// offline fallback) → persist locally. Generation is automatic (no UI trigger).
final class GenerateWeeklyInsightUseCase {

    private let sleepRepo: any SleepRepository
    private let feedingRepo: any FeedingRepository
    private let foodRepo: any ComplementaryFeedingRepository
    private let diaperRepo: any DiaperRepository
    private let repo: any WeeklyInsightRepository
    private let service: any WeeklyInsightService
    private let fallback: any WeeklyInsightService
    private let appState: AppState
    private let hasAIConsent: () -> Bool
    private let leapCheckInRepo: (any LeapCheckInRepository)?
    private let diaryRepo: (any DiaryRepository)?

    init(
        sleepRepo: any SleepRepository,
        feedingRepo: any FeedingRepository,
        foodRepo: any ComplementaryFeedingRepository,
        diaperRepo: any DiaperRepository,
        repo: any WeeklyInsightRepository,
        service: any WeeklyInsightService,
        fallback: any WeeklyInsightService,
        appState: AppState,
        hasAIConsent: @escaping () -> Bool,
        leapCheckInRepo: (any LeapCheckInRepository)? = nil,
        diaryRepo: (any DiaryRepository)? = nil
    ) {
        self.sleepRepo = sleepRepo
        self.feedingRepo = feedingRepo
        self.foodRepo = foodRepo
        self.diaperRepo = diaperRepo
        self.repo = repo
        self.service = service
        self.fallback = fallback
        self.appState = appState
        self.hasAIConsent = hasAIConsent
        self.leapCheckInRepo = leapCheckInRepo
        self.diaryRepo = diaryRepo
    }

    /// Generates a report for the most recent completed week if one doesn't exist yet.
    /// Returns the newly created report, or nil if nothing was generated.
    @MainActor
    @discardableResult
    func generateIfNeeded(now: Date = Date()) async -> WeeklyInsight? {
        guard hasAIConsent() else { return nil }
        let language = LocalizationManager.shared.current
        guard let (weekStart, weekEnd) = Self.weekBounds(now: now) else { return nil }
        // A report for this week already exists — keep it in whatever language it was
        // generated in. Changing the app language never re-generates or re-translates
        // past reports (no Gemini cost on language switch); only future weeks use the
        // new language.
        if ((try? await repo.report(forWeekStarting: weekStart)) ?? nil) != nil { return nil }

        let birthDate = appState.babyProfile?.birthDate
        let insight = await generate(weekStart: weekStart, weekEnd: weekEnd,
                                     birthDate: birthDate, language: language)
        try? await repo.save(insight)
        return insight
    }

    /// Builds stats + narrative (AI, falling back to static) without persistence — testable.
    func generate(weekStart: Date, weekEnd: Date, birthDate: Date?, language: Language) async -> WeeklyInsight {
        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: weekStart, weekEnd: weekEnd, birthDate: birthDate, language: language,
            sleepRepo: sleepRepo, feedingRepo: feedingRepo, foodRepo: foodRepo, diaperRepo: diaperRepo,
            leapCheckInRepo: leapCheckInRepo, diaryRepo: diaryRepo
        )
        // No logged activity this week → don't spend a Gemini request. Emit a
        // static, localized "no data" note so the report still reflects the gap.
        if stats.hasNoData {
            return WeeklyInsight(stats: stats, ai: Self.noDataAI(language: language),
                                 isAIGenerated: false, generatedAt: Date(), language: language)
        }

        let ctx = WeeklyInsightContext(stats: stats, language: language)

        if hasAIConsent(), let ai = try? await service.generate(context: ctx) {
            return WeeklyInsight(stats: stats, ai: ai, isAIGenerated: true, generatedAt: Date(), language: language)
        }
        let ai = (try? await fallback.generate(context: ctx)) ?? Self.emptyAI
        return WeeklyInsight(stats: stats, ai: ai, isAIGenerated: false, generatedAt: Date(), language: language)
    }

    /// Most recent completed Sunday–Saturday week, released each Sunday at 07:00 local time.
    /// Returns [start, end) where start is a Sunday 00:00 and end is the following Sunday 00:00.
    /// Sunday-anchored regardless of the locale's first weekday; before 07:00 Sunday the
    /// previous week is kept so the new report appears exactly at the 07:00 release.
    static func weekBounds(now: Date) -> (start: Date, end: Date)? {
        var cal = Calendar.current
        cal.firstWeekday = 1   // Sunday
        guard let thisWeek = cal.dateInterval(of: .weekOfYear, for: now) else { return nil }
        let thisSunday = thisWeek.start
        guard let release = cal.date(byAdding: .hour, value: 7, to: thisSunday) else { return nil }
        let weekEnd = now >= release
            ? thisSunday
            : (cal.date(byAdding: .day, value: -7, to: thisSunday) ?? thisSunday)
        guard let weekStart = cal.date(byAdding: .day, value: -7, to: weekEnd) else { return nil }
        return (weekStart, weekEnd)
    }

    private static let emptyAI = WeeklyInsightAI(
        sleepSummary: "", sleepRecommendation: "",
        feedingSummary: "", feedingRecommendation: "", overallSummary: ""
    )

    /// Narrative for a week with no logged data. Carries the localized note in
    /// `overallSummary` (the only field the row and detail card render), leaving
    /// the per-section summaries empty so no stats are fabricated.
    private static func noDataAI(language: Language) -> WeeklyInsightAI {
        WeeklyInsightAI(
            sleepSummary: "", sleepRecommendation: "",
            feedingSummary: "", feedingRecommendation: "",
            overallSummary: L10n(language).weeklyInsightNoData
        )
    }
}
