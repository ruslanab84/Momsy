import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

/// Erases the user's cloud footprint: the `babies/{babyId}` log tree plus the
/// `families/{familyId}` and `users/{uid}` documents. Abstracted so the deletion
/// flow can be unit-tested without Firestore.
protocol CloudAccountEraser {
    func deleteCloudData(uid: String) async throws
    /// Server-truth check that the user's cloud footprint is gone. MUST read from the
    /// backend (not the local cache) so a cache-only delete can't masquerade as complete.
    /// Returns `true` while anything that could re-resolve the family still exists.
    func isCloudDataPresent(uid: String) async throws -> Bool
}

/// The slice of `BabySyncService` the roster-wide erase needs. `deleteAllData()` targets a
/// single child (the path resolved from `ActiveBaby`), so the loop in `RosterErasure` calls
/// it once per child. Abstracted so the per-child logic is unit-testable without Firestore.
protocol BabyRosterDataEraser {
    func discoverAllBabyIds() async -> [String]
    func deleteAllData() async throws
}

extension BabySyncService: BabyRosterDataEraser {}

/// Erases EVERY child's cloud subtree, not just the active one. Firestore keeps the per-baby
/// trees at sibling paths (`families/{familyId}/babies/{babyId}/…`) and never cascades a parent
/// delete into them, so erasing only the active child would orphan every sibling's health logs
/// after "delete account" — a GDPR right-to-erasure gap. Each child is erased under a task-local
/// override that retargets the cloud path to it (mirroring `CloudSyncDownloader`). The locally
/// active child is always included even if the roster read missed it (created locally, not yet
/// uploaded); with no roster discovered at all, falls back to erasing the active path once.
enum RosterErasure {
    static func eraseAll(using svc: BabyRosterDataEraser, locallyActiveId: UUID?) async throws {
        var ids = await svc.discoverAllBabyIds()
        if let active = locallyActiveId, !ids.contains(active.uuidString) {
            ids.append(active.uuidString)
        }
        guard !ids.isEmpty else {
            try await svc.deleteAllData()
            return
        }
        for idStr in ids {
            guard let id = UUID(uuidString: idStr) else { continue }
            try await ActiveBaby.$syncTargetOverride.withValue(id) {
                try await svc.deleteAllData()
            }
        }
    }
}

struct FirestoreAccountEraser: CloudAccountEraser {
    let babySync: BabySyncService

    func deleteCloudData(uid: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let userDoc = try await userRef.getDocument(source: .server)
        let resolvedFamilyId = (userDoc.data()?["familyId"] as? String) ?? FamilyManager.shared.familyId

        try await deleteAllDocs(
            in: db.collection("invites").whereField("createdBy", isEqualTo: uid)
        )

        if let familyId = resolvedFamilyId, !familyId.isEmpty {
            do {
                let familyRef = db.collection("families").document(familyId)
                let memberDocuments = try await familyRef.collection("members").getDocuments().documents
                let memberIds = memberDocuments.map(\.documentID)
                let callerRoleRaw = memberDocuments
                    .first { $0.documentID == uid }?
                    .data()["roleRaw"] as? String ?? ""
                let mayTearDownSharedData = AccountErasureGate.mayTearDownSharedData(
                    memberIds: memberIds,
                    callerUid: uid,
                    callerRoleRaw: callerRoleRaw
                )

                if mayTearDownSharedData {
                    let familyDoc = try await familyRef.getDocument(source: .server)
                    let callerCreatedFamily = familyDoc.data()?["createdBy"] as? String == uid
                    let babyIds = try await discoverBabyIds(in: familyRef)
                    for babyId in babyIds {
                        try await deleteBabyTree(familyRef: familyRef, familyId: familyId, babyId: babyId)
                    }
                    try await deleteLegacyFamilyTree(familyId: familyId)
                    if callerCreatedFamily {
                        try await familyRef.delete()
                    }
                    // Firestore never cascades into subcollections: the caller's roster doc
                    // must be removed explicitly or it outlives the erased account as PII.
                    // Ordered AFTER the deletes above — those are authorised by
                    // `belongsToFamily`, which reads this very document.
                    try await familyRef.collection("members").document(uid).delete()
                } else {
                    try await familyRef.collection("members").document(uid).delete()
                }
            } catch let error as NSError
                where error.domain == FirestoreErrorDomain
                && error.code == FirestoreErrorCode.permissionDenied.rawValue {
                // The caller's members/{uid} doc is already gone (a prior partial run
                // deleted it), so every family read/write is now denied by
                // `belongsToFamily`. Nothing in the family branch is reachable or
                // owned by this account anymore; fall through to deleting users/{uid} —
                // the only remaining re-resolution signal `isCloudDataPresent` checks.
            }
        }

        try await userRef.delete()
    }

