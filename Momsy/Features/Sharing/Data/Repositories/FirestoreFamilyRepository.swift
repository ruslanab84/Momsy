import Foundation
import FirebaseFirestore

final class FirestoreFamilyRepository: FamilyRepository {
    private let db = Firestore.firestore()

    private func col() throws -> CollectionReference {
        guard let id = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey) else {
            throw FamilyError.noFamilyId
        }
        return db.collection("families").document(id).collection("members")
    }

    func getMembers() async throws -> [StoredFamilyMember] {
        let snap = try await col().getDocuments()
        return snap.documents.compactMap { StoredFamilyMember(firestoreData: $0.data(), docId: $0.documentID) }
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

    init?(firestoreData data: [String: Any], docId: String) {
        guard
            let idStr = data["id"] as? String,
            let id = UUID(uuidString: idStr),
            let name = data["name"] as? String,
            let roleRaw = data["roleRaw"] as? String
        else { return nil }
        self.id = id
        self.name = name
        self.roleRaw = roleRaw
        self.isMe = data["isMe"] as? Bool ?? false
        self.uid = data["uid"] as? String ?? docId
        self.inviteEmail = data["inviteEmail"] as? String
    }
}
