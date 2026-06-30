import Foundation
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

final class FirestoreFamilyRepository: FamilyRepository {
    private var db: Firestore { Firestore.firestore() }

    private func col() throws -> CollectionReference {
        guard let id = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey) else {
            throw FamilyError.noFamilyId
        }
        return db.collection("families").document(id).collection("members")
    }

    func getMembers() async throws -> [StoredFamilyMember] {
        let snap = try await col().getDocuments()
        let currentUid = Auth.auth().currentUser?.uid
        return snap.documents.compactMap {
            StoredFamilyMember(firestoreData: $0.data(), docId: $0.documentID, currentUid: currentUid)
        }
    }

    func add(_ member: StoredFamilyMember) async throws {
        let docId = member.uid ?? member.id.uuidString
        try await col().document(docId).setData(member.toFirestoreData(), merge: true)
    }

    func update(_ member: StoredFamilyMember) async throws {
        let docId = member.uid ?? member.id.uuidString
        try await col().document(docId).updateData(member.toFirestoreData())
    }

    func remove(id: UUID) async throws {
        // Try to find by id field since docId may be a Firebase uid
        let snap = try await col().whereField("id", isEqualTo: id.uuidString).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
}

extension StoredFamilyMember {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "name": name,
            "roleRaw": roleRaw,
            "isMe": isMe
        ]
        if let uid { data["uid"] = uid }
        if let email = inviteEmail { data["inviteEmail"] = email }
        return data
    }

    init?(firestoreData data: [String: Any], docId: String, currentUid: String? = nil) {
        let id = (data["id"] as? String).flatMap(UUID.init(uuidString:)) ?? Self.stableId(for: docId)
        let uid = data["uid"] as? String ?? docId
        let isCurrentUser = currentUid.map { $0 == uid || $0 == docId }
        guard let name = data["name"] as? String else { return nil }
        self.id = id
        self.name = name
        self.roleRaw = data["roleRaw"] as? String ?? FamilyRole.dad.rawValue
        self.isMe = isCurrentUser ?? (data["isMe"] as? Bool ?? false)
        self.uid = uid
        self.inviteEmail = data["inviteEmail"] as? String
    }

    private static func stableId(for value: String) -> UUID {
        let digest = SHA256.hash(data: Data(value.utf8))
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
