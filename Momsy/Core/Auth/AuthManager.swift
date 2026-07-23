import Foundation
import Combine
import os
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit
#if canImport(GoogleSignIn)
import UIKit
import GoogleSignIn
#endif

enum AuthError: LocalizedError {
    case tokenMissing
    case notImplemented
    case appleSignInUnavailable
    case reauthRequired
    case accountDeletionPending
    case accountDeletionFinished
    case nonceGenerationFailed
    case anonymousSignInRestricted
    case providerAccountConflict

    var errorDescription: String? {
        switch self {
        case .tokenMissing:          return "Apple Sign-In failed. Please try again."
        case .notImplemented:        return "Google Sign-In is coming soon."
        case .appleSignInUnavailable: return "To use Sign in with Apple, open Settings → [Your Name] and sign in with your Apple ID."
        case .reauthRequired:        return "Please sign in again to delete your account."
        case .accountDeletionPending: return "Previous account deletion is still finishing. Please try again."
        case .accountDeletionFinished: return "Previous account deletion finished. Please sign in again."
        case .nonceGenerationFailed: return "Could not start Sign in with Apple. Please try again."
        case .anonymousSignInRestricted: return "Sign in with Apple or Google before creating or joining a family."
        case .providerAccountConflict: return "This email is already linked to a different sign-in method. Use the provider you originally signed in with."
        }
    }
}

final class AuthManager: ObservableObject {
    @Published private(set) var firebaseUser: FirebaseAuth.User?

    /// A user is "really" signed in only with a provider account. An anonymous
    /// user exists purely to give the device a stable uid/familyId for sync.
    var isSignedIn: Bool { firebaseUser != nil && firebaseUser?.isAnonymous == false }

