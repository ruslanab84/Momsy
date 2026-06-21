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

    init(
        sleepRepo: any SleepRepository,
        feedingRepo: any FeedingRepository,
        foodRepo: any ComplementaryFeedingRepository,
        diaperRepo: any DiaperRepository,
        repo: any WeeklyInsightRepository,
        service: any WeeklyInsightService,
        fallback: any WeeklyInsightService,
        appState: AppState
    ) {
        self.sleepRepo = sleepRepo
        self.feedingRepo = feedingRepo
        self.foodRepo = foodRepo
        self.diaperRepo = diaperRepo
        self.repo = repo
        self.service = service
        self.fallback = fallback
        self.appState = appState
    }

    /// Generates a report for the most recent completed week if one doesn't exist yet.
    /// Returns the newly created report, or nil if nothing was generated.
    @MainActor
    @discardableResult
    func generateIfNeeded(now: Date = Date()) async -> WeeklyInsight? {
        let language = LocalizationManager.shared.current
        // Refresh any previously stored reports that are now in the wrong language
        // (e.g. the user switched app language after they were generated).
        await relocalizeStaleReports(to: language)

        guard let (weekStart, weekEnd) = Self.weekBounds(now: now) else { return nil }
        // Skip only when a report for this week already exists in the current language.
        if let existing = (try? await repo.report(forWeekStarting: weekStart)) ?? nil,
           existing.language == language { return nil }

        let birthDate = appState.babyProfile?.birthDate
        let insight = await generate(weekStart: weekStart, weekEnd: weekEnd,
                                     birthDate: birthDate, language: language)
        try? await repo.save(insight)
        return insight
    }

    /// Re-localizes stored reports whose language no longer matches `language`.
    /// Stats are deterministic and already on-device, so only the AI narrative and
    /// the localized leap label are recomputed. Skips a report when the AI call
    /// fails so a good narrative is never downgraded to the offline fallback.
    func relocalizeStaleReports(to language: Language) async {
        let reports = (try? await repo.all()) ?? []
        for report in reports where report.language != language {
            let leap = BabyAgeContext.currentLeapName(ageWeeks: report.stats.ageWeeks, lang: language.rawValue)
            let stats = report.stats.withLeapName(leap)
            let ctx = WeeklyInsightContext(stats: stats, language: language)
            guard let ai = try? await service.generate(context: ctx) else { continue }
            let relocalized = WeeklyInsight(stats: stats, ai: ai, isAIGenerated: true,
                                            generatedAt: report.generatedAt, language: language)
            try? await repo.save(relocalized)
        }
    }

    /// Builds stats + narrative (AI, falling back to static) without persistence — testable.
    func generate(weekStart: Date, weekEnd: Date, birthDate: Date?, language: Language) async -> WeeklyInsight {
        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: weekStart, weekEnd: weekEnd, birthDate: birthDate, language: language,
            sleepRepo: sleepRepo, feedingRepo: feedingRepo, foodRepo: foodRepo, diaperRepo: diaperRepo
        )
        let ctx = WeeklyInsightContext(stats: stats, language: language)

        if let ai = try? await service.generate(context: ctx) {
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
}
