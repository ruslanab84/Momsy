import Foundation
import SwiftUI
import SwiftData

final class AppContainer {

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
    lazy var chatRepository: any ChatRepository            = SwiftDataChatRepository(context: context)
    lazy var walkRepository: any WalkRepository            = SwiftDataWalkRepository(context: context)
    lazy var bathRepository: any BathRepository             = SwiftDataBathRepository(context: context)
    lazy var doctorVisitRepository: any DoctorVisitRepository = SwiftDataDoctorVisitRepository(context: context)
    lazy var vaccinationRepository: any VaccinationRepository = SwiftDataVaccinationRepository(context: context)
    lazy var complementaryFeedingRepository: any ComplementaryFeedingRepository = SwiftDataComplementaryFeedingRepository(context: context)
    lazy var diaperRepository: any DiaperRepository                             = SwiftDataDiaperRepository(context: context)
    lazy var momMoodRepository: any MomMoodRepository                           = SwiftDataMomMoodRepository(context: context)
    lazy var stoolRepository: any StoolRepository                               = SwiftDataStoolRepository(context: context)
    lazy var momSleepRepository: any MomSleepRepository                         = SwiftDataMomSleepRepository(context: context)

    let familyRepository: any FamilyRepository        = LocalFamilyRepository()
    let soundRepository: any SoundRepository           = LocalSoundRepository()
    let photoStorage: any PhotoStorageService          = FirebasePhotoStorageService()
    let inviteService: any InviteServiceProtocol       = LocalInviteService()
    let analytics: any AnalyticsServiceProtocol        = LogAnalyticsService()
    let pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared
    let diaperUseCase                                   = DiaperUseCase()
    let quickLogRepository                              = QuickLogRepository()
    let aiChatService: any AIChatService               = GeminiChatService()
    let preferencesRepository: any UserPreferencesRepository = LocalUserPreferencesRepository()
    let dailyTipRepository                             = DailyTipRepository()
    lazy var dailyTipService: any DailyTipService      = StaticDailyTipService()

    // MARK: — Use Cases — Baby

    lazy var getBabyProfile   = GetBabyProfileUseCase(repository: babyRepository)
    lazy var saveBabyProfile  = SaveBabyProfileUseCase(repository: babyRepository)
    lazy var appState         = AppState(getBabyProfile: getBabyProfile)

    // MARK: — Use Cases — Sleep

    lazy var startSleep         = StartSleepUseCase(repository: sleepRepository)
    lazy var stopSleep          = StopSleepUseCase(repository: sleepRepository)
    lazy var getSleepEntries    = GetSleepEntriesUseCase(repository: sleepRepository)
    lazy var addManualSleep     = AddManualSleepUseCase(repository: sleepRepository)

    // MARK: — Use Cases — Mom Sleep
    lazy var startMomSleep      = StartMomSleepUseCase(repository: momSleepRepository)
    lazy var stopMomSleep       = StopMomSleepUseCase(repository: momSleepRepository)
    lazy var getMomSleepEntries = GetMomSleepEntriesUseCase(repository: momSleepRepository)
    lazy var addManualMomSleep  = AddManualMomSleepUseCase(repository: momSleepRepository)

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

    // MARK: — Use Cases — Chat

    lazy var getChatHistory    = GetChatHistoryUseCase(repository: chatRepository)
    lazy var appendChatMessage = AppendChatMessageUseCase(repository: chatRepository)
    lazy var clearChatHistory  = ClearChatHistoryUseCase(repository: chatRepository)

    // MARK: — Migration

    func runMigrationIfNeeded() {
        UserDefaultsMigration.runIfNeeded(context: context)
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
            diaperRepo: diaperRepository,
            stoolRepo: stoolRepository,
            quickLogRepo: quickLogRepository,
            tipService: dailyTipService,
            tipRepository: dailyTipRepository,
            appState: appState
        )
    }

    func makeOnboardingViewModel(onDone: @escaping () -> Void) -> OnboardingViewModel {
        OnboardingViewModel(
            saveBabyProfile: saveBabyProfile,
            appState: appState,
            analytics: analytics,
            pushNotifications: pushNotifications,
            onDone: onDone
        )
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
                       getSleep: getSleepEntries, addManualSleep: addManualSleep, appState: appState)
    }

    func makeAIChatViewModel() -> AIChatViewModel {
        AIChatViewModel(
            getChatHistory: getChatHistory,
            appendMessage: appendChatMessage,
            clearChat: clearChatHistory,
            chatService: aiChatService,
            appState: appState,
            getLeaps: getLeaps
        )
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
            photoStorage: photoStorage
        )
    }

    func makeSymptomViewModel() -> SymptomViewModel {
        SymptomViewModel(appState: appState, addDiaryEntry: addDiaryEntry)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(repo: preferencesRepository)
    }

    func makeMomMoodViewModel() -> MomMoodViewModel {
        MomMoodViewModel(repository: momMoodRepository)
    }

    func makeMomSleepViewModel() -> MomSleepViewModel {
        MomSleepViewModel(start: startMomSleep, stop: stopMomSleep,
                          get: getMomSleepEntries, addManual: addManualMomSleep)
    }
}

// MARK: — Environment

private struct AppContainerKey: EnvironmentKey {
    // Never used at runtime — withContainer(_:) always injects the real instance.
    nonisolated(unsafe) static let defaultValue = AppContainer()
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
