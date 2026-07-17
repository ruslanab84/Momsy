# P2 — Health-Gated Revocation Detection + Setup Race Fix

**Verified against fresh clone, commit `0402de6`.**
File under change: `Momsy/Core/Family/FamilyManager.swift` only (plus tests).

## Root Cause

### Issue 1 — False-positive revocation (data loss)

`confirmMembership` (lines 313–322) is the **first** server read of the launch on
the cached-familyId path. `classifyMembershipError` (303–310) treats any
`permissionDenied` as `.revoked`. But `permissionDenied` is also what **every**
Firestore read returns when App Check attestation transiently fails — a condition
unrelated to roster membership.

Consequence chain on a transient attestation failure:
`.revoked` → `detachFromRevokedFamily` → `onMembershipRevoked` purge drops
`PendingWritesStore` entries for the family (**unsynced local logs permanently
lost**) → false "removed from family" alert. The routing-field delete (331–332)
also fails under the same denial (swallowed by `try?`), so the next healthy launch
re-adopts the family and cloud data returns — but locally-only entries are gone.

The existing-path check (setup, after the `userRef.getDocument(source: .server)`
read) is already implicitly safe: a successful user-doc read one line earlier
proves auth + App Check are healthy, so a member-doc denial there is genuine.
The cached path has no such health signal.

### Issue 2 — Concurrency race on `hasVerifiedMembershipThisLaunch`

Line 123: the flag is set **after** `await confirmMembership(...)`. `setup()` is
invoked concurrently (app launch + auth state listener); both callers can pass the
`if hasVerifiedMembershipThisLaunch` check (121) before either reaches line 123,
because the `await` at 122 is a suspension point on the MainActor. Result: double
server read; on a real revocation — double `detachFromRevokedFamily` (double
purge, double routing delete, **two alerts**). The `isSettingUp` guard (135) sits
below the cached branch and does not protect it.

## Fix

Both issues resolve inside the cached branch of `setup()` plus one new helper.
The principle: **a member-doc denial counts as revocation only when a self
`users/{uid}` read succeeded in the same probe** — the self read is always
permitted by rules (`allow read: if isSignedIn() && request.auth.uid == uid`),
so its success proves the connection, auth token, and App Check attestation are
all healthy, isolating `permissionDenied` on the member doc to its only remaining
cause: the doc does not exist.

### 1. Replace the cached branch (lines 116–132)

```swift
        // Cached familyId: verify roster membership against the server ONCE per
        // launch. A member removed by a family admin otherwise keeps a dead cache
        // forever — every read/write silently rules-denied. On revocation, fall
        // through below and start a fresh personal family.
        if let cachedId = familyId {
            if hasVerifiedMembershipThisLaunch { isReady = true; return }
            // Set BEFORE the await: setup() is re-entered concurrently (launch +
            // auth listener) and the suspension below would otherwise let both
            // callers run the check — double read, double detach, double alert.
            hasVerifiedMembershipThisLaunch = true
            let check = await confirmMembershipHealthGated(familyId: cachedId, uid: uid)
            switch check {
            case .member, .unknown:
                isReady = true
                return
            case .revoked:
                await detachFromRevokedFamily(uid: uid, familyId: cachedId)
                // Continue below: users/{uid}.familyId is cleared, a new family is created.
            }
        }
```

### 2. Add the health-gated probe (below `confirmMembership`, after line 322)

```swift
    /// Cached-path probe. `permissionDenied` on the member doc is trusted as a
    /// revocation ONLY when a self `users/{uid}` read succeeds in the same probe:
    /// the self read is always permitted by rules, so its success proves the
    /// connection, auth token, and App Check attestation are healthy — leaving
    /// "member doc does not exist" as the only cause of the denial. If the self
    /// read fails too, the denial is environmental → `.unknown`, no detach.
    private func confirmMembershipHealthGated(familyId: String, uid: String) async -> MembershipCheck {
        let check = await confirmMembership(familyId: familyId, uid: uid)
        guard check == .revoked else { return check }
        do {
            _ = try await db.collection("users").document(uid)
                .getDocument(source: .server)
            return .revoked
        } catch {
            Self.log.info("Membership denial not confirmed — self read failed; treating as transient")
            return .unknown
        }
    }
```

Notes:
- The self read runs **only** on the `.revoked` path, so the steady-state cost
  stays at 1 read per launch; the extra read is paid once, only when a detach is
  about to happen — exactly when certainty matters.
- The existing-path call at ~line 148 (`confirmMembership(familyId: candidate,
  uid: uid)`) stays on the plain `confirmMembership` — the `userRef.getDocument
  (source: .server)` immediately above it already is the health gate. Do not
  double-gate it.
- `detachFromRevokedFamily`, `classifyMembershipError`, `onMembershipRevoked`
  wiring, and the notification/alert flow are unchanged.

## Tests

`MomsyTests/Core/Family/FamilyMembershipCheckTests.swift` — the two existing
classification tests stay. The health gate itself needs Firestore, so extract the
pure decision into a testable static and cover it (Swift Testing):

### 3. Add to `FamilyManager`:

```swift
    /// Pure gate decision: a raw `.revoked` classification is confirmed only by a
    /// healthy self read; otherwise it degrades to `.unknown`.
    nonisolated static func gatedMembershipCheck(raw: MembershipCheck,
                                                 selfReadSucceeded: Bool) -> MembershipCheck {
        guard raw == .revoked else { return raw }
        return selfReadSucceeded ? .revoked : .unknown
    }
```

Refactor `confirmMembershipHealthGated` to route its return through this static.

### 4. Add tests:

```swift
    @Test func revokedConfirmedOnlyByHealthySelfRead() {
        #expect(FamilyManager.gatedMembershipCheck(raw: .revoked, selfReadSucceeded: true) == .revoked)
        #expect(FamilyManager.gatedMembershipCheck(raw: .revoked, selfReadSucceeded: false) == .unknown)
    }

    @Test func nonRevokedResultsBypassTheGate() {
        #expect(FamilyManager.gatedMembershipCheck(raw: .member, selfReadSucceeded: false) == .member)
        #expect(FamilyManager.gatedMembershipCheck(raw: .unknown, selfReadSucceeded: false) == .unknown)
    }
```

## Definition of Done

- [ ] Flag set before the `await` in the cached branch; comment explains the race
- [ ] `confirmMembershipHealthGated` added; cached path uses it; existing path untouched
- [ ] `gatedMembershipCheck` static added; helper routes through it
- [ ] Two new tests green; two existing classification tests untouched and green
- [ ] All targets build
- [ ] Steady-state launch cost unchanged: exactly 1 membership read when `.member`

## Manual QA

1. **Real revocation:** device A (parent) removes device B's member. Relaunch B →
   exactly one "removed from family" alert, old children gone from picker, new
   personal space works, B can re-join with a fresh code.
2. **Transient denial simulation:** temporarily enforce App Check with an invalid
   debug token on device B (or revoke the debug token in console). Relaunch →
   NO alert, NO purge, cache intact, log shows "self read failed; treating as
   transient". Restore the token, relaunch → normal sync resumes, pending local
   entries upload.
3. **Concurrent setup:** cold launch while signed in (launch + auth listener both
   fire) → Firestore usage shows a single member-doc read; no duplicate alert
   even when combined with scenario 1.
4. **Regression:** invite-join flow, family switch with purge confirmation, and
   account deletion all behave as before.
