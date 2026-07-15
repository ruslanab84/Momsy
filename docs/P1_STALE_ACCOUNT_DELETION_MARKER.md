# P1 — Stale account-deletion marker blocks Apple sign-in and wipes a different user's device on every launch

## Symptoms
1. Onboarding auth step: "Sign in with Apple" always fails with "Previous account deletion is still finishing. Please try again." Google sign-in works.
2. After completing onboarding via Google, killing and relaunching the app returns to the onboarding start.

## Root cause (verified against fresh clone, commit `4eeb01a`)

One stale `pendingAccountDeletion_uid_v1` marker (the Apple-linked uid from a previous, never server-confirmed account deletion) exposes two independent bugs.

### Bug A — recovery erase can never complete once membership is gone
`FirestoreAccountEraser.deleteCloudData(uid:)` — `Momsy/Core/Account/DeleteAccountUseCase.swift:56-97`.

A prior partial run deleted `families/{familyId}/members/{uid}` but crashed/failed before `userRef.delete()`. Now every retry:
- `users/{uid}` still exists on server with `familyId` → family branch entered;
- `familyRef.collection("members").getDocuments()` is denied by rules — `members/{memberId}: allow read: if belongsToFamily(familyId)` (`firestore.rules:264`), and `belongsToFamily` requires the caller's own member doc, which is already deleted;
- the throw propagates → `AccountDeletionRecovery.runIfNeeded()` keeps the marker → `AuthError.accountDeletionPending` forever. `userRef.delete()` — the only operation that matters for `isCloudDataPresent` — is never reached.

### Bug B — recovery wipes the device for a *different* signed-in user
`AppContainer.recoverPendingAccountDeletion()` — `Momsy/Core/DI/AppContainer.swift:584-590`.

`eraseLocalData()` + `FamilyManager.reset()` run unconditionally whenever any marker exists, even when `AccountDeletionRecovery.runIfNeeded()` correctly did nothing because the current uid ≠ pending uid. `eraseLocalData → clearAccountScopedDefaults` (`AppContainer.swift:336`) removes `onboardingDone`, `familyId`, baby id and all SwiftData. Result for the Google account: onboarding completes, then every launch (`MomsyApp.swift:125`) re-wipes the device and `return true` additionally blocks cloud sync.

## Fix

### 1. Tolerate revoked-membership permission denial in the cloud erase

File: `Momsy/Core/Account/DeleteAccountUseCase.swift`, inside `deleteCloudData(uid:)` (lines 62-94).

Wrap the family branch:

```swift
        if let familyId = resolvedFamilyId, !familyId.isEmpty {
            do {
                let familyRef = db.collection("families").document(familyId)
                let memberDocuments = try await familyRef.collection("members").getDocuments().documents
                let memberIds = memberDocuments.map(\.documentID)
                let callerRoleRaw = memberDocuments
                    .first { $0.documentID == uid }?
                    .data()["roleRaw"] as? String ?? ""
                let mayTearDownSharedData = AccountErasureGate.mayTearDownSharedData(
                    memberIds: memberIds,
                    callerUid: uid,
                    callerRoleRaw: callerRoleRaw
                )

                if mayTearDownSharedData {
                    let familyDoc = try await familyRef.getDocument(source: .server)
                    let callerCreatedFamily = familyDoc.data()?["createdBy"] as? String == uid
                    let babyIds = try await discoverBabyIds(in: familyRef)
                    for babyId in babyIds {
                        try await deleteBabyTree(familyRef: familyRef, familyId: familyId, babyId: babyId)
                    }
                    try await deleteLegacyFamilyTree(familyId: familyId)
                    if callerCreatedFamily {
                        try await familyRef.delete()
                    }
                    // Firestore never cascades into subcollections: the caller's roster doc
                    // must be removed explicitly or it outlives the erased account as PII.
                    // Ordered AFTER the deletes above — those are authorised by
                    // `belongsToFamily`, which reads this very document.
                    try await familyRef.collection("members").document(uid).delete()
                } else {
                    try await familyRef.collection("members").document(uid).delete()
                }
            } catch let error as NSError
                where error.domain == FirestoreErrorDomain
                && error.code == FirestoreErrorCode.permissionDenied.rawValue {
                // The caller's members/{uid} doc is already gone (a prior partial run
                // deleted it), so every family read/write is now denied by
                // `belongsToFamily`. Nothing in the family branch is reachable or
                // owned by this account anymore; fall through to deleting users/{uid} —
                // the only remaining re-resolution signal `isCloudDataPresent` checks.
            }
        }

        try await userRef.delete()
```

Only the indicated `do/catch` wrapper is new; the inner body is unchanged. Keep the catch narrow (`permissionDenied` only) — offline/transient errors must still propagate so the marker is retried, not falsely cleared.

### 2. Scope the launch-recovery wipe to the account being deleted

File: `Momsy/Core/DI/AppContainer.swift` (lines 579-590)

Replace:

```swift
    /// Runs before launch-time migrations/local profile loading, and after a provider sign-in
    /// when that provider maps to the uid being deleted. Returns true while the delete marker
    /// is still unresolved; callers should skip cloud sync in that state so cached remote data
    /// cannot refill the freshly wiped device.
    @MainActor
    func recoverPendingAccountDeletion() async -> Bool {
        guard pendingAccountDeletionStore.loadPending() != nil else { return false }
        await accountDeletionRecovery.runIfNeeded()
        try? eraseLocalData()
        FamilyManager.shared.reset()
        return pendingAccountDeletionStore.loadPending() != nil
    }
```

