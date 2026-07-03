import Foundation
import SwiftUI
import SwiftData

@MainActor
final class AppContainer {

    /// Fallback used only to satisfy the environment default. Real views receive
    /// the instance injected at the view-tree root via `withContainer(_:)`; this is
    /// lazily built (Swift `static let`) so its ModelContainer is created only if the
    /// default is ever actually read.
    static let shared = AppContainer()

    // MARK: — Persistence

    let modelContainer: ModelContainer = AppPersistence.makeContainer()
    private lazy var context: ModelContext = ModelContext(modelContainer)

    // MARK: — Repositories

    lazy var babyRepository: any BabyRepository            = SwiftDataBabyRepository(context: context)
    lazy var sleepRepository: any SleepRepository          = SwiftDataSleepRepository(context: context)
    lazy var feedingRepository: any FeedingRepository      = SwiftDataFeedingRepository(context: context)
    lazy var diaryRepository: any DiaryRepository          = SwiftDataDiaryRepository(context: context)
    lazy var measurementRepository: any MeasurementRepository = SwiftDataMeasurementRepository(context: context)
    lazy var temperatureRepository: any TemperatureRepository = SwiftDataTemperatureRepository(context: context)
    lazy var leapsRepository: any LeapsRepository          = SwiftDataLeapsRepository(context: context)
    lazy var walkRepository: any WalkRepository            = SwiftDataWalkRepository(context: context)
    lazy var bathRepository: any BathRepository             = SwiftDataBathRepository(context: context)
    lazy var doctorVisitRepository: any DoctorVisitRepository = SwiftDataDoctorVisitRepository(context: context)
    lazy var vaccinationRepository: any VaccinationRepository = SwiftDataVaccinationRepository(context: context)
    lazy var complementaryFeedingRepository: any ComplementaryFeedingRepository = SwiftDataComplementaryFeedingRepository(context: context)
    lazy var diaperRepository: any DiaperRepository                             = SwiftDataDiaperRepository(context: context)
    lazy var momMoodRepository: any MomMoodRepository                           = SwiftDataMomMoodRepository(context: context)
    lazy var stoolRepository: any StoolRepository                               = SwiftDataStoolRepository(context: context)
    lazy var momSleepRepository: any MomSleepRepository                         = SwiftDataMomSleepRepository(context: context)
    lazy var waterIntakeRepository: any WaterIntakeRepository                    = SwiftDataWaterIntakeRepository(context: context)
    lazy var pumpingRepository: any PumpingRepository                            = SwiftDataPumpingRepository(context: context)

    lazy var familyRepository: any FamilyRepository   = FirestoreFamilyRepository()
    let soundRepository: any SoundRepository           = LocalSoundRepository()
    let photoStorage: any PhotoStorageService          = FirebasePhotoStorageService()
    lazy var inviteService: any InviteServiceProtocol  = FirestoreInviteService()
    lazy var babySyncRepository: any BabySyncRepositoryProtocol = BabySyncRepository(service: BabySyncService())
    lazy var cloudSyncDownloader: any CloudSyncDownloaderProtocol = CloudSyncDownloader(
        service: BabySyncService(),
        feedingRepo: feedingRepository,
        sleepRepo: sleepRepository,
        diaperRepo: diaperRepository,
        stoolRepo: stoolRepository,
        diaryRepo: diaryRepository,
        walkRepo: walkRepository,
        bathRepo: bathRepository,
        pumpingRepo: pumpingRepository,
        measurementRepo: measurementRepository,
        vaccinationRepo: vaccinationRepository,
        foodDiaryRepo: complementaryFeedingRepository,
        quickLogRepo: quickLogRepository,
        babyRepo: babyRepository,
        temperatureRepo: temperatureRepository,
        momSleepRepo: momSleepRepository,
        waterIntakeRepo: waterIntakeRepository,
        leapsRepo: leapsRepository,
        doctorVisitRepo: doctorVisitRepository
    )
    let analytics: any AnalyticsServiceProtocol        = LogAnalyticsService()
    let pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared
    let authManager                                    = AuthManager()
    let subscriptionManager                            = SubscriptionManager(service: StoreKitSubscriptionService())
    let diaperUseCase                                   = DiaperUseCase()
    let quickLogRepository                              = QuickLogRepository()
    let preferencesRepository: any UserPreferencesRepository = LocalUserPreferencesRepository()
    let dailyTipRepository                             = DailyTipRepository()
    lazy var weeklyInsightRepository: any WeeklyInsightRepository = SwiftDataWeeklyInsightRepository(context: context)
    lazy var weeklyInsightService: any WeeklyInsightService       = GeminiWeeklyInsightService()

