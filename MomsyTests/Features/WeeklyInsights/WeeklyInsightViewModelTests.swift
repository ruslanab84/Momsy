import Testing
@testable import Momsy
import Foundation

@Suite("WeeklyInsightViewModel", .serialized)
@MainActor
struct WeeklyInsightViewModelTests {

    private func makeVM(repo: MockWeeklyInsightRepository, service: MockWeeklyInsightService = MockWeeklyInsightService())
        -> (WeeklyInsightViewModel, AppState) {
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: Date())!
        let sleepRepo = MockSleepRepository()
        sleepRepo.entries = [
            SleepEntry(startDate: bounds.start.addingTimeInterval(21 * 3600),
                       endDate: bounds.start.addingTimeInterval(21 * 3600 + 600 * 60))
        ]
        let generate = GenerateWeeklyInsightUseCase(
            sleepRepo: sleepRepo, feedingRepo: MockFeedingRepository(),
            foodRepo: MockComplementaryFeedingRepository(), diaperRepo: MockDiaperRepository(),
            repo: repo, service: service, fallback: StaticWeeklyInsightService(), appState: appState,
            hasAIConsent: { true }
        )
        let get = GetWeeklyInsightsUseCase(repository: repo)
        return (WeeklyInsightViewModel(generate: generate, get: get), appState)
    }

    @Test("non-premium load does not generate a report")
    func nonPremium() async throws {
        let repo = MockWeeklyInsightRepository()
        let (vm, _) = makeVM(repo: repo)
        await vm.load(isPremium: false)
        #expect(repo.saveCount == 0)
        #expect(vm.reports.isEmpty)
        #expect(vm.state.value != nil)  // .loaded
    }

    @Test("premium load generates and surfaces the report")
    func premium() async throws {
        let repo = MockWeeklyInsightRepository()
        let (vm, _) = makeVM(repo: repo)
        await vm.load(isPremium: true)
        #expect(repo.saveCount == 1)
        #expect(vm.reports.count == 1)
    }

    @Test("error state when loading fails")
    func errorState() async throws {
        let repo = ThrowingWeeklyInsightRepository()
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let generate = GenerateWeeklyInsightUseCase(
            sleepRepo: MockSleepRepository(), feedingRepo: MockFeedingRepository(),
            foodRepo: MockComplementaryFeedingRepository(), diaperRepo: MockDiaperRepository(),
            repo: repo, service: MockWeeklyInsightService(), fallback: StaticWeeklyInsightService(), appState: appState,
            hasAIConsent: { true }
        )
        let vm = WeeklyInsightViewModel(generate: generate, get: GetWeeklyInsightsUseCase(repository: repo))
        await vm.load(isPremium: false)
        #expect(vm.state.errorMessage != nil)
    }
}

private final class ThrowingWeeklyInsightRepository: WeeklyInsightRepository {
    func all() async throws -> [WeeklyInsight] { throw TestError.mock }
    func latest() async throws -> WeeklyInsight? { throw TestError.mock }
    func report(forWeekStarting weekStart: Date) async throws -> WeeklyInsight? { nil }
    func save(_ insight: WeeklyInsight) async throws {}
}
