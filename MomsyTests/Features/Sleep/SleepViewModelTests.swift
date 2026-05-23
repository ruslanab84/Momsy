import Testing
@testable import Momsy
import Foundation

@Suite("SleepViewModel", .serialized)
@MainActor
struct SleepViewModelTests {

    func makeVM(repo: MockSleepRepository = MockSleepRepository(),
                babyRepo: MockBabyRepository = MockBabyRepository()) -> SleepViewModel {
        let appState = AppState(getBabyProfile: GetBabyProfileUseCase(repository: babyRepo))
        return SleepViewModel(
            startSleep: StartSleepUseCase(repository: repo),
            stopSleep: StopSleepUseCase(repository: repo),
            getSleep: GetSleepEntriesUseCase(repository: repo),
            appState: appState
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

    // MARK: - loadChartData

    @Test("loadChartData groups entries into daily points")
    func chartDataGroupsByDay() async throws {
        let repo = MockSleepRepository()
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let e1 = SleepEntry(startDate: yesterday, endDate: yesterday.addingTimeInterval(3600))
        let e2 = SleepEntry(startDate: today, endDate: today.addingTimeInterval(7200))
        repo.entries = [e1, e2]
        let vm = makeVM(repo: repo)
        vm.selectedChartPeriod = 0
        await vm.loadChartData()
        let todayPt = vm.sleepDays.first { cal.isDateInToday($0.id) }
        let yestPt = vm.sleepDays.first { cal.isDate($0.id, inSameDayAs: yesterday) }
        #expect(todayPt?.totalMinutes == 120)
        #expect(yestPt?.totalMinutes == 60)
    }

    @Test("loadChartData produces 7 points for week period")
    func chartDataWeekHasSevenPoints() async throws {
        let vm = makeVM()
        vm.selectedChartPeriod = 0
        await vm.loadChartData()
        #expect(vm.sleepDays.count == 7)
    }

    @Test("loadChartData produces 30 points for month period")
    func chartDataMonthHasThirtyPoints() async throws {
        let vm = makeVM()
        vm.selectedChartPeriod = 1
        await vm.loadChartData()
        #expect(vm.sleepDays.count == 30)
    }

    // MARK: - sleepNorm

    @Test("sleepNorm returns 14-17h for newborn")
    func normForNewborn() {
        let appState = AppState(getBabyProfile: GetBabyProfileUseCase(repository: MockBabyRepository()))
        appState.update(BabyProfile(name: "Test", birthDate: Date(), stage: "newborn", gender: "boy"))
        let vm = SleepViewModel(
            startSleep: StartSleepUseCase(repository: MockSleepRepository()),
            stopSleep: StopSleepUseCase(repository: MockSleepRepository()),
            getSleep: GetSleepEntriesUseCase(repository: MockSleepRepository()),
            appState: appState
        )
        #expect(vm.sleepNorm.min == 14)
        #expect(vm.sleepNorm.max == 17)
    }

    @Test("sleepNorm returns 12-14h for 6-month-old")
    func normForSixMonths() {
        let birth = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let appState = AppState(getBabyProfile: GetBabyProfileUseCase(repository: MockBabyRepository()))
        appState.update(BabyProfile(name: "Test", birthDate: birth, stage: "newborn", gender: "boy"))
        let vm = SleepViewModel(
            startSleep: StartSleepUseCase(repository: MockSleepRepository()),
            stopSleep: StopSleepUseCase(repository: MockSleepRepository()),
            getSleep: GetSleepEntriesUseCase(repository: MockSleepRepository()),
            appState: appState
        )
        #expect(vm.sleepNorm.min == 12)
        #expect(vm.sleepNorm.max == 14)
    }
}
