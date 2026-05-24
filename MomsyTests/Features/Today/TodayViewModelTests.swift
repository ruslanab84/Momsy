import Testing
@testable import Momsy
import Foundation

@Suite("TodayViewModel", .serialized)
@MainActor
struct TodayViewModelTests {

    private let quickLogKey  = "quick_log_today_entries"
    private let quickLogDate = "quick_log_today_date"

    init() {
        UserDefaults.standard.removeObject(forKey: "quick_log_today_entries")
        UserDefaults.standard.removeObject(forKey: "quick_log_today_date")
    }

    func makeVM(
        repo: MockFeedingRepository = MockFeedingRepository(),
        sleepRepo: MockSleepRepository = MockSleepRepository(),
        diaperRepo: MockDiaperRepository = MockDiaperRepository()
    ) -> TodayViewModel {
        TodayViewModel(
            getFeeding: GetFeedingEntriesUseCase(repository: repo),
            getSleep: GetSleepEntriesUseCase(repository: sleepRepo),
            diaperRepo: diaperRepo,
            quickLogRepo: QuickLogRepository()
        )
    }

    // MARK: - diapers

    @Test("logDiaper() increments diaperCount")
    func logDiaperIncrements() {
        let vm = makeVM()
        #expect(vm.diaperCount == 0)
        vm.logDiaper()
        #expect(vm.diaperCount == 1)
        vm.logDiaper()
        #expect(vm.diaperCount == 2)
    }

    @Test("logDiaper() adds entry to logEntries")
    func logDiaperAddsEntry() {
        let vm = makeVM()
        vm.logDiaper()
        #expect(vm.logEntries.count == 1)
        #expect(vm.logEntries[0].kind == .drop)
    }

    @Test("removeDiaper() decrements diaperCount")
    func removeDiaperDecrements() {
        let vm = makeVM()
        vm.logDiaper()
        vm.logDiaper()
        #expect(vm.diaperCount == 2)
        vm.removeDiaper()
        #expect(vm.diaperCount == 1)
    }

    @Test("removeDiaper() does not go below zero")
    func removeDiaperFloorsAtZero() {
        let vm = makeVM()
        #expect(vm.diaperCount == 0)
        vm.removeDiaper()
        #expect(vm.diaperCount == 0)
    }

    @Test("removeDiaper() removes latest drop entry from logEntries")
    func removeDiaperRemovesEntry() {
        let vm = makeVM()
        vm.logDiaper()
        #expect(vm.logEntries.count == 1)
        vm.removeDiaper()
        #expect(vm.logEntries.isEmpty)
    }

    // MARK: - loadTodayEntries

    @Test("loadTodayEntries merges feeding entries and quick log")
    func loadMergesFeedingsAndQuickLog() async throws {
        let repo = MockFeedingRepository()
        let feeding = FeedingEntry(date: Date(), durationSeconds: 600, side: .left)
        repo.entries = [feeding]
        let vm = makeVM(repo: repo)
        vm.logWalk()
        await vm.loadTodayEntries()
        #expect(vm.logEntries.count == 2)
    }

    @Test("loadTodayEntries sorts entries newest first")
    func loadSortsNewestFirst() async throws {
        let repo = MockFeedingRepository()
        let old = FeedingEntry(date: Date().addingTimeInterval(-3600), durationSeconds: 300, side: .left)
        let new = FeedingEntry(date: Date(), durationSeconds: 300, side: .right)
        repo.entries = [old, new]
        let vm = makeVM(repo: repo)
        await vm.loadTodayEntries()
        #expect(vm.logEntries.count == 2)
        #expect(vm.logEntries[0].time >= vm.logEntries[1].time)
    }

    @Test("loadTodayEntries shows empty list when no events today")
    func loadEmptyWhenNoEvents() async throws {
        let vm = makeVM()
        await vm.loadTodayEntries()
        #expect(vm.logEntries.isEmpty)
    }

    // MARK: - quick actions

    @Test("logWalk() adds walk entry to logEntries")
    func logWalkAddsEntry() {
        let vm = makeVM()
        vm.logWalk()
        #expect(vm.logEntries.count == 1)
        #expect(vm.logEntries[0].kind == .walk)
    }

    @Test("logBath() adds bath entry to logEntries")
    func logBathAddsEntry() {
        let vm = makeVM()
        vm.logBath()
        #expect(vm.logEntries.count == 1)
        #expect(vm.logEntries[0].kind == .bath)
    }
}
