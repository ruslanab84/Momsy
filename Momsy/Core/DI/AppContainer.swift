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

    // MARK: — ViewModel Factories

    func makeDiaryViewModel() -> DiaryViewModel {
        DiaryViewModel(repo: diaryRepository)
    }

    func makeTrackingViewModel() -> TrackingViewModel {
        TrackingViewModel(measurementRepo: measurementRepository, temperatureRepo: temperatureRepository)
    }

    func makeSharingViewModel() -> SharingViewModel {
        SharingViewModel(repo: familyRepository)
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
