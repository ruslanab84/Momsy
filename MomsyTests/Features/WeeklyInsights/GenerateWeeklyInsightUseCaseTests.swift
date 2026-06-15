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

    @Test("uses AI narrative when the service succeeds")
    func aiSuccess() async throws {
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let service = MockWeeklyInsightService()
        let uc = makeUseCase(service: service, appState: appState)
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: Date())!

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
        let uc = makeUseCase(service: service, appState: appState)
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: Date())!

        let insight = await uc.generate(weekStart: bounds.start, weekEnd: bounds.end,
                                        birthDate: appState.babyProfile?.birthDate, language: .english)

        #expect(!insight.isAIGenerated)
        #expect(!insight.ai.sleepSummary.isEmpty)
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
