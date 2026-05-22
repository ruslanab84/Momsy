import Foundation

final class LocalUserPreferencesRepository: UserPreferencesRepository {
    private enum Keys {
        static let theme    = "appTheme"
        static let language = "appLanguage"
    }

    func load() -> UserPreferences {
        UserPreferences(
            appTheme:    UserDefaults.standard.string(forKey: Keys.theme)    ?? "system",
            appLanguage: UserDefaults.standard.string(forKey: Keys.language) ?? "en"
        )
    }

    func save(_ prefs: UserPreferences) {
        UserDefaults.standard.set(prefs.appTheme,    forKey: Keys.theme)
        UserDefaults.standard.set(prefs.appLanguage, forKey: Keys.language)
    }
}
