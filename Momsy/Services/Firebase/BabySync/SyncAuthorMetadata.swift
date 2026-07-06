import Foundation

struct SyncAuthorIdentity: Equatable, Sendable {
    let uid: String
    let displayName: String

    nonisolated init(uid: String, displayName: String) {
        self.uid = uid.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.displayName = trimmedName.isEmpty ? "User" : trimmedName
    }
}

enum SyncAuthorMetadata {
    static let addedByKey = "addedBy"
    static let addedByNameKey = "addedByName"

    nonisolated static func requiresAuthor(in payload: [String: Any]) -> Bool {
        payload.keys.contains(addedByKey) || payload.keys.contains(addedByNameKey)
    }

    nonisolated static func stamp(_ payload: [String: Any], author: SyncAuthorIdentity?) -> [String: Any] {
        guard let author, !author.uid.isEmpty else { return payload }

        var stamped = payload
        if stamped.keys.contains(addedByKey) {
            stamped[addedByKey] = author.uid
        }
        if stamped.keys.contains(addedByNameKey) {
            stamped[addedByNameKey] = author.displayName
        }
        return stamped
    }
}

actor SyncAuthorIdentityCache {
    static let shared = SyncAuthorIdentityCache()

    private var displayNamesByFamilyAndUid: [String: String] = [:]

    func displayName(familyId: String, uid: String) -> String? {
        displayNamesByFamilyAndUid[key(familyId: familyId, uid: uid)]
    }

    func setDisplayName(_ displayName: String, familyId: String, uid: String) {
        let identity = SyncAuthorIdentity(uid: uid, displayName: displayName)
        guard !identity.uid.isEmpty else { return }
        displayNamesByFamilyAndUid[key(familyId: familyId, uid: identity.uid)] = identity.displayName
    }

    private func key(familyId: String, uid: String) -> String {
        "\(familyId)|\(uid)"
    }
}
