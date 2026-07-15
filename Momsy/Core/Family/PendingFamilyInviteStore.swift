import Foundation

extension Notification.Name {
    static let pendingFamilyInviteDidChange = Notification.Name("pendingFamilyInviteDidChange")
}

@MainActor
struct PendingFamilyInviteStore {
    static let codeKey = "pending_family_invite_code_v1"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> String? {
        defaults.string(forKey: Self.codeKey).flatMap(JoinDeeplink.normalize(rawCode:))
    }

    func save(_ rawCode: String) {
        guard let code = JoinDeeplink.normalize(rawCode: rawCode) else { return }
        guard defaults.string(forKey: Self.codeKey) != code else { return }
        defaults.set(code, forKey: Self.codeKey)
        NotificationCenter.default.post(name: .pendingFamilyInviteDidChange, object: nil)
    }

    func clear() {
        guard defaults.string(forKey: Self.codeKey) != nil else { return }
        defaults.removeObject(forKey: Self.codeKey)
        NotificationCenter.default.post(name: .pendingFamilyInviteDidChange, object: nil)
    }
}
