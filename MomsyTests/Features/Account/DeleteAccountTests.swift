import Testing
@testable import Momsy
import Foundation
import AuthenticationServices
import FirebaseFirestore

// MARK: - Mocks

private struct MockCloudEraser: CloudAccountEraser {
    final class Calls: @unchecked Sendable {
        var uids: [String] = []
        var presentChecks: [String] = []
        var error: Error?
        var onDelete: (@MainActor () -> Void)?
        /// What `isCloudDataPresent` reports — `false` means "server confirms fully erased".
        var stillPresent = false
        var deleteCount: Int { uids.count }
    }
    let calls: Calls
    // Retains the removed faulty signal so the regression fails if recovery consults it again.
    var inviteMembership = false
    func deleteCloudData(uid: String) async throws {
        calls.uids.append(uid)
        await calls.onDelete?()
        if let error = calls.error { throw error }
    }
    func isCloudDataPresent(uid: String) async throws -> Bool {
        calls.presentChecks.append(uid)
        return calls.stillPresent
    }
    func hasInviteEstablishedMembership(uid: String) async throws -> Bool { inviteMembership }
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

@MainActor
private final class MockAuth: AccountAuthProtocol {
    var currentUID: String?
    var deleteError: Error?
    var deleteCount = 0
    var signOutCount = 0
    var expectedUIDs: [String] = []

    init(uid: String?) { currentUID = uid }

    func deleteAccount(expectedUID: String) async throws {
        deleteCount += 1
        expectedUIDs.append(expectedUID)
        guard currentUID == expectedUID else { throw AuthError.accountDeletionPending }
        if let deleteError { throw deleteError }
    }
    func signOut() throws { signOutCount += 1 }
}

private struct DummyError: Error {}

private final class MockPreferencesRepository: UserPreferencesRepository {
    func load() -> UserPreferences {
        UserPreferences(appTheme: "system", appLanguage: "en", unitSystem: "metric")
    }
    func save(_ prefs: UserPreferences) {}
}

@MainActor
private final class MockDeletionAuthenticator: AccountDeletionAuthenticating {
    var accountDeletionProvider: AccountDeletionProvider?
    var error: Error?
    var appleCount = 0
    var googleCount = 0

    init(provider: AccountDeletionProvider) {
        accountDeletionProvider = provider
    }

    func prepareAppleDeletionRequest(_ request: ASAuthorizationAppleIDRequest) {}

    func reauthenticateForDeletionWithApple(
        _ result: Result<ASAuthorization, Error>
    ) async throws {
        appleCount += 1
        if let error { throw error }
        accountDeletionProvider = nil
    }

