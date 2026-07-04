import Foundation
import Combine
import AuthenticationServices

/// The slice of auth the post-onboarding sign-in sheet needs.
/// `AuthManager` conforms; tests use a mock.
@MainActor
protocol AccountAuthProviding: AnyObject {
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest)
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws
    func signInWithGoogle() async throws
}

extension AuthManager: AccountAuthProviding {}

@MainActor
final class AccountAuthViewModel: ObservableObject {
    @Published private(set) var isSigningIn = false
    @Published private(set) var authError: Error?
    @Published private(set) var didSignIn = false

    private let auth: any AccountAuthProviding
    private let onSignedIn: () async -> Void

    init(auth: any AccountAuthProviding, onSignedIn: @escaping () async -> Void) {
        self.auth = auth
        self.onSignedIn = onSignedIn
    }

    func prepareApple(_ request: ASAuthorizationAppleIDRequest) {
        auth.prepareAppleRequest(request)
    }

    func completeApple(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let error) = result,
           (error as? ASAuthorizationError)?.code == .canceled {
            return
        }
        run { try await self.auth.handleAppleCompletion(result) }
    }

    func signInWithGoogle() {
        run { try await self.auth.signInWithGoogle() }
    }

    private func run(_ op: @escaping () async throws -> Void) {
        guard !isSigningIn else { return }
        isSigningIn = true
        authError = nil
        Task {
            do {
                try await op()
                await onSignedIn()
                didSignIn = true
            } catch {
                authError = error
            }
            isSigningIn = false
        }
    }
}
