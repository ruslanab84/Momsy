import Testing
@testable import Momsy
import Foundation

@Suite("GenerateWeeklyInsightUseCase", .serialized)
@MainActor
struct GenerateWeeklyInsightUseCaseTests {

    private func makeUseCase(
        sleepRepo: MockSleepRepository = MockSleepRepository(),
        feedingRepo: MockFeedingRepository = MockFeedingRepository(),
        foodRepo: MockComplementaryFeedingRepository = MockComplementaryFeedingRepository(),
        diaperRepo: MockDiaperRepository = MockDiaperRepository(),
        repo: MockWeeklyInsightRepository = MockWeeklyInsightRepository(),
        service: MockWeeklyInsightService = MockWeeklyInsightService(),
        appState: AppState
    ) -> GenerateWeeklyInsightUseCase {
        GenerateWeeklyInsightUseCase(
            sleepRepo: sleepRepo, feedingRepo: feedingRepo, foodRepo: foodRepo, diaperRepo: diaperRepo,
            repo: repo, service: service, fallback: StaticWeeklyInsightService(), appState: appState
        )
    }

    /// A sleep repo seeded with one night session inside the given week, so the
    /// week counts as "has data" and the AI path (not the no-data path) is taken.
    private func seededSleepRepo(bounds: (start: Date, end: Date)) -> MockSleepRepository {
        let repo = MockSleepRepository()
        repo.entries = [
            SleepEntry(startDate: bounds.start.addingTimeInterval(21 * 3600),
                       endDate: bounds.start.addingTimeInterval(21 * 3600 + 600 * 60))
        ]
        return repo
    }

    @Test("uses AI narrative when the service succeeds")
    func aiSuccess() async throws {
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let service = MockWeeklyInsightService()
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: Date())!
        let uc = makeUseCase(sleepRepo: seededSleepRepo(bounds: bounds), service: service, appState: appState)

        let insight = await uc.generate(weekStart: bounds.start, weekEnd: bounds.end,
                                        birthDate: appState.babyProfile?.birthDate, language: .english)