    func reauthenticateForDeletionWithGoogle() async throws {
        googleCount += 1
        if let error { throw error }
        accountDeletionProvider = nil
    }
}

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
        MockAuth,
        MockPendingStore,
        MockSuppressedRestoreStore,
        () -> Int
    ) {
        let cloudCalls = MockCloudEraser.Calls()
        cloudCalls.error = cloudError
        cloudCalls.stillPresent = stillPresent
        let auth = MockAuth(uid: uid)
        auth.deleteError = authError
        let pending = MockPendingStore()
        let suppressed = MockSuppressedRestoreStore()
        var localWipes = 0
        let uc = DeleteAccountUseCase(
            cloudEraser: MockCloudEraser(calls: cloudCalls),
            auth: auth,
            pendingStore: pending,
            suppressedRestoreStore: suppressed,
            eraseLocal: { localWipes += 1 }
        )
        return (uc, cloudCalls, auth, pending, suppressed, { localWipes })
    }

    @Test("erases cloud, account, and local data for a signed-in user")
    func fullErasure() async throws {
        let (uc, cloud, auth, _, suppressed, wipes) = makeUseCase(uid: "abc")
        try await uc.execute()
        #expect(cloud.uids == ["abc"])
        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
        #expect(wipes() == 1)
    }

    @Test("keeps the session and deletion marker when recent authentication is required")
    func reauthRequiredDoesNotSignOutOrWipe() async {
        let (uc, _, auth, pending, _, wipes) = makeUseCase(authError: AuthError.reauthRequired)

        await #expect {
            try await uc.execute()
        } throws: { error in
            guard case AuthError.reauthRequired = error else { return false }
            return true
        }

        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        #expect(pending.pendingUid == "user-1")
        #expect(pending.clearCount == 0)
        #expect(wipes() == 0)
    }

    @Test("keeps deletion pending when provider revoke or Auth deletion fails")
    func authRetirementFailureKeepsPending() async {
        let (uc, _, auth, pending, _, wipes) = makeUseCase(authError: DummyError())

        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }

        #expect(auth.signOutCount == 0)
        #expect(pending.pendingUid == "user-1")
        #expect(pending.clearCount == 0)
        #expect(wipes() == 0)
    }

    @Test("never deletes a different Auth account if the session changes during cloud erase")
    func authRetirementIsBoundToOriginalUID() async {
        let (uc, cloud, auth, pending, _, wipes) = makeUseCase(uid: "user-1")
        cloud.onDelete = { auth.currentUID = "user-2" }

        await #expect {
            try await uc.execute()
        } throws: { error in
            guard case AuthError.accountDeletionPending = error else { return false }
            return true
        }

        #expect(auth.expectedUIDs == ["user-1"])
        #expect(pending.pendingUid == "user-1")
        #expect(pending.clearCount == 0)
        #expect(wipes() == 0)
    }

    @Test("with no authenticated user, skips cloud steps but still wipes local")
    func noUserWipesLocalOnly() async throws {
        let (uc, cloud, auth, _, suppressed, wipes) = makeUseCase(uid: nil)
        try await uc.execute()
        #expect(cloud.uids.isEmpty)
        #expect(auth.deleteCount == 0)
        #expect(suppressed.suppressedUIDs.isEmpty)
        #expect(wipes() == 1)
    }

    @Test("surfaces a cloud-erase error but still wipes the device clean")
    func cloudErrorStillWipesLocal() async throws {
        let (uc, _, auth, pending, suppressed, wipes) = makeUseCase(cloudError: DummyError())
        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }
        #expect(auth.deleteCount == 0)
        #expect(pending.pendingUid == "user-1")
        #expect(pending.clearCount == 0)
        #expect(suppressed.isRestoreSuppressed(for: "user-1"))
        #expect(wipes() == 1)
    }

    @Test("marks deletion pending, verifies against the server, then clears the marker")
    func clearsPendingOnceServerConfirmsErasure() async throws {
        let (uc, cloud, _, pending, suppressed, _) = makeUseCase(uid: "abc")
        try await uc.execute()
        #expect(cloud.presentChecks == ["abc"])   // server-truth re-check happened
        #expect(pending.markCount == 1)
        #expect(pending.clearCount == 1)
        #expect(pending.pendingUid == nil)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }

    @Test("keeps the marker and the auth session when the server still reports data after erase")
    func keepsPendingWhenServerStillHasData() async {
        let (uc, _, auth, pending, suppressed, wipes) = makeUseCase(uid: "abc", stillPresent: true)
        await #expect {
            try await uc.execute()
        } throws: { error in
            guard case AuthError.accountDeletionPending = error else { return false }
            return true
        }
        #expect(pending.pendingUid == "abc")   // retained so launch recovery finishes the erase
        #expect(auth.deleteCount == 0)         // session kept alive for recovery, not torn down
        #expect(auth.signOutCount == 0)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
        #expect(wipes() == 1)                  // device still left clean for the user
    }
}

