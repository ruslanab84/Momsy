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

    var errorDescription: String? {
        switch self {
        case .tokenMissing:          return "Apple Sign-In failed. Please try again."
        case .notImplemented:        return "Google Sign-In is coming soon."
        case .appleSignInUnavailable: return "To use Sign in with Apple, open Settings → [Your Name] and sign in with your Apple ID."
        case .reauthRequired:        return "Please sign in again to delete your account."
        }
    }
}

final class AuthManager: ObservableObject {
    @Published private(set) var firebaseUser: FirebaseAuth.User?

    /// A user is "really" signed in only with a provider account. An anonymous
    /// user exists purely to give the device a stable uid/familyId for sync.
    var isSignedIn: Bool { firebaseUser != nil && firebaseUser?.isAnonymous == false }

    private(set) var currentNonce: String?

    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "Auth")

    init() {
        guard FirebaseApp.app() != nil else { return }
        firebaseUser = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.firebaseUser = user
            if let user {
                Task { @MainActor in
                    let name = user.displayName ?? user.email ?? "User"
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

    // MARK: — Anonymous fallback

    /// Ensures a Firebase user always exists so the device has a stable uid and a
    /// `familyId` for Firestore sync — even before the user signs in with a provider.
    /// CloudKit previously gave login-free cross-device sync; anonymous auth restores
    /// that guarantee now that Firebase is the single backend.
    @MainActor
    func signInAnonymouslyIfNeeded() async {
        guard FirebaseApp.app() != nil else { return }
        guard Auth.auth().currentUser == nil else { return }
        do {
            let result = try await Auth.auth().signInAnonymously()
            firebaseUser = result.user
        } catch {
            AuthManager.log.error("Anonymous sign-in failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Promotes the current (possibly anonymous) user to a provider credential.
    /// Linking preserves the existing uid → `familyId` → data; a fresh sign-in would
    /// orphan anything logged anonymously. Falls back to a plain sign-in when the
    /// credential already belongs to another account (that account's data is then
    /// adopted on next launch via CloudSyncDownloader).
    @MainActor
    private func linkOrSignIn(with credential: AuthCredential) async throws -> FirebaseAuth.User {
        if let current = Auth.auth().currentUser, current.isAnonymous {
            do {
                return try await current.link(with: credential).user
            } catch let error as NSError where error.code == AuthErrorCode.credentialAlreadyInUse.rawValue
                || error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                // Credential belongs to an existing account → sign into it directly.
                return try await Auth.auth().signIn(with: credential).user
            }
        }
        return try await Auth.auth().signIn(with: credential).user
    }

    // MARK: — Apple Sign-In

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    @MainActor
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws {
        let auth = try result.get()
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
        firebaseUser = try await linkOrSignIn(with: credential)
    }

    // MARK: — Google Sign-In

    @MainActor
    func signInWithGoogle() async throws {
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
        try Auth.auth().signOut()
        firebaseUser = nil
    }

    // MARK: — Account deletion (GDPR)

    /// Deletes the Firebase Auth account. Anonymous users delete cleanly; a provider
    /// account that hasn't authenticated recently throws `requiresRecentLogin`, which
    /// we surface as `.reauthRequired` so the caller can fall back to `signOut()`.
    @MainActor
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.delete()
            firebaseUser = nil
        } catch let error as NSError where error.code == AuthErrorCode.requiresRecentLogin.rawValue {
            throw AuthError.reauthRequired
        }
    }

    // MARK: — Helpers

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce: \(errorCode)")
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
