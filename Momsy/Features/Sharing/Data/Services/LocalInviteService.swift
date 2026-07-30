import Foundation

@MainActor
final class LocalInviteService: InviteServiceProtocol, @unchecked Sendable {
    private let codeKey   = "invite_code"
    private let expiryKey = "invite_expiry"
    private let roleKey   = "invite_role"
    private let ttl: TimeInterval = 24 * 60 * 60

    func currentCode() -> String {
        if let code = UserDefaults.standard.string(forKey: codeKey),
           let exp  = UserDefaults.standard.object(forKey: expiryKey) as? Date,
           exp > Date() {
            return code
        }
        return issueLocalInvite(role: currentRole())
    }

    func currentRole() -> FamilyRole {
        UserDefaults.standard.string(forKey: roleKey)
            .flatMap(FamilyRole.init(storedRawValue:)) ?? .dad
    }

    func inviteURL(for code: String) -> String {
        "momsy://join?code=\(code)"
    }

    func expiry() -> Date {
        (UserDefaults.standard.object(forKey: expiryKey) as? Date) ?? Date()
    }

    private func issueLocalInvite(role: FamilyRole) -> String {
        // Тот же формат, что и в облачном сервисе: `FamilyManager.joinFamily`
        // валидирует код через `InviteCodeFormat` до сети и отклонит любой другой.
        let code = InviteCodeFormat.generate()
        UserDefaults.standard.set(code, forKey: codeKey)
        UserDefaults.standard.set(Date().addingTimeInterval(ttl), forKey: expiryKey)
        UserDefaults.standard.set(role.rawValue, forKey: roleKey)
        return code
    }

    @discardableResult
    func prepareInvite(defaultRole: FamilyRole) async throws -> String {
        if let code = UserDefaults.standard.string(forKey: codeKey),
           let expiry = UserDefaults.standard.object(forKey: expiryKey) as? Date,
           expiry > Date() {
            return code
        }
        return issueLocalInvite(role: defaultRole)
    }

    @discardableResult
    func issueInvite(role: FamilyRole) async throws -> String {
        issueLocalInvite(role: role)
    }
}
