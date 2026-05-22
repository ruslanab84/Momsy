import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var appTheme: String {
        didSet { repo.save(UserPreferences(appTheme: appTheme, appLanguage: appLanguage)) }
    }
    @Published var appLanguage: String {
        didSet {
            repo.save(UserPreferences(appTheme: appTheme, appLanguage: appLanguage))
            if let lang = Language(rawValue: appLanguage) { LocalizationManager.shared.set(lang) }
        }
    }

    private let repo: any UserPreferencesRepository

    init(repo: any UserPreferencesRepository) {
        let prefs = repo.load()
        self.repo = repo
        self.appTheme    = prefs.appTheme
        self.appLanguage = prefs.appLanguage
    }

    func setTheme(_ id: String) {
        withAnimation(.spring(response: 0.3)) { appTheme = id }
    }
}
