import Foundation

struct UserPreferences {
    var appTheme:    String
    var appLanguage: String
    var unitSystem:  String   // "metric" | "imperial"
}

protocol UserPreferencesRepository {
    func load() -> UserPreferences
    func save(_ prefs: UserPreferences)
}
