import Foundation
import SwiftUI

final class AppContainer {

    // MARK: — Repositories

    let babyRepository: any BabyRepository            = LocalBabyRepository()
    let sleepRepository: any SleepRepository          = LocalSleepRepository()
    let feedingRepository: any FeedingRepository      = LocalFeedingRepository()
    let diaryRepository: any DiaryRepository          = LocalDiaryRepository()
    let measurementRepository: any MeasurementRepository = LocalMeasurementRepository()
    let temperatureRepository: any TemperatureRepository = LocalTemperatureRepository()
    let familyRepository: any FamilyRepository        = LocalFamilyRepository()
    let leapsRepository: any LeapsRepository          = LocalLeapsRepository()
    let soundRepository: any SoundRepository           = LocalSoundRepository()
    let photoStorage: any PhotoStorageService          = LocalPhotoStorageService()
    let inviteService: any InviteServiceProtocol       = LocalInviteService()
    let analytics: any AnalyticsServiceProtocol        = LogAnalyticsService()
    let pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared
    let diaperUseCase                                   = DiaperUseCase()
    let quickLogRepository                              = QuickLogRepository()
    let walkRepository: any WalkRepository             = LocalWalkRepository()
    let chatRepository: any ChatRepository             = LocalChatRepository()
    let aiChatService: any AIChatService               = GeminiChatService()

    // MARK: — Use Cases — Baby

    lazy var getBabyProfile   = GetBabyProfileUseCase(repository: babyRepository)
    lazy var saveBabyProfile  = SaveBabyProfileUseCase(repository: babyRepository)
    lazy var appState         = AppState(getBabyProfile: getBabyProfile)

    // MARK: — Use Cases — Sleep

    lazy var startSleep         = StartSleepUseCase(repository: sleepRepository)
    lazy var stopSleep          = StopSleepUseCase(repository: sleepRepository)
    lazy var getSleepEntries    = GetSleepEntriesUseCase(repository: sleepRepository)

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

    lazy var getLeaps         = GetLeapsUseCase(repository: leapsRepository)
    lazy var markLeapComplete = MarkLeapCompleteUseCase(repository: leapsRepository)

    // MARK: — Use Cases — Chat

    lazy var getChatHistory    = GetChatHistoryUseCase(repository: chatRepository)
    lazy var appendChatMessage = AppendChatMessageUseCase(repository: chatRepository)
    lazy var clearChatHistory  = ClearChatHistoryUseCase(repository: chatRepository)

    // MARK: — ViewModel Factories

    func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(
            logFeeding: logFeeding,
            getFeeding: getFeedingEntries,
            diaperUC: diaperUseCase,
            quickLogRepo: quickLogRepository,
            timerService: FeedingTimerService(),
            analytics: analytics,
            pushNotifications: pushNotifications
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
        DiaryViewModel(repo: diaryRepository, photoStorage: photoStorage, analytics: analytics, appState: appState)
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
        SleepViewModel(startSleep: startSleep, stopSleep: stopSleep, getSleep: getSleepEntries)
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
            temperatureRepo: temperatureRepository,
            appState: appState,
            analytics: analytics
        )
    }

    func makeWalkViewModel() -> WalkViewModel {
        WalkViewModel(walkRepository: walkRepository, quickLogRepo: quickLogRepository)
    }

    func makeSymptomViewModel() -> SymptomViewModel {
        SymptomViewModel(appState: appState)
    }
}

// MARK: — Environment

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue = AppContainer()
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
