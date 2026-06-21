import Testing
@testable import Momsy
import Foundation

// Minimal repo mocks the report needs but that aren't shared elsewhere yet.
private final class MockTemperatureRepository: TemperatureRepository {
    var entries: [TemperatureEntry] = []
    func getAll() async throws -> [TemperatureEntry] { entries }
    func getEntries(from: Date, to: Date) async throws -> [TemperatureEntry] {
        entries.filter { $0.date >= from && $0.date <= to }
    }
    func add(_ entry: TemperatureEntry) async throws { entries.append(entry) }
    func upsert(_ newEntries: [TemperatureEntry]) async throws { entries.append(contentsOf: newEntries) }
    func delete(id: UUID) async throws { entries.removeAll { $0.id == id } }
}

private final class MockMeasurementRepository: MeasurementRepository {
    var entries: [MeasurementEntry] = []
    func getAll() async throws -> [MeasurementEntry] { entries }
    func getEntries(from: Date, to: Date) async throws -> [MeasurementEntry] {
        entries.filter { $0.date >= from && $0.date <= to }
    }
    func add(_ entry: MeasurementEntry) async throws { entries.append(entry) }
    func upsert(_ newEntries: [MeasurementEntry]) async throws { entries.append(contentsOf: newEntries) }
    func delete(id: UUID) async throws { entries.removeAll { $0.id == id } }
}

private final class MockDoctorVisitRepository: DoctorVisitRepository {
    var last: DoctorVisit?
    func getLast() async throws -> DoctorVisit? { last }
    func save(_ visit: DoctorVisit) async throws { last = visit }
    func upsert(_ visits: [DoctorVisit]) async throws { last = visits.last ?? last }
}

@Suite("ReportViewModel", .serialized)
@MainActor
struct ReportViewModelTests {

    // NOTE: deliberately does NOT touch ActiveBaby.currentId. It is process-global
    // (UserDefaults-backed) and other suites race on it; the diary mock here ignores
    // scope, so this suite stays hermetic and doesn't perturb ActiveBaby-sensitive tests.

    private func makeVM(diary: MockDiaryRepository) -> ReportViewModel {
        let profile = BabyProfile(
            id: UUID(),
            name: "Тест",
            birthDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            gender: "girl"
        )
        let babyRepo = MockBabyRepository(initialProfile: profile)
        let appState = AppState(getBabyProfile: GetBabyProfileUseCase(repository: babyRepo),
                                getAllBabies: GetAllBabiesUseCase(repository: babyRepo))
        return ReportViewModel(
            feedingRepo: MockFeedingRepository(),
            sleepRepo: MockSleepRepository(),
            diaperRepo: MockDiaperRepository(),
            temperatureRepo: MockTemperatureRepository(),
            measurementRepo: MockMeasurementRepository(),
            doctorVisitRepo: MockDoctorVisitRepository(),
            diaryRepo: diary,
            appState: appState,
            analytics: MockAnalyticsService()
        )
    }

    private func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }

    @Test("NOTES reflects real diary notes & milestones for the period, not a hardcoded example")
    func notesComeFromDiary() async {
        let diary = MockDiaryRepository()
        diary.items = [
            StoredDiaryItem(date: daysAgo(2), kind: .note, text: "Слегка температурил"),
            StoredDiaryItem(date: daysAgo(1), kind: .milestone, text: "Первый зуб"),
        ]
        let vm = makeVM(diary: diary)
        vm.selectedPeriod = 1   // 7 days
        await vm.loadData()

        #expect(vm.currentNotes.count == 2)
        // Newest first: yesterday's milestone precedes the 2-days-ago note.
        #expect(vm.currentNotes.first?.text == "Первый зуб")
        #expect(vm.currentNotes.last?.text == "Слегка температурил")
    }

    @Test("NOTES excludes photos and blank-text entries")
    func notesExcludePhotosAndBlanks() async {
        let diary = MockDiaryRepository()
        diary.items = [
            StoredDiaryItem(date: daysAgo(1), kind: .photo, text: "подпись к фото"),
            StoredDiaryItem(date: daysAgo(1), kind: .note, text: ""),
            StoredDiaryItem(date: daysAgo(1), kind: .note, text: "настоящая заметка"),
        ]
        let vm = makeVM(diary: diary)
        vm.selectedPeriod = 1
        await vm.loadData()

        #expect(vm.currentNotes.count == 1)
        #expect(vm.currentNotes.first?.text == "настоящая заметка")
    }

    @Test("NOTES is empty when there are no diary entries in the period (block hides)")
    func notesEmptyWhenNone() async {
        let diary = MockDiaryRepository()
        diary.items = [
            // Outside a 3-day window.
            StoredDiaryItem(date: daysAgo(20), kind: .note, text: "старая заметка"),
        ]
        let vm = makeVM(diary: diary)
        vm.selectedPeriod = 0   // 3 days
        await vm.loadData()

        #expect(vm.currentNotes.isEmpty)
    }
}
