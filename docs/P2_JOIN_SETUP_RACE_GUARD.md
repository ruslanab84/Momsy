# P2 — Post-onboarding invite join races the auth listener's `setup()`

**Repo state verified against:** main @ `2b279c6`

## Problem

`AuthManager.shouldDeferAutomaticFamilySetup` (`Momsy/Core/Auth/AuthManager.swift:86-90`) defers the listener-driven `FamilyManager.setup()` **only while onboarding is incomplete**:

```swift
    @MainActor
    static func shouldDeferAutomaticFamilySetup(defaults: UserDefaults) -> Bool {
        guard !defaults.bool(forKey: "onboardingDone") else { return false }
        return PendingFamilyInviteStore(defaults: defaults).load() != nil
    }
```

Post-onboarding scenario: onboarding done, no auth session (after sign-out or account deletion), user taps an invite link. `joinFamilyFromLink` calls `requireAnonymousSignInIfNeeded()` → sign-in fires the auth state listener → listener launches `setup()` **concurrently** with `joinFamily()`. `setup()` finds no `users/{uid}.familyId` and creates a brand-new family (`FamilyManager.swift:114-131`) while `joinFamily()` commits its batch. Results:

- An orphaned empty family (doc + member + possibly a baby profile via `BabySyncService.setupBabyProfile`).
- **Routing divergence**: `setup()`'s `userRef.setData(["familyId": newId])` and the join batch's `["familyId": targetFamilyId]` race — last write wins on the server, last `persist()` wins locally. They can disagree, and the next reinstall adopts the wrong family.

Same race via `retryPendingAuthenticatedJoinIfPossible` after the auth sheet.

## Fix

An in-memory `joinInFlight` flag on `FamilyManager` (`@MainActor`, no persistence — the race exists only within one process lifetime), set by the join entry points **before** the sign-in that triggers the listener, checked at the top of `setup()`.

### 1. `FamilyManager.swift` — add near `@Published private(set) var isReady`:

```swift
    /// True while an explicit invite-join flow owns family state. `setup()` bails while
    /// set so the auth state listener — fired by the join's own sign-in — cannot race
    /// it into creating a parallel fresh family.
    private(set) var joinInFlight = false

    func beginJoinFlow() { joinInFlight = true }
    func endJoinFlow() { joinInFlight = false }
```

### 2. `FamilyManager.setup(uid:displayName:)` — guard at the very top (before the `suppressedRestoreStore` block):

```swift
    func setup(uid: String, displayName: String) async throws {
        guard !joinInFlight else {
            Self.log.info("Deferring family setup — invite join in flight")
            return
        }
```

### 3. Wrap the three join entry points

`MomsyApp.swift` — `joinFamilyFromLink` (~line 199), first statements:

```swift
    @MainActor
    private func joinFamilyFromLink(code: String, force: Bool = false) async {
        FamilyManager.shared.beginJoinFlow()
        defer { FamilyManager.shared.endJoinFlow() }
        do {
```

`SharingViewModel.swift` — `joinFamily(force:)`, immediately inside the `Task {`:

```swift
        Task {
            FamilyManager.shared.beginJoinFlow()
            defer { FamilyManager.shared.endJoinFlow() }
            do {
                // Self-heal a missing session like the deep-link join path does,
```

`AppContainer.swift:432` — `joinFamilyFromOnboarding`. Mark it `@MainActor` (its only caller is the already-`@MainActor` closure stored by `OnboardingViewModel`), then:

```swift
    @MainActor
    func joinFamilyFromOnboarding(code: String, force: Bool = false) async throws {
        FamilyManager.shared.beginJoinFlow()
        defer { FamilyManager.shared.endJoinFlow() }
        try await authManager.requireAnonymousSignInIfNeeded()
```

All three contexts are `@MainActor`, so `defer { … endJoinFlow() }` is a synchronous call — valid in `defer`.

## Accepted limitation (document, do not fix here)

The `anonymousSignInRestricted` → auth-sheet path clears the flag while the sheet is up; a provider sign-in inside the sheet may run `setup()` **sequentially** (possibly creating a fresh family) before the retry joins. That is a sequential leftover family, not concurrent routing corruption — `joinFamily` handles the switch correctly. Optional follow-up: persist the pending join across the sheet.

## Tests (Swift Testing)

New file `MomsyTests/Core/FamilyJoinFlowFlagTests.swift`:

```swift
import Testing
@testable import Momsy

@MainActor
struct FamilyJoinFlowFlagTests {
    @Test func flagTogglesAroundJoinFlow() {
        let manager = FamilyManager.shared
        manager.beginJoinFlow()
        #expect(manager.joinInFlight)
        manager.endJoinFlow()
        #expect(!manager.joinInFlight)
    }
}
```

(`FamilyManager.init` touches only `UserDefaults` — no Firebase configuration needed.)

## Definition of Done

- [ ] `joinInFlight` flag + guard in `setup()` as above
- [ ] All three join entry points wrapped with `begin/endJoinFlow` (defer-based, no leaked flag on any throw/early-return path)
- [ ] `joinFamilyFromOnboarding` is `@MainActor`; project compiles for all targets
- [ ] New test passes; full suite green

## Manual QA (simulator)

1. Complete onboarding on device B, then sign out (Settings).
2. Device A: copy an invite link.
3. Device B: `xcrun simctl openurl booted "momsy://join?code=MOMSY-XXXXXX"` (real code).
4. Expect: join succeeds; Console shows "Deferring family setup — invite join in flight"; Firebase console shows **no** newly created empty family for B's fresh anonymous uid; `users/{uid}.familyId` == A's family.
5. Regression: normal launch with an existing session still runs `setup()` (log absent), and Sharing-screen join still works.
