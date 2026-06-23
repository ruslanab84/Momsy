import Foundation
import Combine
import os
import FirebaseFirestore
import FirebaseAuth

// UserDefaults keys shared across module so repos can read without actor hopping
let kFamilyIdDefaultsKey = "familyId_v1"
let kBabyIdDefaultsKey = "babyId_v1"
// The uid that owns the cached familyId. A cached familyId is valid only for this
// uid; a different uid means the cache is stale and must be re-read from Firestore.
let kFamilyOwnerUidDefaultsKey = "familyOwnerUid_v1"

extension Notification.Name {
    /// Posted after the caller joins an existing family, so the app re-pulls that
    /// family's data (the joined family's logs aren't local yet).
    static let familyDidJoin = Notification.Name("familyDidJoin")
}

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
    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "Family")

    private init() {
        familyId = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey)
        isReady = familyId != nil
    }

    /// True when a cached familyId belongs to a different uid than the one now
    /// signing in. This happens when `AuthManager.linkOrSignIn` falls back to a
    /// plain `signIn` (the credential already belongs to an existing account):
    /// Firebase issues a new uid, but the anonymous session's familyId is still
    /// cached. Without invalidation, `setup` early-returns on that stale id and
    /// strands the user in an empty anonymous family. A nil cached uid (fresh
    /// install, or a cache written before this key existed) is treated as valid.
    nonisolated static func cacheIsStale(cachedOwnerUid: String?, currentUid: String) -> Bool {
        guard let cachedOwnerUid else { return false }
        return cachedOwnerUid != currentUid
    }

    /// Called by AuthManager's state listener on every sign-in / app launch with existing session.
    /// Reads the user's familyId from Firestore; creates a new family if none exists.
    func setup(uid: String, displayName: String) async throws {
        // A uid change since the cache was written (e.g. signing into an existing
        // account that replaced the anonymous user) invalidates the cached familyId.
        if Self.cacheIsStale(
            cachedOwnerUid: UserDefaults.standard.string(forKey: kFamilyOwnerUidDefaultsKey),
            currentUid: uid
        ) {
            reset()
        }
        // Cached familyId is already sufficient — skip remote setup
        if familyId != nil { isReady = true; return }
        // Prevent concurrent invocations (e.g. state listener fires on launch + sign-in)
        guard !isSettingUp else { return }
        isSettingUp = true
        defer { isSettingUp = false }

        let userRef = db.collection("users").document(uid)
        let userDoc = try await userRef.getDocument()

        if let existingId = userDoc.data()?["familyId"] as? String {
            persist(familyId: existingId, ownerUid: uid)
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
            persist(familyId: newId, ownerUid: uid)
            try await BabySyncService().setupBabyProfile(uid: uid, displayName: displayName)
            Self.log.info("Created new family \(newId, privacy: .public) for user")
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

        persist(familyId: targetFamilyId, ownerUid: uid)
        isReady = true
        NotificationCenter.default.post(name: .familyDidJoin, object: nil)
    }

    /// GDPR erasure of the family/user graph: every `families/{familyId}/members`
    /// doc, the family doc itself, and the caller's `users/{uid}` doc. Call while
    /// still authenticated (Firestore rules require it) and before `reset()`.
    func deleteFamilyAndUserDocs(uid: String) async throws {
        if let familyId {
            let members = try await db.collection("families").document(familyId)
                .collection("members").getDocuments()
            for doc in members.documents {
                try await doc.reference.delete()
            }
            try await db.collection("families").document(familyId).delete()
        }
        try await db.collection("users").document(uid).delete()
    }

    func reset() {
        familyId = nil
        isReady = false
        UserDefaults.standard.removeObject(forKey: kFamilyIdDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kFamilyOwnerUidDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kBabyIdDefaultsKey)
    }

    private func persist(familyId id: String, ownerUid uid: String) {
        familyId = id
        UserDefaults.standard.set(id, forKey: kFamilyIdDefaultsKey)
        UserDefaults.standard.set(uid, forKey: kFamilyOwnerUidDefaultsKey)
    }
}
