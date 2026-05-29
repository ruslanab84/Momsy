import Foundation

final class LocalUserPreferencesRepository: UserPreferencesRepository {
    private enum Keys {
        static let theme      = "appTheme"
        static let language   = "appLanguage"
        static let unitSystem = "unitSystem"
    }

    func load() -> UserPreferences {
        UserPreferences(
            appTheme:    UserDefaults.standard.string(forKey: Keys.theme)      ?? "system",
            appLanguage: UserDefaults.standard.string(forKey: Keys.language)   ?? "en",
            unitSystem:  UserDefaults.standard.string(forKey: Keys.unitSystem) ?? "metric"
        )
    }

    func save(_ prefs: UserPreferences) {
        UserDefaults.standard.set(prefs.appTheme,    forKey: Keys.theme)
        UserDefaults.standard.set(prefs.appLanguage, forKey: Keys.language)
        UserDefaults.standard.set(prefs.unitSystem,  forKey: Keys.unitSystem)
    }
}
