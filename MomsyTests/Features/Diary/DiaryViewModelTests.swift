import Testing
import Foundation
@testable import Momsy

@Suite("DiaryViewModel", .serialized)
@MainActor
struct DiaryViewModelTests {

    func makeVM(
        repo: MockDiaryRepository = MockDiaryRepository(),
        profile: BabyProfile? = nil
    ) async throws -> DiaryViewModel {
        let vm = DiaryViewModel(
            repo: repo,
            analytics: MockAnalyticsService(),
            appState: makeAppState(profile: profile)
        )
        try await Task.sleep(nanoseconds: 100_000_000)
        return vm
    }

    // MARK: - insertDay

    @Test("insertDay adds a new day when no today entry exists")
    func insertDayCreatesNewDay() async throws {
        let vm = try await makeVM()
        let item = DiaryItem(id: UUID(), type: .note(text: "First note"))
        let day  = DiaryDay(dateLabel: "", ageLabel: "", items: [item])
        vm.insertDay(day)
        #expect(vm.entries.count == 1)
        #expect(vm.entries[0].items.count == 1)
    }

    @Test("insertDay inserts items into existing today section")
    func insertDayAppendsToExistingToday() async throws {
        let vm = try await makeVM()
        let todayPrefix = LocalizationManager.shared.strings.today
        let existing = DiaryItem(id: UUID(), type: .note(text: "Old"))
        let todayDay = DiaryDay(dateLabel: "\(todayPrefix) · Mon", ageLabel: "", items: [existing])
        vm.entries = [todayDay]

        let newItem = DiaryItem(id: UUID(), type: .note(text: "New"))
        vm.insertDay(DiaryDay(dateLabel: "", ageLabel: "", items: [newItem]))
        #expect(vm.entries.count == 1)
        #expect(vm.entries[0].items.count == 2)
    }

    @Test("insertDay rolls back entry on repository error")
    func insertDayRollsBackOnRepoError() async throws {
        let repo = MockDiaryRepository()
        repo.throwOnAdd = true
        let vm = try await makeVM(repo: repo)
        let item = DiaryItem(id: UUID(), type: .note(text: "Lost note"))
        vm.insertDay(DiaryDay(dateLabel: "", ageLabel: "", items: [item]))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(vm.entries.allSatisfy { $0.items.allSatisfy { $0.id != item.id } })
        #expect(vm.saveError != nil)
    }

    @Test("insertDay second entry appears without removing first")
    func insertDayTwoEntriesCoexist() async throws {
        let vm = try await makeVM()
        let item1 = DiaryItem(id: UUID(), type: .note(text: "First"))
        let item2 = DiaryItem(id: UUID(), type: .milestone(icon: .star, label: "Second"))
        vm.insertDay(DiaryDay(dateLabel: "", ageLabel: "", items: [item1]))
        vm.insertDay(DiaryDay(dateLabel: "", ageLabel: "", items: [item2]))
        try await Task.sleep(nanoseconds: 100_000_000)
        let allItems = vm.entries.flatMap { $0.items }
        #expect(allItems.contains { $0.id == item1.id })
        #expect(allItems.contains { $0.id == item2.id })
    }

    // MARK: - loadEntries

    @Test("loadEntries groups stored items by day")
    func loadEntriesGroups() async throws {
        let repo = MockDiaryRepository()
        let item = StoredDiaryItem(id: UUID(), date: Date(), kind: .note, text: "hello")
        repo.items = [item]
        let vm = try await makeVM(repo: repo)
        await vm.loadEntries()
        #expect(vm.entries.count == 1)
        #expect(vm.entries[0].items.count == 1)
    }

    @Test("loadEntries sorts days newest first")
    func loadEntriesSortsNewestFirst() async throws {
        let repo = MockDiaryRepository()
        let old = StoredDiaryItem(id: UUID(), date: Date().addingTimeInterval(-86400 * 3), kind: .note, text: "old")
        let new = StoredDiaryItem(id: UUID(), date: Date(), kind: .note, text: "new")
        repo.items = [old, new]
        let vm = try await makeVM(repo: repo)
        await vm.loadEntries()
        #expect(vm.entries.count == 2)
        #expect(vm.entries[0].items.first?.id == new.id)
    }

    @Test("loadEntries filters out photo-kind stored items")
    func loadEntriesFiltersPhotos() async throws {
        let repo = MockDiaryRepository()
        let note  = StoredDiaryItem(id: UUID(), date: Date(), kind: .note, text: "hello")
        let photo = StoredDiaryItem(id: UUID(), date: Date(), kind: .photo, text: "pic", photoPath: nil)
        repo.items = [note, photo]
        let vm = try await makeVM(repo: repo)
        await vm.loadEntries()
        #expect(vm.entries.count == 1)
        #expect(vm.entries[0].items.count == 1)
    }

    // MARK: - filteredEntries

    @Test("filteredEntries(0) returns all entries")
    func filterAll() async throws {
        let vm = try await makeVM()
        let note      = DiaryItem(id: UUID(), type: .note(text: "n"))
        let milestone = DiaryItem(id: UUID(), type: .milestone(icon: .star, label: "m"))
        vm.entries = [DiaryDay(dateLabel: "d", ageLabel: "", items: [note, milestone])]
        vm.selectedFilter = 0
        #expect(vm.filteredEntries[0].items.count == 2)
    }

    @Test("filteredEntries(1) returns only milestone items")
    func filterMilestones() async throws {
        let vm = try await makeVM()
        let note      = DiaryItem(id: UUID(), type: .note(text: "n"))
        let milestone = DiaryItem(id: UUID(), type: .milestone(icon: .star, label: "m"))
        vm.entries = [DiaryDay(dateLabel: "d", ageLabel: "", items: [note, milestone])]
        vm.selectedFilter = 1
        #expect(vm.filteredEntries[0].items.count == 1)
        if case .milestone = vm.filteredEntries[0].items[0].type {} else {
            Issue.record("Expected milestone item")
        }
    }

    @Test("filteredEntries(2) returns only note items")
    func filterNotes() async throws {
        let vm = try await makeVM()
        let note      = DiaryItem(id: UUID(), type: .note(text: "n"))
        let milestone = DiaryItem(id: UUID(), type: .milestone(icon: .star, label: "m"))
        vm.entries = [DiaryDay(dateLabel: "d", ageLabel: "", items: [note, milestone])]
        vm.selectedFilter = 2
        #expect(vm.filteredEntries[0].items.count == 1)
        if case .note = vm.filteredEntries[0].items[0].type {} else {
            Issue.record("Expected note item")
        }
    }

    @Test("filteredEntries drops empty days after filter")
    func filterDropsEmptyDays() async throws {
        let vm = try await makeVM()
        let note = DiaryItem(id: UUID(), type: .note(text: "n"))
        vm.entries = [DiaryDay(dateLabel: "d", ageLabel: "", items: [note])]
        vm.selectedFilter = 1 // milestones only — note-only day should disappear
        #expect(vm.filteredEntries.isEmpty)
    }
}
