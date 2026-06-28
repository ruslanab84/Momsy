import Testing
@testable import Momsy
import Foundation
import UIKit

// MARK: - Mocks

private struct MockCloudEraser: CloudAccountEraser {
    final class Calls: @unchecked Sendable {
        var uids: [String] = []
        var presentChecks: [String] = []
        var error: Error?
        /// What `isCloudDataPresent` reports — `false` means "server confirms fully erased".
        var stillPresent = false
    }
    let calls: Calls
    func deleteCloudData(uid: String) async throws {
        calls.uids.append(uid)
        if let error = calls.error { throw error }
    }
    func isCloudDataPresent(uid: String) async throws -> Bool {
        calls.presentChecks.append(uid)
        return calls.stillPresent
    }
}

private final class MockPendingStore: PendingAccountDeletionStore, @unchecked Sendable {
    private(set) var pendingUid: String?
    var markCount = 0
    var clearCount = 0
    init(pendingUid: String? = nil) { self.pendingUid = pendingUid }
    func markPending(uid: String) { pendingUid = uid; markCount += 1 }
    func loadPending() -> String? { pendingUid }
    func clearPending() { pendingUid = nil; clearCount += 1 }
}

private final class MockSuppressedRestoreStore: SuppressedFamilyRestoreStore, @unchecked Sendable {
    private(set) var suppressedUIDs: Set<String> = []
    func suppressRestore(for uid: String) { suppressedUIDs.insert(uid) }
    func isRestoreSuppressed(for uid: String) -> Bool { suppressedUIDs.contains(uid) }
    func clearSuppression(for uid: String) { suppressedUIDs.remove(uid) }
}

private final class MockPhotoStorage: PhotoStorageService, @unchecked Sendable {
    var deleteAllCount = 0
    func save(_ image: UIImage, forID id: UUID) async throws -> String { "" }
    func load(atPath path: String) async -> UIImage? { nil }
    func delete(atPath path: String) async throws {}
    func deleteAll() async throws { deleteAllCount += 1 }
}

@MainActor
private final class MockAuth: AccountAuthProtocol {
    var currentUID: String?
    var deleteError: Error?
    var deleteCount = 0
    var signOutCount = 0

    init(uid: String?) { currentUID = uid }

    func deleteAccount() async throws {
        deleteCount += 1
        if let deleteError { throw deleteError }
    }
    func signOut() throws { signOutCount += 1 }
}

private struct DummyError: Error {}

// MARK: - Tests

@Suite("DeleteAccountUseCase", .serialized)
@MainActor
struct DeleteAccountTests {

    private func makeUseCase(
        uid: String? = "user-1",
        cloudError: Error? = nil,
        authError: Error? = nil,
        stillPresent: Bool = false
    ) -> (
        DeleteAccountUseCase,
        MockCloudEraser.Calls,
        MockPhotoStorage,
        MockAuth,
        MockPendingStore,
        MockSuppressedRestoreStore,
        () -> Int
    ) {
        let cloudCalls = MockCloudEraser.Calls()
        cloudCalls.error = cloudError
        cloudCalls.stillPresent = stillPresent
        let photo = MockPhotoStorage()
        let auth = MockAuth(uid: uid)
        auth.deleteError = authError
        let pending = MockPendingStore()
        let suppressed = MockSuppressedRestoreStore()
        var localWipes = 0
        let uc = DeleteAccountUseCase(
            cloudEraser: MockCloudEraser(calls: cloudCalls),
            photoStorage: photo,
            auth: auth,
            pendingStore: pending,
            suppressedRestoreStore: suppressed,
            eraseLocal: { localWipes += 1 }
        )
        return (uc, cloudCalls, photo, auth, pending, suppressed, { localWipes })
    }

    @Test("erases cloud, photos, account, and local data for a signed-in user")
    func fullErasure() async throws {
        let (uc, cloud, photo, auth, _, suppressed, wipes) = makeUseCase(uid: "abc")
        try await uc.execute()
        #expect(cloud.uids == ["abc"])
        #expect(photo.deleteAllCount == 1)
        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
        #expect(wipes() == 1)
    }

    @Test("falls back to sign-out when account deletion needs re-auth")
    func reauthFallback() async throws {
        let (uc, _, _, auth, _, _, wipes) = makeUseCase(authError: AuthError.reauthRequired)
        try await uc.execute()
        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 1)
        #expect(wipes() == 1)
    }

    @Test("with no authenticated user, skips cloud steps but still wipes local")
    func noUserWipesLocalOnly() async throws {
        let (uc, cloud, photo, auth, _, suppressed, wipes) = makeUseCase(uid: nil)
        try await uc.execute()
        #expect(cloud.uids.isEmpty)
        #expect(photo.deleteAllCount == 0)
        #expect(auth.deleteCount == 0)
        #expect(suppressed.suppressedUIDs.isEmpty)
        #expect(wipes() == 1)
    }

    @Test("surfaces a cloud-erase error but still wipes the device clean")
    func cloudErrorStillWipesLocal() async throws {
        let (uc, _, _, _, _, suppressed, wipes) = makeUseCase(cloudError: DummyError())
        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }
        #expect(suppressed.isRestoreSuppressed(for: "user-1"))
        #expect(wipes() == 1)
    }

    @Test("marks deletion pending, verifies against the server, then clears the marker")
    func clearsPendingOnceServerConfirmsErasure() async throws {
        let (uc, cloud, _, _, pending, suppressed, _) = makeUseCase(uid: "abc")
        try await uc.execute()
        #expect(cloud.presentChecks == ["abc"])   // server-truth re-check happened
        #expect(pending.markCount == 1)
        #expect(pending.clearCount == 1)
        #expect(pending.pendingUid == nil)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }

    @Test("keeps the marker and the auth session when the server still reports data after erase")
    func keepsPendingWhenServerStillHasData() async throws {
        let (uc, _, _, auth, pending, suppressed, wipes) = makeUseCase(uid: "abc", stillPresent: true)
        try await uc.execute()
        #expect(pending.pendingUid == "abc")   // retained so launch recovery finishes the erase
        #expect(auth.deleteCount == 0)         // session kept alive for recovery, not torn down
        #expect(auth.signOutCount == 0)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
        #expect(wipes() == 1)                  // device still left clean for the user
    }
}

