import Foundation
import Combine
import FirebaseAuth
import SwiftUI
import SwiftData

@MainActor
final class AppContainer {

    // MARK: — Persistence

    let modelContainer: ModelContainer
    private lazy var context: ModelContext = ModelContext(modelContainer)

    // MARK: — Repositories

    lazy var babyRepository: any BabyRepository            = SwiftDataBabyRepository(context: context)
    lazy var sleepRepository: any SleepRepository          = SwiftDataSleepRepository(context: context)
    lazy var feedingRepository: any FeedingRepository      = SwiftDataFeedingRepository(context: context)
    lazy var diaryRepository: any DiaryRepository          = SwiftDataDiaryRepository(context: context)
    lazy var measurementRepository: any MeasurementRepository = SwiftDataMeasurementRepository(context: context)
    lazy var temperatureRepository: any TemperatureRepository = SwiftDataTemperatureRepository(context: context)
    lazy var leapsRepository: any LeapsRepository          = SwiftDataLeapsRepository(context: context)
    lazy var leapCheckInRepository: any LeapCheckInRepository = LocalLeapCheckInRepository()
    lazy var walkRepository: any WalkRepository            = SwiftDataWalkRepository(context: context)
    lazy var bathRepository: any BathRepository             = SwiftDataBathRepository(context: context)
    lazy var doctorVisitRepository: any DoctorVisitRepository = SwiftDataDoctorVisitRepository(context: context)
    lazy var vaccinationRepository: any VaccinationRepository = SwiftDataVaccinationRepository(context: context)
    lazy var complementaryFeedingRepository: any ComplementaryFeedingRepository = SwiftDataComplementaryFeedingRepository(context: context)
    lazy var diaperRepository: any DiaperRepository                             = SwiftDataDiaperRepository(context: context)
    lazy var momMoodRepository: any MomMoodRepository                           = SwiftDataMomMoodRepository(context: context)
    lazy var stoolRepository: any StoolRepository                               = SwiftDataStoolRepository(context: context)
    lazy var momSleepRepository: any MomSleepRepository = SwiftDataMomSleepRepository(
        context: context,
        currentUID: { [weak authManager] in authManager?.currentUID }
    )
    lazy var waterIntakeRepository: any WaterIntakeRepository = SwiftDataWaterIntakeRepository(
        context: context,
        currentUID: { [weak authManager] in authManager?.currentUID }
    )
    lazy var pumpingRepository: any PumpingRepository                            = SwiftDataPumpingRepository(context: context)
    lazy var vitaminRepository: any VitaminRepository                            = SwiftDataVitaminRepository(context: context)

    lazy var familyRepository: any FamilyRepository = FirebaseBootstrapper.isConfigured
        ? FirestoreFamilyRepository()
        : LocalFamilyRepository()
    let soundRepository: any SoundRepository           = LocalSoundRepository()
    lazy var inviteService: any InviteServiceProtocol = FirebaseBootstrapper.isConfigured
        ? FirestoreInviteService()
        : LocalInviteService()
    lazy var babySyncRepository: any BabySyncRepositoryProtocol = FirebaseBootstrapper.isConfigured
        ? BabySyncRepository(service: BabySyncService())
        : NoOpBabySyncRepository()
    /// Shared with the downloader so a family-switch purge can reset the same
    /// watermarks the sync advances.
    let syncWatermarks = SyncWatermarkStore()
    lazy var cloudSyncDownloader: any CloudSyncDownloaderProtocol = {
        guard FirebaseBootstrapper.isConfigured else { return NoOpCloudSyncDownloader() }
        return CloudSyncDownloader(
            service: BabySyncService(),
            feedingRepo: feedingRepository,
            sleepRepo: sleepRepository,
            diaperRepo: diaperRepository,
            stoolRepo: stoolRepository,
            diaryRepo: diaryRepository,
            walkRepo: walkRepository,
            bathRepo: bathRepository,
            pumpingRepo: pumpingRepository,
            vitaminRepo: vitaminRepository,
            measurementRepo: measurementRepository,
            vaccinationRepo: vaccinationRepository,
            foodDiaryRepo: complementaryFeedingRepository,
            quickLogRepo: quickLogRepository,
            babyRepo: babyRepository,
            temperatureRepo: temperatureRepository,
            momSleepRepo: momSleepRepository,
            waterIntakeRepo: waterIntakeRepository,
            leapsRepo: leapsRepository,
            doctorVisitRepo: doctorVisitRepository,
            watermarks: syncWatermarks
        )
    }()
    /// Foreground realtime trigger for co-parent sleep updates; baby-scoped, so it is
    /// restarted on every active-baby switch and family join.
    lazy var sleepLiveSync = SleepLiveSyncService(downloader: cloudSyncDownloader)
    let analytics: any AnalyticsServiceProtocol        = LogAnalyticsService()
    let pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared
    let authManager                                    = AuthManager()
    let subscriptionManager                            = SubscriptionManager(
        service: StoreKitSubscriptionService(),
        familyPremiumService: FamilyPremiumService()
    )
    let diaperUseCase                                   = DiaperUseCase()
    let quickLogRepository                              = QuickLogRepository()
    let preferencesRepository: any UserPreferencesRepository = LocalUserPreferencesRepository()
    let dailyTipRepository                             = DailyTipRepository()
    lazy var weeklyInsightRepository: any WeeklyInsightRepository = SwiftDataWeeklyInsightRepository(context: context)
    /// Gemini generation is disabled for the App Store release (see the disabled
    /// consent flow in `MomsyApp.maybeGenerateWeeklyReport`), so the offline service
    /// stands in here. Restoring AI means putting the `FirebaseBootstrapper.isConfigured
    /// ? GeminiWeeklyInsightService() : StaticWeeklyInsightService()` choice back on
    /// this one line — nothing downstream assumes which service it got.
    lazy var weeklyInsightService: any WeeklyInsightService = StaticWeeklyInsightService()

