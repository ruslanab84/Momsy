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

struct FirestoreAccountEraser: CloudAccountEraser {
    func deleteCloudData(uid: String, familyIdHint: String?) async throws -> AccountErasureOutcome {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let userDoc = try await userRef.getDocument(source: .server)
        let serverFamilyId = (userDoc.data()?["familyId"] as? String)
            .flatMap { $0.isEmpty ? nil : $0 }
        let hint = familyIdHint.flatMap { $0.isEmpty ? nil : $0 }

        // The account has been re-routed to a different family since the deletion was
        // recorded (e.g. an invite join). The recorded erase is finished; re-running it
        // here would destroy data the user legitimately owns now.
        if let hint, let serverFamilyId, serverFamilyId != hint {
            return .supersededByNewFamily
        }

        try await deleteAllDocs(
            in: db.collection("invites").whereField("createdBy", isEqualTo: uid)
        )

        guard let familyId = serverFamilyId ?? hint else {
            // Neither a routing doc nor a recorded family: there is nothing left to erase.
            // Reporting this as `.accountDeletionPending` is what deadlocked re-registration.
            if userDoc.exists { try await userRef.delete() }
            return .nothingToErase
        }

        // Membership is the capability that authorises every client delete under
        // `families/{id}/babies/**`. Its deletion also starts the trusted cleanup trigger,
        // so a retry must not attempt an unauthorised old-family scrub.
        guard try await callerIsStillMember(familyId: familyId, uid: uid) else {
            if userDoc.exists { try await userRef.delete() }
            return .nothingToErase
        }

        do {
            let familyRef = db.collection("families").document(familyId)
            let familyDocument = try await familyRef.getDocument(source: .server)
            let callerCreatedFamily =
                familyDocument.data()?["createdBy"] as? String == uid
            let memberDocuments = try await familyRef.collection("members")
                .getDocuments(source: .server)
                .documents
            let partition = AccountErasureGate.partitionMemberDocuments(
                memberDocuments.map {
                    (id: $0.documentID, data: $0.data())
                }
            )
            let placeholderIds = Set(partition.placeholderIds)
            let legacyPlaceholders = memberDocuments.filter {
                placeholderIds.contains($0.documentID)
            }
            let realMembers = memberDocuments
                .filter { !placeholderIds.contains($0.documentID) }
                .map {
                    (id: $0.documentID, roleRaw: $0.data()["roleRaw"] as? String ?? "")
                }
            let callerRoleRaw = realMembers.first { $0.id == uid }?.roleRaw ?? ""
            if AccountErasureGate.isParentRole(callerRoleRaw) {
                for placeholder in legacyPlaceholders {
                    try await placeholder.reference.delete()
                }
            }
            let mayTearDownSharedData = AccountErasureGate.mayTearDownSharedData(
                members: realMembers,
                callerUid: uid,
                callerRoleRaw: callerRoleRaw
            )
            let babyIds = try await discoverBabyIds(in: familyRef)
            let healthDataParentPaths = Self.healthDataParentPaths(
                familyId: familyId,
                babyIds: babyIds
            )

            if mayTearDownSharedData {
                for babyId in babyIds {
                    try await deleteBabyTree(
                        familyRef: familyRef,
                        familyId: familyId,
                        babyId: babyId,
                        ownerUID: uid
                    )
                }
                try await deleteLegacyFamilyTree(familyId: familyId, ownerUID: uid)
                try await verifyHealthDataAbsent(
                    parentPaths: healthDataParentPaths,
                    deletingUID: uid,
                    authoredOnly: false
                )
                // A surviving nanny/grandma would otherwise keep a live membership in a
                // family whose data no longer exists, and neither role can create a new
                // family — a permanent dead end. Removing the roster makes their next
                // `confirmMembership` return `.revoked`, routing them through
                // `detachFromRevokedFamily` and into a clean personal family.
                // Rules: `allow delete: if canManageFamilyRoster(familyId)` — the caller
                // is a parent by definition of `mayTearDownSharedData`.
                for member in realMembers where member.id != uid {
                    try await familyRef.collection("members").document(member.id).delete()
                }
            } else {
                let callerIsParent = AccountErasureGate.isParentRole(callerRoleRaw)
                for babyId in babyIds {
                    let babyRef = familyRef.collection("babies").document(babyId)
                    try await eraseAuthoredData(under: babyRef, uid: uid)
                    if callerIsParent {
                        try await eraseProfileMembership(under: babyRef, uid: uid)
                    }
                }
                let legacyRef = db.collection("babies").document(familyId)
                try await eraseAuthoredData(under: legacyRef, uid: uid)
                if callerIsParent {
                    try await eraseProfileMembership(under: legacyRef, uid: uid)
                }
                try await verifyHealthDataAbsent(
                    parentPaths: healthDataParentPaths,
                    deletingUID: uid,
                    authoredOnly: true
                )
                if callerIsParent {
                    try await verifyProfileMembershipAbsent(
                        parentPaths: healthDataParentPaths,
                        uid: uid
                    )
                }
            }

            // Keep author cleanup and membership access ordered, while making the final
            // membership/user removal atomic so recovery cannot observe a half-finished exit.
            let batch = db.batch()
            if callerCreatedFamily {
                // The family doc survives as a non-reusable tombstone (rules forbid a
                // client delete), so it must not keep storing the erased user's UID.
                // Rules only accept this write together with the membership delete below.
                batch.updateData(["createdBy": ""], forDocument: familyRef)
            }
            batch.deleteDocument(familyRef.collection("members").document(uid))
            batch.deleteDocument(userRef)
            try await batch.commit()
        }
        return .erased
    }

