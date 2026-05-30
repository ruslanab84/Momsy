import Foundation
import Combine
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

    var errorDescription: String? {
        switch self {
        case .tokenMissing:          return "Apple Sign-In failed. Please try again."
        case .notImplemented:        return "Google Sign-In is coming soon."
        case .appleSignInUnavailable: return "To use Sign in with Apple, open Settings → [Your Name] and sign in with your Apple ID."
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
        let authResult = try await Auth.auth().signIn(with: credential)
        firebaseUser = authResult.user
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
