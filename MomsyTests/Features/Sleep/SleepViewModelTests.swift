import Testing
@testable import Momsy
import Foundation

@Suite("SleepViewModel", .serialized)
@MainActor
struct SleepViewModelTests {

    func makeVM(repo: MockSleepRepository = MockSleepRepository()) -> SleepViewModel {
        SleepViewModel(
            startSleep: StartSleepUseCase(repository: repo),
            stopSleep: StopSleepUseCase(repository: repo),
            getSleep: GetSleepEntriesUseCase(repository: repo)
        )
    }

    // MARK: - start

    @Test("start() sets isSleepActive = true")
    func startActivates() async throws {
        let vm = makeVM()
        vm.start()
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.isSleepActive)
    }

    @Test("start() resets sleepSeconds to zero")
    func startResetsSleepSeconds() async throws {
        let vm = makeVM()
        vm.sleepSeconds = 99
        vm.start()
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.sleepSeconds == 0)
    }

    @Test("start() propagates repository error to saveError")
    func startPropagatesError() async throws {
        let repo = MockSleepRepository()
        repo.shouldThrow = true
        let vm = makeVM(repo: repo)
        vm.start()
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.saveError != nil)
        #expect(!vm.isSleepActive)
    }

    // MARK: - stop

    @Test("stop() clears isSleepActive immediately")
    func stopDeactivates() async throws {
        let vm = makeVM()
        vm.start()
        try await Task.sleep(nanoseconds: 50_000_000)
        vm.stop()
        #expect(!vm.isSleepActive)
    }

    @Test("stop() optimistically appends entry to todayEntries")
    func stopOptimisticallyAppendsEntry() async throws {
        let vm = makeVM()
        vm.start()
        try await Task.sleep(nanoseconds: 50_000_000)
        let before = vm.todayEntries.count
        vm.stop()
        #expect(vm.todayEntries.count == before + 1)
    }

    @Test("stop() rolls back optimistic entry on repository error")
    func stopRollsBackOnError() async throws {
        let repo = MockSleepRepository()
        let vm = makeVM(repo: repo)
        vm.start()
        try await Task.sleep(nanoseconds: 50_000_000)
        repo.throwOnUpdate = true
        vm.stop()
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.todayEntries.isEmpty)
        #expect(vm.saveError != nil)
    }

    // MARK: - loadTodayEntries

    @Test("loadTodayEntries populates entries from repository")
    func loadPopulatesEntries() async throws {
        let repo = MockSleepRepository()
        let entry = SleepEntry(startDate: Date(), endDate: Date().addingTimeInterval(3600))
        repo.entries = [entry]
        let vm = makeVM(repo: repo)
        await vm.loadTodayEntries()
        #expect(vm.todayEntries.contains { $0.id == entry.id })
    }

    @Test("loadTodayEntries sorts entries by startDate ascending")
    func loadSortsEntries() async throws {
        let repo = MockSleepRepository()
        let early = SleepEntry(startDate: Date().addingTimeInterval(-3600), endDate: Date().addingTimeInterval(-1800))
        let late  = SleepEntry(startDate: Date().addingTimeInterval(-900),  endDate: Date())
        repo.entries = [late, early]
        let vm = makeVM(repo: repo)
        await vm.loadTodayEntries()
        #expect(vm.todayEntries.count == 2)
        #expect(vm.todayEntries[0].id == early.id)
        #expect(vm.todayEntries[1].id == late.id)
    }

    @Test("loadTodayEntries ignores entries outside today")
    func loadFiltersToToday() async throws {
        let repo = MockSleepRepository()
        let yesterday = SleepEntry(startDate: Date().addingTimeInterval(-86400))
        repo.entries = [yesterday]
        let vm = makeVM(repo: repo)
        await vm.loadTodayEntries()
        #expect(vm.todayEntries.isEmpty)
    }

    // MARK: - syncTimer

    @Test("syncTimerWithStartDate updates sleepSeconds when active")
    func syncTimerUpdatesSeconds() async throws {
        let vm = makeVM()
        vm.start()
        try await Task.sleep(nanoseconds: 50_000_000)
        let before = vm.sleepSeconds
        try await Task.sleep(nanoseconds: 100_000_000)
        vm.syncTimerWithStartDate()
        #expect(vm.sleepSeconds >= before)
    }

    @Test("syncTimerWithStartDate does nothing when sleep is not active")
    func syncTimerDoesNothingWhenInactive() {
        let vm = makeVM()
        vm.sleepSeconds = 0
        vm.syncTimerWithStartDate()
        #expect(vm.sleepSeconds == 0)
    }
}
