import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit

enum AuthError: LocalizedError {
    case tokenMissing
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .tokenMissing:   return "Apple Sign-In failed. Please try again."
        case .notImplemented: return "Google Sign-In is coming soon."
        }
    }
}

final class AuthManager: ObservableObject {
    @Published private(set) var firebaseUser: FirebaseAuth.User?

    var isSignedIn: Bool { firebaseUser != nil }

    private(set) var currentNonce: String?

    init() {
        guard FirebaseApp.app() != nil else { return }
        firebaseUser = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.firebaseUser = user
            if let user {
                Task { @MainActor in
                    let name = user.displayName ?? user.email ?? "User"
                    try? await FamilyManager.shared.setup(uid: user.uid, displayName: name)
                }
            } else {
                Task { @MainActor in FamilyManager.shared.reset() }
            }
        }
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
        let authResult = try await Auth.auth().signIn(with: credential)
        firebaseUser = authResult.user
    }

    // MARK: — Google Sign-In
    // To enable: add GoogleSignIn-iOS SPM package (https://github.com/google/GoogleSignIn-iOS),
    // enable Google Sign-In in Firebase Console, and add the reversed client ID URL scheme to Info.plist.

    @MainActor
    func signInWithGoogle() async throws {
        throw AuthError.notImplemented
    }

    // MARK: — Sign out

    @MainActor
    func signOut() throws {
        try Auth.auth().signOut()
        firebaseUser = nil
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
