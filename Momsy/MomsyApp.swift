import SwiftUI
import FirebaseCore

@main
struct MomsyApp: App {
    @AppStorage("appTheme") private var appTheme = "system"

    private let container = AppContainer()
    private let localization = LocalizationManager.shared
    private var appState: AppState { container.appState }

    private var resolvedColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withContainer(container)
                .environmentObject(localization)
                .environmentObject(appState)
                .withLocalization(localization)
                .preferredColorScheme(resolvedColorScheme)
                .task {
                    await appState.load()
                    await setupNotificationsOnLaunch(appState: appState)
                }
        }
    }
}

private func setupNotificationsOnLaunch(appState: AppState) async {
    let push = LocalPushNotificationService.shared
    await push.requestPermission()

    guard let birth = appState.babyProfile?.birthDate else { return }
    for leap in sampleLeaps {
        guard let start = Calendar.current.date(byAdding: .weekOfYear, value: leap.week, to: birth) else { continue }
        push.scheduleLeapNotification(leapID: leap.id, name: leap.name, nameEn: leap.nameEn, startDate: start)
    }
}
