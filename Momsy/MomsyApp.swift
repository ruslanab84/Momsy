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
        }
    }
}