    // MARK: — Cross-device sync wiring

    private var familyJoinObserver: NSObjectProtocol?

    init() { observeFamilyJoin() }

    /// After a join, drop the active-baby pointer so the downloader adopts the joined
    /// family's roster, then re-pull everything.
    private func observeFamilyJoin() {
        familyJoinObserver = NotificationCenter.default.addObserver(
            forName: .familyDidJoin, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                // Clear the active pointer FIRST (this also clears the persisted babyId)
                // so discovery adopts the joined family's roster. Any writes still queued
                // from a previous family are skipped by the replay's cross-family guard.
                ActiveBaby.currentId = nil
                await self.cloudSyncDownloader.forceResyncAll()
                NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
            }
        }
    }

    // MARK: — Use Cases — Baby

    lazy var getBabyProfile   = GetBabyProfileUseCase(repository: babyRepository)
    lazy var getAllBabies     = GetAllBabiesUseCase(repository: babyRepository)
    lazy var saveBabyProfile  = SaveBabyProfileUseCase(repository: babyRepository)
    lazy var appState         = AppState(getBabyProfile: getBabyProfile, getAllBabies: getAllBabies)

    // MARK: — Multi-child lifecycle

    /// Add a child to the roster (cap-enforced), switch focus to it, push to cloud.
    @MainActor
    func addChild(_ profile: BabyProfile) async throws {
        try await saveBabyProfile.execute(profile)
        appState.update(profile)
        await switchActiveBaby(to: profile.id)
        try? await babySyncRepository.syncBabyProfile(profile)
    }

    /// Point the whole app at a different child and re-pull its cloud logs.
    @MainActor
    func switchActiveBaby(to id: UUID) async {
        appState.setActive(id)
        await cloudSyncDownloader.resyncActiveBaby()
        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
    }

    /// Remove a child: cascade-delete its logs, drop the profile, re-point active.
    @MainActor
    func deleteChild(id: UUID) async throws {
        let profiles = try await babyRepository.getAllProfiles()
        guard profiles.contains(where: { $0.id == id }) else { return }
        guard profiles.count > 1 else { throw BabyError.cannotDeleteLastChild }

        try await babySyncRepository.deleteBaby(id: id)
        PendingWritesStore.shared.removeAll(forBaby: id)
        BabyLogBackfill.deleteLogs(forBaby: id, context: context)
        try context.save()
        try await babyRepository.deleteProfile(id: id)
        if ActiveBaby.currentId == id {
            let remaining = (try? await babyRepository.getAllProfiles()) ?? []
            ActiveBaby.currentId = remaining.first?.id
        }
        await appState.load()
        if ActiveBaby.currentId != nil { await cloudSyncDownloader.resyncActiveBaby() }
        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
    }

    // MARK: — Use Cases — Sleep

    lazy var startSleep         = StartSleepUseCase(repository: sleepRepository)
    lazy var stopSleep          = StopSleepUseCase(repository: sleepRepository)
    lazy var getSleepEntries    = GetSleepEntriesUseCase(repository: sleepRepository)
    lazy var addManualSleep     = AddManualSleepUseCase(repository: sleepRepository)
    lazy var reconcileStaleSleep = ReconcileStaleSleepUseCase(repository: sleepRepository)
    let sleepForecastEngine: any SleepForecastEngine = DeterministicSleepForecastEngine()
    lazy var predictNextSleep   = PredictNextSleepUseCase(getSleep: getSleepEntries, engine: sleepForecastEngine)

    // MARK: — Use Cases — Mom Sleep
    lazy var startMomSleep      = StartMomSleepUseCase(repository: momSleepRepository)
    lazy var stopMomSleep       = StopMomSleepUseCase(repository: momSleepRepository)
    lazy var getMomSleepEntries = GetMomSleepEntriesUseCase(repository: momSleepRepository)
    lazy var addManualMomSleep  = AddManualMomSleepUseCase(repository: momSleepRepository)

    // MARK: — Use Cases — Water Intake
    lazy var logWaterIntake = LogWaterIntakeUseCase(repository: waterIntakeRepository)
    lazy var getWaterIntake = GetWaterIntakeUseCase(repository: waterIntakeRepository)

    // MARK: — Use Cases — Feeding

    lazy var logFeeding         = LogFeedingUseCase(repository: feedingRepository)
    lazy var getFeedingEntries  = GetFeedingEntriesUseCase(repository: feedingRepository)

    // MARK: — Use Cases — Diary

    lazy var addDiaryEntry  = AddDiaryEntryUseCase(repository: diaryRepository)
    lazy var getDiary       = GetDiaryUseCase(repository: diaryRepository)

    // MARK: — Use Cases — Tracking

    lazy var addMeasurement    = AddMeasurementUseCase(repository: measurementRepository)
    lazy var getMeasurements   = GetMeasurementsUseCase(repository: measurementRepository)
    lazy var logTemperature    = LogTemperatureUseCase(repository: temperatureRepository)
    lazy var getTemperatureLog = GetTemperatureLogUseCase(repository: temperatureRepository)

    // MARK: — Use Cases — Sharing

    lazy var getFamily          = GetFamilyUseCase(repository: familyRepository)
    lazy var inviteFamilyMember = InviteFamilyMemberUseCase(repository: familyRepository)

    // MARK: — Use Cases — Leaps

    lazy var getLeaps          = GetLeapsUseCase(repository: leapsRepository)
    lazy var markLeapComplete  = MarkLeapCompleteUseCase(repository: leapsRepository)

    // MARK: — Use Cases — Doctor Visit

    lazy var getLastDoctorVisit = GetLastDoctorVisitUseCase(repository: doctorVisitRepository)
    lazy var saveDoctorVisit    = SaveDoctorVisitUseCase(repository: doctorVisitRepository)

    // MARK: — Use Cases — Vaccination

    lazy var getVaccinationStatus   = GetVaccinationStatusUseCase(repository: vaccinationRepository)
    lazy var markVaccinationDone    = MarkVaccinationDoneUseCase(repository: vaccinationRepository)
    lazy var unmarkVaccination      = UnmarkVaccinationUseCase(repository: vaccinationRepository)
    lazy var addCustomVaccination   = AddCustomVaccinationUseCase(repository: vaccinationRepository)

    // MARK: — Use Cases — Complementary Feeding

    lazy var addFoodEntry   = AddFoodEntryUseCase(repository: complementaryFeedingRepository)
    lazy var getFoodEntries = GetFoodEntriesUseCase(repository: complementaryFeedingRepository)
    lazy var deleteFoodEntry = DeleteFoodEntryUseCase(repository: complementaryFeedingRepository)

    // MARK: — Use Cases — Weekly Insights

    lazy var generateWeeklyInsight = GenerateWeeklyInsightUseCase(
        sleepRepo: sleepRepository,
        feedingRepo: feedingRepository,
        foodRepo: complementaryFeedingRepository,
        diaperRepo: diaperRepository,
        repo: weeklyInsightRepository,
        service: weeklyInsightService,
        fallback: StaticWeeklyInsightService(),
        appState: appState
    )
    lazy var getWeeklyInsights = GetWeeklyInsightsUseCase(repository: weeklyInsightRepository)

    // MARK: — GDPR erasure

    /// Wipes every on-device trace: all SwiftData records, the launch-routing and
    /// sync UserDefaults flags, and the in-memory baby profile. Cloud + auth erasure
    /// is handled by `DeleteAccountUseCase` before this runs.
    @MainActor
    func eraseLocalData() throws {
        try context.delete(model: SleepRecord.self)
        try context.delete(model: FeedingRecord.self)
        try context.delete(model: WalkRecord.self)
        try context.delete(model: BathRecord.self)
        try context.delete(model: BabyRecord.self)
        try context.delete(model: MeasurementRecord.self)
        try context.delete(model: TemperatureRecord.self)
        try context.delete(model: LeapProgressRecord.self)
        try context.delete(model: DiaryItemRecord.self)
        try context.delete(model: DoctorVisitRecord.self)
        try context.delete(model: VaccinationRecord.self)
        try context.delete(model: ComplementaryFoodRecord.self)
        try context.delete(model: DiaperRecord.self)
        try context.delete(model: MomMoodRecord.self)
        try context.delete(model: StoolRecord.self)
        try context.delete(model: WaterIntakeRecord.self)
        try context.delete(model: MomSleepRecord.self)
        try context.delete(model: PumpingRecord.self)
        try context.delete(model: WeeklyInsightRecord.self)
        try context.save()

        clearAccountScopedDefaults()
        PendingWritesStore.shared.clear()
        PendingDeletionsStore.shared.clear()
        WidgetDataStore.shared.clearAll()

        appState.reset()
        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
    }

    @MainActor
    private func clearAccountScopedDefaults() {
        let defaults = UserDefaults.standard
        let exactKeys = [
            "onboardingDone",
            "paywallShown",
            kFamilyIdDefaultsKey,
            kFamilyOwnerUidDefaultsKey,
            kBabyIdDefaultsKey,
            "AppPersistence.schemaVersion",
            "babysync_perbaby_migration_v1_done",
            "firestore_quicklogs_cleanup_v1_done",
            "babyLogBackfill_v1_done",
            "diaper_today_count",
            "diaper_today_date",
            "uid",
            "displayName",
            "watch_processed_cmd_ids",
            "invite_code",
            "invite_expiry",
            FirestoreInviteService.codeKey,
            FirestoreInviteService.expiryKey,
            FirestoreInviteService.syncedCodeKey,
            PendingFamilyInviteStore.codeKey,
        ]
        exactKeys.forEach { defaults.removeObject(forKey: $0) }

        let prefixes = [
            "quick_log_today_",
            "babysync_watermarks_v1_",
            "local_",
        ]
        for key in defaults.dictionaryRepresentation().keys where prefixes.contains(where: { key.hasPrefix($0) }) {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: — Migration

    func runMigrationIfNeeded() {
        UserDefaultsMigration.runIfNeeded(context: context)
        UserDefaultsMigration.runVaccinationRemapIfNeeded(context: context)
        BabyLogBackfill.run(context: context)
    }

    // MARK: — ViewModel Factories

    func makeFeedingViewModel() -> FeedingViewModel {
        FeedingViewModel(
            logFeeding: logFeeding,
            getFeeding: getFeedingEntries,
            timerService: FeedingTimerService(),
            analytics: analytics,
            pushNotifications: pushNotifications
        )
    }

    func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(
            getFeeding: getFeedingEntries,
            getSleep: getSleepEntries,
            getLeaps: getLeaps,
            diaperRepo: diaperRepository,
            stoolRepo: stoolRepository,
            quickLogRepo: quickLogRepository,
            tipRepository: dailyTipRepository,
            appState: appState,
            syncRepo: babySyncRepository,
            predictNextSleep: predictNextSleep
        )
    }

    func makeOnboardingViewModel(onDone: @escaping () -> Void) -> OnboardingViewModel {
        OnboardingViewModel(
            saveBabyProfile: saveBabyProfile,
            appState: appState,
            authManager: authManager,
            syncRepo: babySyncRepository,
            inviteService: inviteService,
            pendingInviteStore: PendingFamilyInviteStore(),
            ensureFamilyReady: { [unowned self] displayName in
                try await self.ensureFamilyReady(displayName: displayName)
            },
            joinFamily: { [unowned self] code, force in
                try await self.joinFamilyFromOnboarding(code: code, force: force)
            },
            syncAfterJoiningFamily: { [unowned self] in
                await self.cloudSyncDownloader.forceResyncAll()
                await self.appState.load()
            },
            analytics: analytics,
            pushNotifications: pushNotifications,
            recoverPendingAccountDeletion: { [unowned self] in
                await self.recoverPendingAccountDeletion()
            },
            onDone: onDone
        )
    }

    func ensureFamilyReady(displayName: String) async throws {
        await authManager.signInAnonymouslyIfNeeded()
        guard let uid = authManager.currentUID else { throw FamilyError.noFamilyId }
        try await FamilyManager.shared.setup(uid: uid, displayName: displayName)
    }

    func joinFamilyFromOnboarding(code: String, force: Bool = false) async throws {
        await authManager.signInAnonymouslyIfNeeded()
        guard let uid = authManager.currentUID else { throw FamilyError.noFamilyId }
        try await FamilyManager.shared.joinFamily(code: code, uid: uid, force: force)
    }

    func makeDiaryViewModel() -> DiaryViewModel {
        DiaryViewModel(repo: diaryRepository, analytics: analytics, appState: appState)
    }

    func makeTrackingViewModel() -> TrackingViewModel {
        TrackingViewModel(measurementRepo: measurementRepository, temperatureRepo: temperatureRepository, appState: appState)
    }

    func makeSharingViewModel() -> SharingViewModel {
        SharingViewModel(repo: familyRepository, inviteService: inviteService, appState: appState)
    }

    func makeSoundsViewModel() -> SoundsViewModel {
        SoundsViewModel(
            soundRepository: soundRepository,
            sleepTimerUC: SleepTimerUseCase(),
            nowPlaying: NowPlayingService.shared,
            soundEngine: SoundEngine.shared
        )
    }

    func makeSleepViewModel() -> SleepViewModel {
        SleepViewModel(startSleep: startSleep, stopSleep: stopSleep,
                       getSleep: getSleepEntries, addManualSleep: addManualSleep,
                       reconcileStaleSleep: reconcileStaleSleep, appState: appState,
                       predictNextSleep: predictNextSleep)
    }

    func makeReportViewModel() -> ReportViewModel {
        ReportViewModel(
            feedingRepo: feedingRepository,
            sleepRepo: sleepRepository,
            diaperRepo: diaperRepository,
            temperatureRepo: temperatureRepository,
            measurementRepo: measurementRepository,
            doctorVisitRepo: doctorVisitRepository,
            appState: appState,
            analytics: analytics
        )
    }

    lazy var addManualWalk = AddManualWalkUseCase(repository: walkRepository)
    lazy var addManualBath = AddManualBathUseCase(repository: bathRepository)

    func makeWalkViewModel() -> WalkViewModel {
        WalkViewModel(walkRepository: walkRepository, quickLogRepo: quickLogRepository,
                      addManualWalk: addManualWalk)
    }

    func makeBathViewModel() -> BathViewModel {
        BathViewModel(bathRepository: bathRepository, quickLogRepo: quickLogRepository,
                      addManualBath: addManualBath)
    }

    func makeVitaminViewModel() -> VitaminViewModel {
        VitaminViewModel(quickLogRepo: quickLogRepository)
    }

    func makePumpingViewModel() -> PumpingViewModel {
        PumpingViewModel(repository: pumpingRepository, quickLogRepo: quickLogRepository)
    }

    func makeLeapsViewModel() -> LeapsViewModel {
        LeapsViewModel(getLeaps: getLeaps, markLeapComplete: markLeapComplete, appState: appState)
    }

    func makeVaccinationViewModel() -> VaccinationViewModel {
        VaccinationViewModel(
            getStatus: getVaccinationStatus,
            markDone: markVaccinationDone,
            unmark: unmarkVaccination,
            addCustom: addCustomVaccination,
            pushNotifications: pushNotifications,
            appState: appState
        )
    }

    func makeFoodDiaryViewModel() -> FoodDiaryViewModel {
        FoodDiaryViewModel(
            add: addFoodEntry,
            get: getFoodEntries,
            delete: deleteFoodEntry,
            photoStorage: photoStorage,
            syncRepo: babySyncRepository
        )
    }

    func makeSymptomViewModel() -> SymptomViewModel {
        SymptomViewModel(appState: appState, addDiaryEntry: addDiaryEntry, syncRepo: babySyncRepository)
    }

    /// Durable "deletion in progress" marker, shared by the delete use case (writes it) and
    /// launch recovery (completes/clears it). Survives `eraseLocalData()`.
    let pendingAccountDeletionStore: PendingAccountDeletionStore = UserDefaultsPendingAccountDeletionStore()
    let suppressedFamilyRestoreStore: SuppressedFamilyRestoreStore = UserDefaultsSuppressedFamilyRestoreStore()

    func makeDeleteAccountUseCase() -> DeleteAccountUseCase {
        DeleteAccountUseCase(
            cloudEraser: FirestoreAccountEraser(babySync: BabySyncService()),
            photoStorage: photoStorage,
            auth: authManager,
            pendingStore: pendingAccountDeletionStore,
            suppressedRestoreStore: suppressedFamilyRestoreStore,
            eraseLocal: { [unowned self] in try self.eraseLocalData() }
        )
    }

    /// Completes an account deletion interrupted before the backend confirmed it. Run at
    /// launch (before any cloud download) so erased data can never resurface on re-login.
    lazy var accountDeletionRecovery = AccountDeletionRecovery(
        cloudEraser: FirestoreAccountEraser(babySync: BabySyncService()),
        auth: authManager,
        pendingStore: pendingAccountDeletionStore,
        suppressedRestoreStore: suppressedFamilyRestoreStore
    )

    /// Runs before launch-time migrations/local profile loading, and after a provider sign-in
    /// when that provider maps to the uid being deleted. Returns true while the delete marker
    /// is still unresolved; callers should skip cloud sync in that state so cached remote data
    /// cannot refill the freshly wiped device.
    @MainActor
    func recoverPendingAccountDeletion() async -> Bool {
        guard pendingAccountDeletionStore.loadPending() != nil else { return false }
        await accountDeletionRecovery.runIfNeeded()
        try? eraseLocalData()
        FamilyManager.shared.reset()
        return pendingAccountDeletionStore.loadPending() != nil
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(repo: preferencesRepository, deleteAccount: makeDeleteAccountUseCase())
    }

    func makeMomMoodViewModel() -> MomMoodViewModel {
        MomMoodViewModel(repository: momMoodRepository)
    }

    func makeMomSleepViewModel() -> MomSleepViewModel {
        MomSleepViewModel(start: startMomSleep, stop: stopMomSleep,
                          get: getMomSleepEntries, addManual: addManualMomSleep)
    }

    func makeWaterIntakeViewModel() -> WaterIntakeViewModel {
        WaterIntakeViewModel(log: logWaterIntake, get: getWaterIntake)
    }

    func makeWeeklyInsightViewModel() -> WeeklyInsightViewModel {
        WeeklyInsightViewModel(generate: generateWeeklyInsight, get: getWeeklyInsights)
    }
}

// MARK: — Environment

private struct AppContainerKey: EnvironmentKey {
    // SwiftUI may evaluate this default while seeding/diffing the environment even
    // though withContainer(_:) injects the real instance at the root, so it must not
    // crash. `defaultValue` is a nonisolated requirement while AppContainer is
    // @MainActor; environment reads happen on the main thread, so assumeIsolated is
    // safe here. Returns the shared fallback rather than a fresh instance to avoid
    // building a second ModelContainer per access.
    nonisolated static var defaultValue: AppContainer {
        MainActor.assumeIsolated { AppContainer.shared }
    }
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

extension View {
    func withContainer(_ container: AppContainer) -> some View {
        environment(\.appContainer, container)
    }
}
