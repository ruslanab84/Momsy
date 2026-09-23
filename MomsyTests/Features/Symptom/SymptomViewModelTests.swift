import Testing
@testable import Momsy
import Foundation

private final class RecordingSymptomSyncRepository: BabySyncRepositoryProtocol {
    var symptomLogs: [SymptomLog] = []

    func addFeedingLog(_ log: FeedingLog) async throws {}
    func addSleepLog(_ log: SleepLog) async throws {}
    func addDiaperLog(_ log: DiaperLog) async throws {}
    func addSymptomLog(_ log: SymptomLog) async throws { symptomLogs.append(log) }
    func addDiaryLog(_ log: DiaryLog) async throws {}
    func addMeasurementLog(_ log: MeasurementLog) async throws {}
    func addVaccinationLog(_ log: VaccinationLog) async throws {}
    func addFoodDiaryLog(_ log: FoodDiaryLog) async throws {}
    func fetchTodayFeedings() async throws -> [FeedingLog] { [] }
    func fetchTodaySleep() async throws -> [SleepLog] { [] }
    func syncBabyProfile(_ profile: BabyProfile) async throws {}
    func fetchBabyProfile() async throws -> BabyProfile? { nil }
    func deleteBaby(id: UUID) async throws {}
}

@MainActor
struct SymptomViewModelTests {
    private let diaryRepo = MockDiaryRepository()
    private let syncRepo = RecordingSymptomSyncRepository()

    private func makeVM() -> SymptomViewModel {
        SymptomViewModel(
            appState: makeAppState(),
            addDiaryEntry: AddDiaryEntryUseCase(repository: diaryRepo),
            syncRepo: syncRepo
        )
    }

    @Test("starts with nothing selected and save disabled")
    func initialState() {
        let vm = makeVM()
        #expect(vm.isOnIDs.isEmpty)
        #expect(vm.canSave == false)
    }

    @Test("logs selected labels, note and the parent's own severity")
    func logsObservedSymptoms() async {
        let vm = makeVM()
        let strings = LocalizationManager.shared.strings
        vm.toggleSymptom("fever")
        vm.toggleSymptom("rash")
        vm.note = "  37.9 in the evening \n"
        vm.severity = .moderate

        await vm.logToDiary()?.value

        #expect(diaryRepo.addedItems.count == 1)
        let text = diaryRepo.addedItems.first?.text ?? ""
        #expect(text.contains(strings.symptomLabelTemperature))
        #expect(text.contains(strings.symptomLabelRash))
        #expect(text.contains("37.9 in the evening"))
        #expect(syncRepo.symptomLogs.count == 1)
        #expect(syncRepo.symptomLogs.first?.severity == .moderate)
        // Inputs reset after saving.
        #expect(vm.isOnIDs.isEmpty)
        #expect(vm.note.isEmpty)
        #expect(vm.severity == .mild)
    }

    @Test("whitespace-only note with no symptoms writes nothing")
    func emptyInputWritesNothing() async {
        let vm = makeVM()
        vm.note = "   \n"

        #expect(vm.canSave == false)
        #expect(vm.logToDiary() == nil)
        #expect(diaryRepo.addedItems.isEmpty)
        #expect(syncRepo.symptomLogs.isEmpty)
    }

    @Test("note is capped at 500 characters")
    func noteIsCapped() {
        let vm = makeVM()
        vm.note = String(repeating: "a", count: 600)
        #expect(vm.note.count == SymptomViewModel.noteLimit)
    }
}
