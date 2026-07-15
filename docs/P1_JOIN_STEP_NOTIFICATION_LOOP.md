# P1 — Join step bounces back after tapping Continue (pendingFamilyInviteDidChange self-trigger loop)

## Symptom
During onboarding join flow: user pastes `momsy://join?code=MOMSY-XXXX`, taps Continue. The field text collapses to the bare code (expected normalization), but the flow stays on the Join step. A second tap is required to advance.

## Root cause (verified against fresh clone)
Self-triggering notification loop:

1. `OnboardingViewModel.advance()` → `persistPendingInviteForAuth()`
   (`Momsy/Features/Onboarding/Presentation/ViewModel/OnboardingViewModel.swift:346-353`)
   normalizes the pasted URL, sets `pendingInviteCode = code`, and — since the stored value differs — calls `pendingInviteStore.save(code)`.
2. `PendingFamilyInviteStore.save(_:)` (`Momsy/Core/Family/PendingFamilyInviteStore.swift:21-25`) posts `.pendingFamilyInviteDidChange`.
3. `advance()` moves `step = .auth`, but `OnboardingView` (`Momsy/Features/Onboarding/Presentation/Views/OnboardingView.swift:36-38`) receives the notification → `loadPendingInviteIfNeeded()` (`OnboardingViewModel.swift:200-203`) → `startJoinFlow(code:)` → resets `step = .join`.
4. On the second tap `pendingInviteStore.load() == code`, so `save` is skipped, no notification fires, and the transition sticks.

## Fix

### 1. Make `loadPendingInviteIfNeeded()` idempotent for the current join flow

File: `Momsy/Features/Onboarding/Presentation/ViewModel/OnboardingViewModel.swift` (lines 200-203)

Replace:

```swift
    func loadPendingInviteIfNeeded() {
        guard let code = pendingInviteStore.load() else { return }
        startJoinFlow(code: code)
    }
```

With:

```swift
    func loadPendingInviteIfNeeded() {
        guard let code = pendingInviteStore.load() else { return }
        // A store write initiated by this flow (persistPendingInviteForAuth) posts
        // .pendingFamilyInviteDidChange; re-entering startJoinFlow here would reset
        // step back to .join and swallow the first Continue tap. Only (re)start the
        // join flow for a code we are not already handling.
        if flow == .joinFamily,
           JoinDeeplink.normalize(rawCode: pendingInviteCode) == code {
            return
        }
        startJoinFlow(code: code)
    }
```

Note: a genuinely *new* deeplink arriving mid-onboarding still restarts the join flow (different code → guard falls through), preserving the original purpose of the notification hook.

### 2. Defense in depth: idempotent `save()` / `clear()` in the store

File: `Momsy/Core/Family/PendingFamilyInviteStore.swift` (lines 21-30)

Replace:

```swift
    func save(_ rawCode: String) {
        guard let code = JoinDeeplink.normalize(rawCode: rawCode) else { return }
        defaults.set(code, forKey: Self.codeKey)
        NotificationCenter.default.post(name: .pendingFamilyInviteDidChange, object: nil)
    }

    func clear() {
        defaults.removeObject(forKey: Self.codeKey)
        NotificationCenter.default.post(name: .pendingFamilyInviteDidChange, object: nil)
    }
```

With:

```swift
    func save(_ rawCode: String) {
        guard let code = JoinDeeplink.normalize(rawCode: rawCode) else { return }
        guard defaults.string(forKey: Self.codeKey) != code else { return }
        defaults.set(code, forKey: Self.codeKey)
        NotificationCenter.default.post(name: .pendingFamilyInviteDidChange, object: nil)
    }

    func clear() {
        guard defaults.string(forKey: Self.codeKey) != nil else { return }
        defaults.removeObject(forKey: Self.codeKey)
        NotificationCenter.default.post(name: .pendingFamilyInviteDidChange, object: nil)
    }
```

### 3. Unit test (Swift Testing)

File: `MomsyTests/OnboardingJoinFlowTests.swift` (add to existing test target; adapt VM construction to the existing test factory/mocks used elsewhere in `MomsyTests`)

```swift
import Testing
@testable import Momsy

@MainActor
struct PendingInviteLoopTests {

    @Test func saveIsIdempotentAndDoesNotRepost() {
        let suiteName = "test_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = PendingFamilyInviteStore(defaults: defaults)

        var posts = 0
        let observer = NotificationCenter.default.addObserver(
            forName: .pendingFamilyInviteDidChange, object: nil, queue: nil
        ) { _ in posts += 1 }
        defer { NotificationCenter.default.removeObserver(observer) }

        store.save("MOMSY-TEST")
        store.save("momsy://join?code=MOMSY-TEST")   // same normalized code
        #expect(posts == 1)
        #expect(store.load() == "MOMSY-TEST")

        store.clear()
        store.clear()
        #expect(posts == 2)
    }
}
```

If the existing test infrastructure already provides an `OnboardingViewModel` factory with mocks, add a second test asserting that after `startJoinFlow(code:)` → `advance()` the step is `.auth` and a subsequent `loadPendingInviteIfNeeded()` call does **not** reset it to `.join`.

## Definition of Done
- [ ] `loadPendingInviteIfNeeded()` returns early when `flow == .joinFamily` and the stored code equals the normalized `pendingInviteCode`.
- [ ] `PendingFamilyInviteStore.save` does not post when the stored value is unchanged; `clear` does not post when nothing is stored.
- [ ] New Swift Testing tests pass; existing onboarding/join tests unchanged and green.
- [ ] Build succeeds for all 4 targets.

## Manual QA
1. Fresh install (or clear onboarding state). Start onboarding → "Join with invite".
2. Paste a full link `momsy://join?code=MOMSY-XXXX` into the field.
3. Tap Continue **once** → expected: field normalizes to bare code AND the flow advances to the Auth step in the same tap. No bounce back to Join.
4. Regression: with onboarding NOT done, open a `momsy://join?code=...` deeplink from outside the app (Notes/Safari) → onboarding must land on the Join step with the code prefilled (notification path still works).
5. Regression: while on the Auth step of a join flow, open a deeplink with a *different* code → flow must return to Join with the new code.
6. Regression: manually type a bare code `MOMSY-XXXX` → single tap advances.
