import Foundation

final class LocalInviteService: InviteServiceProtocol, @unchecked Sendable {
    private let codeKey   = "invite_code"
    private let expiryKey = "invite_expiry"
    private let ttl: TimeInterval = 24 * 60 * 60

    func currentCode() -> String {
        if let code = UserDefaults.standard.string(forKey: codeKey),
           let exp  = UserDefaults.standard.object(forKey: expiryKey) as? Date,
           exp > Date() {
            return code
        }
        return regenerate()
    }

    func inviteURL(for code: String) -> String {
        "momsy://join?code=\(code)"
    }

    func expiry() -> Date {
        (UserDefaults.standard.object(forKey: expiryKey) as? Date) ?? Date()
    }

    @discardableResult
    func regenerate() -> String {
        let code = "MOMSY-\(String(format: "%04d", Int.random(in: 1000...9999)))"
        UserDefaults.standard.set(code, forKey: codeKey)
        UserDefaults.standard.set(Date().addingTimeInterval(ttl), forKey: expiryKey)
        return code
    }

    @discardableResult
    func prepareInvite() async throws -> String {
        currentCode()
    }

    @discardableResult
    func regenerateAndSync() async throws -> String {
        regenerate()
    }

    func updateInviteRole(code: String, role: FamilyRole) async throws { }
}
