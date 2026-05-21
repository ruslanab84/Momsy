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
    let diaperUseCase                                   = DiaperUseCase()
    let chatRepository: any ChatRepository             = LocalChatRepository()
    let aiChatService: any AIChatService               = GeminiChatService()

    // MARK: — Use Cases — Baby

    lazy var getBabyProfile   = GetBabyProfileUseCase(repository: babyRepository)
    lazy var saveBabyProfile  = SaveBabyProfileUseCase(repository: babyRepository)

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
            timerService: FeedingTimerService()
        )
    }

    func makeDiaryViewModel() -> DiaryViewModel {
        DiaryViewModel(repo: diaryRepository)
    }

    func makeTrackingViewModel() -> TrackingViewModel {
        TrackingViewModel(measurementRepo: measurementRepository, temperatureRepo: temperatureRepository)
    }

    func makeSharingViewModel() -> SharingViewModel {
        SharingViewModel(repo: familyRepository)
    }

    func makeSoundsViewModel() -> SoundsViewModel {
        SoundsViewModel(
            soundRepository: soundRepository,
            sleepTimerUC: SleepTimerUseCase(),
            nowPlaying: NowPlayingService.shared
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
            chatService: aiChatService
        )
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
