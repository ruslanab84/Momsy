# P2 — `firestore.rules`: any family member can rewrite `createdBy` on the family doc

**Repo state verified against:** main @ `2b279c6`

## Problem

`firestore.rules:158-163`:

```
    match /families/{familyId} {
      allow read:          if belongsToFamily(familyId);
      allow create:        if isSignedIn()
                           && request.resource.data.createdBy == request.auth.uid
                           && request.resource.data.bootstrapComplete == false;
      allow update, delete: if belongsToFamily(familyId);
```

Any member — including Nanny/Grandma — may rewrite `createdBy` and `bootstrapComplete`. `createdBy` anchors `isFamilyCreator` (rules lines 35-40), which gates the creator-bootstrap path; it must be immutable after create. Practical exploit value today is low (all `isFamilyCreator` consumers require the caller to *lack* a member doc, which a tampering member has), but it is an invariant leak and free to close.

## Fix — replace the `match /families/{familyId}` block header rules

```
    match /families/{familyId} {
      allow read:   if belongsToFamily(familyId);
      allow create: if isSignedIn()
                    && request.resource.data.createdBy == request.auth.uid
                    && request.resource.data.bootstrapComplete == false;
      // Any member may update lifecycle fields (setup flips `bootstrapComplete` to
      // true) but `createdBy` is immutable — it anchors `isFamilyCreator`.
      allow update: if belongsToFamily(familyId)
                    && request.resource.data.createdBy == resource.data.createdBy;
      // Delete deliberately stays member-wide: account erasure must succeed for a
      // sole remaining member of ANY role (nanny/grandma); a `canManageFamilyRoster`
      // gate would strand their erasure — rules cannot count roster docs to special-
      // case "sole member".
      allow delete: if belongsToFamily(familyId);
```

The nested `match /members/{memberId}` and `match /babies/{babyId}/{document=**}` blocks stay unchanged.

## Design decisions (record in the rules comments, as above)

1. **`delete` is NOT tightened to `canManageFamilyRoster`.** `FirestoreAccountEraser.deleteCloudData` calls `familyRef.delete()` for a sole member of *any* role. Gating delete on Mom/Dad would permanently break account deletion for a sole remaining Nanny (recovery marker would retry forever). A member deleting the family doc is low-impact vandalism: subcollections survive, `belongsToFamily` (and therefore all data access) is unaffected.
2. **`bootstrapComplete` stays mutable by members.** With `createdBy` immutable, flipping it back to `false` grants nothing: `isFamilyCreator` only matters to a caller who has no member doc yet, and every path that could exploit it requires being `createdBy`.

## Client compatibility (verified — deploy safe any time, no app release dependency)

The only top-level family-doc writers in the app:

- `FamilyManager.createFamily` (`FamilyManager.swift:137-145`) — create path, unchanged rules.
- `FamilyManager.setup` (`FamilyManager.swift:122-123`) — `updateData(["bootstrapComplete": true])`. In rules, `request.resource.data` is the merged post-write document: `createdBy` is present and equal to `resource.data.createdBy` → allowed. ✓
- `FirestoreAccountEraser` / (dead) `leaveFamily` — delete path, unchanged rules.

No client code writes `createdBy` after creation (grep-verified across `Momsy/`, `MomsyWatch/`).

## Definition of Done

- [ ] Rules block updated exactly as above; `firebase deploy --only firestore:rules` succeeds
- [ ] Post-deploy smoke: fresh onboarding creates a family with no permission errors in Console (the `bootstrapComplete` flip is the sensitive write)
- [ ] Invite join from a second device still works
- [ ] Sole-member account deletion still completes (family doc delete allowed)

## Manual QA

1. Deploy rules.
2. Fresh account → full onboarding → verify family doc exists with `bootstrapComplete: true` (the flip succeeded under the new update rule).
3. Second device joins via invite → roster shows both members.
4. Negative check (Firebase console → Rules Playground, or a scratch client): authenticated update setting `createdBy` to another uid on an existing family → **denied**; update touching only other fields → allowed.
5. Delete the sole-member account → family doc deleted successfully.