    /// Reads from the server so a cache-confirmed-but-not-yet-flushed delete can't pass as
    /// complete while either the routing document or account-owned invites still exist.
    func isCloudDataPresent(uid: String) async throws -> Bool {
        let db = Firestore.firestore()
        let userDoc = try await db.collection("users").document(uid)
            .getDocument(source: .server)
        guard !userDoc.exists else { return true }
        let invites = try await db.collection("invites")
            .whereField("createdBy", isEqualTo: uid)
            .limit(to: 1)
            .getDocuments(source: .server)
        return !invites.isEmpty
    }

    private func discoverBabyIds(in familyRef: DocumentReference) async throws -> [String] {
        var ids = try await familyRef.collection("babies").getDocuments()
            .documents
            .map(\.documentID)
            .filter { !$0.isEmpty }
        if let active = ActiveBaby.currentId, !ids.contains(active.uuidString) {
            ids.append(active.uuidString)
        }
        return ids
    }

    private func deleteBabyTree(familyRef: DocumentReference, familyId: String, babyId: String) async throws {
        let babyRef = familyRef.collection("babies").document(babyId)
        for subcollection in BabySyncService.allSubcollections {
            try await deleteAllDocs(in: babyRef.collection(subcollection))
        }
        try await babyRef.collection("profile").document("info").delete()
        try await babyRef.delete()
        SyncWatermarkStore().reset(family: familyId, baby: babyId)
    }

    private func deleteLegacyFamilyTree(familyId: String) async throws {
        let oldParent = Firestore.firestore().collection("babies").document(familyId)
        for subcollection in BabySyncService.allSubcollections {
            try? await deleteAllDocs(in: oldParent.collection(subcollection))
        }
        try? await oldParent.collection("profile").document("info").delete()
        try? await oldParent.delete()
    }

    private func deleteAllDocs(in ref: Query) async throws {
        let docs = try await ref.getDocuments().documents
        guard !docs.isEmpty else { return }
        let db = Firestore.firestore()
        for start in stride(from: 0, to: docs.count, by: 400) {
            let batch = db.batch()
            for doc in docs[start..<min(start + 400, docs.count)] {
                batch.deleteDocument(doc.reference)
            }
            try await batch.commit()
        }
    }
}

/// The slice of auth the deletion flow needs. `AuthManager` conforms; tests use a mock.
@MainActor
protocol AccountAuthProtocol: AnyObject {
    var currentUID: String? { get }
    func deleteAccount(expectedUID: String) async throws
}

extension AuthManager: AccountAuthProtocol {
    var currentUID: String? {
        guard FirebaseApp.app() != nil else { return firebaseUser?.uid }
        return Auth.auth().currentUser?.uid ?? firebaseUser?.uid
    }
}

/// GDPR "right to erasure" orchestrator. Deletes cloud data while still
/// authenticated, deletes the auth account, then wipes the device clean last.
@MainActor
final class DeleteAccountUseCase {
    private let cloudEraser: CloudAccountEraser
    private let auth: any AccountAuthProtocol
    private let pendingStore: PendingAccountDeletionStore
    private let suppressedRestoreStore: SuppressedFamilyRestoreStore
    private let eraseLocal: @MainActor () throws -> Void

    init(
        cloudEraser: CloudAccountEraser,
        auth: any AccountAuthProtocol,
        pendingStore: PendingAccountDeletionStore,
        suppressedRestoreStore: SuppressedFamilyRestoreStore,
        eraseLocal: @MainActor @escaping () throws -> Void
    ) {
        self.cloudEraser = cloudEraser
        self.auth = auth
        self.pendingStore = pendingStore
        self.suppressedRestoreStore = suppressedRestoreStore
        self.eraseLocal = eraseLocal
    }

