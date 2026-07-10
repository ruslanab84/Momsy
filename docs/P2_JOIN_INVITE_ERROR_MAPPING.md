# P2 — Invalid/expired invite codes surface as raw "Missing or insufficient permissions"

**Repo state verified against:** main @ `2b279c6`
**Depends on:** `FirestoreErrorClassification.swift` from `P1_FAMILY_SETUP_MEMBERSHIP_ORDER.md` (create it first if that task has not run — snippet included there).

## Problem

`firestore.rules:151-152` allows `get` on `invites/{code}` only while `resource.data.expiresAt > request.time`. For a **nonexistent** code `resource.data` fails to evaluate, for an **expired** code the comparison fails — both result in a rules deny, and the SDK **throws `permission-denied`** before the client-side guard ever runs.

Verified current code (`Momsy/Core/Family/FamilyManager.swift:164-170`):

```swift
        let inviteDoc = try await db.collection("invites").document(trimmed).getDocument()
        guard
            let data = inviteDoc.data(),
            let targetFamilyId = data["familyId"] as? String,
            let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue(),
            expiresAt > Date()
        else { throw FamilyError.invalidOrExpiredCode }
```

`FamilyError.invalidOrExpiredCode` is unreachable from the Firestore path. Users see `error.localizedDescription` = "Missing or insufficient permissions." (`SharingViewModel.swift`, catch-all in `joinFamily`) or the same raw error as `authError` in onboarding.

Additionally `FamilyError.errorDescription` (`FamilyManager.swift:25-31`) is hardcoded English, violating the 7-language localization rule.

## Fix

### 1. Map the deny at the source — replace `FamilyManager.swift:164`:

```swift
        let inviteDoc: DocumentSnapshot
        do {
            inviteDoc = try await db.collection("invites").document(trimmed).getDocument()
        } catch where error.isFirestorePermissionDenied {
            // Rules deny `get` for nonexistent AND expired codes (`resource.data.expiresAt`
            // fails or is past), so both surface here — never as an empty snapshot.
            throw FamilyError.invalidOrExpiredCode
        }
```

Keep the existing `guard` below unchanged (it still validates decode shape).

### 2. Localize the message — in `FamilyError.errorDescription` (`FamilyManager.swift:28`), replace:

```swift
        case .invalidOrExpiredCode:       return "This invite code is invalid or has expired."
```

with:

```swift
        case .invalidOrExpiredCode:       return LocalizationManager.shared.strings.joinFailedMessage
```

The key exists and is fully localized across all 7 languages (`Momsy/Core/Localization/L10n.swift:773`). `LocalizationManager.shared` is deliberately not `@MainActor` and is safe to read synchronously (established pattern: `LocalPushNotificationService`, `CloudSyncDownloader`).

Leave `.noFamilyId` / `.wouldAbandonExistingFamily` strings as-is — `.wouldAbandonExistingFamily` is caught and replaced by localized confirm dialogs at every call site; localizing `.noFamilyId` is optional follow-up.

## Tests (Swift Testing)

Append to `MomsyTests/Services/FirestoreErrorClassificationTests.swift` (or a new file):

```swift
import Testing
@testable import Momsy

struct FamilyErrorLocalizationTests {
    @Test func invalidCodeMessageIsLocalized() {
        #expect(
            FamilyError.invalidOrExpiredCode.errorDescription
            == LocalizationManager.shared.strings.joinFailedMessage
        )
    }
}
```

## Definition of Done

- [ ] `permission-denied` on the invite `get` maps to `FamilyError.invalidOrExpiredCode`
- [ ] `.invalidOrExpiredCode` renders the localized `joinFailedMessage`
- [ ] Test passes; full suite green; all targets build

## Manual QA (simulator)

1. Sharing → Join: enter `MOMSY-ZZZZZZ` (nonexistent). Expect the localized "invalid or expired" message (RU device: «Этот код приглашения недействителен или истёк.»), not "Missing or insufficient permissions."
2. In Firebase console, set an existing invite's `expiresAt` to the past → enter that code → same localized message.
3. Valid code still joins successfully.
4. Onboarding join flow (`.joinFamily`): garbage code after auth → localized message shown as the auth-step error.
