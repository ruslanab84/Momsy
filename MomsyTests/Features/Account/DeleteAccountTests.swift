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
    init(
        pendingUid: String? = nil,
        familyId: String? = nil,
        localWipeCompleted: Bool = false
    ) {
        pending = pendingUid.map {
            PendingAccountDeletion(
                uid: $0,
                familyId: familyId,
                localWipeCompleted: localWipeCompleted
            )
        }
    }
    var pendingUid: String? { pending?.uid }
    var localWipeCompleted: Bool { pending?.localWipeCompleted == true }
    func markPending(uid: String, familyId: String?) {
        pending = PendingAccountDeletion(uid: uid, familyId: familyId); markCount += 1
    }
    func loadPending() -> PendingAccountDeletion? { pending }
    func markLocalWipeCompleted(for uid: String) {
        guard let pending, pending.uid == uid else { return }
        self.pending = PendingAccountDeletion(
            uid: pending.uid,
            familyId: pending.familyId,
            localWipeCompleted: true
        )
    }
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
        stillPresent: Bool = false,
        localError: Error? = nil
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
            eraseLocal: {
                localWipes += 1
                if let localError { throw localError }
            }
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
        #expect(pending.localWipeCompleted)
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
        #expect(pending.localWipeCompleted)
    }

    @Test("does not mark the local wipe complete when device erasure fails")
    func failedLocalWipeRemainsPending() async {
        let (uc, _, _, pending, _, _, wipes) = makeUseCase(
            stillPresent: true,
            localError: DummyError()
        )

        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }

        #expect(wipes() == 1)
        #expect(pending.pendingUid == "user-1")
        #expect(!pending.localWipeCompleted)
    }

    @Test("keeps the marker and Auth session when server-clean local erasure fails")
    func serverCleanLocalWipeFailureRemainsRetryable() async {
        let (uc, _, auth, pending, authPending, _, wipes) = makeUseCase(
            localError: DummyError()
        )

        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }

        #expect(wipes() == 1)
        #expect(pending.pendingUid == "user-1")
        #expect(!pending.localWipeCompleted)
        #expect(pending.clearCount == 0)
        #expect(auth.deleteCount == 0)
        #expect(authPending.pendingUid == nil)
    }
}

@Suite("Pending account deletion store")
struct PendingAccountDeletionStoreTests {
    @Test("tracks a completed local wipe only for the deletion owner")
    func tracksCompletedLocalWipe() throws {
        let suiteName = UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsPendingAccountDeletionStore(defaults: defaults)

        store.markPending(uid: "user-1", familyId: "family-1")
        #expect(store.loadPending()?.localWipeCompleted == false)

        store.markLocalWipeCompleted(for: "user-2")
        #expect(store.loadPending()?.localWipeCompleted == false)

        store.markLocalWipeCompleted(for: "user-1")
        #expect(store.loadPending()?.localWipeCompleted == true)
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
    func serverVerificationPathPlan() async {
        let parents = FirestoreAccountEraser.healthDataParentPaths(
            familyId: "family-1",
            babyIds: ["baby-1", "baby-2"]
        )
        #expect(parents == [
            "families/family-1/babies/baby-1",
            "families/family-1/babies/baby-2",
            "babies/family-1",
        ])

