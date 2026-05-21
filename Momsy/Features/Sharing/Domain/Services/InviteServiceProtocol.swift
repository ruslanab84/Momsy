import Foundation

protocol InviteServiceProtocol: Sendable {
    func currentCode() -> String
    func inviteURL(for code: String) -> String
    func expiry() -> Date
    func regenerate() -> String
}
