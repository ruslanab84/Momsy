import SwiftUI
import Combine
import AuthenticationServices

enum OBStep: Int, CaseIterable, Equatable {
    case join, age, profile, role, invite, auth, ready
}

enum OnboardingFlow: Equatable {
    case createProfile
    case joinFamily
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var flow: OnboardingFlow = .createProfile
    @Published var step: OBStep = .age
    @Published var forward = true
    @Published var selectedStage: BabyAgeStage = .baby
    @Published var babyName = ""
    @Published var birthDate: Date = {
        Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date()
    }()
    @Published var babyGender = ""
    @Published var parentName = ""
    @Published var parentRole = "mom"
    @Published var isSigningIn = false
    @Published var authError: Error?
    @Published var selectedInviteRole: FamilyRole = .dad
    @Published private(set) var inviteCode = ""
    @Published private(set) var inviteURL = ""
    @Published private(set) var inviteExpiry = Date()
    @Published private(set) var isPreparingInvite = false
    @Published var inviteError: Error?
    @Published var pendingInviteCode = ""
    @Published var showJoinConfirm = false

    let authManager: AuthManager

    private let saveBabyProfileUC: SaveBabyProfileUseCase
    private let appState: AppState
    private let analytics: any AnalyticsServiceProtocol
    private let pushNotifications: any PushNotificationServiceProtocol
    private let syncRepo: any BabySyncRepositoryProtocol
    private let inviteService: any InviteServiceProtocol
    private let pendingInviteStore: PendingFamilyInviteStore
    private let ensureFamilyReady: @MainActor (_ displayName: String) async throws -> Void
    private let joinFamily: @MainActor (_ code: String, _ force: Bool) async throws -> Void
    private let syncAfterJoiningFamily: @MainActor () async -> Void
    private let recoverPendingAccountDeletion: @MainActor () async -> Bool
    private let onDone: () -> Void
    private var savedProfile: BabyProfile?
    private var hasSyncedSavedProfile = false

    init(saveBabyProfile: SaveBabyProfileUseCase,
         appState: AppState,
         authManager: AuthManager,
         syncRepo: any BabySyncRepositoryProtocol,
         inviteService: any InviteServiceProtocol,
         pendingInviteStore: PendingFamilyInviteStore,
         ensureFamilyReady: @MainActor @escaping (_ displayName: String) async throws -> Void,
         joinFamily: @MainActor @escaping (_ code: String, _ force: Bool) async throws -> Void,
         syncAfterJoiningFamily: @MainActor @escaping () async -> Void,
         analytics: any AnalyticsServiceProtocol,
         pushNotifications: any PushNotificationServiceProtocol,
         recoverPendingAccountDeletion: @MainActor @escaping () async -> Bool = { false },
         onDone: @escaping () -> Void) {
        self.saveBabyProfileUC = saveBabyProfile
        self.appState = appState
        self.authManager = authManager
        self.syncRepo = syncRepo
        self.inviteService = inviteService
        self.pendingInviteStore = pendingInviteStore
        self.ensureFamilyReady = ensureFamilyReady
        self.joinFamily = joinFamily
        self.syncAfterJoiningFamily = syncAfterJoiningFamily
        self.analytics = analytics
        self.pushNotifications = pushNotifications
        self.recoverPendingAccountDeletion = recoverPendingAccountDeletion
        self.onDone = onDone

        if let code = pendingInviteStore.load() {
            flow = .joinFamily
            step = .join
            pendingInviteCode = code
        }
    }

    var steps: [OBStep] {
        switch flow {
        case .createProfile:
            return [.age, .profile, .role, .invite, .auth, .ready]
        case .joinFamily:
            return [.join, .auth, .ready]
        }
    }

    var currentStepNumber: Int {
        (steps.firstIndex(of: step) ?? 0) + 1
    }

    var canContinue: Bool {
        switch step {
        case .profile:
            return !babyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .join:
            return JoinDeeplink.normalize(rawCode: pendingInviteCode) != nil
        default:
            return true
        }
    }

    var stepColor: Color {
        switch step {
        case .join:    return .bbSky
        case .age:     return .bbCoral
        case .profile: return .bbMint
        case .role:    return .bbLilac
        case .invite:  return .bbRose
        case .auth:    return .bbSky
        case .ready:   return .bbButter
        }
    }

    var readyBabyName: String {
        switch flow {
        case .createProfile:
            return babyName
        case .joinFamily:
            return appState.displayName
        }
    }

    var readyBirthDate: Date {
        appState.babyProfile?.birthDate ?? birthDate
    }

    var readyStage: BabyAgeStage {
        if flow == .joinFamily,
           let raw = appState.babyProfile?.stage,
           let stage = BabyAgeStage(rawValue: raw) {
            return stage
        }
        return selectedStage
    }

    var isJoinFlow: Bool { flow == .joinFamily }

