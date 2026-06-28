import SwiftUI
import Combine
import AuthenticationServices

enum OBStep: Int, CaseIterable {
    case age, profile, role, auth, ready
}

@MainActor
final class OnboardingViewModel: ObservableObject {
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

    let authManager: AuthManager

    private let saveBabyProfileUC: SaveBabyProfileUseCase
    private let appState: AppState
    private let analytics: any AnalyticsServiceProtocol
    private let pushNotifications: any PushNotificationServiceProtocol
    private let syncRepo: any BabySyncRepositoryProtocol
    private let recoverPendingAccountDeletion: @MainActor () async -> Bool
    private let onDone: () -> Void

    init(saveBabyProfile: SaveBabyProfileUseCase,
         appState: AppState,
         authManager: AuthManager,
         syncRepo: any BabySyncRepositoryProtocol,
         analytics: any AnalyticsServiceProtocol = LogAnalyticsService(),
         pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared,
         recoverPendingAccountDeletion: @MainActor @escaping () async -> Bool = { false },
         onDone: @escaping () -> Void) {
        self.saveBabyProfileUC = saveBabyProfile
        self.appState = appState
        self.authManager = authManager
        self.syncRepo = syncRepo
        self.analytics = analytics
        self.pushNotifications = pushNotifications
        self.recoverPendingAccountDeletion = recoverPendingAccountDeletion
        self.onDone = onDone
    }

    var canContinue: Bool {
        step == .profile ? !babyName.trimmingCharacters(in: .whitespaces).isEmpty : true
    }

    var stepColor: Color {
        switch step {
        case .age:     return .bbCoral
        case .profile: return .bbMint
        case .role:    return .bbLilac
        case .auth:    return .bbSky
        case .ready:   return .bbButter
        }
    }

    func advance() {
        guard canContinue else { return }
        forward = true
        let all = OBStep.allCases
        if let idx = all.firstIndex(of: step), idx + 1 < all.count {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = all[idx + 1]
            }
        }
    }

    func goBack() {
        forward = false
        let all = OBStep.allCases
        if let idx = all.firstIndex(of: step), idx > 0 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = all[idx - 1]
            }
        }
    }

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        isSigningIn = true
        authError = nil
        Task {
            do {
                try await authManager.handleAppleCompletion(result)
                if await finishPendingAccountDeletionIfNeeded() { return }
                advance()
            } catch let error as ASAuthorizationError where error.code == .canceled {
                // User cancelled — no error shown
            } catch let asError as ASAuthorizationError where asError.code == .unknown {
                // Error 1000 — Apple ID not signed in on device / Simulator
                authError = AuthError.appleSignInUnavailable
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
                if await finishPendingAccountDeletionIfNeeded() { return }
                advance()
            } catch {
                authError = error
            }
            isSigningIn = false
        }
    }

    func skipAuth() { advance() }

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
        let name = babyName.trimmingCharacters(in: .whitespaces)
        let profile = BabyProfile(name: name, birthDate: birthDate, stage: selectedStage.rawValue, gender: babyGender)
        analytics.track(.onboardingComplete)
        pushNotifications.scheduleMorningDiary(hour: 9, minute: 0)
        Task {
            try? await saveBabyProfileUC.execute(profile)
            appState.update(profile)
            // Push to Firestore so a signed-in user's baby shows up in the cloud
            // immediately (otherwise it only lands on the next launch sync).
            try? await syncRepo.syncBabyProfile(profile)
            onDone()
        }
    }
}
