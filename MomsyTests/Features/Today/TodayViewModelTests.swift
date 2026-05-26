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
        tipService: MockDailyTipService = MockDailyTipService(),
        tipRepository: DailyTipRepository? = nil
    ) -> TodayViewModel {
        let tipRepo = tipRepository ?? makeTipRepository()
        return TodayViewModel(
            getFeeding: GetFeedingEntriesUseCase(repository: repo),
            getSleep: GetSleepEntriesUseCase(repository: sleepRepo),
            diaperRepo: diaperRepo,
            quickLogRepo: QuickLogRepository(),
            tipService: tipService,
            tipRepository: tipRepo,
            appState: makeAppState()
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

    // MARK: - Daily AI Tip

    @Test("fetchDailyTipIfNeeded sets dailyTip text from service")
    func fetchDailyTipIfNeeded_setsDailyTip() async {
        let service = MockDailyTipService()
        service.stubbedText = "Test AI tip"
        let vm = makeVM(tipService: service)
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.dailyTip?.text == "Test AI tip")
        #expect(vm.isTipLoading == false)
    }

    @Test("fetchDailyTipIfNeeded does not call service when cache is fresh")
    func fetchDailyTipIfNeeded_usesCache_whenHashUnchanged() async {
        let service = MockDailyTipService()
        service.stubbedText = "Cached tip"
        let tipRepo = makeTipRepository()
        let vm = makeVM(tipService: service, tipRepository: tipRepo)

        // First fetch — populates cache
        await vm.fetchDailyTipIfNeeded()
        #expect(service.callCount == 1)

        // Second fetch — same context hash, cache is fresh
        await vm.fetchDailyTipIfNeeded()
        #expect(service.callCount == 1)   // service NOT called again
        #expect(vm.dailyTip?.isFromCache == true)
    }

    @Test("fetchDailyTipIfNeeded falls back to stale cache on network error")
    func fetchDailyTipIfNeeded_fallsBackToCache_onError() async {
        let service = MockDailyTipService()
        service.stubbedText = "Stale tip"
        let tipRepo = makeTipRepository()
        let vm = makeVM(tipService: service, tipRepository: tipRepo)

        // Populate cache with a successful fetch
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.dailyTip?.text == "Stale tip")

        // Force cache to be stale by modifying diaperCount so hash changes
        vm.logDiaper()

        // Now network fails
        service.shouldThrow = true
        await vm.fetchDailyTipIfNeeded()

        // Should show stale cached tip, not nil
        #expect(vm.dailyTip != nil)
        #expect(vm.dailyTip?.isFromCache == true)
        #expect(vm.isTipLoading == false)
    }

    @Test("fetchDailyTipIfNeeded resets isTipLoading to false after fetch")
    func fetchDailyTipIfNeeded_resetsLoadingState() async {
        let service = MockDailyTipService()
        let vm = makeVM(tipService: service)
        #expect(vm.isTipLoading == false)
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.isTipLoading == false)
    }
}
