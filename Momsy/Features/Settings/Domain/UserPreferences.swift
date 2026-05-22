import Foundation

struct UserPreferences {
    var appTheme: String
    var appLanguage: String
}

protocol UserPreferencesRepository {
    func load() -> UserPreferences
    func save(_ prefs: UserPreferences)
}
