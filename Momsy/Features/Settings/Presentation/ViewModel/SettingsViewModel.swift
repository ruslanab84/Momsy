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
    /// Active child's schedule (stored choice, else auto-detected). Optimistic: set
    /// before the save completes and rolled back if it fails.
    @Published private(set) var scheduleKey: VaccinationScheduleKey = .who
    @Published var scheduleError: Error?

    @Published private(set) var isDeleting = false
    @Published private(set) var isReauthenticating = false
    @Published var showsDeletionReauthentication = false
    @Published var reauthenticationError: Error?
    @Published var deletionError: String?
    @Published var cloudSyncError: Error?
    @Published private(set) var cloudSyncEnabled: Bool

    private let repo: any UserPreferencesRepository
    private let deleteAccount: DeleteAccountUseCase
    private let accountAuth: any AccountDeletionAuthenticating
    private let updateCloudSync: @MainActor (Bool) async throws -> Void
    private let activeBaby: @MainActor () -> BabyProfile?
    private let updateBaby: @MainActor (BabyProfile) async throws -> Void
    private let canEditBaby: @MainActor () -> Bool
    private let accessState: @MainActor () -> PremiumAccessState
    private let cancelVaccinationReminders: @MainActor ([Int]) -> Void
    private let scheduleResolver: any VaccinationScheduleResolving

    init(
        repo: any UserPreferencesRepository,
        deleteAccount: DeleteAccountUseCase,
        accountAuth: any AccountDeletionAuthenticating,
        cloudSyncEnabled: Bool = CloudSyncConsent.isGranted(),
        updateCloudSync: @MainActor @escaping (Bool) async throws -> Void = {
            CloudSyncConsent.set($0 ? .granted : .denied)
        },
        activeBaby: @MainActor @escaping () -> BabyProfile? = { nil },
        updateBaby: @MainActor @escaping (BabyProfile) async throws -> Void = { _ in },
        canEditBaby: @MainActor @escaping () -> Bool = { false },
        accessState: @MainActor @escaping () -> PremiumAccessState = { .resolving },
        cancelVaccinationReminders: @MainActor @escaping ([Int]) -> Void = { _ in },
        scheduleResolver: (any VaccinationScheduleResolving)? = nil
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
        self.activeBaby             = activeBaby
        self.updateBaby             = updateBaby
        self.canEditBaby            = canEditBaby
        self.accessState            = accessState
        self.cancelVaccinationReminders = cancelVaccinationReminders
        self.scheduleResolver       = scheduleResolver ?? VaccinationScheduleResolver()
        reloadSchedule()
    }

    // MARK: - Vaccination schedule (per child)

    var availableScheduleKeys: [VaccinationScheduleKey] { scheduleResolver.availableKeys }
    var scheduleSourceID: MedicalSourceID { definition(for: scheduleKey).sourceID }
    var canEditSchedule: Bool { canEditBaby() && activeBaby() != nil }
    var scheduleAccess: PremiumAccessState { accessState() }
    var activeChildName: String { activeBaby()?.name ?? "" }

    /// Re-read after a child switch or a co-parent change arriving via sync.
    func reloadSchedule() {
        scheduleKey = scheduleResolver.definition(for: activeBaby()).key
    }

    func selectSchedule(_ key: VaccinationScheduleKey) async {
        // Defence in depth — the view already blocks these paths.
        guard accessState() == .premium, canEditBaby(), var baby = activeBaby(),
              key != scheduleKey else { return }
        let previous = definition(for: scheduleKey)
        scheduleKey = key
        scheduleError = nil
        baby.vaccinationScheduleKey = key.rawValue
        do {
            try await updateBaby(baby)
            cancelVaccinationReminders(previous.items.map(\.id))
        } catch {
            scheduleKey = previous.key
            scheduleError = error
        }
    }

    private func definition(for key: VaccinationScheduleKey) -> VaccinationScheduleDefinition {
        scheduleResolver.definition(for: BabyProfile(vaccinationScheduleKey: key.rawValue))
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
        let previousValue = cloudSyncEnabled
        cloudSyncEnabled = enabled
        cloudSyncError = nil
        Task {
            do {
                try await updateCloudSync(enabled)
            } catch {
                cloudSyncEnabled = previousValue
                cloudSyncError = error
            }
        }
    }

    private func save() {
        var prefs = repo.load()
        prefs.appTheme = appTheme
        prefs.appLanguage = appLanguage
        prefs.unitSystem = unitSystem
        repo.save(prefs)
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