    func advance() {
        guard canContinue else { return }
        if step == .join {
            guard persistPendingInviteForAuth() else { return }
        }
        forward = true
        if let idx = steps.firstIndex(of: step), idx + 1 < steps.count {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = steps[idx + 1]
            }
        }
    }

    func goBack() {
        forward = false
        if let idx = steps.firstIndex(of: step), idx > 0 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = steps[idx - 1]
            }
        }
    }

    func startJoinFlow(code: String? = nil) {
        let resolved = code.flatMap(JoinDeeplink.normalize(rawCode:)) ?? pendingInviteStore.load()
        if let resolved {
            if pendingInviteStore.load() != resolved {
                pendingInviteStore.save(resolved)
            }
            pendingInviteCode = resolved
        }
        flow = .joinFamily
        forward = true
        authError = nil
        inviteError = nil
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            step = .join
        }
    }

    func startCreateFlow() {
        pendingInviteStore.clear()
        pendingInviteCode = ""
        flow = .createProfile
        forward = false
        authError = nil
        inviteError = nil
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            step = .age
        }
    }

    func loadPendingInviteIfNeeded() {
        guard let code = pendingInviteStore.load() else { return }
        startJoinFlow(code: code)
    }

    func skipInvite() {
        advance()
    }

    func prepareInvite() async {
        await prepareInvite(regenerate: false)
    }

    func regenerateInvite() async {
        await prepareInvite(regenerate: true)
    }

    func updateInviteRole(_ role: FamilyRole) {
        selectedInviteRole = role
        guard !inviteCode.isEmpty else { return }
        Task {
            do {
                try await inviteService.updateInviteRole(code: inviteCode, role: role)
            } catch {
                inviteError = error
            }
        }
    }

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        isSigningIn = true
        authError = nil
        Task {
            do {
                try await authManager.handleAppleCompletion(result)
                if await finishPendingAccountDeletionIfNeeded() {
                    isSigningIn = false
                    return
                }
                try await continueAfterAuth()
            } catch let error as ASAuthorizationError where error.code == .canceled {
                // User cancelled — no error shown
            } catch let asError as ASAuthorizationError where asError.code == .unknown {
                // Error 1000 — Apple ID not signed in on device / Simulator
                authError = AuthError.appleSignInUnavailable
            } catch FamilyError.wouldAbandonExistingFamily {
                showJoinConfirm = true
            } catch {
                authError = error
            }
            isSigningIn = false
        }
    }

    func signInWithGoogle() {
        isSigningIn = true
        authError = nil
        Task {
            do {
                try await authManager.signInWithGoogle()
                if await finishPendingAccountDeletionIfNeeded() {
                    isSigningIn = false
                    return
                }
                try await continueAfterAuth()
            } catch FamilyError.wouldAbandonExistingFamily {
                showJoinConfirm = true
            } catch {
                authError = error
            }
            isSigningIn = false
        }
    }

    func skipAuth() {
        guard flow == .createProfile else { return }
        advance()
    }

    func confirmJoinReplacingFamily() {
        guard flow == .joinFamily else { return }
        showJoinConfirm = false
        isSigningIn = true
        authError = nil
        Task {
            do {
                try await joinPendingFamily(force: true)
                advance()
            } catch {
                authError = error
            }
            isSigningIn = false
        }
    }

    private func finishPendingAccountDeletionIfNeeded() async -> Bool {
        guard
            let uid = authManager.currentUID,
            UserDefaultsPendingAccountDeletionStore().loadPending() == uid
        else { return false }

        let stillPending = await recoverPendingAccountDeletion()
        authError = stillPending ? AuthError.accountDeletionPending : AuthError.accountDeletionFinished
        return true
    }

    func finish() {
        analytics.track(.onboardingComplete)
        pushNotifications.scheduleMorningDiary(hour: 9, minute: 0)
        guard flow == .createProfile else {
            pendingInviteStore.clear()
            onDone()
            return
        }
        Task {
            let profile = try? await saveBabyProfileLocallyIfNeeded()
            try? await ensureFamilyReady(familyDisplayName)
            if let profile, !hasSyncedSavedProfile {
                try? await syncRepo.syncBabyProfile(profile)
                hasSyncedSavedProfile = true
            }
            onDone()
        }
    }

    private func continueAfterAuth() async throws {
        switch flow {
        case .createProfile:
            advance()
        case .joinFamily:
            try await joinPendingFamily(force: false)
            advance()
        }
    }

    private func joinPendingFamily(force: Bool) async throws {
        guard let code = JoinDeeplink.normalize(rawCode: pendingInviteCode) else {
            throw FamilyError.invalidOrExpiredCode
        }
        pendingInviteCode = code
        try await joinFamily(code, force)
        pendingInviteStore.clear()
        await syncAfterJoiningFamily()
        await appState.load()
    }

    private func persistPendingInviteForAuth() -> Bool {
        guard let code = JoinDeeplink.normalize(rawCode: pendingInviteCode) else { return false }
        pendingInviteCode = code
        if pendingInviteStore.load() != code {
            pendingInviteStore.save(code)
        }
        return true
    }

    private func prepareInvite(regenerate: Bool) async {
        guard !isPreparingInvite else { return }
        isPreparingInvite = true
        inviteError = nil
        do {
            let profile = try await saveBabyProfileLocallyIfNeeded()
            try await ensureFamilyReady(familyDisplayName)
            if !hasSyncedSavedProfile {
                try await syncRepo.syncBabyProfile(profile)
                hasSyncedSavedProfile = true
            }

            let code = regenerate
                ? try await inviteService.regenerateAndSync()
                : try await inviteService.prepareInvite()
            try await inviteService.updateInviteRole(code: code, role: selectedInviteRole)
            inviteCode = code
            inviteURL = inviteService.inviteURL(for: code)
            inviteExpiry = inviteService.expiry()
        } catch {
            inviteError = error
        }
        isPreparingInvite = false
    }

    private func saveBabyProfileLocallyIfNeeded() async throws -> BabyProfile {
        if let savedProfile { return savedProfile }
        let name = babyName.trimmingCharacters(in: .whitespacesAndNewlines)
        let profile = BabyProfile(
            name: name,
            birthDate: birthDate,
            stage: selectedStage.rawValue,
            gender: babyGender
        )
        try await saveBabyProfileUC.execute(profile)
        appState.update(profile)
        savedProfile = profile
        return profile
    }

    private var familyDisplayName: String {
        let trimmedParent = parentName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedParent.isEmpty { return trimmedParent }
        return "User"
    }
}
