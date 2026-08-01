import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

/// Erases the user's cloud footprint while retaining `families/{familyId}` as a
/// non-reusable tombstone. Abstracted so the deletion flow can be unit-tested
/// without Firestore.
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
                let callerRoleRaw = memberDocuments
                    .first { $0.documentID == uid }?
                    .data()["roleRaw"] as? String ?? ""
                if FamilyRole(storedRawValue: callerRoleRaw)?.canManageFamilyMembers == true {
                    for placeholder in legacyPlaceholders {
                        try await placeholder.reference.delete()
                    }
                }
                let mayTearDownSharedData = AccountErasureGate.mayTearDownSharedData(
                    memberIds: partition.realIds,
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
                        try await deleteBabyTree(familyRef: familyRef, familyId: familyId, babyId: babyId)
                    }
                    try await deleteLegacyFamilyTree(familyId: familyId)
                    try await verifyHealthDataAbsent(parentPaths: healthDataParentPaths)
                } else {
                    for babyId in babyIds {
                        try await eraseAuthoredData(
                            under: familyRef.collection("babies").document(babyId),
                            uid: uid
                        )
                    }
                    try await eraseAuthoredData(
                        under: db.collection("babies").document(familyId),
                        uid: uid
                    )
                    try await verifyHealthDataAbsent(
                        parentPaths: healthDataParentPaths,
                        authoredBy: uid
                    )
                }

                // Keep author cleanup and membership access ordered, while making the final
                // membership/user removal atomic so recovery cannot observe a half-finished exit.
                let batch = db.batch()
                batch.deleteDocument(familyRef.collection("members").document(uid))
                batch.deleteDocument(userRef)
                try await batch.commit()
            }
        } else {
            throw AuthError.accountDeletionPending
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
        return invites.metadata.hasPendingWrites || !invites.isEmpty
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
            try await Self.performLegacyDeletion {
                try await deleteAllDocs(in: oldParent.collection(subcollection))
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
        authoredBy uid: String? = nil
    ) async throws {
        let db = Firestore.firestore()
        for path in Self.healthDataCollectionPaths(
            parentPaths: parentPaths,
            includingDeletionMarkers: uid == nil
        ) {
            let collection = db.collection(path)
            let query: Query
            if let uid {
                query = collection.whereField("addedBy", isEqualTo: uid)
            } else {
                query = collection
            }
            let snapshot = try await query.limit(to: 1).getDocuments(source: .server)
            guard snapshot.isEmpty, !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
        }

        guard uid == nil else { return }
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

    private func deleteAllDocs(in ref: Query) async throws {
        let docs = try await ref.getDocuments(source: .server).documents
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

    /// Captures ownership before recovery can clear Auth and the marker. A different account
    /// becoming active while recovery awaits must not have its local data wiped.
    nonisolated static func shouldWipeDevice(
        pendingUidAtStart: String?,
        currentUidAtStart: String?,
        currentUidAfterRecovery: String?
    ) -> Bool {
        guard let pendingUidAtStart, currentUidAtStart == pendingUidAtStart else { return false }
        return currentUidAfterRecovery == nil || currentUidAfterRecovery == pendingUidAtStart
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
