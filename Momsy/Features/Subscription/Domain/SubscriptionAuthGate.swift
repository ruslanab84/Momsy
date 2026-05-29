import Foundation

/// Call before presenting the paywall. Returns false when the user must sign in first.
/// The caller should present an auth sheet, then retry after sign-in succeeds.
struct SubscriptionAuthGate {
    static func canProceed(authManager: AuthManager) -> Bool {
        authManager.isSignedIn
    }
}
