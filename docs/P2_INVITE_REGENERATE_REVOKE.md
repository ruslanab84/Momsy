# P2 — Regenerating an invite does not revoke the previous code

**Repo state verified against:** main @ `2b279c6`

## Problem

`FirestoreInviteService.regenerate()` writes a new `invites/{code}` document but never deletes the previous one. The old code stays valid until its own `expiresAt` (up to 24h). "Regenerate" is the user's revocation action ("I shared the code with the wrong person") — today it revokes nothing.

Verified current code (`Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift:36-45`):

```swift
    @discardableResult
    func regenerate() -> String {
        let code = generateCode()
        let exp = Date().addingTimeInterval(86400)
        defaults.set(code, forKey: codeKey)
        defaults.set(exp, forKey: expiryKey)
        defaults.removeObject(forKey: syncedCodeKey)
        pendingWrite = Task { try await self.writeToFirestore(code: code, expiry: exp) }
        return code
    }
```

## Fix

Capture the superseded code before overwriting the cache; delete its Firestore document inside the same pending task, **after** the new code is written (so `regenerateAndSync()` / `prepareInvite()` awaiting `pendingWrite` still guarantee the new code exists before sharing, and revocation completes within the same awaited task).

Replace `regenerate()` and add the private helper:

```swift
    @discardableResult
    func regenerate() -> String {
        let previousCode = defaults.string(forKey: codeKey)
        let code = generateCode()
        let exp = Date().addingTimeInterval(86400)
        defaults.set(code, forKey: codeKey)
        defaults.set(exp, forKey: expiryKey)
        defaults.removeObject(forKey: syncedCodeKey)
        pendingWrite = Task {
            try await self.writeToFirestore(code: code, expiry: exp)
            await self.revokeInvite(previousCode, replacedBy: code)
        }
        return code
    }

    /// Best-effort revocation of the superseded code. Failure is non-fatal — the old
    /// document still self-expires via `expiresAt` (≤24h) and rules deny expired gets.
    private func revokeInvite(_ oldCode: String?, replacedBy newCode: String) async {
        guard let oldCode, oldCode != newCode else { return }
        do {
            try await db.collection("invites").document(oldCode).delete()
        } catch {
            // Old code may belong to a previous family (rules deny) or be gone already.
        }
    }
```

## Rules cross-check (no rules changes needed)

- `invites/{code}` delete requires `canManageFamilyRoster(resource.data.familyId)` (`firestore.rules:155`). Regenerate is gated on `canManageMembers` in `SharingViewModel` and the invite-role step in onboarding — the caller is Mom/Dad of that family. ✓
- Deleting a **nonexistent** doc: `resource` is null → rule evaluation errors → deny → throw → swallowed by `revokeInvite`. Idempotent. ✓
- Side benefit: `currentCode()` calling `regenerate()` on local expiry now also cleans up the expired remote doc.

## Definition of Done

- [ ] Old invite document is deleted from Firestore on regenerate (both `SharingViewModel.regenerateInvite` and onboarding `prepareInvite(regenerate: true)` paths)
- [ ] New code is written before the old one is deleted
- [ ] Full test suite green; all targets build

## Manual QA (simulator)

1. Device A (Mom): Sharing → invite sheet → note code **X** → regenerate → note code **Y**.
2. Firebase console: `invites` contains **only Y**; X's document is gone.
3. Device B: enter **X** → localized "invalid or expired" message (with `P2_JOIN_INVITE_ERROR_MAPPING` applied).
4. Device B: enter **Y** → joins successfully.
