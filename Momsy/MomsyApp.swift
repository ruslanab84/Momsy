import SwiftUI
import FirebaseCore

@main
struct MomsyApp: App {
    @AppStorage("appTheme") private var appTheme = "system"

    private let container = AppContainer()
    private let localization = LocalizationManager.shared

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
                .withLocalization(localization)
                .preferredColorScheme(resolvedColorScheme)
                .task { await setupNotificationsOnLaunch() }
        }
    }
}

private func setupNotificationsOnLaunch() async {
    let push = LocalPushNotificationService.shared
    await push.requestPermission()

    let birthInterval = UserDefaults.standard.double(forKey: "babyBirthDate")
    guard birthInterval > 0 else { return }
    let birth = Date(timeIntervalSince1970: birthInterval)
    for leap in sampleLeaps {
        guard let start = Calendar.current.date(byAdding: .weekOfYear, value: leap.week, to: birth) else { continue }
        push.scheduleLeapNotification(leapID: leap.id, name: leap.name, nameEn: leap.nameEn, startDate: start)
    }
}