    func execute() async throws {
        var cloudError: Error?
        var authError: Error?
        var completionError: Error?

        if let uid = auth.currentUID {
            // Persist the intent FIRST so a deletion that doesn't reach the backend is
            // completed by launch recovery instead of resurfacing on the next sign-in.
            pendingStore.markPending(uid: uid)
            suppressedRestoreStore.suppressRestore(for: uid)
            do {
                try await cloudEraser.deleteCloudData(uid: uid)

                if try await cloudEraser.isCloudDataPresent(uid: uid) {
                    // Cache said done but the SERVER still has the user doc. Keep the marker
                    // AND keep the session alive so launch recovery can finish the erase while
                    // still authenticated — do NOT delete/sign out the account yet.
                    completionError = AuthError.accountDeletionPending
                } else {
                    do {
                        try await auth.deleteAccount(expectedUID: uid)
                        pendingStore.clearPending()
                    } catch {
                        authError = error
                    }
                }
            } catch {
                // Network/permission failure mid-erase: leave the marker for recovery.
                cloudError = error
            }
        }

        // Keep the current session, retry marker, and local UI available so provider
        // reauthentication/revocation can finish before the deletion is reported complete.
        if let authError { throw authError }

        // Always leave the device clean, even if the cloud erase didn't fully confirm.
        try eraseLocal()
        FamilyManager.shared.reset()

        if let cloudError { throw cloudError }
        if let completionError { throw completionError }
    }
}

/// Finishes an account deletion that the original `DeleteAccountUseCase.execute()` started
/// but could not server-confirm (offline, a transient Firestore error, or a cache-only
/// commit dropped when the session ended). Runs at launch BEFORE any cloud download, so the
/// data is erased before it could be shown again.
///
/// It only acts when the currently signed-in user is the SAME account that was being
/// deleted: re-running the cloud erase requires that account's Firestore membership, and a
/// different signed-in user has neither the permission nor the reason to delete it.
@MainActor
final class AccountDeletionRecovery {
    private let cloudEraser: CloudAccountEraser
    private let auth: any AccountAuthProtocol
    private let pendingStore: PendingAccountDeletionStore
    private let suppressedRestoreStore: SuppressedFamilyRestoreStore

    init(
        cloudEraser: CloudAccountEraser,
        auth: any AccountAuthProtocol,
        pendingStore: PendingAccountDeletionStore,
        suppressedRestoreStore: SuppressedFamilyRestoreStore
    ) {
        self.cloudEraser = cloudEraser
        self.auth = auth
        self.pendingStore = pendingStore
        self.suppressedRestoreStore = suppressedRestoreStore
    }

    /// The device is wiped only while a deletion is BOTH unresolved AND owned by this session.
    ///
    /// `pendingUid == nil` — `runIfNeeded()` just finished the erase. Wiping again would clear
    /// `cloudSyncConsent`, which gates `AuthManager`'s auth-state listener and `FamilyManager.setup`;
    /// the next sign-in would then create a Firebase user with no users/{uid} doc and no family.
    ///
    /// `currentUid != pendingUid` (including signed out) — the marker belongs to an account that
    /// isn't in this session, so nothing of its can be downloaded here. `DeleteAccountUseCase`
    /// already wiped this device; repeating it every launch resets onboarding forever.
    nonisolated static func shouldWipeDevice(pendingUid: String?, currentUid: String?) -> Bool {
        guard let pendingUid else { return false }
        return currentUid == pendingUid
    }

    func runIfNeeded() async {
        guard let pendingUid = pendingStore.loadPending() else { return }
        guard let currentUid = auth.currentUID, currentUid == pendingUid else {
            suppressedRestoreStore.suppressRestore(for: pendingUid)
            return
        }
        suppressedRestoreStore.suppressRestore(for: pendingUid)
        do {
            try await cloudEraser.deleteCloudData(uid: currentUid)
            guard try await cloudEraser.isCloudDataPresent(uid: currentUid) == false else {
                return // still on the server — keep the marker and retry next launch
            }
            do {
                try await auth.deleteAccount(expectedUID: currentUid)
                pendingStore.clearPending()
            } catch {
                return // keep the authenticated session and marker for interactive re-auth
            }
        } catch {
            // Leave the marker in place; the next launch retries.
        }
    }
}
