import Testing
@testable import Momsy
import Foundation

final class MockBabySyncRepository: BabySyncRepositoryProtocol {
    var feedingLogs: AsyncStream<[FeedingLog]> { AsyncStream { $0.finish() } }
    var sleepLogs: AsyncStream<[SleepLog]>     { AsyncStream { $0.finish() } }
    var diaperLogs: AsyncStream<[DiaperLog]>   { AsyncStream { $0.finish() } }

    func addFeedingLog(_ log: FeedingLog) async throws {}
    func addSleepLog(_ log: SleepLog) async throws {}
    func addDiaperLog(_ log: DiaperLog) async throws {}
    func addSymptomLog(_ log: SymptomLog) async throws {}
    func addDiaryLog(_ log: DiaryLog) async throws {}
    func addMeasurementLog(_ log: MeasurementLog) async throws {}
    func addVaccinationLog(_ log: VaccinationLog) async throws {}
    func addFoodDiaryLog(_ log: FoodDiaryLog) async throws {}

    func fetchTodayFeedings() async throws -> [FeedingLog] { [] }
    func fetchTodaySleep() async throws -> [SleepLog] { [] }

    func syncBabyProfile(_ profile: BabyProfile) async throws {}
    func fetchBabyProfile() async throws -> BabyProfile? { nil }
}

@Suite("TodayViewModel", .serialized)
@MainActor
struct TodayViewModelTests {

    private let quickLogKey  = "quick_log_today_entries"
    private let quickLogDate = "quick_log_today_date"

    init() {
        UserDefaults.standard.removeObject(forKey: "quick_log_today_entries")
        UserDefaults.standard.removeObject(forKey: "quick_log_today_date")
    }

    private func makeAppState() -> AppState {
        let profile = BabyProfile(
            id: UUID(),
            name: "Тест",
            birthDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            gender: "girl"
        )
        let repo = MockBabyRepository(initialProfile: profile)
        return AppState(getBabyProfile: GetBabyProfileUseCase(repository: repo))
    }

    private func makeTipRepository() -> DailyTipRepository {
        // Isolated UserDefaults suite per test run to avoid cache pollution
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return DailyTipRepository(defaults: defaults)
    }

    func makeVM(
        repo: MockFeedingRepository = MockFeedingRepository(),
        sleepRepo: MockSleepRepository = MockSleepRepository(),
        diaperRepo: MockDiaperRepository = MockDiaperRepository(),
        stoolRepo: MockStoolRepository = MockStoolRepository(),
        tipRepository: DailyTipRepository? = nil
    ) -> TodayViewModel {
        let tipRepo = tipRepository ?? makeTipRepository()
        return TodayViewModel(
            getFeeding: GetFeedingEntriesUseCase(repository: repo),
            getSleep: GetSleepEntriesUseCase(repository: sleepRepo),
            diaperRepo: diaperRepo,
            stoolRepo: stoolRepo,
            quickLogRepo: QuickLogRepository(),
            tipRepository: tipRepo,
            appState: makeAppState(),
            syncRepo: MockBabySyncRepository()
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

    // MARK: - Daily Tip

    @Test("fetchDailyTipIfNeeded always produces a non-nil tip")
    func fetchDailyTipIfNeeded_setsDailyTip() async {
        let vm = makeVM()
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.dailyTip != nil)
        #expect(vm.isTipLoading == false)
    }

    @Test("fetchDailyTipIfNeeded does not recompute on second call in same session")
    func fetchDailyTipIfNeeded_skipsSecondCall_withinSession() async {
        let vm = makeVM()
        await vm.fetchDailyTipIfNeeded()
        let firstTip = vm.dailyTip
        // Second call: tip object must be the same instance (no recompute)
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.dailyTip?.contextHash == firstTip?.contextHash)
    }

    @Test("fetchDailyTipIfNeeded sets a TipCategory on the returned tip")
    func fetchDailyTipIfNeeded_setsTipCategory() async {
        let vm = makeVM()
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.dailyTip?.category != nil)
    }

    @Test("fetchDailyTipIfNeeded resets isTipLoading to false after fetch")
    func fetchDailyTipIfNeeded_resetsLoadingState() async {
        let vm = makeVM()
        #expect(vm.isTipLoading == false)
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.isTipLoading == false)
    }
}