    /// `permissionDenied` on reading one's OWN member doc means the doc no longer exists
    /// (rules require it to exist for the read). Reuses `FamilyManager`'s classifier so the
    /// two call sites cannot drift apart.
    private func callerIsStillMember(familyId: String, uid: String) async throws -> Bool {
        let ref = Firestore.firestore()
            .collection("families").document(familyId)
            .collection("members").document(uid)
        do {
            return try await ref.getDocument(source: .server).exists
        } catch let error where FamilyManager.classifyMembershipError(error) == .revoked {
            return false
        }
    }

    /// Final server check for routing data after health paths were verified while membership
    /// still existed. Pending local writes are not accepted as backend confirmation.
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

    private func discoverBabyIds(in familyRef: DocumentReference) async throws -> [String] {
        var ids = try await familyRef.collection("babies").getDocuments(source: .server)
            .documents
            .map(\.documentID)
            .filter { !$0.isEmpty }
        if let active = ActiveBaby.currentId, !ids.contains(active.uuidString) {
            ids.append(active.uuidString)
        }
        return ids
    }

    private func deleteBabyTree(
        familyRef: DocumentReference,
        familyId: String,
        babyId: String,
        ownerUID: String
    ) async throws {
        let babyRef = familyRef.collection("babies").document(babyId)
        for subcollection in BabySyncService.allSubcollections {
            try await deleteAllDocs(
                in: babyRef.collection(subcollection),
                subcollection: subcollection,
                ownerUID: ownerUID
            )
        }
        try await babyRef.collection("profile").document("info").delete()
        try await babyRef.delete()
        SyncWatermarkStore().reset(family: familyId, baby: babyId)
    }

    private func deleteLegacyFamilyTree(familyId: String, ownerUID: String) async throws {
        let oldParent = Firestore.firestore().collection("babies").document(familyId)
        for subcollection in BabySyncService.allSubcollections {
            try await Self.performLegacyDeletion {
                try await deleteAllDocs(
                    in: oldParent.collection(subcollection),
                    subcollection: subcollection,
                    ownerUID: ownerUID
                )
            }
        }
        try await Self.performLegacyDeletion {
            try await oldParent.collection("profile").document("info").delete()
        }
        try await Self.performLegacyDeletion {
            try await oldParent.delete()
        }
    }

