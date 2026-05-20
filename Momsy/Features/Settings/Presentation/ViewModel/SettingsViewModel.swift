import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var appTheme: String {
        didSet { UserDefaults.standard.set(appTheme, forKey: "appTheme") }
    }
    @Published var appLanguage: String {
        didSet { UserDefaults.standard.set(appLanguage, forKey: "appLanguage") }
    }

    init() {
        appTheme    = UserDefaults.standard.string(forKey: "appTheme")    ?? "system"
        appLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }

    func setTheme(_ id: String) {
        withAnimation(.spring(response: 0.3)) { appTheme = id }
    }
}
