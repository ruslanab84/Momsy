import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

/// Terminal state of one cloud-erase attempt. "Nothing left to erase" is a SUCCESS,
/// not a failure: treating it as an error kept the pending marker set forever and
/// permanently blocked re-registration with the same Apple/Google account.
enum AccountErasureOutcome: Equatable {
    /// Family data was found and erased on this attempt.
    case erased
    /// No client-reachable membership remains; the membership-deletion trigger owns any
    /// remaining old-family cleanup.
    case nothingToErase
    /// `users/{uid}.familyId` now points at a DIFFERENT family than the one this
    /// deletion recorded. The recorded erase finished and the account has since been
    /// re-routed; re-running would destroy data the user legitimately owns now.
    case supersededByNewFamily
}

/// Erases the user's cloud footprint while retaining `families/{familyId}` as a
/// non-reusable tombstone. Abstracted so the deletion flow can be unit-tested
/// without Firestore.
protocol CloudAccountEraser {
    /// - Parameter familyIdHint: the family recorded when the deletion started. It is the
    ///   ONLY family this attempt is authorised to touch; passing it explicitly removes the
    ///   hidden `FamilyManager.shared` fallback that let recovery retarget a new family.
    func deleteCloudData(uid: String, familyIdHint: String?) async throws -> AccountErasureOutcome
    /// Server-truth check that the user's cloud footprint is gone. MUST read from the
    /// backend (not the local cache) so a cache-only delete can't masquerade as complete.
    /// Returns `true` while anything that could re-resolve the family still exists.
    func isCloudDataPresent(uid: String) async throws -> Bool
}

struct FirestoreAccountEraser: CloudAccountEraser, Sendable {
    func deleteCloudData(uid: String, familyIdHint: String?) async throws -> AccountErasureOutcome {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let userDoc = try await userRef.getDocument(source: .server)
        let serverFamilyId = (userDoc.data()?["familyId"] as? String)
            .flatMap { $0.isEmpty ? nil : $0 }
        let hint = familyIdHint.flatMap { $0.isEmpty ? nil : $0 }

        if let hint, let serverFamilyId, serverFamilyId != hint {
            return .supersededByNewFamily
        }

        guard let familyId = serverFamilyId ?? hint else {
            try await deleteRoutingFootprint(uid: uid, userRef: userRef, userExists: userDoc.exists)
            return .nothingToErase
        }

        guard let memberRef = try await memberReference(familyId: familyId, uid: uid) else {
            try await waitForDepartureCleanup(uid: uid)
            let currentUser = try await userRef.getDocument(source: .server)
            let currentFamilyId = currentUser.data()?["familyId"] as? String
            if let currentFamilyId, currentFamilyId != familyId {
                return .supersededByNewFamily
            }
            try await deleteRoutingFootprint(
                uid: uid,
                userRef: userRef,
                userExists: currentUser.exists
            )
            return .nothingToErase
        }

        let cleanupRef = db.collection("familyDepartureCleanups").document(
            FamilyDepartureCleanupJob.documentID(familyID: familyId, uid: uid)
        )
        let batch = db.batch()
        batch.setData([
            "familyId": familyId,
            "uid": uid,
            "removedMemberId": memberRef.documentID,
            "requestedAt": FieldValue.serverTimestamp(),
            "kind": FamilyDepartureCleanupJob.accountDeletionKind,
        ], forDocument: cleanupRef)
        batch.deleteDocument(memberRef)
        try await batch.commit()
        try await waitForDepartureCleanup(uid: uid)
        return .erased
    }

    private func waitForDepartureCleanup(uid: String) async throws {
        let query = Firestore.firestore().collection("familyDepartureCleanups")
            .whereField("uid", isEqualTo: uid)
            .limit(to: 1)
        var delay: UInt64 = 250_000_000
        for _ in 0..<35 {
            try Task.checkCancellation()
            let snapshot = try await query.getDocuments(source: .server)
            if snapshot.isEmpty, !snapshot.metadata.hasPendingWrites { return }
            try await Task.sleep(nanoseconds: delay)
            delay = min(delay * 2, 2_000_000_000)
        }
        throw AuthError.accountDeletionPending
    }

    private func deleteRoutingFootprint(
        uid: String,
        userRef: DocumentReference,
        userExists: Bool
    ) async throws {
        let db = Firestore.firestore()
        let query = db.collection("invites").whereField("createdBy", isEqualTo: uid)
        while true {
            let documents = try await query.limit(to: 400)
                .getDocuments(source: .server)
                .documents
            guard !documents.isEmpty else { break }
            let batch = db.batch()
            for document in documents { batch.deleteDocument(document.reference) }
            try await batch.commit()
        }
        if userExists { try await userRef.delete() }
    }

