# Splash Lockout & Subscription Sync — P0/P1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Guarantee the app can never be stuck on the splash screen waiting for premium access to resolve, rebuild the family entitlement listener after an auth change, and stop re-POSTing already-synchronized transactions to the Cloud Function on every launch.

**Architecture:** `ContentView` renders `SplashView()` for the whole app while `SubscriptionManager.accessState == .resolving`. That state has no upper bound today, and three separate paths can leave it stuck. Fixes stay inside `SubscriptionManager` / `FamilyPremiumService` / `SubscriptionSyncQueue` so `ContentView` needs **no change** — `accessState` remains the single source of truth and the existing `.onReceive` propagates the fix automatically.

**Tech Stack:** Swift 5 language mode (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`), SwiftUI, StoreKit 2, Firebase Firestore, Swift Testing (`@Test` / `#expect`), Node 22 Cloud Functions.

**Anchor commit:** `da69af4e8bc1f9b317faec442578f5a902484eb5` — *"Add diagnostic error tracking to distinguish empty product catalog from network timeout"* (2026-08-24). All line numbers below refer to this commit. **Re-clone before starting:**

```bash
git clone --depth 1 https://github.com/ruslanab84/Momsy.git && cd Momsy && git log -1 --format=%H
# expect: da69af4e8bc1f9b317faec442578f5a902484eb5
```

---

## Problem Statement

| # | Severity | Symptom | Root cause |
|---|----------|---------|------------|
| 1 | P0 | Offline cold start never leaves the splash | `FamilyPremiumService.resolvedAccess` returns `nil` for a cache-only snapshot without active premium (deliberate — prevents a stale doc flashing premium). `observe` then never calls `onChange`, so `isResolvingFamily` stays `true` forever. |
| 2 | P0 | A permanently failing Firestore listener never leaves the splash | `observe`'s `guard error == nil … else { return }` swallows the error and never calls `onChange`. |
| 3 | P0 | Re-auth with an unchanged `familyId` never leaves the splash | `authSessionDidChange` calls `stopObserving()` and sets `isResolvingFamily = true`, then waits on `FamilyManager.shared.$familyId`, which is `.removeDuplicates()`-filtered. No element ⇒ `observeCurrentFamily` never runs ⇒ the torn-down listener is never rebuilt. |
| 4 | P1 | One `syncSubscriptionEntitlement` invocation per launch per paying user | `SubscriptionSyncQueue.discardPendingIfScopeChanged` calls `store.clearAll()` when nothing is pending, erasing the `successful_subscription_sync_v1` idempotency marker. The next `updatePersonalStatus` re-enqueues and re-POSTs. |
| 5 | P1 | Backoff dies for the rest of the process after 3 failures | `retryAttempt` only resets on success or a terminal error; `scheduleRetry` then refuses to arm forever. |
| 6 | P1 | "Restore Purchases" does nothing visible when there is nothing to restore | `restore()` succeeds, `isPremium` stays `false`, `onComplete()` is not called, no message is shown. |

**Out of scope** (tracked separately): the fixed 2.2 s splash in `ContentView.swift:60`, Dynamic Type on `PaywallView`, `SWIFT_STRICT_CONCURRENCY`, unregistered test files, analytics.

---

## File Structure

| File | Change | Responsibility after the change |
|------|--------|---------------------------------|
| `Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift` | Modify (`:171-179`, `:181-190`) | Scope guard drops only the pending job; backoff budget is restorable. |
| `Momsy/Features/Subscription/Data/Services/FamilyPremiumService.swift` | Modify (`:1-4`, `:16`, `:52-63`) | Listener failures resolve to "no family premium" and are logged instead of swallowed. |
| `Momsy/Features/Subscription/Domain/SubscriptionManager.swift` | Modify (`:37-60`, `:81-85`, `:150-153`, `:180-195`, `:431-438`) | Bounded `.resolving`; family observer rebuilt on auth change; backoff budget restored on foreground. |
| `Momsy/Features/Subscription/Presentation/Views/PaywallView.swift` | Modify (`:11`, `:178-242`) | Restore reports "nothing found" and disables while running. |
| `Momsy/Core/Localization/L10n.swift` | Modify (`:1727-1733`) | New `restoreNoPurchasesFound` across all 7 languages. |
| `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift` | Modify (append before `private func pending`) | 5 new `@Test` cases. |

`ContentView.swift` is intentionally **not** modified.

---

### Task 1: Stop the scope guard from erasing the success marker

**Files:**
- Modify: `Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift:171-179`
- Test: `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift`

- [ ] **Step 1: Write the two failing tests**

Insert both tests into `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift`, immediately **above** the line `    private func pending(signedTransaction: String) -> PendingSubscriptionSync {`.

```swift
    @Test func scopeCheckKeepsTheSuccessMarkerWhenNothingIsPending() async {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        let context = SubscriptionSyncContext(uid: "uid-a", familyID: "family-a")
        let job = pending(signedTransaction: "signed")
        let queue = SubscriptionSyncQueue(
            store: store,
            currentContext: { context },
            synchronize: { _ in },
            retryDelays: []
        )
        queue.enqueue(job)
        await queue.flush()
        #expect(store.wasSuccessfullySynchronized(job))

        // Runs on every launch from `observeCurrentFamily`.
        queue.discardPendingIfScopeChanged(to: context)

        #expect(store.wasSuccessfullySynchronized(job))
        store.save(job)
        #expect(store.load() == nil)
    }

    @Test func scopeChangeStillDropsTheStalePendingJob() {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        let queue = SubscriptionSyncQueue(
            store: store,
            currentContext: {
                SubscriptionSyncContext(uid: "uid-b", familyID: "family-b")
            },
            synchronize: { _ in Issue.record("A stale job must not reach the network") },
            retryDelays: []
        )
        store.save(pending(signedTransaction: "signed"))

        queue.discardPendingIfScopeChanged(
            to: SubscriptionSyncContext(uid: "uid-b", familyID: "family-b")
        )

        #expect(store.load() == nil)
    }
```

- [ ] **Step 2: Run the tests to verify the first one fails**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SubscriptionManagerLogicTests 2>&1 | tail -30
```

Expected: `scopeCheckKeepsTheSuccessMarkerWhenNothingIsPending` FAILS on the second `#expect(store.wasSuccessfullySynchronized(job))` — `clearAll()` wiped the marker. `scopeChangeStillDropsTheStalePendingJob` passes already (it is the regression guard).

- [ ] **Step 3: Replace `discardPendingIfScopeChanged`**

BEFORE (`SubscriptionSyncQueue.swift:171-179`):

```swift
    func discardPendingIfScopeChanged(to context: SubscriptionSyncContext?) {
        guard let pending = store.load(),
              let context,
              pending.matches(context)
        else {
            if context != nil { store.clearAll() }
            return
        }
    }
```

AFTER:

```swift
    /// Drops a job that no longer belongs to the current account/family. Only the pending job
    /// goes: `clearAll()` here also erased the success marker, and because this runs from
    /// `observeCurrentFamily` on every cold start, the next `updatePersonalStatus` re-enqueued
    /// and re-POSTed an already-synchronized transaction — one Cloud Function invocation per
    /// launch per paying user. The marker is a 4-field exact match, so keeping a stale one is
    /// inert; family departure still wipes everything through `clear()`.
    func discardPendingIfScopeChanged(to context: SubscriptionSyncContext?) {
        guard let context, let pending = store.load() else { return }
        guard !pending.matches(context) else { return }
        store.clearPending()
    }
```

- [ ] **Step 4: Run the tests to verify they pass**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SubscriptionManagerLogicTests 2>&1 | tail -30
```

Expected: PASS, including the 5 pre-existing sync-queue tests.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift \
        MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift
git commit -m "fix: keep the subscription sync success marker across launches"
```

---

### Task 2: Make the retry budget restorable

**Files:**
- Modify: `Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift:95` and `:181-190`
- Modify: `Momsy/Features/Subscription/Domain/SubscriptionManager.swift:150-153`
- Test: `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift`

- [ ] **Step 1: Write the failing test**

Insert into `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift`, above `    private func pending(signedTransaction: String) -> PendingSubscriptionSync {`.

```swift
    @Test func resetRetryBudgetRearmsTheBackoff() async {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        let context = SubscriptionSyncContext(uid: "uid-a", familyID: "family-a")
        let queue = SubscriptionSyncQueue(
            store: store,
            currentContext: { context },
            synchronize: { _ in
                throw FamilyPremiumSyncError(
                    code: "verification_unavailable",
                    isRetryable: true
                )
            },
            retryDelays: [.zero, .zero, .zero],
            sleep: { _ in }
        )
        store.save(pending(signedTransaction: "signed"))

        await queue.flush()
        #expect(queue.retryAttempt > 0)

        queue.resetRetryBudget()

        #expect(queue.retryAttempt == 0)
        queue.clear()
    }
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SubscriptionManagerLogicTests/resetRetryBudgetRearmsTheBackoff 2>&1 | tail -20
```

Expected: FAIL to compile — `retryAttempt` is private and `resetRetryBudget` does not exist.

- [ ] **Step 3: Expose the counter and add the reset**

BEFORE (`SubscriptionSyncQueue.swift:95`):

```swift
    private var retryAttempt = 0
```

AFTER:

```swift
    /// Readable by tests; only this type mutates it.
    private(set) var retryAttempt = 0
```

BEFORE (`SubscriptionSyncQueue.swift:181-190`, the `clear()` method):

```swift
    func clear() {
        flushTask?.cancel()
        retryTask?.cancel()
        flushTask = nil
        retryTask = nil
        retryAttempt = 0
        needsFlush = false
        store.clearAll()
    }
```

AFTER (adds a new method directly below `clear()`, leaves `clear()` itself untouched):

```swift
    func clear() {
        flushTask?.cancel()
        retryTask?.cancel()
        flushTask = nil
        retryTask = nil
        retryAttempt = 0
        needsFlush = false
        store.clearAll()
    }

    /// Restores the backoff budget when the app returns to the foreground. Without this the
    /// third consecutive failure retires the job for the rest of the process: `scheduleRetry`
    /// refuses to arm once `retryAttempt` reaches `retryDelays.count`, and nothing lowers it
    /// again except a success that can no longer be attempted.
    func resetRetryBudget() {
        retryAttempt = 0
    }
```

- [ ] **Step 4: Call it from the foreground refresh path**

BEFORE (`SubscriptionManager.swift:150-153`):

```swift
    func refreshAccess() async {
        await updatePersonalStatus(synchronizeFamilyEntitlement: true)
        syncQueue.scheduleFlush()
    }
```

AFTER:

```swift
    /// `ContentView` calls this on every `scenePhase == .active`, which is exactly the moment
    /// a previously dead network may be back — so the backoff budget is restored here.
    func refreshAccess() async {
        await updatePersonalStatus(synchronizeFamilyEntitlement: true)
        syncQueue.resetRetryBudget()
        syncQueue.scheduleFlush()
    }
```

- [ ] **Step 5: Run the tests to verify they pass**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SubscriptionManagerLogicTests 2>&1 | tail -30
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift \
        Momsy/Features/Subscription/Domain/SubscriptionManager.swift \
        MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift
git commit -m "fix: restore the entitlement sync backoff budget on foreground"
```

---

### Task 3: Resolve family access when the Firestore listener fails

**Files:**
- Modify: `Momsy/Features/Subscription/Data/Services/FamilyPremiumService.swift:1-4`, `:16`, `:52-63`

No unit test — the closure requires a live Firestore listener. Covered by QA scenario 3.

- [ ] **Step 1: Add the `os` import**

BEFORE (`FamilyPremiumService.swift:1-4`):

```swift
import FirebaseAppCheck
import FirebaseAuth
import FirebaseFirestore
import Foundation
```

AFTER:

```swift
import FirebaseAppCheck
import FirebaseAuth
import FirebaseFirestore
import Foundation
import os
```

- [ ] **Step 2: Add the logger**

BEFORE (`FamilyPremiumService.swift:16`):

```swift
    private static let endpoint = URL(string: "https://us-central1-momsy-cf74a.cloudfunctions.net/syncSubscriptionEntitlement")!
```

AFTER:

```swift
    private static let endpoint = URL(string: "https://us-central1-momsy-cf74a.cloudfunctions.net/syncSubscriptionEntitlement")!

    /// `nonisolated` because the Firestore snapshot callback is not MainActor-isolated. The
    /// class is, and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` would otherwise isolate this
    /// static too — fine under today's minimal checking, a hard error once strict concurrency
    /// is turned on. `Logger` is `Sendable`. Matches how `resolvedAccess` is already declared.
    private nonisolated static let log = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "RuslanAbd.Momsy",
        category: "subscription"
    )
