import Foundation

/// Presentation rules for the signed-in account identity. A "Hide My Email" relay
/// address is valid auth data but must never surface as a user-facing name.
enum AccountDisplay {
    static func isPrivateRelay(_ email: String) -> Bool {
        email.lowercased().hasSuffix("@privaterelay.appleid.com")
    }

    /// Display name for family member docs and sync-author metadata.
    static func memberName(displayName: String?, email: String?, fallback: String = "User") -> String {
        if let displayName, !displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            return displayName
        }
        if let email, !email.isEmpty, !isPrivateRelay(email) {
            return email
        }
        return fallback
    }
}
