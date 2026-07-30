import Foundation

@MainActor
protocol InviteServiceProtocol: Sendable {
    func currentCode() -> String
    func currentRole() -> FamilyRole
    func inviteURL(for code: String) -> String
    func expiry() -> Date
    @discardableResult
    func prepareInvite(defaultRole: FamilyRole) async throws -> String
    @discardableResult
    func issueInvite(role: FamilyRole) async throws -> String
}
