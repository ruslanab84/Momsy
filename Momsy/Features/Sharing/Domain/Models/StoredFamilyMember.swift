import Foundation

struct StoredFamilyMember: Identifiable, Codable {
    var id: UUID
    var name: String
    var roleRaw: String  // FamilyRole.rawValue
    var isMe: Bool
    var inviteEmail: String?

    init(id: UUID = UUID(), name: String, roleRaw: String,
         isMe: Bool = false, inviteEmail: String? = nil) {
        self.id = id
        self.name = name
        self.roleRaw = roleRaw
        self.isMe = isMe
        self.inviteEmail = inviteEmail
    }
}
