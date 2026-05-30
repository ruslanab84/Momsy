import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

// UserDefaults key shared across module so repos can read without actor hopping
let kFamilyIdDefaultsKey = "familyId_v1"

enum FamilyError: LocalizedError {
    case noFamilyId
    case invalidOrExpiredCode

    var errorDescription: String? {
        switch self {
        case .noFamilyId:           return "Family not set up. Please sign in."
        case .invalidOrExpiredCode: return "This invite code is invalid or has expired."
        }
    }
}

@MainActor
final class FamilyManager: ObservableObject {
    static let shared = FamilyManager()

    @Published private(set) var familyId: String?
    @Published private(set) var isReady = false

    private var db: Firestore { Firestore.firestore() }
    private var isSettingUp = false

    private init() {
        familyId = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey)
        isReady = familyId != nil
    }

    /// Called by AuthManager's state listener on every sign-in / app launch with existing session.
    /// Reads the user's familyId from Firestore; creates a new family if none exists.
    func setup(uid: String, displayName: String) async throws {
        // Cached familyId is already sufficient — skip remote setup
        if familyId != nil { isReady = true; return }
        // Prevent concurrent invocations (e.g. state listener fires on launch + sign-in)
        guard !isSettingUp else { return }
        isSettingUp = true
        defer { isSettingUp = false }

        let userRef = db.collection("users").document(uid)
        let userDoc = try await userRef.getDocument()

        if let existingId = userDoc.data()?["familyId"] as? String {
            persist(familyId: existingId)
            try await BabySyncService().setupBabyProfile(uid: uid, displayName: displayName)
        } else {
            let newId = try await createFamily(for: uid)
            try await db.collection("families").document(newId)
                .collection("members").document(uid)
                .setData(["name": displayName, "joinedAt": Timestamp(date: Date())])
            try await userRef.setData(
                ["familyId": newId, "displayName": displayName],
                merge: true
            )
            persist(familyId: newId)
            try await BabySyncService().setupBabyProfile(uid: uid, displayName: displayName)
        }
        isReady = true
    }

    @discardableResult
    func createFamily(for uid: String) async throws -> String {
        let ref = db.collection("families").document()
        try await ref.setData(["createdAt": Timestamp(date: Date()), "createdBy": uid])
        return ref.documentID
    }

    /// Accepts an invite code, looks it up in Firestore, and assigns this user to that family.
    func joinFamily(code: String, uid: String) async throws {
        let trimmed = code.trimmingCharacters(in: .whitespaces).uppercased()
        let inviteDoc = try await db.collection("invites").document(trimmed).getDocument()
        guard
            let data = inviteDoc.data(),
            let targetFamilyId = data["familyId"] as? String,
            let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue(),
            expiresAt > Date()
        else { throw FamilyError.invalidOrExpiredCode }

        try await db.collection("users").document(uid)
            .setData(["familyId": targetFamilyId], merge: true)

        // Also add as member in the family
        let displayName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "User"
        try await db.collection("families").document(targetFamilyId)
            .collection("members").document(uid)
            .setData(["name": displayName, "joinedAt": Timestamp(date: Date())], merge: true)

        persist(familyId: targetFamilyId)
        isReady = true
    }

    func reset() {
        familyId = nil
        isReady = false
        UserDefaults.standard.removeObject(forKey: kFamilyIdDefaultsKey)
    }

    private func persist(familyId id: String) {
        familyId = id
        UserDefaults.standard.set(id, forKey: kFamilyIdDefaultsKey)
    }
}
