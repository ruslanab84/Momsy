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

    init() {
        // Quick-log storage is scoped per active child. Pin to a clean, child-less
        // state and clear that scope's bucket so each test starts empty.
        ActiveBaby.currentId = nil
        UserDefaults.standard.removeObject(forKey: "quick_log_today_entries_\(ActiveBaby.scope.uuidString)")
        UserDefaults.standard.removeObject(forKey: "quick_log_today_date_\(ActiveBaby.scope.uuidString)")
    }

    private func makeAppState(profile: BabyProfile? = nil) -> AppState {
        let resolved = profile ?? BabyProfile(
            id: UUID(),
            name: "Тест",
            birthDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            gender: "girl"
        )
        let repo = MockBabyRepository(initialProfile: resolved)
        let state = AppState(getBabyProfile: GetBabyProfileUseCase(repository: repo),
                             getAllBabies: GetAllBabiesUseCase(repository: repo))
        // Set synchronously only when a test passes an explicit profile (e.g. leap
        // tests that read babyProfile immediately). The default path keeps the
        // original async-load timing the daily-tip tests were written against.
        if profile != nil { state.babyProfile = resolved }
        return state
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
        leapsRepo: MockLeapsRepository = MockLeapsRepository(),
        tipRepository: DailyTipRepository? = nil,
        profile: BabyProfile? = nil
    ) -> TodayViewModel {
        let tipRepo = tipRepository ?? makeTipRepository()
        return TodayViewModel(
            getFeeding: GetFeedingEntriesUseCase(repository: repo),
            getSleep: GetSleepEntriesUseCase(repository: sleepRepo),
            getLeaps: GetLeapsUseCase(repository: leapsRepo),
            diaperRepo: diaperRepo,
            stoolRepo: stoolRepo,
            quickLogRepo: QuickLogRepository(),
            tipRepository: tipRepo,
            appState: makeAppState(profile: profile),
            syncRepo: MockBabySyncRepository(),
            predictNextSleep: PredictNextSleepUseCase(
                getSleep: GetSleepEntriesUseCase(repository: sleepRepo),
                engine: DeterministicSleepForecastEngine()
            )
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

    @Test("tip is built from loaded diaper count, not a stale 0")
    func tipReflectsLoadedDiaperCount() async {
        let diaperRepo = MockDiaperRepository()
        diaperRepo.entries = (0..<6).map { _ in DiaperEntry() }   // 6 today
        // Stool logged today so the unrelated "no stool" alert doesn't fire and
        // the assertion can focus on the diaper-driven tip.
        let stoolRepo = MockStoolRepository()
        stoolRepo.entries = [Date()]
        // Adequate sleep logged so the evening sleep-deficit alert (hour >= 19)
        // can't fire with "slept 0 h" — keeps this test independent of wall-clock time.
        let sleepRepo = MockSleepRepository()
        let dayStart = Calendar.current.startOfDay(for: Date())
        sleepRepo.entries = [SleepEntry(startDate: dayStart, endDate: dayStart.addingTimeInterval(16 * 3600))]
        let vm = makeVM(sleepRepo: sleepRepo, diaperRepo: diaperRepo, stoolRepo: stoolRepo)
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.diaperCount == 6)
        // false "insufficient fluid" alert must not be shown for 6 diapers
        #expect(vm.dailyTip?.text.contains("0") != true || vm.dailyTip?.category != .alert)
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

    @Test("daily tip recomputes after a profile switch (cloud merge), not left stale from the prior baby")
    func dailyTipRecomputesAfterMerge() async {
        let diaperRepo = MockDiaperRepository()
        diaperRepo.entries = (0..<6).map { _ in DiaperEntry() }   // baby A: 6 diapers
        let vm = makeVM(diaperRepo: diaperRepo)
        await vm.fetchDailyTipIfNeeded()
        let beforeHash = vm.dailyTip?.contextHash
        #expect(beforeHash?.hasSuffix("-6") == true)

        // Switching the active child re-pulls its cloud logs and posts
        // .cloudSyncDidMerge → reloadAfterMerge. The repos now report the new
        // (child-less / empty) baby's data; the tip must follow.
        diaperRepo.entries = []
        await vm.reloadAfterMerge()

        #expect(vm.dailyTip?.contextHash != beforeHash)
        #expect(vm.dailyTip?.contextHash.hasSuffix("-0") == true)
    }

    // MARK: - Developmental leap

    @Test("9-week-old baby resolves to leap #2 on the Today screen, not hardcoded #4")
    func nineWeekBabyResolvesToLeapTwo() async throws {
        let birth = Calendar.current.date(byAdding: .day, value: -65, to: Date())! // ~9w2d
        let profile = BabyProfile(name: "Test", birthDate: birth)
        let vm = makeVM(profile: profile)
        await vm.loadLeap()
        #expect(vm.currentLeap?.id == 2)
        #expect(vm.leapPhase == .settled) // hard window of leap #2 has passed by 9w
    }

    @Test("newborn has no active leap, so the badge and card are hidden")
    func newbornHasNoActiveLeap() async throws {
        let profile = BabyProfile(name: "Test", birthDate: Date())
        let vm = makeVM(profile: profile)
        await vm.loadLeap()
        #expect(vm.currentLeap == nil)
        #expect(vm.leapPhase == nil)
        #expect(vm.currentLeapName == nil)
    }

    @Test("a baby at a leap's onset is in the stormy phase on day 1")
    func babyAtOnsetIsStormy() async throws {
        // Leap 1 (week 5) surfaces 1 week early → onset at day 28.
        let birth = Calendar.current.date(byAdding: .day, value: -28, to: Date())!
        let vm = makeVM(profile: BabyProfile(name: "Test", birthDate: birth))
        await vm.loadLeap()
        let leap1HardDays = DevelopmentLeap.catalog.first { $0.id == 1 }!.hardDays
        #expect(vm.currentLeap?.id == 1)
        #expect(vm.leapPhase == .stormy(day: 1, total: leap1HardDays))
    }
}
