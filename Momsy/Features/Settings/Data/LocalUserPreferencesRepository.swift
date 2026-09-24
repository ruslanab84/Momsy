import Foundation

final class LocalUserPreferencesRepository: UserPreferencesRepository {
    private enum Keys {
        static let theme      = "appTheme"
        static let language   = "appLanguage"
        static let unitSystem = "unitSystem"
        static let waterGoalMl = "waterGoalMl"
    }

    func load() -> UserPreferences {
        let waterGoal = UserDefaults.standard.integer(forKey: Keys.waterGoalMl)
        return UserPreferences(
            appTheme:    UserDefaults.standard.string(forKey: Keys.theme)      ?? "system",
            appLanguage: UserDefaults.standard.string(forKey: Keys.language)   ?? "en",
            unitSystem:  UserDefaults.standard.string(forKey: Keys.unitSystem) ?? "metric",
            waterGoalMl: waterGoal > 0 ? waterGoal : UserPreferences.defaultWaterGoalMl
        )
    }

    func save(_ prefs: UserPreferences) {
        UserDefaults.standard.set(prefs.appTheme,    forKey: Keys.theme)
        UserDefaults.standard.set(prefs.appLanguage, forKey: Keys.language)
        UserDefaults.standard.set(prefs.unitSystem,  forKey: Keys.unitSystem)
        UserDefaults.standard.set(prefs.waterGoalMl, forKey: Keys.waterGoalMl)
    }
}
