import Testing
@testable import Momsy
import Foundation
import AuthenticationServices
import FirebaseFirestore

// MARK: - Mocks

private struct MockCloudEraser: CloudAccountEraser {
    final class Calls: @unchecked Sendable {
        var uids: [String] = []
        var familyHints: [String?] = []
        var presentChecks: [String] = []
        var error: Error?
        var onDelete: (@MainActor () -> Void)?
        var outcome: AccountErasureOutcome = .erased
        var stillPresent = false
        var deleteCount: Int { uids.count }
    }
    let calls: Calls
    func deleteCloudData(uid: String, familyIdHint: String?) async throws -> AccountErasureOutcome {
        calls.uids.append(uid)
        calls.familyHints.append(familyIdHint)
        await calls.onDelete?()
        if let error = calls.error { throw error }
        return calls.outcome
    }
    func isCloudDataPresent(uid: String) async throws -> Bool {
        calls.presentChecks.append(uid)
        return calls.stillPresent
    }
}

private final class MockPendingStore: PendingAccountDeletionStore, @unchecked Sendable {
    private(set) var pending: PendingAccountDeletion?
    var markCount = 0
    var clearCount = 0
    init(pendingUid: String? = nil, familyId: String? = nil) {
        pending = pendingUid.map { PendingAccountDeletion(uid: $0, familyId: familyId) }
    }
    var pendingUid: String? { pending?.uid }
    func markPending(uid: String, familyId: String?) {
        pending = PendingAccountDeletion(uid: uid, familyId: familyId); markCount += 1
    }
    func loadPending() -> PendingAccountDeletion? { pending }
    func clearPending() { pending = nil; clearCount += 1 }
}

