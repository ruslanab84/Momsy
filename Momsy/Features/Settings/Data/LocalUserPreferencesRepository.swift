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
            // Falls back to the live in-app language (device-resolved on a
            // first launch), never to a hardcoded "en" that would leave the
            // Settings picker out of step with the UI around it.
            appLanguage: UserDefaults.standard.string(forKey: Keys.language)
                ?? LocalizationManager.shared.lang,
            unitSystem:  UserDefaults.standard.string(forKey: Keys.unitSystem) ?? "metric"
        )
    }

    func save(_ prefs: UserPreferences) {
        UserDefaults.standard.set(prefs.appTheme,    forKey: Keys.theme)
        UserDefaults.standard.set(prefs.appLanguage, forKey: Keys.language)
        UserDefaults.standard.set(prefs.unitSystem,  forKey: Keys.unitSystem)
    }
}
