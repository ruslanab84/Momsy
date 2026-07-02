import Foundation

struct StoredFamilyMember: Identifiable, Codable {
    var id: UUID
    var name: String
    var roleRaw: String  // FamilyRole.rawValue
    var isMe: Bool
    var uid: String?        // Firebase Auth UID (Firestore document key)
    var inviteEmail: String?
    var documentId: String?

    init(id: UUID = UUID(), name: String, roleRaw: String,
         isMe: Bool = false, uid: String? = nil, inviteEmail: String? = nil,
         documentId: String? = nil) {
        self.id = id
        self.name = name
        self.roleRaw = roleRaw
        self.isMe = isMe
        self.uid = uid
        self.inviteEmail = inviteEmail
        self.documentId = documentId
    }
}