    static func performLegacyDeletion(_ operation: () async throws -> Void) async throws {
        do {
            try await operation()
        } catch {
            let nsError = error as NSError
            guard nsError.domain == FirestoreErrorCode.errorDomain,
                  nsError.code == FirestoreErrorCode.notFound.rawValue else {
                throw error
            }
        }
    }

    static func healthDataParentPaths(familyId: String, babyIds: [String]) -> [String] {
        babyIds.map { "families/\(familyId)/babies/\($0)" } + ["babies/\(familyId)"]
    }

    static func healthDataCollectionPaths(
        parentPaths: [String],
        includingDeletionMarkers: Bool
    ) -> [String] {
        let subcollections = includingDeletionMarkers
            ? BabySyncService.allSubcollections
            : BabySyncService.allSubcollections.filter { $0 != "deletions" }
        return parentPaths.flatMap { parent in
            subcollections.map { "\(parent)/\($0)" }
        }
    }

    static func healthDataDocumentPaths(parentPaths: [String]) -> [String] {
        parentPaths.flatMap { [$0, "\($0)/profile/info"] }
    }

    private func verifyHealthDataAbsent(
        parentPaths: [String],
        deletingUID: String,
        authoredOnly: Bool
    ) async throws {
        let db = Firestore.firestore()
        for path in Self.healthDataCollectionPaths(
            parentPaths: parentPaths,
            includingDeletionMarkers: !authoredOnly
        ) {
            let collection = db.collection(path)
            let subcollection = String(path.split(separator: "/").last ?? "")
            let query: Query
            if BabySyncService.requiresAuthorScopedQuery(
                for: subcollection,
                authoredOnly: authoredOnly
            ) {
                query = collection.whereField("addedBy", isEqualTo: deletingUID)
            } else {
                query = collection
            }
            let snapshot = try await query.limit(to: 1).getDocuments(source: .server)
            guard snapshot.isEmpty, !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
        }

        guard !authoredOnly else { return }
        for path in Self.healthDataDocumentPaths(parentPaths: parentPaths) {
            let snapshot = try await db.document(path).getDocument(source: .server)
            guard !snapshot.exists, !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
        }
    }

    private func eraseAuthoredData(under parent: DocumentReference, uid: String) async throws {
        for subcollection in BabySyncService.allSubcollections where subcollection != "deletions" {
            let documents = try await parent.collection(subcollection)
                .whereField("addedBy", isEqualTo: uid)
                .getDocuments(source: .server)
                .documents
            for start in stride(from: 0, to: documents.count, by: 400) {
                let batch = Firestore.firestore().batch()
                for document in documents[start..<min(start + 400, documents.count)] {
                    switch AccountErasureGate.authoredDataAction(
                        subcollection: subcollection,
                        documentData: document.data(),
                        deletingUid: uid
                    ) {
                    case .delete:
                        batch.deleteDocument(document.reference)
                    case .anonymize:
                        guard let update = AccountErasureGate.authorAnonymizationUpdate(
                            documentData: document.data(),
                            deletingUid: uid
                        ) else { continue }
                        batch.updateData(update, forDocument: document.reference)
                    case nil:
                        continue
                    }
                }
                try await batch.commit()
            }
        }
    }

    /// `profile/info` carries `members: [{uid, role, name}]` written by
    /// `BabySyncService.setupBabyProfile`. It is NOT in `BabySyncService.allSubcollections`,
    /// so the scoped erase used to leave the departing parent's uid and display name in the
    /// child's profile forever — visible to the remaining co-parent.
    ///
    /// Rewrites the array filtered rather than using `arrayRemove`: `arrayRemove` needs an
    /// exact element match and `name` may have drifted since it was written.
    ///
    /// Rules: `families/{id}/babies/{babyId}/{subcollection}/{doc=**}` allows update for
    /// `canManageFamilyRoster` — satisfied while the caller's member doc still exists, i.e.
    /// before the exit batch commits. Only parents are ever written into `members`, so this
    /// is gated on the caller's parent role.
    private func eraseProfileMembership(under parent: DocumentReference, uid: String) async throws {
        let ref = parent.collection("profile").document("info")
        let snapshot = try await Self.readIgnoringMissingParent(ref)
        guard let members = snapshot?.data()?["members"] as? [[String: Any]] else { return }
        let remaining = members.filter { ($0["uid"] as? String) != uid }
        guard remaining.count != members.count else { return }
        try await ref.updateData(["members": remaining])
    }

