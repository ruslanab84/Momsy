import Testing
@testable import Momsy
import Foundation

@Suite("MomMoodViewModel", .serialized)
@MainActor
struct MomMoodViewModelTests {

    func makeVM(repo: MockMomMoodRepository = MockMomMoodRepository()) -> MomMoodViewModel {
        MomMoodViewModel(repository: repo)
    }

    // MARK: - loadHistory

    @Test("loadHistory returns empty when no entries")
    func loadHistoryEmpty() async {
        let vm = makeVM()
        await vm.loadHistory()
        #expect(vm.entries.isEmpty)
    }

    @Test("loadHistory returns entries within 30-day window")
    func loadHistoryFilters() async {
        let repo = MockMomMoodRepository()
        let recent = MomMoodEntry(id: UUID(), date: Date(), mood: 3, energy: 3, note: "", epdsScore: nil)
        let old = MomMoodEntry(id: UUID(), date: Date().addingTimeInterval(-40 * 86400), mood: 2, energy: 2, note: "", epdsScore: nil)
        repo.entries = [recent, old]
        let vm = makeVM(repo: repo)
        await vm.loadHistory()
        #expect(vm.entries.count == 1)
        #expect(vm.entries[0].id == recent.id)
    }

    @Test("Persisted moods are clamped to the display range")
    func persistedMoodIsClamped() {
        let tooLow = MomMoodRecord(mood: 0, energy: 3, note: "").toDomain()
        let tooHigh = MomMoodRecord(mood: 6, energy: 3, note: "").toDomain()

        #expect(tooLow.mood == 1)
        #expect(tooHigh.mood == 5)
    }

    // MARK: - saveCheckin

    @Test("saveCheckin adds entry and reloads")
    func saveCheckinAdds() async {
        let repo = MockMomMoodRepository()
        let vm = makeVM(repo: repo)
        await vm.saveCheckin(mood: 4, energy: 5, note: "Good day")
        #expect(repo.entries.count == 1)
        #expect(repo.entries[0].mood == 4)
        #expect(repo.entries[0].energy == 5)
        #expect(repo.entries[0].epdsScore == nil)
        #expect(vm.entries.count == 1)
    }

    // MARK: - saveEPDS

    @Test("saveEPDS computes correct score sum")
    func saveEPDSScore() async {
        let repo = MockMomMoodRepository()
        let vm = makeVM(repo: repo)
        let scores = [2, 1, 3, 2, 1, 0, 2, 1, 1, 0]
        await vm.saveEPDS(scores: scores, mood: 3, energy: 3)
        #expect(repo.entries.count == 1)
        #expect(repo.entries[0].epdsScore == scores.reduce(0, +))
    }

    @Test("EPDS uses displayed scores and flags every positive Q10 response")
    func epdsScoringAndSafetySupport() {
        let healthyAnswers = Array(repeating: 0, count: 10)
        #expect(MomMoodViewModel.epdsScore(for: healthyAnswers) == 0)
        #expect(MomMoodViewModel.requiresEPDSSafetySupport(for: healthyAnswers) == false)

        var severeQ1AndQ2 = healthyAnswers
        severeQ1AndQ2[0] = 3
        severeQ1AndQ2[1] = 3
        #expect(MomMoodViewModel.epdsScore(for: severeQ1AndQ2) == 6)
        #expect(MomMoodViewModel.epdsScore(for: Array(repeating: 3, count: 10)) == 30)

        for response in 1...3 {
            var answers = healthyAnswers
            answers[9] = response
            #expect(MomMoodViewModel.requiresEPDSSafetySupport(for: answers))
        }
    }

    // MARK: - epdsRiskColor

    @Test("epdsRiskColor is mint for score < 10")
    func riskColorLow() async {
        let repo = MockMomMoodRepository()
        let entry = MomMoodEntry(id: UUID(), date: Date(), mood: 4, energy: 4, note: "", epdsScore: 6)
        repo.entries = [entry]
        let vm = makeVM(repo: repo)
        await vm.loadHistory()
        #expect(vm.epdsRiskColor == .bbMint)
    }

    @Test("epdsRiskColor is bbButter for score 10–12")
    func riskColorMild() async {
        let repo = MockMomMoodRepository()
        let entry = MomMoodEntry(id: UUID(), date: Date(), mood: 2, energy: 2, note: "", epdsScore: 11)
        repo.entries = [entry]
        let vm = makeVM(repo: repo)
        await vm.loadHistory()
        #expect(vm.epdsRiskColor == .bbButter)
    }

    @Test("epdsRiskColor is bbCoral for score >= 13")
    func riskColorHigh() async {
        let repo = MockMomMoodRepository()
        let entry = MomMoodEntry(id: UUID(), date: Date(), mood: 1, energy: 1, note: "", epdsScore: 15)
        repo.entries = [entry]
        let vm = makeVM(repo: repo)
        await vm.loadHistory()
        #expect(vm.epdsRiskColor == .bbCoral)
    }

    // MARK: - shouldPromptEPDS

    @Test("shouldPromptEPDS is true when no EPDS taken")
    func promptEPDSNoEntry() {
        let vm = makeVM()
        #expect(vm.shouldPromptEPDS == true)
    }
}

// MARK: - Water goal (A4: user-set target, not a health recommendation)

@Suite("WaterIntakeGoal")
@MainActor
struct WaterIntakeGoalTests {

    @Test func defaultsTo2000WhenNothingStored() {
        let vm = makeVM(prefs: InMemoryPreferences())
        #expect(vm.goalMl == 2000)
    }

    @Test func goalPersistsAcrossViewModels() {
        let prefs = InMemoryPreferences()
        makeVM(prefs: prefs).setGoal(2750)
        #expect(prefs.stored.waterGoalMl == 2750)
        #expect(makeVM(prefs: prefs).goalMl == 2750)
    }

    @Test func goalClampsTo1000Through4000() {
        let prefs = InMemoryPreferences()
        let vm = makeVM(prefs: prefs)
        vm.setGoal(250)
        #expect(vm.goalMl == 1000)
        vm.setGoal(9000)
        #expect(vm.goalMl == 4000)
        #expect(prefs.stored.waterGoalMl == 4000)
    }

    @Test func storedOutOfRangeValueIsClampedOnLoad() {
        let prefs = InMemoryPreferences()
        prefs.stored.waterGoalMl = 12_000
        #expect(makeVM(prefs: prefs).goalMl == 4000)
    }

    @Test func settingGoalKeepsOtherPreferences() {
        let prefs = InMemoryPreferences()
        prefs.stored.unitSystem = "imperial"
        makeVM(prefs: prefs).setGoal(1500)
        #expect(prefs.stored.unitSystem == "imperial")
    }

    private func makeVM(prefs: InMemoryPreferences) -> WaterIntakeViewModel {
        let repo = NoopWaterRepository()
        return WaterIntakeViewModel(
            log: LogWaterIntakeUseCase(repository: repo),
            get: GetWaterIntakeUseCase(repository: repo),
            preferences: prefs
        )
    }
}

private final class InMemoryPreferences: UserPreferencesRepository {
    var stored = UserPreferences(appTheme: "system", appLanguage: "en", unitSystem: "metric")
    func load() -> UserPreferences { stored }
    func save(_ prefs: UserPreferences) { stored = prefs }
}

private struct NoopWaterRepository: WaterIntakeRepository {
    func add(_ entry: WaterIntakeEntry) async throws {}
    func upsert(_ entries: [WaterIntakeEntry]) async throws {}
    func getEntries(from: Date, to: Date) async throws -> [WaterIntakeEntry] { [] }
}