// MARK: - Roster-wide erasure (multi-child GDPR coverage)

/// Records which child each `deleteAllData()` call targeted by reading the task-local
/// `ActiveBaby.syncTargetOverride` that scopes the cloud path for that single erase.
private final class MockRosterEraser: BabyRosterDataEraser, @unchecked Sendable {
    let rosterIds: [String]
    private(set) var erasedTargets: [String] = []
    init(rosterIds: [String]) { self.rosterIds = rosterIds }
    func discoverAllBabyIds() async -> [String] { rosterIds }
    func deleteAllData() async throws {
        erasedTargets.append(ActiveBaby.syncTargetOverride?.uuidString ?? "<active-path>")
    }
}

@Suite("RosterErasure")
struct RosterErasureTests {

    @Test("erases every child in the family roster, not just the active one")
    func erasesEntireRoster() async throws {
        let a = UUID(), b = UUID(), c = UUID()
        let mock = MockRosterEraser(rosterIds: [a, b, c].map(\.uuidString))
        try await RosterErasure.eraseAll(using: mock, locallyActiveId: a)
        #expect(Set(mock.erasedTargets) == Set([a, b, c].map(\.uuidString)))
        #expect(mock.erasedTargets.count == 3)
    }

    @Test("includes a locally-active child the roster read missed")
    func includesLocalActiveMissingFromRoster() async throws {
        let inRoster = UUID(), localOnly = UUID()
        let mock = MockRosterEraser(rosterIds: [inRoster.uuidString])
        try await RosterErasure.eraseAll(using: mock, locallyActiveId: localOnly)
        #expect(Set(mock.erasedTargets) == Set([inRoster, localOnly].map(\.uuidString)))
    }

    @Test("with an empty roster and no active child, erases the active path once")
    func emptyRosterFallsBackToActivePath() async throws {
        let mock = MockRosterEraser(rosterIds: [])
        try await RosterErasure.eraseAll(using: mock, locallyActiveId: nil)
        #expect(mock.erasedTargets == ["<active-path>"])
    }
}

// MARK: - Launch recovery (completes an interrupted / server-incomplete erase)

@Suite("AccountDeletionRecovery", .serialized)
@MainActor
struct AccountDeletionRecoveryTests {

    @Test("completes the pending erase for the re-authenticated user and clears the marker")
    func recoversForMatchingUser() async throws {
        let cloud = MockCloudEraser.Calls()
        let auth = MockAuth(uid: "abc")
        let pending = MockPendingStore(pendingUid: "abc")
        let suppressed = MockSuppressedRestoreStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: auth,
            pendingStore: pending,
            suppressedRestoreStore: suppressed)

        await rec.runIfNeeded()

        #expect(cloud.uids == ["abc"])         // re-ran the cloud erase
        #expect(pending.pendingUid == nil)     // and cleared the marker once verified gone
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }

    @Test("does nothing when no deletion is pending")
    func noPendingIsNoOp() async throws {
        let cloud = MockCloudEraser.Calls()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: MockAuth(uid: "abc"),
            pendingStore: MockPendingStore(pendingUid: nil),
            suppressedRestoreStore: MockSuppressedRestoreStore())

        await rec.runIfNeeded()

        #expect(cloud.uids.isEmpty)
    }

    @Test("leaves the marker untouched when a different user is signed in")
    func keepsMarkerForOtherUser() async throws {
        let cloud = MockCloudEraser.Calls()
        let pending = MockPendingStore(pendingUid: "abc")
        let suppressed = MockSuppressedRestoreStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: MockAuth(uid: "someone-else"),
            pendingStore: pending,
            suppressedRestoreStore: suppressed)

        await rec.runIfNeeded()

        #expect(cloud.uids.isEmpty)
        #expect(pending.pendingUid == "abc")
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }

    @Test("keeps the marker when the server still reports data after the recovery attempt")
    func keepsMarkerWhenVerificationStillFails() async throws {
        let cloud = MockCloudEraser.Calls()
        cloud.stillPresent = true
        let pending = MockPendingStore(pendingUid: "abc")
        let suppressed = MockSuppressedRestoreStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: MockAuth(uid: "abc"),
            pendingStore: pending,
            suppressedRestoreStore: suppressed)

        await rec.runIfNeeded()

        #expect(cloud.uids == ["abc"])         // attempted
        #expect(pending.pendingUid == "abc")   // but not cleared — will retry next launch
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }
}
