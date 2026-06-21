import Testing
@testable import Momsy
import Foundation
import UIKit

// MARK: - Mocks

private struct MockCloudEraser: CloudAccountEraser {
    final class Calls: @unchecked Sendable { var uids: [String] = []; var error: Error? }
    let calls: Calls
    func deleteCloudData(uid: String) async throws {
        calls.uids.append(uid)
        if let error = calls.error { throw error }
    }
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
        authError: Error? = nil
    ) -> (DeleteAccountUseCase, MockCloudEraser.Calls, MockPhotoStorage, MockAuth, () -> Int) {
        let cloudCalls = MockCloudEraser.Calls()
        cloudCalls.error = cloudError
        let photo = MockPhotoStorage()
        let auth = MockAuth(uid: uid)
        auth.deleteError = authError
        var localWipes = 0
        let uc = DeleteAccountUseCase(
            cloudEraser: MockCloudEraser(calls: cloudCalls),
            photoStorage: photo,
            auth: auth,
            eraseLocal: { localWipes += 1 }
        )
        return (uc, cloudCalls, photo, auth, { localWipes })
    }

    @Test("erases cloud, photos, account, and local data for a signed-in user")
    func fullErasure() async throws {
        let (uc, cloud, photo, auth, wipes) = makeUseCase(uid: "abc")
        try await uc.execute()
        #expect(cloud.uids == ["abc"])
        #expect(photo.deleteAllCount == 1)
        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        #expect(wipes() == 1)
    }

    @Test("falls back to sign-out when account deletion needs re-auth")
    func reauthFallback() async throws {
        let (uc, _, _, auth, wipes) = makeUseCase(authError: AuthError.reauthRequired)
        try await uc.execute()
        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 1)
        #expect(wipes() == 1)
    }

    @Test("with no authenticated user, skips cloud steps but still wipes local")
    func noUserWipesLocalOnly() async throws {
        let (uc, cloud, photo, auth, wipes) = makeUseCase(uid: nil)
        try await uc.execute()
        #expect(cloud.uids.isEmpty)
        #expect(photo.deleteAllCount == 0)
        #expect(auth.deleteCount == 0)
        #expect(wipes() == 1)
    }

    @Test("surfaces a cloud-erase error but still wipes the device clean")
    func cloudErrorStillWipesLocal() async throws {
        let (uc, _, _, _, wipes) = makeUseCase(cloudError: DummyError())
        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }
        #expect(wipes() == 1)
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
