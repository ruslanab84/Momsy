import Foundation
import FirebaseAuth

/// Erases the user's cloud footprint: the `babies/{babyId}` log tree plus the
/// `families/{familyId}` and `users/{uid}` documents. Abstracted so the deletion
/// flow can be unit-tested without Firestore.
protocol CloudAccountEraser {
    func deleteCloudData(uid: String) async throws
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
        // Shared baby data + the family doc are torn down ONLY when the caller is the
        // last member. A co-parent's deletion must leave the family and its logs intact.
        let soleMember = try await FamilyManager.shared.isSoleMember(uid: uid)
        if soleMember {
            try await RosterErasure.eraseAll(using: babySync, locallyActiveId: ActiveBaby.currentId)
        }
        try await FamilyManager.shared.leaveFamily(uid: uid, tearDownSharedFamily: soleMember)
    }
}

/// The slice of auth the deletion flow needs. `AuthManager` conforms; tests use a mock.
@MainActor
protocol AccountAuthProtocol: AnyObject {
    var currentUID: String? { get }
    func deleteAccount() async throws
    func signOut() throws
}

extension AuthManager: AccountAuthProtocol {
    var currentUID: String? { firebaseUser?.uid }
}

/// GDPR "right to erasure" orchestrator. Deletes cloud data while still
/// authenticated, removes Storage photos, deletes the auth account (falling back
/// to sign-out when re-auth would be required), then always wipes the device clean
/// last so the app ends in a fresh, pre-onboarding state even if a cloud step fails.
@MainActor
final class DeleteAccountUseCase {
    private let cloudEraser: CloudAccountEraser
    private let photoStorage: any PhotoStorageService
    private let auth: any AccountAuthProtocol
    private let eraseLocal: @MainActor () throws -> Void

    init(
        cloudEraser: CloudAccountEraser,
        photoStorage: any PhotoStorageService,
        auth: any AccountAuthProtocol,
        eraseLocal: @MainActor @escaping () throws -> Void
    ) {
        self.cloudEraser = cloudEraser
        self.photoStorage = photoStorage
        self.auth = auth
        self.eraseLocal = eraseLocal
    }

    func execute() async throws {
        var cloudError: Error?

        if let uid = auth.currentUID {
            do {
                try await cloudEraser.deleteCloudData(uid: uid)
                try await photoStorage.deleteAll()
                do {
                    try await auth.deleteAccount()
                } catch AuthError.reauthRequired {
                    // Data is already gone; just end the session locally.
                    try? auth.signOut()
                }
            } catch {
                cloudError = error
            }
        }

        // Always leave the device clean, even if the cloud erase failed.
        try eraseLocal()
        FamilyManager.shared.reset()

        if let cloudError { throw cloudError }
    }
}
