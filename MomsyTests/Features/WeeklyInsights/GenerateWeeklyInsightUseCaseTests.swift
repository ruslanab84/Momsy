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
}
