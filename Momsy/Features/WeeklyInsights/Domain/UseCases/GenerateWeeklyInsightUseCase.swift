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
        guard let (weekStart, weekEnd) = Self.weekBounds(now: now) else { return nil }
        if ((try? await repo.report(forWeekStarting: weekStart)) ?? nil) != nil { return nil }

        let birthDate = appState.babyProfile?.birthDate
        let language = LocalizationManager.shared.current

        let insight = await generate(weekStart: weekStart, weekEnd: weekEnd,
                                     birthDate: birthDate, language: language)
        try? await repo.save(insight)
        return insight
    }

    /// Builds stats + narrative (AI, falling back to static) without persistence — testable.
    func generate(weekStart: Date, weekEnd: Date, birthDate: Date?, language: Language) async -> WeeklyInsight {
        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: weekStart, weekEnd: weekEnd, birthDate: birthDate, language: language,
            sleepRepo: sleepRepo, feedingRepo: feedingRepo, foodRepo: foodRepo, diaperRepo: diaperRepo
        )
        let ctx = WeeklyInsightContext(stats: stats, language: language)

        if let ai = try? await service.generate(context: ctx) {
            return WeeklyInsight(stats: stats, ai: ai, isAIGenerated: true, generatedAt: Date())
        }
        let ai = (try? await fallback.generate(context: ctx)) ?? Self.emptyAI
        return WeeklyInsight(stats: stats, ai: ai, isAIGenerated: false, generatedAt: Date())
    }

    /// Most recent completed week: [start, end) where end = start of the current week.
    static func weekBounds(now: Date) -> (start: Date, end: Date)? {
        let cal = Calendar.current
        guard let thisWeek = cal.dateInterval(of: .weekOfYear, for: now) else { return nil }
        let weekEnd = thisWeek.start
        guard let weekStart = cal.date(byAdding: .day, value: -7, to: weekEnd) else { return nil }
        return (weekStart, weekEnd)
    }

    private static let emptyAI = WeeklyInsightAI(
        sleepSummary: "", sleepRecommendation: "",
        feedingSummary: "", feedingRecommendation: "", overallSummary: ""
    )
}