```

- [ ] **Step 3: Handle the listener error**

BEFORE (`FamilyPremiumService.swift:52-63`):

```swift
        listener = Firestore.firestore().collection("families").document(familyId)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                guard error == nil,
                      let snapshot,
                      let isPremium = Self.resolvedAccess(
                        snapshot.data(),
                        isFromCache: snapshot.metadata.isFromCache
                      )
                else { return }
                Task { @MainActor in onChange(isPremium) }
            }
```

AFTER:

```swift
        listener = Firestore.firestore().collection("families").document(familyId)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                // A permanently failing listener — denied rules, revoked membership — used to
                // return silently and leave the caller resolving forever, which blanks the whole
                // app behind the splash. Report "no family premium" instead: the personal
                // entitlement resolves independently and still grants access on its own.
                if let error {
                    Self.log.error(
                        "Family entitlement listener failed: \(error.localizedDescription, privacy: .public)"
                    )
                    Task { @MainActor in onChange(false) }
                    return
                }
                guard let snapshot,
                      let isPremium = Self.resolvedAccess(
                        snapshot.data(),
                        isFromCache: snapshot.metadata.isFromCache
                      )
                else { return }
                Task { @MainActor in onChange(isPremium) }
            }
```

- [ ] **Step 4: Verify it compiles and nothing regressed**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/FamilyPremiumAccessTests 2>&1 | tail -20
```

