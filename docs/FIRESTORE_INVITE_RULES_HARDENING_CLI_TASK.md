# CLI Task: Firestore Rules — Invite Enumeration & Expiry Hardening

**Severity:** P0 (active data-exposure hole in production) + P1 (expiry not enforced server-side)
**Scope:** `firestore.rules` only. No Swift changes. No client-behavior changes.
**Estimated diff:** ~6 lines in one `match` block.

---

## Problem

`firestore.rules` currently exposes every family's invite code to any signed-in user:

```
match /invites/{code} {
  allow read:          if isSignedIn();
  allow create, update: if isFamilyMember(request.resource.data.familyId);
  allow delete:        if isFamilyMember(resource.data.familyId);
}
```

Two issues:

1. **P0 — Enumeration.** In Firestore rules, `read` grants BOTH `get` (single doc) AND `list` (collection query). A signed-in attacker can run `db.collection("invites").getDocuments()` and receive **every active invite code + its `familyId`**. Because a user can freely write their own `users/{uid}` doc (`allow read, write: if request.auth.uid == uid`), the attacker sets `users/{uid}.familyId = <victimFamilyId>`, which makes `isFamilyMember(victimFamilyId)` return true, granting full read/write access to another family's baby data under `families/{familyId}/babies/**`.

2. **P1 — Expiry not enforced.** The client (`FamilyManager.joinFamily`) checks `expiresAt > Date()`, but the rules do not. A modified/replayed client can join using an expired code.

## Fix

Split `read` into `get` + `list`. Allow single-document `get` (needed so `joinFamily` can look up one code by its exact ID), deny `list` entirely (nobody should enumerate the collection), and require the invite to be unexpired on `get`.

Invite docs carry `expiresAt` as a Firestore `Timestamp` (written by `FirestoreInviteService.writeToFirestore`), so `resource.data.expiresAt > request.time` is a valid comparison.

---

### Task 1: Harden the `/invites/{code}` match block

**Files:**
- Modify: `firestore.rules` (the `match /invites/{code}` block)

- [ ] **Step 1: Replace the block**

Find:

```
    // Any signed-in user may read an invite to discover the familyId to join.
    // Only members of the referenced family may create/replace or delete a code.
    match /invites/{code} {
      allow read:          if isSignedIn();
      allow create, update: if isFamilyMember(request.resource.data.familyId);
      allow delete:        if isFamilyMember(resource.data.familyId);
    }
```

Replace with:

```
    // A signed-in user may look up ONE invite by its exact code to discover the
    // familyId to join — but only while it is unexpired. `list` is denied outright:
    // allowing it would let any signed-in user enumerate every family's code and
    // familyId, then self-assign membership via their own users/{uid} doc.
    // Only members of the referenced family may create/replace or delete a code.
    match /invites/{code} {
      allow get:            if isSignedIn()
                            && resource.data.expiresAt > request.time;
      allow list:           if false;
      allow create, update: if isFamilyMember(request.resource.data.familyId);
      allow delete:         if isFamilyMember(resource.data.familyId);
    }
```

- [ ] **Step 2: Lint locally**

Run: `firebase deploy --only firestore:rules --dry-run`
Expected: `✔ rules file firestore.rules compiled successfully` (no syntax errors). If the CLI reports an unknown flag, use the Rules Playground in the Firebase console instead (paste the file, confirm it compiles).

- [ ] **Step 3: Verify with the emulator (if available)**

If the Firestore emulator + a rules test harness is set up, assert:
- A `get` on a valid, unexpired invite as any signed-in user → ALLOW.
- A `get` on an expired invite (`expiresAt` in the past) → DENY.
- A `list`/collection query on `invites` as any user → DENY.
- `create`/`update` by a non-member of `request.resource.data.familyId` → DENY.

If no harness exists, skip to Step 4 — the change is small and the dry-run compile plus the manual QA below cover it.

- [ ] **Step 4: Deploy**

```bash
firebase deploy --only firestore:rules
```

Expected: `✔ Deploy complete!`

---

## Definition of Done

- [ ] `firestore.rules` compiles clean via dry-run or console.
- [ ] `allow read` on `/invites/{code}` no longer exists; replaced by `get` (with expiry check) + `list: if false`.
- [ ] `create`/`update`/`delete` rules unchanged in behavior.
- [ ] Rules deployed to production.

## Manual QA (two accounts, real devices/simulators)

1. **Happy path still works:** Account A generates an invite in Sharing → shares the `momsy://join?code=…` link → Account B taps it → B joins A's family and sees A's baby data. (Confirms single-`get` lookup still works.)
2. **Expired code rejected:** In the Firebase console, edit an invite doc's `expiresAt` to a past date. Attempt to join with that code from a fresh account → join fails with "invalid or expired code." (Confirms server-side expiry.)
3. **No regression on generation:** Account A regenerates the code (Sharing → regenerate); the new code writes successfully. (Confirms `create`/`update` unaffected.)

## Notes / Out of Scope

- This does NOT address the missing Firebase App Check (a separate P1 — App Check is what stops a non-app client from making authenticated Firestore/Gemini calls at all). File that separately.
- The `families/{familyId}/babies/{babyId}/**` read rule still trusts `users/{uid}.familyId`. That trust is now safe *for invites* because codes can no longer be enumerated, but App Check remains the defense-in-depth layer against forged clients.
