import Foundation
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

final class FirestoreFamilyRepository: FamilyRepository {
    private var db: Firestore { Firestore.firestore() }

    private func col() throws -> CollectionReference {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
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
        let docId = documentId(for: member)
        try await col().document(docId).setData(member.toFirestoreData(), merge: true)
    }

    func update(_ member: StoredFamilyMember) async throws {
        let docId = documentId(for: member)
        try await col().document(docId).updateData(member.toFirestoreData())
    }

    func prepareForRosterManagement(currentMember: StoredFamilyMember) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard currentMember.isMe else { return }
        guard let currentRole = currentMember.role, currentRole.canManageFamilyMembers else { return }

        let collection = try col()
        let canonicalRef = collection.document(uid)
        let canonicalSnap = try await canonicalRef.getDocument()
        var canonicalMember = currentMember
        canonicalMember.uid = uid
        canonicalMember.documentId = uid
        canonicalMember.roleRaw = currentRole.rawValue

        if canonicalSnap.exists {
            let existingRaw = canonicalSnap.data()?["roleRaw"] as? String ?? ""
            if FamilyRole(storedRawValue: existingRaw)?.rawValue != currentRole.rawValue {
                try await canonicalRef.setData(canonicalMember.toFirestoreData(), merge: true)
            }
        } else {
            try await canonicalRef.setData(canonicalMember.toFirestoreData(), merge: true)
        }

        if let documentId = currentMember.documentId, documentId != uid {
            try? await collection.document(documentId).delete()
        }
    }

    func remove(_ member: StoredFamilyMember) async throws {
        let collection = try col()
        let docIds = [
            member.documentId,
            member.uid,
            member.id.uuidString
        ].compactMap { $0 }

        var checkedDocIds = Set<String>()
        for docId in docIds {
            guard checkedDocIds.insert(docId).inserted else { continue }
            let ref = collection.document(docId)
            let snap = try await ref.getDocument()
            if snap.exists {
                try await ref.delete()
                return
            }
        }

        let snap = try await collection.whereField("id", isEqualTo: member.id.uuidString).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }

    private func documentId(for member: StoredFamilyMember) -> String {
        member.documentId ?? member.uid ?? member.id.uuidString
    }
}

private extension StoredFamilyMember {
    var role: FamilyRole? {
        FamilyRole(storedRawValue: roleRaw)
    }
}

extension StoredFamilyMember {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "name": name,
            "roleRaw": FamilyRole(storedRawValue: roleRaw)?.rawValue ?? roleRaw,
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
        guard
            let name = data["name"] as? String,
            let roleRaw = data["roleRaw"] as? String,
            let role = FamilyRole(storedRawValue: roleRaw)
        else { return nil }
        self.id = id
        self.name = name
        self.roleRaw = role.rawValue
        self.isMe = isCurrentUser ?? (data["isMe"] as? Bool ?? false)
        self.uid = uid
        self.inviteEmail = data["inviteEmail"] as? String
        self.documentId = docId
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