        let collectionPaths = await FirestoreAccountEraser.healthDataCollectionPaths(
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

// MARK: - Bounded concurrency

private actor ConcurrencyProbe {
    private(set) var inFlight = 0
    private(set) var peak = 0
    private(set) var completed: [Int] = []

    func enter() {
        inFlight += 1
        peak = max(peak, inFlight)
    }

    func leave(_ item: Int) {
        inFlight -= 1
        completed.append(item)
    }
}

private struct ProbeFailure: Error {}

@Suite("BoundedConcurrency")
struct BoundedConcurrencyTests {
    @Test("runs every item exactly once")
    func runsEveryItem() async throws {
        let probe = ConcurrencyProbe()

        try await BoundedConcurrency.forEach(Array(0..<50), limit: 8) { item in
            await probe.enter()
            try await Task.sleep(nanoseconds: 1_000_000)
            await probe.leave(item)
        }

        let completed = await probe.completed
        #expect(completed.count == 50)
        #expect(Set(completed) == Set(0..<50))
    }

    @Test("respects the limit while overlapping work")
    func respectsLimit() async throws {
        let probe = ConcurrencyProbe()

        try await BoundedConcurrency.forEach(Array(0..<40), limit: 5) { item in
            await probe.enter()
            try await Task.sleep(nanoseconds: 3_000_000)
            await probe.leave(item)
        }

        let peak = await probe.peak
        #expect(peak <= 5, "peak in-flight \(peak) exceeded the limit")
        #expect(peak > 1, "work never overlapped")
    }

    @Test("rethrows an error without scheduling every remaining item")
    func failsFast() async {
        let probe = ConcurrencyProbe()

        await #expect(throws: ProbeFailure.self) {
            try await BoundedConcurrency.forEach(Array(0..<100), limit: 4) { item in
                if item == 0 { throw ProbeFailure() }
                await probe.enter()
                try await Task.sleep(nanoseconds: 20_000_000)
                await probe.leave(item)
            }
        }

        let completed = await probe.completed
        #expect(completed.count < 100)
    }

    @Test("uses the sequential path for degenerate inputs")
    func degenerateInputs() async throws {
        let emptyProbe = ConcurrencyProbe()
        try await BoundedConcurrency.forEach([Int](), limit: 8) { item in
            await emptyProbe.enter()
            await emptyProbe.leave(item)
        }
        #expect(await emptyProbe.peak == 0)

        let serialProbe = ConcurrencyProbe()
        try await BoundedConcurrency.forEach([1, 2, 3], limit: 1) { item in
            await serialProbe.enter()
            await serialProbe.leave(item)
        }
        #expect(await serialProbe.peak == 1)
        #expect(await serialProbe.completed == [1, 2, 3])
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
            suppressedRestoreStore: suppressed,
            eraseLocal: {})

        await rec.runIfNeeded()

        #expect(cloud.uids == ["abc"])         // re-ran the cloud erase
        #expect(pending.pendingUid == nil)     // and cleared the marker once verified gone
        #expect(suppressed.isRestoreSuppressed(for: "abc"))
    }

    @Test("retries a failed local wipe before releasing a server-clean marker")
    func retriesFailedLocalWipeBeforeFinalizingDeletion() async {
        let cloud = MockCloudEraser.Calls()
        let auth = MockAuth(uid: "abc")
        let pending = MockPendingStore(pendingUid: "abc")
        var localError: Error? = DummyError()
        var localWipes = 0
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: auth,
            pendingStore: pending,
            pendingAuthStore: MockPendingAuthStore(),
            suppressedRestoreStore: MockSuppressedRestoreStore(),
            eraseLocal: {
                localWipes += 1
                if let localError { throw localError }
            }
        )

        await rec.runIfNeeded()

        #expect(localWipes == 1)
        #expect(pending.pendingUid == "abc")
        #expect(!pending.localWipeCompleted)
        #expect(auth.deleteCount == 0)

        localError = nil
        await rec.runIfNeeded()