    private(set) var currentNonce: String?
    private var appleRequestPreparationError: Error?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "Auth")

    init() {
        installStateListenerIfPossible()
    }

    private func installStateListenerIfPossible() {
        guard FirebaseApp.app() != nil else { return }
        guard authStateHandle == nil else { return }
        firebaseUser = Auth.auth().currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.firebaseUser = user
            if let user {
                Task { @MainActor in
                    if UserDefaultsPendingAccountDeletionStore().loadPending() == user.uid {
                        AuthManager.log.info("Skipping family setup while account deletion is pending")
                        return
                    }
                    FamilyManager.shared.resetStaleCacheIfNeeded(for: user.uid)
                    if Self.shouldDeferAutomaticFamilySetup(defaults: .standard) {
                        AuthManager.log.info("Deferring family setup while onboarding invite join is pending")
                        return
                    }
                    let name = AccountDisplay.memberName(displayName: user.displayName, email: user.email)
                    do {
                        try await FamilyManager.shared.setup(uid: user.uid, displayName: name)
                    } catch {
                        // Don't fail silently — a denied write here (rules/permissions)
                        // means the user/family/baby never reach Firestore.
                        AuthManager.log.error("FamilyManager.setup failed: \(error.localizedDescription, privacy: .public)")
                    }
                }
            } else {
                Task { @MainActor in FamilyManager.shared.reset() }
            }
        }
    }

    @MainActor
    static func shouldDeferAutomaticFamilySetup(defaults: UserDefaults) -> Bool {
        guard !defaults.bool(forKey: "onboardingDone") else { return false }
        return PendingFamilyInviteStore(defaults: defaults).load() != nil
    }

    // MARK: — Anonymous fallback

    /// Ensures a Firebase user always exists so the device has a stable uid and a
    /// `familyId` for Firestore sync — even before the user signs in with a provider.
    /// CloudKit previously gave login-free cross-device sync; anonymous auth restores
    /// that guarantee now that Firebase is the single backend.
    @MainActor
    func signInAnonymouslyIfNeeded() async {
        try? await requireAnonymousSignInIfNeeded()
    }

    @MainActor
    func requireAnonymousSignInIfNeeded() async throws {
        installStateListenerIfPossible()
        guard FirebaseApp.app() != nil else { return }
        guard Auth.auth().currentUser == nil else {
            firebaseUser = Auth.auth().currentUser
            return
        }
        do {
            let result = try await Auth.auth().signInAnonymously()
            firebaseUser = result.user
        } catch {
            AuthManager.log.error("Anonymous sign-in failed: \(error.localizedDescription, privacy: .public)")
            throw normalizedAnonymousSignInError(error)
        }
    }

    private func normalizedAnonymousSignInError(_ error: Error) -> Error {
        let nsError = error as NSError
        if nsError.code == AuthErrorCode.adminRestrictedOperation.rawValue ||
            nsError.code == AuthErrorCode.operationNotAllowed.rawValue ||
            nsError.localizedDescription.localizedCaseInsensitiveContains("restricted to administrators") {
            return AuthError.anonymousSignInRestricted
        }
        return error
    }

    /// Promotes the current (possibly anonymous) user to a provider credential.
    /// Linking preserves the existing uid → `familyId` → data; a fresh sign-in would
    /// orphan anything logged anonymously. Falls back to a plain sign-in when the
    /// credential already belongs to another account (that account's data is then
    /// adopted on next launch via CloudSyncDownloader).
    nonisolated static func fallbackCredential(
        original: AuthCredential,
        linkError: NSError
    ) -> AuthCredential {
        (linkError.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential) ?? original
    }

    @MainActor
    private func linkOrSignIn(with credential: AuthCredential) async throws -> FirebaseAuth.User {
        if let current = Auth.auth().currentUser, current.isAnonymous {
            let anonymousUid = current.uid
            let cachedFamilyId = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey)
            do {
                return try await current.link(with: credential).user
            } catch let error as NSError where error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                let fallback = Self.fallbackCredential(original: credential, linkError: error)
                let user = try await Auth.auth().signIn(with: fallback).user
                Task { @MainActor in
                    await FamilyManager.shared.removeStaleAnonymousMemberIfNeeded(
                        anonymousUid: anonymousUid,
                        signedInUid: user.uid,
                        familyId: cachedFamilyId
                    )
                }
                return user
            } catch let error as NSError where error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                throw AuthError.providerAccountConflict
            }
        }
        return try await Auth.auth().signIn(with: credential).user
    }

    // MARK: — Apple Sign-In

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        currentNonce = nil
        appleRequestPreparationError = nil
        request.requestedScopes = [.fullName, .email]

        do {
            let nonce = try randomNonceString()
            currentNonce = nonce
            request.nonce = sha256(nonce)
        } catch {
            appleRequestPreparationError = error
            AuthManager.log.error("Apple nonce generation failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    @MainActor
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws {
        installStateListenerIfPossible()
        defer {
            currentNonce = nil
            appleRequestPreparationError = nil
        }
        let auth = try result.get()
        if let appleRequestPreparationError {
            throw appleRequestPreparationError
        }
        guard
            let cred = auth.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = cred.identityToken,
            let token = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else { throw AuthError.tokenMissing }

        let credential = OAuthProvider.appleCredential(
            withIDToken: token,
            rawNonce: nonce,
            fullName: cred.fullName
        )
        let user = try await linkOrSignIn(with: credential)
        await adoptAppleFullNameIfNeeded(cred.fullName, for: user)
        firebaseUser = user
    }

    /// `link(with:)` (the anonymous-promotion path) does not propagate the Apple
    /// credential's fullName into Firebase `displayName`, and Apple only supplies it
    /// on the first authorization — persist it here or lose it forever.
    @MainActor
    private func adoptAppleFullNameIfNeeded(_ components: PersonNameComponents?,
                                            for user: FirebaseAuth.User) async {
        guard (user.displayName ?? "").isEmpty, let components else { return }
        let name = PersonNameComponentsFormatter.localizedString(from: components, style: .default)
            .trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let change = user.createProfileChangeRequest()
        change.displayName = name
        do {
            try await change.commitChanges()
        } catch {
            AuthManager.log.error("displayName commit failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: — Google Sign-In

    @MainActor
    func signInWithGoogle() async throws {
        installStateListenerIfPossible()
#if canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.tokenMissing
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else { throw AuthError.tokenMissing }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.tokenMissing
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        firebaseUser = try await linkOrSignIn(with: credential)
#else
        throw AuthError.notImplemented
#endif
    }

    // MARK: — Sign out

    @MainActor
    func signOut() throws {
        installStateListenerIfPossible()
        try Auth.auth().signOut()
        firebaseUser = nil
    }

    // MARK: — Account deletion (GDPR)

    /// Deletes the Firebase Auth account. Anonymous users delete cleanly; a provider
    /// account that hasn't authenticated recently throws `requiresRecentLogin`, which
    /// we surface as `.reauthRequired` so the caller can fall back to `signOut()`.
    @MainActor
    func deleteAccount() async throws {
        installStateListenerIfPossible()
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.delete()
            firebaseUser = nil
        } catch let error as NSError where error.code == AuthErrorCode.requiresRecentLogin.rawValue {
            throw AuthError.reauthRequired
        }
    }

    // MARK: — Helpers

    private func randomNonceString(length: Int = 32) throws -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard errorCode == errSecSuccess else {
            throw AuthError.nonceGenerationFailed
        }
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
