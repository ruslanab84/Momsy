import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var appTheme: String {
        didSet { save() }
    }
    @Published var appLanguage: String {
        didSet {
            save()
            if let lang = Language(rawValue: appLanguage) { LocalizationManager.shared.set(lang) }
        }
    }
    @Published var unitSystem: String {
        didSet {
            save()
            if let sys = UnitSystem(rawValue: unitSystem) { UnitSystemManager.shared.set(sys) }
        }
    }

    private let repo: any UserPreferencesRepository

    init(repo: any UserPreferencesRepository) {
        let prefs = repo.load()
        self.repo        = repo
        self.appTheme    = prefs.appTheme
        self.appLanguage = prefs.appLanguage
        self.unitSystem  = prefs.unitSystem
    }

    func setTheme(_ id: String) {
        withAnimation(.spring(response: 0.3)) { appTheme = id }
    }

    func setUnitSystem(_ id: String) {
        withAnimation(.spring(response: 0.3)) { unitSystem = id }
    }

    private func save() {
        repo.save(UserPreferences(appTheme: appTheme, appLanguage: appLanguage, unitSystem: unitSystem))
    }
}
