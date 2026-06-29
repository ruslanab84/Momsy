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
    case wouldAbandonExistingFamily

    var errorDescription: String? {
        switch self {
        case .noFamilyId:                 return "Family not set up. Please sign in."
        case .invalidOrExpiredCode:       return "This invite code is invalid or has expired."
        case .wouldAbandonExistingFamily: return "You already belong to a family."
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
        let suppressedRestoreStore = UserDefaultsSuppressedFamilyRestoreStore()
        let restoreSuppressed = suppressedRestoreStore.isRestoreSuppressed(for: uid)
        if restoreSuppressed {
            reset()
        }

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
        // This routing document decides whether a provider login adopts an existing
        // family or starts fresh. Read it from the backend, not Firestore's persistent
        // cache, so a just-deleted account cannot reattach to a stale cached familyId.
        let userDoc = try await userRef.getDocument(source: .server)
        let existingId = userDoc.data()?["familyId"] as? String

        if let existingId, !restoreSuppressed {
            persist(familyId: existingId, ownerUid: uid)
            try await BabySyncService().setupBabyProfile(uid: uid, displayName: displayName)
        } else {
            if let existingId, restoreSuppressed {
                try? await db.collection("families").document(existingId)
                    .collection("members").document(uid).delete()
            }
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
            suppressedRestoreStore.clearSuppression(for: uid)
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

    /// Whether the caller's current family already has a child profile (data that would
    /// be orphaned by switching families). One cheap, capped read.
    private func currentFamilyHasData() async throws -> Bool {
        guard let familyId else { return false }
        let snap = try await db.collection("families").document(familyId)
            .collection("babies").limit(to: 1).getDocuments()
        return !snap.documents.isEmpty
    }

    /// Accepts an invite code, looks it up in Firestore, and assigns this user to that family.
    func joinFamily(code: String, uid: String, force: Bool = false) async throws {
        // Accept either a bare code or a full `momsy://join?code=…` link a user may
        // have pasted; reject anything else so it can't become a `//` Firestore path.
        guard let trimmed = JoinDeeplink.normalize(rawCode: code) else {
            throw FamilyError.invalidOrExpiredCode
        }
        let inviteDoc = try await db.collection("invites").document(trimmed).getDocument()
        guard
            let data = inviteDoc.data(),
            let targetFamilyId = data["familyId"] as? String,
            let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue(),
            expiresAt > Date()
        else { throw FamilyError.invalidOrExpiredCode }

        // Already in the target family — idempotent no-op.
        if familyId == targetFamilyId { isReady = true; return }

        // Only pay for the data read when actually switching to a different family.
        let switchingFamily = (familyId != nil && familyId != targetFamilyId)
        let hasData = switchingFamily ? try await currentFamilyHasData() : false
        if FamilyJoinGuard.requiresConfirmation(
            currentFamilyId: familyId, targetFamilyId: targetFamilyId,
            currentFamilyHasData: hasData, force: force
        ) {
            throw FamilyError.wouldAbandonExistingFamily
        }

        // Detach from the previous roster BEFORE repointing users/{uid}.familyId,
        // otherwise the rules no longer authorise deleting the old membership doc.
        if let previous = familyId, previous != targetFamilyId {
            try? await db.collection("families").document(previous)
                .collection("members").document(uid).delete()
        }

        try await db.collection("users").document(uid)
            .setData(["familyId": targetFamilyId], merge: true)

        let displayName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "User"
        try await db.collection("families").document(targetFamilyId)
            .collection("members").document(uid)
            .setData(["name": displayName, "joinedAt": Timestamp(date: Date())], merge: true)

        persist(familyId: targetFamilyId, ownerUid: uid)
        isReady = true
        NotificationCenter.default.post(name: .familyDidJoin, object: nil)
    }

    /// True when the caller is the only remaining member (or the roster is empty).
    /// Gates whether account deletion may tear down shared family data.
    func isSoleMember(uid: String) async throws -> Bool {
        guard let familyId else { return true }
        let snap = try await db.collection("families").document(familyId)
            .collection("members").getDocuments()
        let ids = snap.documents.map { $0.documentID }
        return AccountErasureGate.mayTearDownSharedData(memberIds: ids, callerUid: uid)
    }

    /// Removes the caller's own membership and their `users/{uid}` doc. When
    /// `tearDownSharedFamily` is true (caller is the sole member) the family doc itself
    /// is also deleted; otherwise the family and co-parents' memberships are left intact.
    /// Call while still authenticated (rules require it) and before `reset()`. The order
    /// matters: `users/{uid}` is deleted LAST so membership-based rules still authorise
    /// the family/member deletes above it.
    func leaveFamily(uid: String, tearDownSharedFamily: Bool) async throws {
        if let familyId {
            let familyRef = db.collection("families").document(familyId)
            try await familyRef.collection("members").document(uid).delete()
            if tearDownSharedFamily {
                try await familyRef.delete()
            }
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