        #expect(localWipes == 2)
        #expect(pending.pendingUid == nil)
        #expect(auth.deleteCount == 1)
    }

    @Test("does nothing when no deletion is pending")
    func noPendingIsNoOp() async throws {
        let cloud = MockCloudEraser.Calls()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud),
            auth: MockAuth(uid: "abc"),
            pendingStore: MockPendingStore(pendingUid: nil),
            pendingAuthStore: MockPendingAuthStore(),
            suppressedRestoreStore: MockSuppressedRestoreStore(),
            eraseLocal: {})

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
            suppressedRestoreStore: suppressed,
            eraseLocal: {})

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
            suppressedRestoreStore: suppressed,
            eraseLocal: {})

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
            suppressedRestoreStore: MockSuppressedRestoreStore(), eraseLocal: {}, accountIsInUse: { false })

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
            suppressedRestoreStore: MockSuppressedRestoreStore(), eraseLocal: {}, accountIsInUse: { false })

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
            suppressedRestoreStore: MockSuppressedRestoreStore(), eraseLocal: {}, accountIsInUse: { false })

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
            suppressedRestoreStore: MockSuppressedRestoreStore(), eraseLocal: {}, accountIsInUse: { false })

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
            suppressedRestoreStore: suppressed, eraseLocal: {}, accountIsInUse: { true })

        let disposition = await rec.runIfNeeded()

        #expect(pending.pendingUid == nil)
        #expect(cloud.presentChecks.isEmpty)                      // no erase was attempted
        #expect(suppressed.isRestoreSuppressed(for: "abc") == false)
        #expect(disposition == .supersededByNewFamily)
    }

    @Test("nothing-to-erase completes the deletion instead of blocking forever")
    func nothingToEraseCompletes() async {
        let cloud = MockCloudEraser.Calls(); cloud.outcome = .nothingToErase
        let pending = MockPendingStore(pendingUid: "abc", familyId: nil)
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud), auth: MockAuth(uid: "abc"),
            pendingStore: pending, pendingAuthStore: MockPendingAuthStore(),
            suppressedRestoreStore: MockSuppressedRestoreStore(), eraseLocal: {}, accountIsInUse: { false })

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
            suppressedRestoreStore: MockSuppressedRestoreStore(), eraseLocal: {}, accountIsInUse: { true })

        await rec.runIfNeeded()

        #expect(auth.deleteCount == 0)
        #expect(authPending.pendingUid == nil)
    }

    // MARK: - shouldWipeDevice (guards AppContainer.recoverPendingAccountDeletion)

    @Test("wipes after recovery clears Auth and the marker for the owning session")
    func recoveryCompletionStillRequiresWipe() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingAtStart: PendingAccountDeletion(uid: "u1", familyId: nil),
            currentUidAtStart: "u1",
            currentUidAfterRecovery: nil,
            disposition: .continueDeletion
        ))
    }

    @Test("wipes the device while the pending deletion owns the session")
    func wipesForOwningSession() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingAtStart: PendingAccountDeletion(uid: "u1", familyId: nil),
            currentUidAtStart: "u1",
            currentUidAfterRecovery: "u1",
            disposition: .continueDeletion
        ))
    }

    @Test("no device wipe for a stale marker with nobody signed in")
    func skipsWipeWhenSignedOut() {
        // Otherwise a marker whose uid never signs in again re-wipes — and so resets
        // onboarding — on every cold launch, forever.
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingAtStart: PendingAccountDeletion(uid: "u1", familyId: nil),
            currentUidAtStart: nil,
            currentUidAfterRecovery: nil,
            disposition: .continueDeletion
        ) == false)
    }

    @Test("no device wipe when a different account is signed in")
    func skipsWipeForOtherUser() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingAtStart: PendingAccountDeletion(uid: "u1", familyId: nil),
            currentUidAtStart: "u2",
            currentUidAfterRecovery: "u2",
            disposition: .continueDeletion
        ) == false)
    }

    @Test("no device wipe if the session switches accounts during recovery")
    func skipsWipeAfterAccountSwitch() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingAtStart: PendingAccountDeletion(uid: "u1", familyId: nil),
            currentUidAtStart: "u1",
            currentUidAfterRecovery: "u2",
            disposition: .continueDeletion
        ) == false)
    }

    @Test("no device wipe when recovery found a legitimate replacement family")
    func skipsWipeWhenDeletionWasSuperseded() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingAtStart: PendingAccountDeletion(uid: "u1", familyId: "old-family"),
            currentUidAtStart: "u1",
            currentUidAfterRecovery: "u1",
            disposition: .supersededByNewFamily
        ) == false)
    }

    @Test("no repeated wipe after the deletion already cleaned the device")
    func skipsCompletedLocalWipe() {
        #expect(AccountDeletionRecovery.shouldWipeDevice(
            pendingAtStart: PendingAccountDeletion(
                uid: "u1",
                familyId: "old-family",
                localWipeCompleted: true
            ),
            currentUidAtStart: "u1",
            currentUidAfterRecovery: "u1",
            disposition: .continueDeletion
        ) == false)
    }
}