private final class MockPendingAuthStore: PendingAuthAccountDeletionStore, @unchecked Sendable {
    private(set) var pendingUid: String?
    func markPending(uid: String) { pendingUid = uid }
    func loadPending() -> String? { pendingUid }
    func clearPending() { pendingUid = nil }
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
        MockPendingAuthStore,
        MockSuppressedRestoreStore,
        () -> Int
    ) {
        let cloudCalls = MockCloudEraser.Calls()
        cloudCalls.error = cloudError
        cloudCalls.stillPresent = stillPresent
        let auth = MockAuth(uid: uid)
        auth.deleteError = authError
        let pending = MockPendingStore()
        let authPending = MockPendingAuthStore()
        let suppressed = MockSuppressedRestoreStore()
        var localWipes = 0
        let uc = DeleteAccountUseCase(
            cloudEraser: MockCloudEraser(calls: cloudCalls),
            auth: auth,
            pendingStore: pending,
            pendingAuthStore: authPending,
            suppressedRestoreStore: suppressed,
            eraseLocal: { localWipes += 1 }
        )
        return (uc, cloudCalls, auth, pending, authPending, suppressed, { localWipes })
    }

    @Test("erases cloud, account, and local data for a signed-in user")
    func fullErasure() async throws {
        let (uc, cloud, auth, _, _, suppressed, wipes) = makeUseCase(uid: "abc")
        try await uc.execute()
        #expect(cloud.uids == ["abc"])
        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
        #expect(wipes() == 1)
    }

    @Test("wipes the device and releases the blocking marker when only Auth deletion fails")
    func reauthRequiredStillCompletesTheErasure() async {
        let (uc, _, auth, pending, authPending, _, wipes) = makeUseCase(authError: AuthError.reauthRequired)

        await #expect {
            try await uc.execute()
        } throws: { error in
            guard case AuthError.reauthRequired = error else { return false }
            return true
        }

        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        // The cloud is server-confirmed clean, so the marker that blocks re-registration
        // must go; only the non-blocking Auth retry survives.
        #expect(pending.pendingUid == nil)
        #expect(pending.clearCount == 1)
        #expect(authPending.pendingUid == "user-1")
        // …and the device is wiped, so the deletion cannot undo itself on the next launch.
        #expect(wipes() == 1)
    }

    @Test("hands a failed provider revoke to the Auth retry without blocking re-registration")
    func authRetirementFailureDefersToAuthRetry() async {
        let (uc, _, auth, pending, authPending, _, wipes) = makeUseCase(authError: DummyError())

        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }

        #expect(auth.signOutCount == 0)
        #expect(pending.pendingUid == nil)
        #expect(authPending.pendingUid == "user-1")
        #expect(wipes() == 1)
    }

    @Test("never deletes a different Auth account if the session changes during cloud erase")
    func authRetirementIsBoundToOriginalUID() async {
        let (uc, cloud, auth, pending, authPending, _, wipes) = makeUseCase(uid: "user-1")
        cloud.onDelete = { auth.currentUID = "user-2" }

        await #expect {
            try await uc.execute()
        } throws: { error in
            guard case AuthError.accountDeletionPending = error else { return false }
            return true
        }

        #expect(auth.expectedUIDs == ["user-1"])
        // The retry stays pinned to the original uid; recovery re-checks the signed-in
        // account before acting, so "user-2" can never be deleted in its place.
        #expect(pending.pendingUid == nil)
        #expect(authPending.pendingUid == "user-1")
        #expect(wipes() == 1)
    }

    @Test("with no authenticated user, skips cloud steps but still wipes local")
    func noUserWipesLocalOnly() async throws {
        let (uc, cloud, auth, _, _, suppressed, wipes) = makeUseCase(uid: nil)
        try await uc.execute()
        #expect(cloud.uids.isEmpty)
        #expect(auth.deleteCount == 0)
        #expect(suppressed.suppressedUIDs.isEmpty)
        #expect(wipes() == 1)
    }

    @Test("surfaces a cloud-erase error but still wipes the device clean")
    func cloudErrorStillWipesLocal() async throws {
        let (uc, _, auth, pending, _, suppressed, wipes) = makeUseCase(cloudError: DummyError())
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
        let (uc, cloud, _, pending, _, suppressed, _) = makeUseCase(uid: "abc")
        try await uc.execute()
        #expect(cloud.presentChecks == ["abc"])   // server-truth re-check happened
        #expect(pending.markCount == 1)
        #expect(pending.clearCount == 1)
        #expect(pending.pendingUid == nil)
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }

    @Test("keeps the marker and the auth session when the server still reports data after erase")
    func keepsPendingWhenServerStillHasData() async {
        let (uc, _, auth, pending, _, suppressed, wipes) = makeUseCase(uid: "abc", stillPresent: true)
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
    @Test("private wellbeing queries remain author scoped during full teardown")
    func privateWellbeingQueryScope() {
        #expect(BabySyncService.requiresAuthorScopedQuery(for: "momSleepLogs"))
        #expect(BabySyncService.requiresAuthorScopedQuery(for: "waterIntakeLogs"))
        #expect(!BabySyncService.requiresAuthorScopedQuery(for: "feedingLogs"))
        #expect(BabySyncService.requiresAuthorScopedQuery(
            for: "feedingLogs",
            authoredOnly: true
        ))
    }

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
        let authPending = MockPendingAuthStore()
        let authenticator = MockDeletionAuthenticator(provider: provider)
        var wipes = 0
        let useCase = DeleteAccountUseCase(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: auth,
            pendingStore: pending,
            pendingAuthStore: authPending,
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

// MARK: - Launch recovery (completes an interrupted / server-incomplete erase)

@Suite("AccountDeletionRecovery", .serialized)
@MainActor
struct AccountDeletionRecoveryTests {

    @Test("completes the pending erase for the re-authenticated user and clears the marker")
    func recoversForMatchingUser() async throws {
        let cloud = MockCloudEraser.Calls()
        let auth = MockAuth(uid: "abc")
        let pending = MockPendingStore(pendingUid: "abc")
        let authPending = MockPendingAuthStore()
        let suppressed = MockSuppressedRestoreStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: auth,
            pendingStore: pending,
            pendingAuthStore: authPending,
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
            pendingAuthStore: MockPendingAuthStore(),
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
            pendingAuthStore: MockPendingAuthStore(),
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
            pendingAuthStore: MockPendingAuthStore(),
            suppressedRestoreStore: suppressed)

        await rec.runIfNeeded()

        #expect(cloud.uids == ["abc"])         // attempted
        #expect(pending.pendingUid == "abc")   // but not cleared — will retry next launch
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }

    @Test("keeps the session and marker when the server still reports data during recovery")
    func recoveryKeepsMarkerWhileServerStillHasData() async {
        let cloud = MockCloudEraser.Calls()
        cloud.stillPresent = true
        let auth = MockAuth(uid: "abc")
        auth.deleteError = AuthError.reauthRequired
        let pending = MockPendingStore(pendingUid: "abc", familyId: "fam-1")
        let authPending = MockPendingAuthStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud), auth: auth,
            pendingStore: pending, pendingAuthStore: authPending,
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { false })

        await rec.runIfNeeded()

        #expect(auth.deleteCount == 0)        // Auth is never touched before the cloud is clean
        #expect(pending.pendingUid == "abc")  // marker survives for the next launch
        #expect(authPending.pendingUid == nil)
    }

    @Test("drives the Auth retry when only the non-blocking marker is left")
    func runsAuthRetryWithoutBlockingMarker() async {
        let authPending = MockPendingAuthStore()
        authPending.markPending(uid: "abc")
        let auth = MockAuth(uid: "abc")
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: .init()), auth: auth,
            pendingStore: MockPendingStore(pendingUid: nil), pendingAuthStore: authPending,
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { false })

        await rec.runIfNeeded()

        #expect(auth.deleteCount == 1)
        #expect(authPending.pendingUid == nil)
    }

    @Test("clears the marker when the recorded erase finished but Auth deletion still fails")
    func clearsMarkerAfterConfirmedCleanCloud() async {
        let cloud = MockCloudEraser.Calls()
        let auth = MockAuth(uid: "abc"); auth.deleteError = AuthError.reauthRequired
        let pending = MockPendingStore(pendingUid: "abc", familyId: "fam-1")
        let authPending = MockPendingAuthStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud), auth: auth,
            pendingStore: pending, pendingAuthStore: authPending,
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { false })

        await rec.runIfNeeded()

        #expect(pending.pendingUid == nil)
        #expect(authPending.pendingUid == "abc")
    }

    @Test("re-runs the erase against the RECORDED family, never a re-resolved one")
    func passesRecordedFamilyHint() async {
        let cloud = MockCloudEraser.Calls()
        let pending = MockPendingStore(pendingUid: "abc", familyId: "fam-old")
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud), auth: MockAuth(uid: "abc"),
            pendingStore: pending, pendingAuthStore: MockPendingAuthStore(),
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { false })

        await rec.runIfNeeded()

        #expect(cloud.familyHints == ["fam-old"])
    }

    @Test("drops a stale marker instead of erasing a family the account joined afterwards")
    func supersededMarkerIsDropped() async {
        let cloud = MockCloudEraser.Calls(); cloud.outcome = .supersededByNewFamily
        let pending = MockPendingStore(pendingUid: "abc", familyId: "fam-old")
        let suppressed = MockSuppressedRestoreStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud), auth: MockAuth(uid: "abc"),
            pendingStore: pending, pendingAuthStore: MockPendingAuthStore(),
            suppressedRestoreStore: suppressed, accountIsInUse: { true })

        await rec.runIfNeeded()

        #expect(pending.pendingUid == nil)
        #expect(cloud.presentChecks.isEmpty)                      // no erase was attempted
        #expect(suppressed.isRestoreSuppressed(for: "abc") == false)
    }

    @Test("nothing-to-erase completes the deletion instead of blocking forever")
    func nothingToEraseCompletes() async {
        let cloud = MockCloudEraser.Calls(); cloud.outcome = .nothingToErase
        let pending = MockPendingStore(pendingUid: "abc", familyId: nil)
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud), auth: MockAuth(uid: "abc"),
            pendingStore: pending, pendingAuthStore: MockPendingAuthStore(),
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { false })

        await rec.runIfNeeded()

        #expect(pending.pendingUid == nil)
    }

    @Test("abandons the Auth retry once the account is back in use")
    func authRetrySkippedWhenAccountInUse() async {
        let authPending = MockPendingAuthStore(); authPending.markPending(uid: "abc")
        let auth = MockAuth(uid: "abc")
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: .init()), auth: auth,
            pendingStore: MockPendingStore(pendingUid: nil), pendingAuthStore: authPending,
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { true })

        await rec.runIfNeeded()

        #expect(auth.deleteCount == 0)
        #expect(authPending.pendingUid == nil)
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
