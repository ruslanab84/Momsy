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
    @Published var vaccinationScheduleKey: String {
        didSet {
            if let key = VaccinationScheduleKey(rawValue: vaccinationScheduleKey) {
                VaccinationScheduleProvider.shared.setKey(key)
            }
        }
    }

    /// Schedules the user can choose between today (only WHO has data for v1).
    let availableScheduleKeys: [VaccinationScheduleKey] = VaccinationScheduleProvider.shared.availableKeys

    @Published private(set) var isDeleting = false
    @Published var deletionError: String?

    private let repo: any UserPreferencesRepository
    private let deleteAccount: DeleteAccountUseCase

    init(repo: any UserPreferencesRepository, deleteAccount: DeleteAccountUseCase) {
        let prefs = repo.load()
        self.repo                   = repo
        self.deleteAccount          = deleteAccount
        self.appTheme               = prefs.appTheme
        self.appLanguage            = prefs.appLanguage
        self.unitSystem             = prefs.unitSystem
        self.vaccinationScheduleKey = VaccinationScheduleProvider.shared.activeKey.rawValue
    }

    /// Performs full GDPR erasure. On success the cleared `onboardingDone` /
    /// `paywallShown` flags (removed inside the use case's local wipe) make
    /// `ContentView` reroute back to onboarding automatically.
    func deleteAllData() async {
        guard !isDeleting else { return }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await deleteAccount.execute()
        } catch {
            deletionError = error.localizedDescription
        }
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
