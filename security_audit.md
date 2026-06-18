# Security Audit — Momsy

**Date:** 2026-06-19
**Scope:** Data-isolation bindings — Firebase Storage (diary photos), Cloud Firestore (per-baby logs), AI generation safety.
**Method:** Source-level review of the real bindings, not a checklist. Each control is rated against what the *backend enforces*, not what the client *intends*.

**Overall verdict: ❌ FAIL (conditional)** — blocked by Findings #1 and #2. The photo data class has no backend-enforced isolation. Firestore and AI controls pass.

A prior `PASS` was not defensible: it credited "User data isolation" as a single control, but isolation is enforced for Firestore and **not** for Storage. The two must be rated separately.

---

## Findings

### #1 — Firebase Storage has no security rules (Critical)

**Binding:** `Momsy/Features/Diary/Data/Services/FirebasePhotoStorageService.swift:29`
```
let path = "users/\(uid)/diary/\(id.uuidString).jpg"
```
Diary photos are uploaded under a per-uid path. That path is the *only* thing scoping one user's photos from another's — and it is enforced **nowhere on the backend**.

**Evidence of the gap:** `firebase.json` declares only Firestore rules:
```json
{ "firestore": { "rules": "firestore.rules" } }
```
There is no `storage` block and no `storage.rules` file in the repository. With no deployed Storage rules, object access is governed by the bucket's default policy. The client *writes* to `users/{uid}/…`, but nothing prevents an authenticated caller from reading or deleting `users/<any-other-uid>/diary/*`.

**Impact:** The "User data isolation" claim in `software-design-and-architecture-analysis.md` does not hold for diary photos. Cross-user photo read/delete is possible depending on the bucket default.

**Remediation:**
1. Add `storage.rules` enforcing ownership:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{uid}/{allPaths=**} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }
   ```
2. Wire it into `firebase.json`:
   ```json
   { "firestore": { "rules": "firestore.rules" },
     "storage":   { "rules": "storage.rules" } }
   ```
3. Deploy (`firebase deploy --only storage`) and verify with the emulator/rules test that a uid cannot read another uid's object.

---

### #2 — Photo ownership keyed to ephemeral anonymous uid (High)

**Binding:** `FirebasePhotoStorageService.swift:59-62`
```swift
private func resolveUID() async throws -> String {
    if let uid = Auth.auth().currentUser?.uid { return uid }
    return try await Auth.auth().signInAnonymously().user.uid
}
```
When no user is signed in, ownership falls back to an **anonymous** uid. Anonymous uids are per-install and non-durable: an app reinstall or signed-out state mints a new uid, orphaning the previous bucket (no access to prior photos, no cleanup path).

This is also an **identity-axis mismatch**: every other data class is isolated by authenticated *family membership* — `families/{familyId}/babies/{babyId}/**` (`firestore.rules:77`), derived from `users/{uid}.familyId`. Photos alone are isolated by a raw Storage uid that may be anonymous and is not tied to family membership. Even after Finding #1 is fixed, this leaves photos on a weaker, inconsistent ownership model than the rest of the app.

> Note: the previous fix (commit `638…`, replacing a shared `users/anonymous/` literal with a per-device uid) correctly closed the *shared-bucket* hole. It did **not** add Storage rules (#1) and does not make the anonymous binding durable (#2).

**Remediation:**
- Require an authenticated (Apple/Google) session before photo upload, or migrate anonymous uploads to the real uid on sign-in.
- Once #1's rules are deployed, confirm `deleteAll()` (`:91-103`) — already correctly a no-op when unauthenticated (`:94`) — still clears the right bucket under the durable uid.

---

## Controls that pass

### Firestore data isolation — ✅ PASS
`firestore.rules` enforces per-user and per-family access:
- `users/{uid}` readable/writable only by that uid (`:51-53`).
- Family subtree (`families/{familyId}/…`, including `babies/{babyId}/{document=**}`) gated by `belongsToFamily()` — membership derived from `users/{uid}.familyId`, with a scoped creator exception during setup (`:34-48`, `:63-80`).
- Invites are readable by any signed-in user (needed to discover a `familyId` to join) but writable only by members of the referenced family (`:57-61`) — appropriate.
- **Caveat:** the legacy family-keyed tree `babies/{familyId}/{document=**}` (`:84-86`) remains open to members and should be removed once all clients have migrated off the pre-per-baby path.

### AI generation safety — ✅ PASS
`Momsy/Core/AI/GeminiSafety.swift` applies backend-enforced `SafetySetting`s (`blockMediumAndAbove` across harassment, hate speech, sexually explicit, dangerous content) to every Gemini request. Enforced by the model backend, not by system-prompt phrasing. Inputs are app-built context (daily tips, weekly insights), not free-form user chat, so the threshold is appropriate.

---

## Summary

| Control                         | Verdict | Reference |
|---------------------------------|---------|-----------|
| Firestore per-family isolation  | ✅ PASS | `firestore.rules:51-86` |
| AI generation safety filters    | ✅ PASS | `GeminiSafety.swift` |
| Storage photo isolation (rules) | ❌ FAIL | Finding #1 — no `storage.rules` |
| Photo ownership durability      | ❌ FAIL | Finding #2 — anonymous uid fallback |
| Legacy `babies/{familyId}` tree | ⚠️ WATCH | `firestore.rules:84-86` — remove post-migration |

**Gate to PASS:** deploy enforced Storage rules (#1) and bind photos to a durable authenticated identity (#2). Until then, the documented "User data isolation" claim is accurate for Firestore only and must not be stated unqualified.
