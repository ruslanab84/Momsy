import Foundation

/// The slice of auth the manual join flow needs. Mirrors the deep-link path
/// (`joinFamilyFromLink`), which self-heals a missing session by signing in
/// anonymously before joining. `AuthManager` conforms; tests use a mock.
@MainActor
protocol JoinAuthProviding: AnyObject {
    var currentUID: String? { get }
    func requireAnonymousSignInIfNeeded() async throws
}

extension AuthManager: JoinAuthProviding {}
