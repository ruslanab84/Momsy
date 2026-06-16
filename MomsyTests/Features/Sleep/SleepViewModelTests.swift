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
            addManualSleep: AddManualSleepUseCase(repository: repo),
            reconcileStaleSleep: ReconcileStaleSleepUseCase(repository: repo),
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
            addManualSleep: AddManualSleepUseCase(repository: MockSleepRepository()),
            reconcileStaleSleep: ReconcileStaleSleepUseCase(repository: MockSleepRepository()),
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
            addManualSleep: AddManualSleepUseCase(repository: MockSleepRepository()),
            reconcileStaleSleep: ReconcileStaleSleepUseCase(repository: MockSleepRepository()),
            appState: appState
        )
        #expect(vm.sleepNorm.min == 12)
        #expect(vm.sleepNorm.max == 14)
    }
}

// MARK: - Stale open-session recovery (bug #1 — phantom multi-hour sessions)

@Suite("StaleSessionReconciler")
struct StaleSessionReconcilerTests {

    private let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    @Test("discards when no recovered end is known")
    func discardsWhenNil() {
        let r = StaleSessionReconciler.resolve(
            start: start, recoveredEnd: nil, maxDuration: 24 * 3600, now: start.addingTimeInterval(3600)
        )
        #expect(r == .discard)
    }

    @Test("discards when recovered end is before start")
    func discardsWhenBeforeStart() {
        let r = StaleSessionReconciler.resolve(
            start: start, recoveredEnd: start.addingTimeInterval(-60),
            maxDuration: 24 * 3600, now: start.addingTimeInterval(3600)
        )
        #expect(r == .discard)
    }

    @Test("discards when recovered end equals start (zero-length)")
    func discardsWhenEqualsStart() {
        let r = StaleSessionReconciler.resolve(
            start: start, recoveredEnd: start, maxDuration: 24 * 3600, now: start.addingTimeInterval(3600)
        )
        #expect(r == .discard)
    }

    @Test("discards when recovered end is in the future")
    func discardsWhenFuture() {
        let now = start.addingTimeInterval(1800)
        let r = StaleSessionReconciler.resolve(
            start: start, recoveredEnd: now.addingTimeInterval(60), maxDuration: 24 * 3600, now: now
        )
        #expect(r == .discard)
    }

    @Test("discards when duration exceeds the plausible cap")
    func discardsWhenTooLong() {
        let end = start.addingTimeInterval(25 * 3600) // 25h > 24h cap
        let r = StaleSessionReconciler.resolve(
            start: start, recoveredEnd: end, maxDuration: 24 * 3600, now: end.addingTimeInterval(60)
        )
        #expect(r == .discard)
    }

    @Test("closes at the recovered end for a plausible session")
    func closesWhenValid() {
        let end = start.addingTimeInterval(2 * 3600) // 2h nap
        let r = StaleSessionReconciler.resolve(
            start: start, recoveredEnd: end, maxDuration: 24 * 3600, now: end.addingTimeInterval(86_400)
        )
        #expect(r == .close(at: end))
    }

    @Test("closes at exactly the cap boundary")
    func closesAtCapBoundary() {
        let end = start.addingTimeInterval(24 * 3600) // == cap
        let r = StaleSessionReconciler.resolve(
            start: start, recoveredEnd: end, maxDuration: 24 * 3600, now: end.addingTimeInterval(1)
        )
        #expect(r == .close(at: end))
    }
}

@Suite("ReconcileStaleSleepUseCase")
struct ReconcileStaleSleepUseCaseTests {

    @Test("closes the orphan at the recovered end")
    func closesOrphan() async throws {
        let repo = MockSleepRepository()
        let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
        repo.entries = [SleepEntry(id: UUID(), startDate: start, endDate: nil)]
        let end = start.addingTimeInterval(3600)

        try await ReconcileStaleSleepUseCase(repository: repo).execute(repo.entries[0], end: end)

        #expect(repo.entries.count == 1)
        #expect(repo.entries.first?.endDate == end)
        #expect(repo.entries.first?.durationMinutes == 60)
    }