    // MARK: — Cross-device sync wiring

    private var familyJoinObserver: NSObjectProtocol?
    private var authSessionObserver: AnyCancellable?

    convenience init() {
        do {
            try self.init(modelContainer: AppPersistence.makeInMemoryContainer())
        } catch {
            preconditionFailure("Failed to build in-memory AppContainer: \(error.localizedDescription)")
        }
    }

    static func makeProduction() throws -> AppContainer {
        try AppContainer(modelContainer: AppPersistence.makeContainer())
    }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        observeFamilyJoin()
        observeAuthSession()
        wireMembershipRevocation()
    }

    private func observeAuthSession() {
        authSessionObserver = authManager.$firebaseUser
            .map { $0?.uid }
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] uid in
                Task { @MainActor in
                    guard let self else { return }
                    PaywallPresentationState.resetForAuthenticationChange()
                    await self.subscriptionManager.authSessionDidChange(
                        isAuthenticated: uid != nil
                    )
                }
            }
    }

    /// Revocation purge hook. Runs synchronously-before the revoked family is
    /// replaced (FamilyManager awaits it), reusing the same local-cache purge the
    /// family-switch path uses — otherwise the old family's children would be
    /// re-uploaded into the freshly created personal family by `syncBabyProfile`.
    private func wireMembershipRevocation() {
        FamilyManager.shared.onMembershipRevoked = { [weak self] revokedFamilyId in
            guard let self else { return }
            self.purgeLocalData(previousFamilyId: revokedFamilyId)
            ActiveBaby.currentId = nil
        }
    }

    /// After a join, drop the active-baby pointer so the downloader adopts the joined
    /// family's roster, then re-pull everything. When the join SWITCHED families, wipe
    /// the old family's local cache first — otherwise its children stay in the picker
    /// and `syncBabyProfile` would re-upload them into the new family.
    private func observeFamilyJoin() {
        familyJoinObserver = NotificationCenter.default.addObserver(
            forName: .familyDidJoin, object: nil, queue: .main) { [weak self] note in
            guard let self else { return }
            let previous = note.userInfo?[FamilyManager.previousFamilyIdUserInfoKey] as? String
            Task { @MainActor in
                if let newFamily = FamilyManager.shared.familyId,
                   FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: previous,
                                                           newFamilyId: newFamily) {
                    self.purgeLocalData(previousFamilyId: previous ?? "")
                }
                // Clear the active pointer FIRST (this also clears the persisted babyId)
                // so discovery adopts the joined family's roster. Any writes still queued
                // from a previous family are skipped by the replay's cross-family guard.
                ActiveBaby.currentId = nil
                await self.cloudSyncDownloader.forceResyncAll()
                self.sleepLiveSync.restart()
                NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
            }
        }
    }

    /// Removes every locally cached child and log of the family being left so nothing
    /// from it can surface in the picker or be re-uploaded into the joined family.
    /// The old family's watermarks are reset too: the local rows backing that delta
    /// are gone, so a later re-join must start from a clean full pull. Queued cloud
    /// deletes are dropped — replaying them would write stray tombstones into the
    /// new family's tree.
    @MainActor
    private func purgeLocalData(previousFamilyId: String) {
        let records = (try? context.fetch(FetchDescriptor<BabyRecord>())) ?? []
        for record in records {
            BabyLogBackfill.deleteLogs(forBaby: record.id, context: context)
            PendingWritesStore.shared.removeAll(forBaby: record.id)
            if !previousFamilyId.isEmpty {
                syncWatermarks.reset(family: previousFamilyId, baby: record.id.uuidString)
            }
            context.delete(record)
        }
        try? context.save()
        PendingDeletionsStore.shared.clear()
        WidgetDataStore.shared.clearAll()
        Task { await appState.load() }
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
        guard FamilyManager.shared.canPerform(.manageBabyProfiles) else {
            throw FamilyError.accessDenied
        }
        try await saveBabyProfile.execute(profile)
        appState.update(profile)
        await switchActiveBaby(to: profile.id)
        try? await babySyncRepository.syncBabyProfile(profile)
    }

    @MainActor
    func updateChildProfile(_ profile: BabyProfile) async throws {
        guard FamilyManager.shared.canPerform(.manageBabyProfiles) else {
            throw FamilyError.accessDenied
        }
        try await saveBabyProfile.execute(profile)
        appState.update(profile)
        try? await babySyncRepository.syncBabyProfile(profile)
    }

    /// Point the whole app at a different child and re-pull its cloud logs.
    @MainActor
    func switchActiveBaby(to id: UUID) async {
        appState.setActive(id)
        await cloudSyncDownloader.resyncActiveBaby()
        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
        sleepLiveSync.restart()
    }

    /// Remove a child: cascade-delete its logs, drop the profile, re-point active.
    @MainActor
    func deleteChild(id: UUID) async throws {
        guard FamilyManager.shared.canPerform(.manageBabyProfiles) else {
            throw FamilyError.accessDenied
        }
        let profiles = try await babyRepository.getAllProfiles()
        guard profiles.contains(where: { $0.id == id }) else { return }
        guard profiles.count > 1 else { throw BabyError.cannotDeleteLastChild }

        try await babySyncRepository.deleteBaby(id: id)
        PendingWritesStore.shared.removeAll(forBaby: id)
        BabyLogBackfill.deleteLogs(forBaby: id, context: context)
        try context.save()
        try await babyRepository.deleteProfile(id: id)
        let replacedActiveBaby = ActiveBaby.currentId == id
        if replacedActiveBaby {
            let remaining = (try? await babyRepository.getAllProfiles()) ?? []
            ActiveBaby.currentId = remaining.first?.id
        }
        await appState.load()
        if ActiveBaby.currentId != nil { await cloudSyncDownloader.resyncActiveBaby() }
        if replacedActiveBaby { sleepLiveSync.restart() }
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

    // MARK: — Use Cases — Leaps

    lazy var getLeaps          = GetLeapsUseCase(repository: leapsRepository)
    lazy var markLeapComplete  = MarkLeapCompleteUseCase(repository: leapsRepository)
    lazy var getLeapCheckIns   = GetLeapCheckInsUseCase(repository: leapCheckInRepository)
    lazy var saveLeapCheckIn   = SaveLeapCheckInUseCase(repository: leapCheckInRepository)
    lazy var recordLeapSkill   = RecordLeapSkillUseCase(addDiaryEntry: addDiaryEntry, syncRepo: babySyncRepository)
    lazy var scheduleLeapNotifications = ScheduleLeapNotificationsUseCase(pushNotifications: pushNotifications)

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
        appState: appState,
        hasAIConsent: { WeeklyInsightAIConsent.status() == .granted },
        leapCheckInRepo: leapCheckInRepository,
        diaryRepo: diaryRepository
    )
    lazy var getWeeklyInsights = GetWeeklyInsightsUseCase(repository: weeklyInsightRepository)

    // MARK: — GDPR erasure

    /// Wipes every on-device trace: all SwiftData records, the launch-routing and
    /// sync UserDefaults flags, and the in-memory baby profile. Cloud + auth erasure
    /// is handled by `DeleteAccountUseCase` before this runs.
    @MainActor
    func eraseLocalData() throws {
        sleepLiveSync.stop()
        subscriptionManager.eraseLocalSubscriptionState()
        SleepLiveActivityManager().endActivity()
        FeedingLiveActivityManager().endActivity()
        WalkLiveActivityManager().endActivity()
        BathLiveActivityManager().endActivity()
        PumpingLiveActivityManager().endActivity()

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
        try context.delete(model: VitaminRecord.self)
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
            "babyLogBackfill_v2_done",
            "diaper_today_count",
            "diaper_today_date",
            "uid",
            "displayName",
            "watch_processed_cmd_ids",
            "invite_code",
            "invite_expiry",
            "invite_role",
            WeeklyInsightAIConsent.storageKey,
            FirestoreInviteService.codeKey,
            FirestoreInviteService.expiryKey,
            FirestoreInviteService.familyKey,
            FirestoreInviteService.roleKey,
            FirestoreInviteService.syncedCodeKey,
            PendingFamilyInviteStore.codeKey,
            PendingOnboardingSetupStore.storageKey,
            PendingSubscriptionSyncStore.storageKey,
            PendingSubscriptionSyncStore.successStorageKey,
            CloudSyncConsent.storageKey,
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
            inviteService: inviteService,
            pendingInviteStore: PendingFamilyInviteStore(),
            pendingSetupStore: PendingOnboardingSetupStore(),
            ensureFamilyReady: { [unowned self] displayName, role, profile in
                try await self.ensureFamilyReady(
                    displayName: displayName,
                    role: role,
                    initialProfile: profile
                )
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
            initialCloudSyncEnabled: CloudSyncConsent.isGranted(),
            setCloudSyncConsent: { [unowned self] status in
                CloudSyncConsent.set(status)
                self.subscriptionManager.cloudSyncConsentDidChange(
                    enabled: status == .granted
                )
            },
            onDone: onDone
        )
    }

    func ensureFamilyReady(
        displayName: String,
        role: FamilyRole,
        initialProfile: BabyProfile
    ) async throws {
        try await authManager.requireAnonymousSignInIfNeeded()
        guard let uid = authManager.currentUID else { throw FamilyError.noFamilyId }
        try await FamilyManager.shared.setup(
            uid: uid,
            displayName: displayName,
            role: role,
            initialProfile: initialProfile
        )
    }

    func joinFamilyFromOnboarding(code: String, force: Bool = false) async throws {
        FamilyManager.shared.beginJoinFlow()
        defer { FamilyManager.shared.endJoinFlow() }
        try await authManager.requireAnonymousSignInIfNeeded()
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
        SharingViewModel(repo: familyRepository, inviteService: inviteService, appState: appState, auth: authManager)
    }

    func makeAccountAuthViewModel() -> AccountAuthViewModel {
        AccountAuthViewModel(auth: authManager) { [weak self] in
            await self?.cloudSyncDownloader.downloadAndMergeWhenReady()
        }
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
                       predictNextSleep: predictNextSleep,
                       currentUid: { [weak authManager] in authManager?.currentUID })
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
        VitaminViewModel(quickLogRepo: quickLogRepository, vitaminRepo: vitaminRepository)
    }

    lazy var getLogReportEntries = GetLogReportEntriesUseCase(
        feedingRepo: feedingRepository,
        sleepRepo: sleepRepository,
        diaperRepo: diaperRepository,
        stoolRepo: stoolRepository,
        walkRepo: walkRepository,
        bathRepo: bathRepository,
        pumpingRepo: pumpingRepository,
        vitaminRepo: vitaminRepository
    )

    func makeLogReportViewModel() -> LogReportViewModel {
        LogReportViewModel(getEntries: getLogReportEntries)
    }

    func makePumpingViewModel() -> PumpingViewModel {
        PumpingViewModel(repository: pumpingRepository, quickLogRepo: quickLogRepository)
    }

    func makeLeapsViewModel() -> LeapsViewModel {
        LeapsViewModel(
            getLeaps: getLeaps,
            markLeapComplete: markLeapComplete,
            getCheckIns: getLeapCheckIns,
            saveCheckIn: saveLeapCheckIn,
            getSleep: getSleepEntries,
            getFeeding: getFeedingEntries,
            appState: appState,
            recordLeapSkill: recordLeapSkill,
            scheduleLeapNotifications: scheduleLeapNotifications
        )
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
            syncRepo: babySyncRepository
        )
    }

    func makeSymptomViewModel() -> SymptomViewModel {
        SymptomViewModel(appState: appState, addDiaryEntry: addDiaryEntry, syncRepo: babySyncRepository)
    }

    /// Durable "deletion in progress" marker, shared by the delete use case (writes it) and
    /// launch recovery (completes/clears it). Survives `eraseLocalData()`.
    let pendingAccountDeletionStore: PendingAccountDeletionStore = UserDefaultsPendingAccountDeletionStore()
    let pendingAuthAccountDeletionStore: PendingAuthAccountDeletionStore = UserDefaultsPendingAuthAccountDeletionStore()
    let suppressedFamilyRestoreStore: SuppressedFamilyRestoreStore = UserDefaultsSuppressedFamilyRestoreStore()

    func makeDeleteAccountUseCase() -> DeleteAccountUseCase {
        DeleteAccountUseCase(
            cloudEraser: FirestoreAccountEraser(),
            auth: authManager,
            pendingStore: pendingAccountDeletionStore,
            pendingAuthStore: pendingAuthAccountDeletionStore,
            suppressedRestoreStore: suppressedFamilyRestoreStore,
            eraseLocal: { [unowned self] in try self.eraseLocalData() }
        )
    }

    /// Completes an account deletion interrupted before the backend confirmed it. Run at
    /// launch (before any cloud download) so erased data can never resurface on re-login.
    lazy var accountDeletionRecovery = AccountDeletionRecovery(
        cloudEraser: FirestoreAccountEraser(),
        auth: authManager,
        pendingStore: pendingAccountDeletionStore,
        pendingAuthStore: pendingAuthAccountDeletionStore,
        suppressedRestoreStore: suppressedFamilyRestoreStore,
        eraseLocal: { [unowned self] in
            defer { FamilyManager.shared.reset() }
            try self.eraseLocalData()
        }
    )

    /// Runs before launch-time migrations/local profile loading, and after a provider sign-in
    /// when that provider maps to the uid being deleted. Returns true while the delete marker
    /// is still unresolved AND applies to the current session; callers should skip cloud sync
    /// in that state so cached remote data cannot refill the freshly wiped device.
    @MainActor
    func recoverPendingAccountDeletion() async -> Bool {
        let pendingAtStart = pendingAccountDeletionStore.loadPending()
        // Recovery runs even without a blocking marker: that is the state in which it drives
        // the non-blocking Auth-record retry, and this is its only production entry point.
        await accountDeletionRecovery.runIfNeeded()
        guard let pendingAtStart else { return false }

        let currentUidAfterRecovery = authManager.currentUID
        return pendingAccountDeletionStore.loadPending()?.uid == pendingAtStart.uid &&
            currentUidAfterRecovery == pendingAtStart.uid
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            repo: preferencesRepository,
            deleteAccount: makeDeleteAccountUseCase(),
            accountAuth: authManager,
            cloudSyncEnabled: CloudSyncConsent.isGranted(),
            updateCloudSync: { [unowned self] enabled in
                CloudSyncConsent.set(enabled ? .granted : .denied)
                if enabled {
                    do {
                        try await self.authManager.signInAnonymouslyIfNeeded()
                    } catch {
                        CloudSyncConsent.set(.denied)
                        self.subscriptionManager.cloudSyncConsentDidChange(enabled: false)
                        throw error
                    }
                    self.subscriptionManager.cloudSyncConsentDidChange(enabled: true)
                    await self.cloudSyncDownloader.downloadAndMergeWhenReady()
                    self.sleepLiveSync.start()
                } else {
                    self.subscriptionManager.cloudSyncConsentDidChange(enabled: false)
                    self.sleepLiveSync.stop()
                }
            }
        )
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

    func makeCareTipsViewModel() -> CareTipsViewModel {
        CareTipsViewModel(appState: appState)
    }
}

// MARK: — Environment

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer? = nil
}

extension EnvironmentValues {
    fileprivate var injectedAppContainer: AppContainer? {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }

    var appContainer: AppContainer {
        get {
            guard let container = injectedAppContainer else {
                preconditionFailure("AppContainer is missing. Inject one at the root with .withContainer(_:).")
            }
            return container
        }
    }
}

extension View {
    func withContainer(_ container: AppContainer) -> some View {
        environment(\.injectedAppContainer, container)
    }
}