        #expect(insight.isAIGenerated)
        #expect(insight.ai.sleepSummary == "AI sleep summary")
        #expect(service.callCount == 1)
    }

    @Test("falls back to static narrative when the service throws")
    func fallback() async throws {
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let service = MockWeeklyInsightService()
        service.shouldThrow = true
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: Date())!
        let uc = makeUseCase(sleepRepo: seededSleepRepo(bounds: bounds), service: service, appState: appState)

        let insight = await uc.generate(weekStart: bounds.start, weekEnd: bounds.end,
                                        birthDate: appState.babyProfile?.birthDate, language: .english)

        #expect(!insight.isAIGenerated)
        #expect(!insight.ai.sleepSummary.isEmpty)
    }

    @Test("a week with no logged data skips the AI service and reflects the gap")
    func emptyWeekSkipsAI() async throws {
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let service = MockWeeklyInsightService()
        // All repos are empty by default → the week has no data at all.
        let uc = makeUseCase(service: service, appState: appState)
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: Date())!

        let insight = await uc.generate(weekStart: bounds.start, weekEnd: bounds.end,
                                        birthDate: appState.babyProfile?.birthDate, language: .english)

        #expect(service.callCount == 0)              // no Gemini request was sent
        #expect(!insight.isAIGenerated)
        #expect(insight.stats.hasNoData)
        #expect(!insight.ai.overallSummary.isEmpty)  // report still reflects "no data"
        #expect(insight.ai.sleepSummary.isEmpty)     // no fabricated stats narrative
    }

    @Test("generateIfNeeded creates a report then no-ops for the same week")
    func dedup() async throws {
        let now = Date()
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: now)!
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let sleepRepo = MockSleepRepository()
        sleepRepo.entries = [
            SleepEntry(startDate: bounds.start.addingTimeInterval(21 * 3600),
                       endDate: bounds.start.addingTimeInterval(21 * 3600 + 600 * 60))
        ]
        let repo = MockWeeklyInsightRepository()
        let uc = makeUseCase(sleepRepo: sleepRepo, repo: repo, appState: appState)

        let first = await uc.generateIfNeeded(now: now)
        #expect(first != nil)
        #expect(repo.saveCount == 1)

        let second = await uc.generateIfNeeded(now: now)
        #expect(second == nil)
        #expect(repo.saveCount == 1)
    }

    /// Pre-aggregated stats for a baby in the "World of Patterns" leap (week 8, id 2).
    private func sampleStats(weekStart: Date, weekEnd: Date) -> WeeklyStats {
        WeeklyStats(
            weekStart: weekStart, weekEnd: weekEnd,
            ageMonths: 2, ageWeeks: 9, currentLeapName: "World of Patterns",
            avgSleepMinutesPerDay: 840, avgNightSleepMinutes: 600, avgDaySleepMinutes: 240,
            avgNapsPerDay: 3, sleepTrendVsPrevWeekMinutes: 0,
            whoMinSleepMinutes: 840, whoAwakeWindowMax: 90,
            avgFeedingsPerDay: 6, totalFeedings: 42,
            newFoodsIntroduced: [], allergensFlagged: [], totalDiapers: 35
        )
    }

    @Test("changing app language keeps existing reports as-is (no Gemini call)")
    func languageChangeKeepsReportsAsIs() async throws {
        let previous = LocalizationManager.shared.current
        defer { LocalizationManager.shared.set(previous) }

        let now = Date()
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: now)!
        LocalizationManager.shared.set(.russian)            // app language is now RU…
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let repo = MockWeeklyInsightRepository()
        let englishAI = WeeklyInsightAI(sleepSummary: "English summary", sleepRecommendation: "",
                                        feedingSummary: "", feedingRecommendation: "", overallSummary: "")
        // …but this week's report was generated earlier in English.
        try await repo.save(WeeklyInsight(stats: sampleStats(weekStart: bounds.start, weekEnd: bounds.end),
                                          ai: englishAI, isAIGenerated: true,
                                          generatedAt: Date(), language: .english))
        let service = MockWeeklyInsightService()
        let uc = makeUseCase(repo: repo, service: service, appState: appState)

        let result = await uc.generateIfNeeded(now: now)

        #expect(result == nil)                       // existing report → not regenerated
        #expect(service.callCount == 0)              // zero Gemini calls on language change
        let stored = try await repo.all()
        #expect(stored.count == 1)
        #expect(stored.first?.language == .english)  // old report untouched
        #expect(stored.first?.ai.sleepSummary == "English summary")
    }

    @Test("weekBounds returns a 7-day window ending at the current week start")
    func weekBounds() {
        let now = Date()
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: now)!
        let days = Calendar.current.dateComponents([.day], from: bounds.start, to: bounds.end).day
        #expect(days == 7)
        #expect(bounds.end <= now)
    }

    /// Builds a date in the device's current calendar/timezone (matching `weekBounds`,
    /// which uses `Calendar.current`) so the assertions are independent of CI locale.
    private func date(_ y: Int, _ mo: Int, _ d: Int, _ h: Int) -> Date {
        var comps = DateComponents()
        comps.year = y; comps.month = mo; comps.day = d; comps.hour = h
        return Calendar.current.date(from: comps)!
    }

    @Test("weekBounds is Sunday-anchored: after 07:00 Sunday shows the just-completed Sun–Sat week")
    func weekBoundsSundayAfterRelease() {
        // Sunday June 14, 2026 at 09:00 → should release the Jun 7 – Jun 14 window.
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: date(2026, 6, 14, 9))!
        var cal = Calendar.current
        cal.firstWeekday = 1
        #expect(cal.startOfDay(for: bounds.end) == cal.startOfDay(for: date(2026, 6, 14, 0)))
        #expect(cal.startOfDay(for: bounds.start) == cal.startOfDay(for: date(2026, 6, 7, 0)))
        #expect(cal.component(.weekday, from: bounds.start) == 1) // Sunday
    }

    @Test("weekBounds keeps the previous week before 07:00 Sunday")
    func weekBoundsSundayBeforeRelease() {
        // Sunday June 14, 2026 at 06:00 → still the prior week (May 31 – Jun 7).
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: date(2026, 6, 14, 6))!
        var cal = Calendar.current
        cal.firstWeekday = 1
        #expect(cal.startOfDay(for: bounds.end) == cal.startOfDay(for: date(2026, 6, 7, 0)))
        #expect(cal.startOfDay(for: bounds.start) == cal.startOfDay(for: date(2026, 5, 31, 0)))
    }
}
