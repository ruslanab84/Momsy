import Foundation

protocol InviteServiceProtocol: Sendable {
    func currentCode() -> String
    func inviteURL(for code: String) -> String
    func expiry() -> Date
    func regenerate() -> String
    @discardableResult
    func prepareInvite() async throws -> String
    @discardableResult
    func regenerateAndSync() async throws -> String
    func updateInviteRole(code: String, role: FamilyRole) async throws
}