@Suite("FirestoreAccountEraser")
struct FirestoreAccountEraserTests {
    @Test("legacy deletion ignores notFound but propagates every other error")
    func legacyDeletionErrorPolicy() async throws {
        let notFound = NSError(
            domain: FirestoreErrorCode.errorDomain,
            code: FirestoreErrorCode.notFound.rawValue
        )
        try await FirestoreAccountEraser.performLegacyDeletion { throw notFound }

        let propagatedErrors = [
            NSError(
                domain: FirestoreErrorCode.errorDomain,
                code: FirestoreErrorCode.unavailable.rawValue
            ),
            NSError(
                domain: FirestoreErrorCode.errorDomain,
                code: FirestoreErrorCode.permissionDenied.rawValue
            ),
            NSError(domain: "not-firestore", code: FirestoreErrorCode.notFound.rawValue),
        ]
        for expected in propagatedErrors {
            await #expect {
                try await FirestoreAccountEraser.performLegacyDeletion { throw expected }
            } throws: { error in
                let actual = error as NSError
                return actual.domain == expected.domain && actual.code == expected.code
            }
        }
    }

    @Test("server verification covers every current and legacy health path")
    func serverVerificationPathPlan() {
        let parents = FirestoreAccountEraser.healthDataParentPaths(
            familyId: "family-1",
            babyIds: ["baby-1", "baby-2"]
        )
        #expect(parents == [
            "families/family-1/babies/baby-1",
            "families/family-1/babies/baby-2",
            "babies/family-1",
        ])

        let collectionPaths = FirestoreAccountEraser.healthDataCollectionPaths(
            parentPaths: parents,
            includingDeletionMarkers: true
        )
        let documentPaths = FirestoreAccountEraser.healthDataDocumentPaths(parentPaths: parents)
        #expect(collectionPaths.count == parents.count * BabySyncService.allSubcollections.count)
        #expect(documentPaths.count == parents.count * 2)
        #expect(collectionPaths.count + documentPaths.count == 66)

        for parent in parents {
            #expect(documentPaths.contains(parent))
            #expect(documentPaths.contains("\(parent)/profile/info"))
            for subcollection in BabySyncService.allSubcollections {
                #expect(collectionPaths.contains("\(parent)/\(subcollection)"))
            }
        }
    }
}

@Suite("Settings account deletion reauthentication", .serialized)
@MainActor
struct SettingsAccountDeletionReauthenticationTests {
    private func makeViewModel(
        provider: AccountDeletionProvider,
        updateCloudSync: @MainActor @escaping (Bool) async throws -> Void = { _ in }
    ) -> (SettingsViewModel, MockAuth, MockDeletionAuthenticator, () -> Int) {
        let cloud = MockCloudEraser.Calls()
        let auth = MockAuth(uid: "user-1")
        let pending = MockPendingStore()
        let authenticator = MockDeletionAuthenticator(provider: provider)
        var wipes = 0
        let useCase = DeleteAccountUseCase(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: auth,
            pendingStore: pending,
            suppressedRestoreStore: MockSuppressedRestoreStore(),
            eraseLocal: { wipes += 1 }
        )
        let viewModel = SettingsViewModel(
            repo: MockPreferencesRepository(),
            deleteAccount: useCase,
            accountAuth: authenticator,
            cloudSyncEnabled: false,
            updateCloudSync: updateCloudSync
        )
        return (viewModel, auth, authenticator, { wipes })
    }

    @Test("Apple reauthentication retries account deletion")
    func appleSuccessRetriesDeletion() async throws {
        let (viewModel, auth, authenticator, wipes) = makeViewModel(provider: .apple)
        await viewModel.requestAccountDeletion()
        #expect(viewModel.showsDeletionReauthentication)
        #expect(auth.deleteCount == 0)
        #expect(wipes() == 0)

        viewModel.completeAppleDeletion(.failure(DummyError()))
        try await waitForDeletion { auth.deleteCount == 1 }

        #expect(authenticator.appleCount == 1)
        #expect(wipes() == 1)
        #expect(!viewModel.showsDeletionReauthentication)
    }

    @Test("Google reauthentication retries account deletion")
    func googleSuccessRetriesDeletion() async throws {
        let (viewModel, auth, authenticator, wipes) = makeViewModel(provider: .google)
        await viewModel.requestAccountDeletion()
        #expect(auth.deleteCount == 0)
        #expect(wipes() == 0)

        viewModel.reauthenticateDeletionWithGoogle()
        try await waitForDeletion { auth.deleteCount == 1 }

        #expect(authenticator.googleCount == 1)
        #expect(wipes() == 1)
        #expect(!viewModel.showsDeletionReauthentication)
    }