    @Test("deletes the orphan when no end is recoverable")
    func deletesOrphan() async throws {
        let repo = MockSleepRepository()
        repo.entries = [SleepEntry(id: UUID(), startDate: Date(), endDate: nil)]

        try await ReconcileStaleSleepUseCase(repository: repo).execute(repo.entries[0], end: nil)

        #expect(repo.entries.isEmpty)
    }
}

@Suite("SyncMerge last-write-wins")
struct SyncMergeTests {
    private let t0 = Date(timeIntervalSinceReferenceDate: 1_000_000)
    private let t1 = Date(timeIntervalSinceReferenceDate: 2_000_000)

    @Test("inserts when the row does not exist locally")
    func insertsWhenAbsent() {
        #expect(SyncMerge.decide(localExists: false, localUpdatedAt: nil, incomingUpdatedAt: t1) == .insert)
    }

    @Test("inserts when absent even if the incoming stamp is nil")
    func insertsWhenAbsentNilStamp() {
        #expect(SyncMerge.decide(localExists: false, localUpdatedAt: nil, incomingUpdatedAt: nil) == .insert)
    }

    @Test("updates when the incoming copy is strictly newer")
    func updatesWhenNewer() {
        #expect(SyncMerge.decide(localExists: true, localUpdatedAt: t0, incomingUpdatedAt: t1) == .update)
    }

    @Test("skips when the incoming copy is older")
    func skipsWhenOlder() {
        #expect(SyncMerge.decide(localExists: true, localUpdatedAt: t1, incomingUpdatedAt: t0) == .skip)
    }

    @Test("skips on an equal timestamp (the originating device's round-trip)")
    func skipsWhenEqual() {
        #expect(SyncMerge.decide(localExists: true, localUpdatedAt: t1, incomingUpdatedAt: t1) == .skip)
    }

    @Test("a missing local stamp is treated as oldest, so a stamped cloud edit wins")
    func nilLocalLosesToStampedIncoming() {
        #expect(SyncMerge.decide(localExists: true, localUpdatedAt: nil, incomingUpdatedAt: t0) == .update)
    }

    @Test("a missing incoming stamp never clobbers an existing stamped local row")
    func nilIncomingDoesNotClobber() {
        #expect(SyncMerge.decide(localExists: true, localUpdatedAt: t0, incomingUpdatedAt: nil) == .skip)
    }

    @Test("both stamps missing is non-destructive (keeps local)")
    func bothNilSkips() {
        #expect(SyncMerge.decide(localExists: true, localUpdatedAt: nil, incomingUpdatedAt: nil) == .skip)
    }
}

@Suite("PendingDeletionsStore")
struct PendingDeletionsStoreTests {
    private func freshStore() -> PendingDeletionsStore {
        let defaults = UserDefaults(suiteName: "test_pending_\(UUID().uuidString)")!
        return PendingDeletionsStore(defaults: defaults)
    }

    @Test("records a pending deletion with its collection")
    func recordsPending() {
        let store = freshStore()
        let id = UUID()
        store.add(id: id, collection: "foodDiaryLogs")
        #expect(store.ids() == [id])
        #expect(store.all()[id.uuidString] == "foodDiaryLogs")
    }

    @Test("removing a deletion clears it")
    func removesPending() {
        let store = freshStore()
        let id = UUID()
        store.add(id: id, collection: "vaccinationLogs")
        store.remove(id: id)
        #expect(store.ids().isEmpty)
        #expect(store.all().isEmpty)
    }

    @Test("persists across instances backed by the same defaults")
    func persists() {
        let defaults = UserDefaults(suiteName: "test_pending_\(UUID().uuidString)")!
        let id = UUID()
        PendingDeletionsStore(defaults: defaults).add(id: id, collection: "diaperLogs")
        #expect(PendingDeletionsStore(defaults: defaults).ids() == [id])
    }
}
