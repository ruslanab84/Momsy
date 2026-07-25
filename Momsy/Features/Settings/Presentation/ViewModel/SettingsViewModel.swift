import SwiftUI
import Combine
import AuthenticationServices

@MainActor
protocol AccountDeletionAuthenticating: AnyObject {
    var accountDeletionProvider: AccountDeletionProvider? { get }
    func prepareAppleDeletionRequest(_ request: ASAuthorizationAppleIDRequest)
    func reauthenticateForDeletionWithApple(
        _ result: Result<ASAuthorization, Error>
    ) async throws
    func reauthenticateForDeletionWithGoogle() async throws
}

extension AuthManager: AccountDeletionAuthenticating {}

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
    @Published private(set) var isReauthenticating = false
    @Published var showsDeletionReauthentication = false
    @Published var reauthenticationError: Error?
    @Published var deletionError: String?
    @Published private(set) var cloudSyncEnabled: Bool

    private let repo: any UserPreferencesRepository
    private let deleteAccount: DeleteAccountUseCase
    private let accountAuth: any AccountDeletionAuthenticating
    private let updateCloudSync: @MainActor (Bool) async -> Void

    init(
        repo: any UserPreferencesRepository,
        deleteAccount: DeleteAccountUseCase,
        accountAuth: any AccountDeletionAuthenticating,
        cloudSyncEnabled: Bool = CloudSyncConsent.isGranted(),
        updateCloudSync: @MainActor @escaping (Bool) async -> Void = {
            CloudSyncConsent.set($0 ? .granted : .denied)
        }
    ) {
        let prefs = repo.load()
        self.repo                   = repo
        self.deleteAccount          = deleteAccount
        self.accountAuth             = accountAuth
        self.cloudSyncEnabled        = cloudSyncEnabled
        self.updateCloudSync         = updateCloudSync
        self.appTheme               = prefs.appTheme
        self.appLanguage            = prefs.appLanguage
        self.unitSystem             = prefs.unitSystem
        self.vaccinationScheduleKey = VaccinationScheduleProvider.shared.activeKey.rawValue
    }

    /// Performs full GDPR erasure. On success the cleared `onboardingDone` /
    /// `paywallShown` flags (removed inside the use case's local wipe) make
    /// `ContentView` reroute back to onboarding automatically.
    func requestAccountDeletion() async {
        reauthenticationError = nil
        guard accountAuth.accountDeletionProvider == nil else {
            showsDeletionReauthentication = true
            return
        }
        await deleteAllData()
    }

    func deleteAllData() async {
        guard !isDeleting else { return }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await deleteAccount.execute()
        } catch AuthError.reauthRequired {
            showsDeletionReauthentication = true
        } catch {
            deletionError = error.localizedDescription
        }
    }

    var accountDeletionProvider: AccountDeletionProvider? {
        accountAuth.accountDeletionProvider
    }

    func prepareAppleDeletion(_ request: ASAuthorizationAppleIDRequest) {
        accountAuth.prepareAppleDeletionRequest(request)
    }

    func completeAppleDeletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let error) = result,
           (error as? ASAuthorizationError)?.code == .canceled {
            return
        }
        reauthenticate {
            try await self.accountAuth.reauthenticateForDeletionWithApple(result)
        }
    }

    func reauthenticateDeletionWithGoogle() {
        reauthenticate {
            try await self.accountAuth.reauthenticateForDeletionWithGoogle()
        }
    }

    func setTheme(_ id: String) {
        withAnimation(.spring(response: 0.3)) { appTheme = id }
    }

    func setUnitSystem(_ id: String) {
        withAnimation(.spring(response: 0.3)) { unitSystem = id }
    }

    func setCloudSyncEnabled(_ enabled: Bool) {
        cloudSyncEnabled = enabled
        Task { await updateCloudSync(enabled) }
    }

    private func save() {
        repo.save(UserPreferences(appTheme: appTheme, appLanguage: appLanguage, unitSystem: unitSystem))
    }

    private func reauthenticate(_ operation: @escaping () async throws -> Void) {
        guard !isReauthenticating else { return }
        isReauthenticating = true
        reauthenticationError = nil
        Task {
            do {
                try await operation()
                if accountAuth.accountDeletionProvider == nil {
                    showsDeletionReauthentication = false
                    await deleteAllData()
                }
            } catch {
                reauthenticationError = error
            }
            isReauthenticating = false
        }
    }
}