    @Test("provider failure keeps deletion pending in the UI")
    func providerFailureDoesNotDelete() async throws {
        let (viewModel, auth, authenticator, wipes) = makeViewModel(provider: .google)
        authenticator.error = DummyError()
        await viewModel.requestAccountDeletion()

        viewModel.reauthenticateDeletionWithGoogle()
        try await waitForDeletion { viewModel.reauthenticationError != nil }

        #expect(auth.deleteCount == 0)
        #expect(wipes() == 0)
        #expect(viewModel.showsDeletionReauthentication)
    }

    @Test("cloud sync error is surfaced and restores the toggle")
    func cloudSyncFailureRestoresToggle() async throws {
        let (viewModel, _, _, _) = makeViewModel(
            provider: .apple,
            updateCloudSync: { _ in throw DummyError() }
        )

        viewModel.setCloudSyncEnabled(true)
        try await waitForDeletion { viewModel.cloudSyncError != nil }

        #expect(!viewModel.cloudSyncEnabled)
    }
}

@MainActor
private func waitForDeletion(
    timeout: Duration = .seconds(2),
    until condition: @escaping () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !condition() {
        guard clock.now < deadline else { throw DummyError() }
        await Task.yield()
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

    @Test("keeps the session and marker when recovery needs recent authentication")
    func recoveryReauthRequiredKeepsSessionAndMarker() async {
        let cloud = MockCloudEraser.Calls()
        let auth = MockAuth(uid: "abc")
        auth.deleteError = AuthError.reauthRequired
        let pending = MockPendingStore(pendingUid: "abc")
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: auth,
            pendingStore: pending,
            suppressedRestoreStore: MockSuppressedRestoreStore())

        await rec.runIfNeeded()

        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        #expect(pending.pendingUid == "abc")
        #expect(pending.clearCount == 0)
    }

    @Test("continues a pending erase when the existing membership has an old invite code")
    func recoveryContinuesEraseForLegacyInviteMembership() async throws {
        let cloud = MockCloudEraser.Calls()
        let pending = MockPendingStore(pendingUid: "u1")
        let suppressed = MockSuppressedRestoreStore()
        suppressed.suppressRestore(for: "u1")
        let auth = MockAuth(uid: "u1")
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud, inviteMembership: true),
            auth: auth,
            pendingStore: pending,
            suppressedRestoreStore: suppressed)

        await rec.runIfNeeded()

        #expect(cloud.deleteCount == 1)
        #expect(auth.deleteCount == 1)
        #expect(pending.pendingUid == nil)
        #expect(suppressed.isRestoreSuppressed(for: "u1"))
    }

    // MARK: - shouldWipeDevice (guards AppContainer.recoverPendingAccountDeletion)

    @Test("wipes after recovery clears Auth and the marker for the owning session")
    func recoveryCompletionStillRequiresWipe() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingUidAtStart: "u1",
            currentUidAtStart: "u1",
            currentUidAfterRecovery: nil
        ))
    }

    @Test("wipes the device while the pending deletion owns the session")
    func wipesForOwningSession() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingUidAtStart: "u1",
            currentUidAtStart: "u1",
            currentUidAfterRecovery: "u1"
        ))
    }

    @Test("no device wipe for a stale marker with nobody signed in")
    func skipsWipeWhenSignedOut() {
        // Otherwise a marker whose uid never signs in again re-wipes — and so resets
        // onboarding — on every cold launch, forever.
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingUidAtStart: "u1",
            currentUidAtStart: nil,
            currentUidAfterRecovery: nil
        ) == false)
    }

    @Test("no device wipe when a different account is signed in")
    func skipsWipeForOtherUser() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingUidAtStart: "u1",
            currentUidAtStart: "u2",
            currentUidAfterRecovery: "u2"
        ) == false)
    }

    @Test("no device wipe if the session switches accounts during recovery")
    func skipsWipeAfterAccountSwitch() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingUidAtStart: "u1",
            currentUidAtStart: "u1",
            currentUidAfterRecovery: "u2"
        ) == false)
    }
}