Expected: PASS (11 tests). `resolvedAccess` is deliberately unchanged — the cache-only `nil` still prevents a premium flash.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Subscription/Data/Services/FamilyPremiumService.swift
git commit -m "fix: resolve family entitlement to false when the listener errors"
```

---

### Task 4: Bound how long the app may sit on `.resolving`

This is the fix that closes the offline lockout, which no listener change can reach — a cache-only snapshot is a *successful* read that legitimately carries no answer.

**Files:**
- Modify: `Momsy/Features/Subscription/Domain/SubscriptionManager.swift:37-60`, `:81-85`, `:431-438`
- Test: `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift`

- [ ] **Step 1: Write the two failing tests**

Insert into `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift`, above `    private func pending(signedTransaction: String) -> PendingSubscriptionSync {`.

```swift
    @Test func aStalledResolutionFallsBackToThePaywall() {
        let manager = SubscriptionManager(
            service: StalledSubscriptionService(),
            familyPremiumService: NoFamilyPremiumService(),
            syncStore: PendingSubscriptionSyncStore(defaults: makeDefaults())
        )
        #expect(manager.accessState == .resolving)

        manager.resolveStalledAccessIfNeeded()

        #expect(manager.accessState == .requiresPurchase)
        #expect(!manager.isPremium)
    }

    @Test func theWatchdogNeverOverridesAResolvedState() async {
        let manager = SubscriptionManager(
            service: StalledSubscriptionService(),
            familyPremiumService: NoFamilyPremiumService(),
            syncStore: PendingSubscriptionSyncStore(defaults: makeDefaults())
        )
        await manager.authSessionDidChange(isAuthenticated: false)
        #expect(manager.accessState == .requiresPurchase)

        manager.resolveStalledAccessIfNeeded()

        #expect(manager.accessState == .requiresPurchase)
    }
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SubscriptionManagerLogicTests 2>&1 | tail -20
```

Expected: FAIL to compile — `resolveStalledAccessIfNeeded` does not exist.

- [ ] **Step 3: Add the timeout property and init parameter**

BEFORE (`SubscriptionManager.swift:37-60`):

```swift
    private let service: any SubscriptionServicing
    private let familyPremiumService: any FamilyPremiumServicing
    private let productLoadTimeout: Duration
    private let syncQueue: SubscriptionSyncQueue
    private var listenerTask: Task<Void, Never>?
    private var bootstrapTask: Task<Void, Never>?
    private var productLoadTask: Task<[Product], Error>?
    private var familyIDObserver: AnyCancellable?
    private var personalPremium = false
    private var familyPremium = false
    private var isResolvingPersonal = true
    private var isResolvingFamily = true
    private var observedFamilyID: String?
    private var hasObservedFamily = false

    init(
        service: any SubscriptionServicing,
        familyPremiumService: any FamilyPremiumServicing,
        syncStore: PendingSubscriptionSyncStore = PendingSubscriptionSyncStore(),
        productLoadTimeout: Duration = .seconds(15)
    ) {
        self.service = service
        self.familyPremiumService = familyPremiumService
        self.productLoadTimeout = productLoadTimeout
```

AFTER:

```swift
    private let service: any SubscriptionServicing
    private let familyPremiumService: any FamilyPremiumServicing
    private let productLoadTimeout: Duration
    private let accessResolutionTimeout: Duration
    private let syncQueue: SubscriptionSyncQueue
    private var listenerTask: Task<Void, Never>?
    private var bootstrapTask: Task<Void, Never>?
    private var productLoadTask: Task<[Product], Error>?
    private var accessResolutionTimeoutTask: Task<Void, Never>?
    private var familyIDObserver: AnyCancellable?
    private var personalPremium = false
    private var familyPremium = false
    private var isResolvingPersonal = true
    private var isResolvingFamily = true
    private var observedFamilyID: String?
    private var hasObservedFamily = false

    init(
        service: any SubscriptionServicing,
        familyPremiumService: any FamilyPremiumServicing,
        syncStore: PendingSubscriptionSyncStore = PendingSubscriptionSyncStore(),
        productLoadTimeout: Duration = .seconds(15),
        accessResolutionTimeout: Duration = .seconds(6)
    ) {
        self.service = service
        self.familyPremiumService = familyPremiumService
        self.productLoadTimeout = productLoadTimeout
        self.accessResolutionTimeout = accessResolutionTimeout
```

- [ ] **Step 4: Cancel the watchdog in `deinit`**

BEFORE (`SubscriptionManager.swift:81-85`):

```swift
    deinit {
        listenerTask?.cancel()
        bootstrapTask?.cancel()
        familyIDObserver?.cancel()
    }
```

AFTER:

```swift
    deinit {
        listenerTask?.cancel()
        bootstrapTask?.cancel()
        accessResolutionTimeoutTask?.cancel()
        familyIDObserver?.cancel()
    }
```

- [ ] **Step 5: Arm the watchdog from the single state choke point**

Every mutation of `isResolvingPersonal` / `isResolvingFamily` in this file already ends in `updateAccessState()`, so arming there covers all of them without touching six call sites.

BEFORE (`SubscriptionManager.swift:431-438`):

```swift
    private func updateAccessState() {
        accessState = PremiumAccessPolicy.state(
            personalPremium: personalPremium,
            familyPremium: familyPremium,
            isResolving: isResolvingPersonal || isResolvingFamily
        )
        isPremium = accessState == .premium
    }
```

AFTER:

```swift
    private func updateAccessState() {
        accessState = PremiumAccessPolicy.state(
            personalPremium: personalPremium,
            familyPremium: familyPremium,
            isResolving: isResolvingPersonal || isResolvingFamily
        )
        isPremium = accessState == .premium
        armAccessResolutionTimeout()
    }

    /// Bounds how long the UI may sit on `.resolving`. `ContentView` replaces the entire app
    /// with `SplashView()` in that state, and the family listener can legitimately never
    /// answer: an offline cold start yields a cache-only snapshot, which `resolvedAccess` maps
    /// to nil on purpose so a stale doc cannot flash premium. Arms once on entry and cancels on
    /// exit — re-arming on every call would let a chatty resolving loop push the deadline back
    /// indefinitely.
    private func armAccessResolutionTimeout() {
        guard accessState == .resolving else {
            accessResolutionTimeoutTask?.cancel()
            accessResolutionTimeoutTask = nil
            return
        }
        guard accessResolutionTimeoutTask == nil else { return }
        let timeout = accessResolutionTimeout
        accessResolutionTimeoutTask = Task { [weak self] in
            try? await Task.sleep(for: timeout)
            guard !Task.isCancelled else { return }
            self?.resolveStalledAccessIfNeeded()
        }
    }

    /// Forces a stalled `.resolving` open. Only ever downgrades to `.requiresPurchase`: both
    /// entitlement sources keep resolving in the background, and either one flipping to true
    /// re-grants premium through `updateAccessState`. Showing the paywall to someone who turns
    /// out to be premium is recoverable; a permanent splash is not.
    func resolveStalledAccessIfNeeded() {
        guard accessState == .resolving else { return }
        Self.log.error("Premium access resolution timed out; opening the paywall")
        isResolvingPersonal = false
        isResolvingFamily = false
        updateAccessState()
    }
```

- [ ] **Step 6: Run the tests to verify they pass**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SubscriptionManagerLogicTests 2>&1 | tail -30
```

Expected: PASS, all 26 pre-existing tests plus the 5 new ones.

- [ ] **Step 7: Commit**

```bash
git add Momsy/Features/Subscription/Domain/SubscriptionManager.swift \
        MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift
git commit -m "fix: bound premium access resolution so the splash cannot lock the app"
```

---

### Task 5: Rebuild the family observer after an auth session change

**Files:**
- Modify: `Momsy/Features/Subscription/Domain/SubscriptionManager.swift:180-195`

Covered by QA scenario 4. No unit test: `observeCurrentFamily` reads `FamilyManager.shared`, a Firebase-backed singleton with no injection seam (tracked as separate P2 debt).

- [ ] **Step 1: Force the re-observe**

BEFORE (`SubscriptionManager.swift:180-195`):

```swift
    func authSessionDidChange(isAuthenticated: Bool) async {
        familyPremiumService.stopObserving()
        personalPremium = false
        familyPremium = false
        observedFamilyID = nil
        hasObservedFamily = false
        isResolvingPersonal = isAuthenticated
        isResolvingFamily = isAuthenticated
            && FirebaseBootstrapper.isConfigured
            && CloudSyncConsent.isGranted()
        updateAccessState()

        guard isAuthenticated else { return }
        await updatePersonalStatus(synchronizeFamilyEntitlement: true)
        syncQueue.scheduleFlush()
    }
```

AFTER:

```swift
    func authSessionDidChange(isAuthenticated: Bool) async {
        familyPremiumService.stopObserving()
        personalPremium = false
        familyPremium = false
        observedFamilyID = nil
        hasObservedFamily = false
        isResolvingPersonal = isAuthenticated
        isResolvingFamily = isAuthenticated
            && FirebaseBootstrapper.isConfigured
            && CloudSyncConsent.isGranted()
        updateAccessState()

        guard isAuthenticated else { return }
        // The listener torn down above is otherwise only rebuilt by `FamilyManager.$familyId`,
        // which is `removeDuplicates()`-filtered. A uid change that leaves the family id
        // untouched publishes nothing, so nobody rebuilds it and `isResolvingFamily` stays
        // true forever. `force: true` bypasses the `observedFamilyID` equality guard.
        observeCurrentFamily(FamilyManager.shared.familyId, force: true)
        await updatePersonalStatus(synchronizeFamilyEntitlement: true)
        syncQueue.scheduleFlush()
    }
```

- [ ] **Step 2: Run the tests to verify nothing regressed**

```bash
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SubscriptionManagerLogicTests 2>&1 | tail -30
```

Expected: PASS. `signOutClearsInMemoryPremiumAccess` uses `isAuthenticated: false` and returns before the new line, so no test touches `FamilyManager.shared`.

- [ ] **Step 3: Commit**

```bash
git add Momsy/Features/Subscription/Domain/SubscriptionManager.swift
git commit -m "fix: rebuild the family entitlement observer after an auth session change"
```

---

### Task 6: Add the "nothing to restore" string in all 7 languages

**Files:**
- Modify: `Momsy/Core/Localization/L10n.swift:1727-1733`

- [ ] **Step 1: Add the key**

BEFORE (`L10n.swift:1727-1733`):

```swift
    var restorePurchases: String   { s("Restore Purchases",
                                       "Восстановить покупки",
                                       "Käufe wiederherstellen",
                                       "Restaurar compras",
                                       "Restaurer les achats",
                                       "Restaurar compras",
                                       "恢复购买") }
```

AFTER:

```swift
    var restorePurchases: String   { s("Restore Purchases",
                                       "Восстановить покупки",
                                       "Käufe wiederherstellen",
                                       "Restaurar compras",
                                       "Restaurer les achats",
                                       "Restaurar compras",
                                       "恢复购买") }
    var restoreNoPurchasesFound: String {
        s("No previous purchases found for this Apple Account.",
          "Для этого Apple Account покупок не найдено.",
          "Für dieses Apple-Konto wurden keine früheren Käufe gefunden.",
          "No se encontraron compras anteriores para esta cuenta de Apple.",
          "Aucun achat antérieur trouvé pour ce compte Apple.",
          "Não foram encontradas compras anteriores para esta conta Apple.",
          "未找到此 Apple 账户的历史购买记录。")
    }
```

- [ ] **Step 2: Verify all 7 languages are present**

`s(...)` takes exactly 7 arguments in EN, RU, DE, ES, FR, PT, ZH order — a missing one is a compile error, an out-of-order one is not. Count the quoted lines:

```bash
grep -A 8 "var restoreNoPurchasesFound" Momsy/Core/Localization/L10n.swift | grep -c '"'
```

Expected: `7` — one quoted value per line, one line per language.

- [ ] **Step 3: Commit**

```bash
git add Momsy/Core/Localization/L10n.swift
git commit -m "feat: localize the empty-restore notice across all 7 languages"
```

---

### Task 7: Report the restore outcome on the paywall

**Files:**
- Modify: `Momsy/Features/Subscription/Presentation/Views/PaywallView.swift:11`, `:178-242`

- [ ] **Step 1: Add the notice state**

BEFORE (`PaywallView.swift:11`):

```swift
    @State private var restoreError: Error?
```

AFTER:

```swift
    @State private var restoreError: Error?
    @State private var restoreNotice: String?
```

- [ ] **Step 2: Clear the notice when the primary CTA runs**

BEFORE (`PaywallView.swift:178-185`):

```swift
    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    restoreError = nil
                    if await actionHandler.perform() { onComplete() }
                }
            } label: {
```

AFTER:

```swift
    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    restoreError = nil
                    restoreNotice = nil
                    if await actionHandler.perform() { onComplete() }
                }
            } label: {
```

- [ ] **Step 3: Render the notice**

BEFORE (`PaywallView.swift:207-214`):

```swift
            if let error = restoreError ?? actionHandler.error {
                let purchaseAlert = localizedPurchaseAlert(error)
                Text("\(purchaseAlert.title): \(purchaseAlert.message)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
```

AFTER:

```swift
            if let error = restoreError ?? actionHandler.error {
                let purchaseAlert = localizedPurchaseAlert(error)
                Text("\(purchaseAlert.title): \(purchaseAlert.message)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            } else if let restoreNotice {
                Text(restoreNotice)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
```

- [ ] **Step 4: Report the restore outcome**

BEFORE (`PaywallView.swift:224-239`):

```swift
            Button {
                Task {
                    restoreError = nil
                    do {
                        try await subscriptionManager.restore()
                        if subscriptionManager.isPremium { onComplete() }
                    } catch {
                        restoreError = error
                    }
                }
            } label: {
                Text(lm.restorePurchases)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
                    .underline()
            }
```

AFTER:

```swift
            Button {
                Task {
                    restoreError = nil
                    restoreNotice = nil
                    do {
                        try await subscriptionManager.restore()
                        // A restore with nothing to restore succeeds and grants nothing. Saying
                        // so beats a button that visibly does nothing at all.
                        if subscriptionManager.isPremium {
                            onComplete()
                        } else {
                            restoreNotice = lm.restoreNoPurchasesFound
                        }
                    } catch {
                        restoreError = error
                    }
                }
            } label: {
                Text(lm.restorePurchases)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
                    .underline()
            }
            .disabled(subscriptionManager.isLoading || actionHandler.isLoading)
```

- [ ] **Step 5: Build to verify it compiles**

```bash
xcodebuild build -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 6: Commit**

```bash
git add Momsy/Features/Subscription/Presentation/Views/PaywallView.swift
git commit -m "feat: tell the user when a restore finds no purchases"
```

---

## Definition of Done — grep-verifiable

Run from the repository root. Every line must print exactly what is stated.

```bash
# 1. The scope guard no longer wipes the success marker.
grep -c "store.clearAll()" Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift
# expect: 2   (was 3: flush() and clear() keep theirs, discardPendingIfScopeChanged loses its own)
grep -A 4 "func discardPendingIfScopeChanged" Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift | grep -c "clearPending"
# expect: 1

# 2. The backoff budget is restorable and wired to the foreground refresh.
grep -c "func resetRetryBudget" Momsy/Features/Subscription/Data/Services/SubscriptionSyncQueue.swift
# expect: 1
grep -A 4 "func refreshAccess" Momsy/Features/Subscription/Domain/SubscriptionManager.swift | grep -c "resetRetryBudget"
# expect: 1

# 3. Listener errors resolve instead of returning silently.
grep -c "guard error == nil" Momsy/Features/Subscription/Data/Services/FamilyPremiumService.swift
# expect: 0
grep -c "Family entitlement listener failed" Momsy/Features/Subscription/Data/Services/FamilyPremiumService.swift
# expect: 1

# 4. The resolution watchdog exists, is armed, and is cancelled.
#    NB: plain "accessResolutionTimeout" also matches "accessResolutionTimeoutTask" — match exactly.
grep -c "private let accessResolutionTimeout: Duration" Momsy/Features/Subscription/Domain/SubscriptionManager.swift
# expect: 1
grep -c "accessResolutionTimeout: Duration = .seconds(6)" Momsy/Features/Subscription/Domain/SubscriptionManager.swift
# expect: 1
grep -c "func resolveStalledAccessIfNeeded" Momsy/Features/Subscription/Domain/SubscriptionManager.swift
# expect: 1
grep -A 3 "private func updateAccessState" Momsy/Features/Subscription/Domain/SubscriptionManager.swift | grep -c "armAccessResolutionTimeout()"
# expect: 0   (the call sits below the 3 assignment lines — see the next check)
grep -c "        armAccessResolutionTimeout()" Momsy/Features/Subscription/Domain/SubscriptionManager.swift
# expect: 1
grep -A 6 "deinit {" Momsy/Features/Subscription/Domain/SubscriptionManager.swift | grep -c "accessResolutionTimeoutTask?.cancel()"
# expect: 1

# 5. The family observer is rebuilt after an auth change.
grep -A 16 "func authSessionDidChange" Momsy/Features/Subscription/Domain/SubscriptionManager.swift | grep -c "observeCurrentFamily(FamilyManager.shared.familyId, force: true)"
# expect: 1

# 6. Localization present in all 7 languages.
grep -c "restoreNoPurchasesFound" Momsy/Core/Localization/L10n.swift
# expect: 1
grep -c "restoreNoPurchasesFound" Momsy/Features/Subscription/Presentation/Views/PaywallView.swift
# expect: 1

# 7. ContentView was NOT modified.
git diff --name-only da69af4e -- Momsy/ContentView.swift
# expect: (empty)

# 8. No new hardcoded user-facing strings in the paywall.
grep -nE 'Text\("[A-Za-z]' Momsy/Features/Subscription/Presentation/Views/PaywallView.swift
# expect: (empty)

# 9. Full suite.
xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "Test Suite .* (passed|failed)" | tail -3
# expect: all passed; SubscriptionManagerLogicTests reports 31 tests, FamilyPremiumAccessTests reports 11
```

---

## Manual QA script

Device build, **not** the Xcode StoreKit configuration (it bypasses `shouldSynchronizeFamilyEntitlement`). Use a Sandbox Apple Account.

**Scenario 1 — Offline cold start, family member without premium (the P0 repro)**
1. Sign in, enable cloud sync, join or create a family. Confirm the app reaches the main tab bar.
2. Force-quit. Enable Airplane Mode.
3. Launch. **Expect:** splash for ≤ ~9 s (2.2 s fixed + 6 s watchdog), then the paywall. **Fail:** splash forever.
4. Console filter `subsystem:RuslanAbd.Momsy category:subscription` → `Premium access resolution timed out`.

**Scenario 2 — Offline cold start, family member *with* premium**
1. Same setup, but with an active family subscription synced at least once while online.
2. Force-quit → Airplane Mode → launch.
3. **Expect:** the cached family doc resolves to premium, main tab bar appears, **no** paywall flash. This is the regression the watchdog must not break.

**Scenario 3 — Denied family listener**
1. In the Firebase console, remove your `members/{uid}` doc from your family so `belongsToFamily` fails.
2. Force-quit, launch online.
3. **Expect:** paywall within seconds; console shows `Family entitlement listener failed`. **Fail:** splash forever.
4. Restore the member doc afterwards.

**Scenario 4 — Re-auth with an unchanged family**
1. Signed in with cloud sync and a family. Sign out from Settings, then sign back in with the same Apple Account.
2. **Expect:** the app resolves to premium or paywall within seconds. **Fail:** splash forever.

**Scenario 5 — No duplicate Cloud Function calls**
1. Firebase Console → Functions → `syncSubscriptionEntitlement` → note the invocation count.
2. As a paying user, force-quit and relaunch 5 times online.
3. **Expect:** invocation count unchanged (+0). Before this change it was +5.

**Scenario 6 — Backoff recovers**
1. Enable Airplane Mode, purchase in Sandbox → the sync fails and exhausts 3 retries (~72 s).
2. Wait 2 minutes, disable Airplane Mode, background the app, foreground it.
3. **Expect:** a new invocation lands and the family doc gets `premiumEntitlement`.

**Scenario 7 — Restore with nothing to restore**
1. Fresh Sandbox Apple Account with no purchases. Open the paywall, tap Restore Purchases.
2. **Expect:** *"No previous purchases found for this Apple Account."* in the current UI language. **Fail:** nothing happens.
3. Repeat with the device set to RU / DE / ES / FR / PT / ZH.

**Scenario 8 — Happy path unaffected**
1. Fresh install, sign in, purchase annual in Sandbox.
2. **Expect:** premium unlocks, transaction finishes, family doc receives `premiumEntitlement`, relaunch keeps premium with no extra function call.

---

## Risk notes for the reviewer

- **The watchdog can show the paywall to a genuinely premium user** on a slow-but-working network. Mitigated by the 6 s budget, by `updateAccessState` re-granting the moment either source answers, and by `PaywallPresentationState.shouldResetDecision` re-arming the paywall only on `.requiresPurchase`. If field telemetry shows false paywalls, raise `accessResolutionTimeout` rather than removing the watchdog.
- **`resolvedAccess` is deliberately untouched.** Returning `false` for a cache-only snapshot would fix the hang and introduce a premium→paywall flicker on every offline launch for paying users. The watchdog is the correct layer.
- **Task 5 has no automated coverage** because `observeCurrentFamily` reaches `FamilyManager.shared` directly. Injecting a `FamilyIdentityProviding` protocol is the right follow-up but is a wider refactor — keep it out of this change.