    private func verifyProfileMembershipAbsent(parentPaths: [String], uid: String) async throws {
        let db = Firestore.firestore()
        for path in parentPaths {
            let ref = db.document("\(path)/profile/info")
            guard let snapshot = try await Self.readIgnoringMissingParent(ref) else { continue }
            guard !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
            let members = snapshot.data()?["members"] as? [[String: Any]] ?? []
            guard members.allSatisfy({ ($0["uid"] as? String) != uid }) else {
                throw AuthError.accountDeletionPending
            }
        }
    }

    /// The legacy `babies/{familyId}` tree may not exist at all; a missing parent must not
    /// fail the erase.
    private static func readIgnoringMissingParent(
        _ ref: DocumentReference
    ) async throws -> DocumentSnapshot? {
        do {
            let snapshot = try await ref.getDocument(source: .server)
            return snapshot.exists ? snapshot : nil
        } catch let error as NSError
            where error.domain == FirestoreErrorCode.errorDomain
            && error.code == FirestoreErrorCode.notFound.rawValue {
            return nil
        }
    }

    private func deleteAllDocs(
        in collection: CollectionReference,
        subcollection: String,
        ownerUID: String
    ) async throws {
        let query: Query
        if BabySyncService.requiresAuthorScopedQuery(for: subcollection) {
            query = collection.whereField("addedBy", isEqualTo: ownerUID)
        } else {
            query = collection
        }
        try await deleteAllDocs(in: query)
    }

    private func deleteAllDocs(in query: Query) async throws {
        let docs = try await query.getDocuments(source: .server).documents
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
                    // Cloud is server-confirmed clean: the user owns no data from here on,
                    // so the blocking marker must go regardless of what Auth does next.
                    pendingStore.clearPending()
                    do {
                        try await auth.deleteAccount(expectedUID: uid)
                        pendingAuthStore.clearPending()
                    } catch {
                        // Hand the Auth record to the non-blocking retry. Surfacing the error
                        // still lets Settings offer reauthentication in this session.
                        pendingAuthStore.markPending(uid: uid)
                        authError = error
                    }
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
    /// True while the account has been put back into use (a family is resolved again).
    /// Injected so the policy is testable without `FamilyManager.shared`.
    private let accountIsInUse: @MainActor () -> Bool

    init(
        cloudEraser: CloudAccountEraser,
        auth: any AccountAuthProtocol,
        pendingStore: PendingAccountDeletionStore,
        pendingAuthStore: PendingAuthAccountDeletionStore,
        suppressedRestoreStore: SuppressedFamilyRestoreStore,
        accountIsInUse: @MainActor @escaping () -> Bool = { FamilyManager.shared.familyId != nil }
    ) {
        self.cloudEraser = cloudEraser
        self.auth = auth
        self.pendingStore = pendingStore
        self.pendingAuthStore = pendingAuthStore
        self.suppressedRestoreStore = suppressedRestoreStore
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
            guard try await cloudEraser.isCloudDataPresent(uid: currentUid) == false else {
                return .continueDeletion // still on the server — keep the marker and retry next launch
            }
            // Server-confirmed clean. Releasing the blocking marker HERE is the fix for the
            // re-registration deadlock: with no data left, reusing the Auth uid is safe.
            pendingStore.clearPending()
            do {
                try await auth.deleteAccount(expectedUID: currentUid)
                pendingAuthStore.clearPending()
            } catch {
                pendingAuthStore.markPending(uid: currentUid)
            }
        } catch {
            // Leave the marker in place; the next launch retries.
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
