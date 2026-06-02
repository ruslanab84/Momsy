import Foundation
import FirebaseAuth

/// Erases the user's cloud footprint: the `babies/{babyId}` log tree plus the
/// `families/{familyId}` and `users/{uid}` documents. Abstracted so the deletion
/// flow can be unit-tested without Firestore.
protocol CloudAccountEraser {
    func deleteCloudData(uid: String) async throws
}

struct FirestoreAccountEraser: CloudAccountEraser {
    let babySync: BabySyncService

    func deleteCloudData(uid: String) async throws {
        try await babySync.deleteAllData()
        try await FamilyManager.shared.deleteFamilyAndUserDocs(uid: uid)
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