With:

```swift
    /// Runs before launch-time migrations/local profile loading, and after a provider sign-in
    /// when that provider maps to the uid being deleted. Returns true while the delete marker
    /// is still unresolved AND applies to the current session; callers should skip cloud sync
    /// in that state so cached remote data cannot refill the freshly wiped device.
    @MainActor
    func recoverPendingAccountDeletion() async -> Bool {
        guard let pendingUid = pendingAccountDeletionStore.loadPending() else { return false }
        await accountDeletionRecovery.runIfNeeded()

        let currentUid = authManager.currentUID
        let markerAppliesToSession = currentUid == nil || currentUid == pendingUid
        guard markerAppliesToSession else {
            // A DIFFERENT account is signed in. The stale marker belongs to another uid;
            // wiping here would destroy this user's onboarding/family state on every
            // launch. Leave the marker for the owning account's next sign-in.
            return false
        }

        try? eraseLocalData()
        FamilyManager.shared.reset()
        return pendingAccountDeletionStore.loadPending() != nil
    }
```

Behavior preserved: matched uid (post-sign-in path from `finishPendingAccountDeletionIfNeeded`) and signed-out launches still wipe and block sync; only the cross-account collateral wipe is removed.

### 3. Unit tests (Swift Testing)

File: `MomsyTests/AccountDeletionRecoveryScopeTests.swift`

```swift
import Testing
@testable import Momsy

@MainActor
private final class AuthStub: AccountAuthProtocol {
    var currentUID: String?
    init(uid: String?) { currentUID = uid }
    func deleteAccount() async throws {}
    func signOut() throws {}
}

private final class EraserStub: CloudAccountEraser {
    var present = true
    func deleteCloudData(uid: String) async throws {}
    func isCloudDataPresent(uid: String) async throws -> Bool { present }
}

@MainActor
struct AccountDeletionRecoveryScopeTests {

    private func makeStore() -> (PendingAccountDeletionStore, UserDefaults, String) {
        let name = "test_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        return (UserDefaultsPendingAccountDeletionStore(defaults: defaults), defaults, name)
    }

    @Test func recoveryDoesNotActForDifferentUid() async {
        let (store, defaults, name) = makeStore()
        defer { defaults.removePersistentDomain(forName: name) }
        store.markPending(uid: "apple-uid")

        let recovery = AccountDeletionRecovery(
            cloudEraser: EraserStub(),
            auth: AuthStub(uid: "google-uid"),
            pendingStore: store,
            suppressedRestoreStore: UserDefaultsSuppressedFamilyRestoreStore(defaults: defaults)
        )
        await recovery.runIfNeeded()
        #expect(store.loadPending() == "apple-uid")  // untouched, retried by the owner later
    }

    @Test func recoveryClearsMarkerWhenServerConfirmsGone() async {
        let (store, defaults, name) = makeStore()
        defer { defaults.removePersistentDomain(forName: name) }
        store.markPending(uid: "apple-uid")

        let eraser = EraserStub()
        eraser.present = false
        let recovery = AccountDeletionRecovery(
            cloudEraser: eraser,
            auth: AuthStub(uid: "apple-uid"),
            pendingStore: store,
            suppressedRestoreStore: UserDefaultsSuppressedFamilyRestoreStore(defaults: defaults)
        )
        await recovery.runIfNeeded()
        #expect(store.loadPending() == nil)
    }
}
```

Adapt `AuthStub`/`EraserStub` to existing mocks in `MomsyTests` if equivalents already exist. Testing the `AppContainer` wipe-scoping directly requires a container factory with an injectable auth — if that infrastructure doesn't exist, cover it via Manual QA step 3 and note it in the PR.

## Definition of Done
- [ ] `deleteCloudData` falls through to `userRef.delete()` on `permissionDenied` inside the family branch; all other errors still propagate.
- [ ] `recoverPendingAccountDeletion()` never calls `eraseLocalData()` when a different uid is signed in, and returns `false` in that case.
- [ ] New tests pass; existing account-deletion tests green.
- [ ] Build succeeds for all 4 targets.

## Manual QA
1. **Unstick Apple (real device state):** with the stale marker present, tap "Sign in with Apple". First attempt should now complete the erase — expected error changes to "Previous account deletion finished. Please sign in again." Second Apple attempt signs in cleanly and proceeds through the join flow.
2. **Google relaunch persistence:** complete onboarding via Google (join flow), kill the app, relaunch → app opens on the main screen, family data intact, no onboarding.
3. **Cross-account isolation:** set a fake marker (`defaults write` `pendingAccountDeletion_uid_v1 = "other-uid"` or via debug hook), sign in with Google, complete onboarding, relaunch twice → onboarding never reappears, marker still present.
4. **Regression — genuine deletion recovery:** delete account while offline (airplane mode mid-delete), relaunch online, sign in with the same provider → recovery finishes, marker cleared, device clean, onboarding shown once.
5. **Regression — deletion still blocks the deleted account's sync:** with marker for uid X and uid X signed in, launch → cloud download skipped until marker resolves.
