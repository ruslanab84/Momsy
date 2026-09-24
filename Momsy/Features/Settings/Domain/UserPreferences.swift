import Foundation

struct UserPreferences {
    var appTheme:    String
    var appLanguage: String
    var unitSystem:  String   // "metric" | "imperial"
    /// The parent's own water target — user-set, not a health recommendation.
    var waterGoalMl: Int = UserPreferences.defaultWaterGoalMl

    static let defaultWaterGoalMl = 2000
}

protocol UserPreferencesRepository {
    func load() -> UserPreferences
    func save(_ prefs: UserPreferences)
}
