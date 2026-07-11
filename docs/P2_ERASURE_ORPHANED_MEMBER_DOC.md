# P2 — Sole-member account erasure leaves `members/{uid}` orphaned

**Repo state verified against:** main @ `2b279c6`

## Problem

`FirestoreAccountEraser.deleteCloudData` (sole-member branch) deletes the baby trees, the legacy tree, and the family document — but **never the caller's own roster document**. Firestore does not cascade parent-doc deletes into subcollections, so `families/{familyId}/members/{uid}` (containing `name` + `uid` — PII) survives GDPR erasure forever.

Verified current code (`Momsy/Core/Account/DeleteAccountUseCase.swift:69-78`):

```swift
            if soleMember {
                let babyIds = try await discoverBabyIds(in: familyRef)
                for babyId in babyIds {
                    try await deleteBabyTree(familyRef: familyRef, familyId: familyId, babyId: babyId)
                }
                try await deleteLegacyFamilyTree(familyId: familyId)
                try await familyRef.delete()
            } else {
                try await familyRef.collection("members").document(uid).delete()
            }
```

## Fix

Add the member-doc delete at the **end** of the sole-member branch:

```swift
            if soleMember {
                let babyIds = try await discoverBabyIds(in: familyRef)
                for babyId in babyIds {
                    try await deleteBabyTree(familyRef: familyRef, familyId: familyId, babyId: babyId)
                }
                try await deleteLegacyFamilyTree(familyId: familyId)
                try await familyRef.delete()
                // Firestore never cascades into subcollections: the caller's roster doc
                // must be removed explicitly or it outlives the erased account as PII.
                // Ordered AFTER the deletes above — those are authorised by
                // `belongsToFamily`, which reads this very document.
                try await familyRef.collection("members").document(uid).delete()
            } else {
                try await familyRef.collection("members").document(uid).delete()
            }
```

`userRef.delete()` at line 81 stays last overall — unchanged (the comment on `FamilyManager.leaveFamily` already documents why: membership-based rules must still authorise the deletes above it).

## Rules cross-check (no rules changes needed)

- Baby-tree and family-doc deletes are authorised by `belongsToFamily` → the member doc **must still exist** while they run. The new delete is therefore last among family-scoped writes. ✓
- Member **self**-delete (`firestore.rules:178-179`): `isSignedIn() && memberId == request.auth.uid` — evaluated without reading `resource` and independent of the (already deleted) family doc. ✓
- Deleting a missing doc succeeds in Firestore → `AccountDeletionRecovery.runIfNeeded()` reruns stay idempotent (empty roster ⇒ `soleMember == true` per `AccountErasureGate`, every delete no-ops). ✓

## Related cleanup (same file scope, optional but recommended)

`FamilyManager.leaveFamily(uid:tearDownSharedFamily:)` (`FamilyManager.swift:243-252`) has **no callers** (grep-verified; the real path is this use case). If ever invoked with `tearDownSharedFamily: true` it would orphan the entire `babies/**` subtree. Delete the method to remove the trap.

## Definition of Done

- [ ] Sole-member erase deletes the caller's `members/{uid}` doc after the family doc
- [ ] `FamilyManager.leaveFamily` removed (or explicitly kept with a written reason)
- [ ] Full test suite green; all targets build

## Manual QA (simulator)

1. Fresh account, complete onboarding, log some sleep/feeding entries, add a photo.
2. Settings → Delete account → confirm.
3. Firebase console: `families/{id}` doc gone, **`families/{id}/members` empty (no residual doc)**, all `babies` subtrees gone, `users/{uid}` gone, Storage photos gone.
4. Relaunch → clean pre-onboarding state; sign in again with the same provider → no ghost data resurfaces.