    /// Prefer the canonical UID document, with the same legacy UID lookup used by roster
    /// cleanup. A revoked member cannot enumerate the old roster.
    private func memberReference(familyId: String, uid: String) async throws -> DocumentReference? {
        let members = Firestore.firestore()
            .collection("families").document(familyId)
            .collection("members")
        let canonical = members.document(uid)
        do {
            if try await canonical.getDocument(source: .server).exists { return canonical }
        } catch let error where FamilyManager.classifyMembershipError(error) == .revoked {
            // A missing canonical document is denied by rules; legacy records can still
            // be found by their authenticated uid field.
        }
        do {
            return try await members.whereField("uid", isEqualTo: uid)
                .limit(to: 1)
                .getDocuments(source: .server)
                .documents
                .first?
                .reference
        } catch let error where FamilyManager.classifyMembershipError(error) == .revoked {
            return nil
        }
    }

    /// Final server check after the trusted cleanup job completes. Pending local writes are
    /// not accepted as backend confirmation.
    func isCloudDataPresent(uid: String) async throws -> Bool {
        let db = Firestore.firestore()
        let userDoc = try await db.collection("users").document(uid)
            .getDocument(source: .server)
        guard !userDoc.exists, !userDoc.metadata.hasPendingWrites else { return true }
        let invites = try await db.collection("invites")
            .whereField("createdBy", isEqualTo: uid)
            .limit(to: 1)
            .getDocuments(source: .server)
        guard invites.isEmpty, !invites.metadata.hasPendingWrites else { return true }
        let departureCleanups = try await db.collection("familyDepartureCleanups")
            .whereField("uid", isEqualTo: uid)
            .limit(to: 1)
            .getDocuments(source: .server)
        return departureCleanups.metadata.hasPendingWrites || !departureCleanups.isEmpty
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
    private let pendingAuthStore: PendingAuthAccountDeletionStore
    private let suppressedRestoreStore: SuppressedFamilyRestoreStore
    private let eraseLocal: @MainActor () throws -> Void

    init(
        cloudEraser: CloudAccountEraser,
        auth: any AccountAuthProtocol,
        pendingStore: PendingAccountDeletionStore,
        pendingAuthStore: PendingAuthAccountDeletionStore,
        suppressedRestoreStore: SuppressedFamilyRestoreStore,
        eraseLocal: @MainActor @escaping () throws -> Void
    ) {
        self.cloudEraser = cloudEraser
        self.auth = auth
        self.pendingStore = pendingStore
        self.pendingAuthStore = pendingAuthStore
        self.suppressedRestoreStore = suppressedRestoreStore
        self.eraseLocal = eraseLocal
    }

    func execute() async throws {
        var cloudError: Error?
        var authError: Error?
        var completionError: Error?
        var cloudIsConfirmedClean = false
        let deletingUid = auth.currentUID

        if let uid = deletingUid {
            // Persist the intent FIRST so a deletion that doesn't reach the backend is
            // completed by launch recovery instead of resurfacing on the next sign-in.
            // The family is recorded WITH the uid: recovery must never re-resolve it.
            let familyId = FamilyManager.shared.familyId
            pendingStore.markPending(uid: uid, familyId: familyId)
            suppressedRestoreStore.suppressRestore(for: uid)
            do {
                _ = try await cloudEraser.deleteCloudData(uid: uid, familyIdHint: familyId)

                if try await cloudEraser.isCloudDataPresent(uid: uid) {
                    // Cache said done but the SERVER still has the user doc. Keep the marker
                    // AND keep the session alive so launch recovery can finish the erase while
                    // still authenticated — do NOT delete/sign out the account yet.
                    completionError = AuthError.accountDeletionPending
                } else {
                    cloudIsConfirmedClean = true
                }
            } catch {
                // Network/permission failure mid-erase: leave the marker for recovery.
                cloudError = error
            }
        }

        // Always leave the device clean, even if the cloud erase didn't fully confirm.
        try eraseLocal()
        if let deletingUid {
            pendingStore.markLocalWipeCompleted(for: deletingUid)
        }
        FamilyManager.shared.reset()

        if cloudIsConfirmedClean, let uid = deletingUid {
            // Keep the marker and authenticated session until the local wipe is durable.
            // Otherwise a SwiftData failure would strand health data with no safe retry.
            pendingStore.clearPending()
            // Marked BEFORE the attempt: the app dying mid-delete must still leave the
            // Auth record to the retry, or it survives forever with nothing tracking it.
            pendingAuthStore.markPending(uid: uid)
            do {
                try await auth.deleteAccount(expectedUID: uid)
                pendingAuthStore.clearPending()
            } catch {
                // The marker stays for the non-blocking retry. Surfacing the error
                // still lets Settings offer reauthentication in this session.
                authError = error
            }
        }

        // The Auth failure surfaces only AFTER the wipe: it can be set only once the server
        // confirmed the cloud is clean, and returning early there would strand the local store
        // — `FamilyManager` would then adopt a brand-new family on the next launch and re-upload
        // it all. Still thrown so Settings can offer reauthentication; the session survives.
        if let authError { throw authError }
        if let cloudError { throw cloudError }
        if let completionError { throw completionError }
    }
}

nonisolated enum AccountDeletionRecoveryDisposition: Equatable {
    case continueDeletion
    case supersededByNewFamily
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
    private let pendingAuthStore: PendingAuthAccountDeletionStore
    private let suppressedRestoreStore: SuppressedFamilyRestoreStore
    private let eraseLocal: @MainActor () throws -> Void
    /// True while the account has been put back into use (a family is resolved again).
    /// Injected so the policy is testable without `FamilyManager.shared`.
    private let accountIsInUse: @MainActor () -> Bool

    init(
        cloudEraser: CloudAccountEraser,
        auth: any AccountAuthProtocol,
        pendingStore: PendingAccountDeletionStore,
        pendingAuthStore: PendingAuthAccountDeletionStore,
        suppressedRestoreStore: SuppressedFamilyRestoreStore,
        eraseLocal: @MainActor @escaping () throws -> Void,
        accountIsInUse: @MainActor @escaping () -> Bool = { FamilyManager.shared.familyId != nil }
    ) {
        self.cloudEraser = cloudEraser
        self.auth = auth
        self.pendingStore = pendingStore
        self.pendingAuthStore = pendingAuthStore
        self.suppressedRestoreStore = suppressedRestoreStore
        self.eraseLocal = eraseLocal
        self.accountIsInUse = accountIsInUse
    }

    /// Captures ownership before recovery can clear Auth and the marker. A different account
    /// becoming active while recovery awaits must not have its local data wiped.
    nonisolated static func shouldWipeDevice(
        pendingAtStart: PendingAccountDeletion?,
        currentUidAtStart: String?,
        currentUidAfterRecovery: String?,
        disposition: AccountDeletionRecoveryDisposition
    ) -> Bool {
        guard let pendingAtStart,
              !pendingAtStart.localWipeCompleted,
              disposition != .supersededByNewFamily,
              currentUidAtStart == pendingAtStart.uid else { return false }
        return currentUidAfterRecovery == nil || currentUidAfterRecovery == pendingAtStart.uid
    }

    @discardableResult
    func runIfNeeded() async -> AccountDeletionRecoveryDisposition {
        guard let pending = pendingStore.loadPending() else {
            await retryAuthDeletionIfNeeded()
            return .continueDeletion
        }
        guard let currentUid = auth.currentUID, currentUid == pending.uid else {
            suppressedRestoreStore.suppressRestore(for: pending.uid)
            return .continueDeletion
        }
        suppressedRestoreStore.suppressRestore(for: pending.uid)
        var cloudIsConfirmedClean = false
        do {
            let outcome = try await cloudEraser.deleteCloudData(
                uid: currentUid,
                familyIdHint: pending.familyId
            )
            if outcome == .supersededByNewFamily {
                // The recorded family was already erased and the account now belongs to a
                // different family. The marker is stale — clearing the suppression lets the
                // new family be adopted normally on the next `FamilyManager.setup`.
                pendingStore.clearPending()
                suppressedRestoreStore.clearSuppression(for: currentUid)
                return .supersededByNewFamily
            }
            cloudIsConfirmedClean = try await cloudEraser.isCloudDataPresent(uid: currentUid) == false
        } catch {
            // Leave the marker in place; the next launch retries the cloud erase.
        }

        if !pending.localWipeCompleted {
            guard Self.shouldWipeDevice(
                pendingAtStart: pending,
                currentUidAtStart: currentUid,
                currentUidAfterRecovery: auth.currentUID,
                disposition: .continueDeletion
            ) else {
                return .continueDeletion
            }
            do {
                try eraseLocal()
                pendingStore.markLocalWipeCompleted(for: currentUid)
            } catch {
                // Fail closed: keep the marker and session so the next recovery can retry.
                return .continueDeletion
            }
        }

        guard cloudIsConfirmedClean,
              pendingStore.loadPending()?.localWipeCompleted == true else {
            return .continueDeletion
        }
        // The cloud and device are both clean, so reusing this uid cannot restore old data.
        pendingStore.clearPending()
        pendingAuthStore.markPending(uid: currentUid)
        do {
            try await auth.deleteAccount(expectedUID: currentUid)
            pendingAuthStore.clearPending()
        } catch {
            // The marker stays; a later launch retries.
        }
        return .continueDeletion
    }

    /// Best-effort removal of an Auth record whose data is already gone. Never blocks the UI.
    /// Skipped — and dropped — once the account is back in use, so a returning user is not
    /// signed out of a session they deliberately restarted.
    private func retryAuthDeletionIfNeeded() async {
        guard let uid = pendingAuthStore.loadPending() else { return }
        guard let currentUid = auth.currentUID, currentUid == uid else { return }
        guard !accountIsInUse() else {
            pendingAuthStore.clearPending()
            return
        }
        do {
            try await auth.deleteAccount(expectedUID: uid)
            pendingAuthStore.clearPending()
        } catch {
            // Retry on a later launch.
        }
    }
}
