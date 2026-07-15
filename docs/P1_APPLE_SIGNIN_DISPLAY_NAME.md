# P1: Apple sign-in shows private-relay email instead of user name

## Symptom
After Sign in with Apple ("Hide My Email"), Settings → Account shows `xxxxx@privaterelay.appleid.com`. The same string is also written as the family member's display name visible to co-parents.

## Root cause (verified against fresh clone)

1. **`Momsy/Core/Auth/AuthManager.swift:135` — `linkOrSignIn`**: the primary path links the Apple credential onto the existing **anonymous** user via `current.link(with:)`. Unlike `Auth.signIn`, `link` does **not** propagate `cred.fullName` (passed at line 187 via `OAuthProvider.appleCredential(..., fullName:)`) into Firebase `displayName`. Result: `displayName == nil` even on first sign-in.

2. With `displayName` nil, three sites fall back to the raw email — which for "Hide My Email" users is the Apple private relay address:
   - `Momsy/Features/Settings/Presentation/Views/SettingsView.swift:277` — account row subtitle (the screenshot).
   - `Momsy/Core/Auth/AuthManager.swift:71` — `let name = user.displayName ?? user.email ?? "User"` → `FamilyManager.setup(displayName:)` → member doc.
   - `Momsy/Services/Firebase/BabySync/BabySyncService.swift:103` — `let fallbackName = user.displayName ?? user.email ?? "User"` → `SyncAuthorIdentity`.

**Constraint:** Apple provides `fullName` only on the FIRST authorization for this app. The fix persists it going forward; accounts that already authorized will show a provider label instead of the relay address.

---

## Fix 1 — Persist Apple full name to Firebase `displayName`

**`Momsy/Core/Auth/AuthManager.swift`**, in `handleAppleCompletion` (lines 183-190) — replace:

```swift
        let credential = OAuthProvider.appleCredential(
            withIDToken: token,
            rawNonce: nonce,
            fullName: cred.fullName
        )
        firebaseUser = try await linkOrSignIn(with: credential)
```

with:

```swift
        let credential = OAuthProvider.appleCredential(
            withIDToken: token,
            rawNonce: nonce,
            fullName: cred.fullName
        )
        let user = try await linkOrSignIn(with: credential)
        await adoptAppleFullNameIfNeeded(cred.fullName, for: user)
        firebaseUser = user
```

Add below `handleAppleCompletion`:

```swift
    /// `link(with:)` (the anonymous-promotion path) does not propagate the Apple
    /// credential's fullName into Firebase `displayName`, and Apple only supplies it
    /// on the first authorization — persist it here or lose it forever.
    @MainActor
    private func adoptAppleFullNameIfNeeded(_ components: PersonNameComponents?,
                                            for user: FirebaseAuth.User) async {
        guard (user.displayName ?? "").isEmpty, let components else { return }
        let name = PersonNameComponentsFormatter.localizedString(from: components, style: .default)
            .trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let change = user.createProfileChangeRequest()
        change.displayName = name
        do {
            try await change.commitChanges()
        } catch {
            AuthManager.log.error("displayName commit failed: \(error.localizedDescription, privacy: .public)")
        }
    }
```

The auth-state listener (line 59) fires after linking; by the time `FamilyManager.setup` runs with `user.displayName`, the commit has already been applied to the local user object. Idempotent — only runs when `displayName` is empty.

---

## Fix 2 — Never leak a private-relay address as a name

**Create `Momsy/Core/Auth/AccountDisplay.swift`:**

```swift
import Foundation

/// Presentation rules for the signed-in account identity. A "Hide My Email" relay
/// address is valid auth data but must never surface as a user-facing name.
enum AccountDisplay {
    static func isPrivateRelay(_ email: String) -> Bool {
        email.lowercased().hasSuffix("@privaterelay.appleid.com")
    }

    /// Display name for family member docs and sync-author metadata.
    static func memberName(displayName: String?, email: String?, fallback: String = "User") -> String {
        if let displayName, !displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            return displayName
        }
        if let email, !email.isEmpty, !isPrivateRelay(email) {
            return email
        }
        return fallback
    }
}
```

**`Momsy/Core/Auth/AuthManager.swift:71`** — replace:

```swift
                    let name = user.displayName ?? user.email ?? "User"
```

with:

```swift
                    let name = AccountDisplay.memberName(displayName: user.displayName, email: user.email)
```

**`Momsy/Services/Firebase/BabySync/BabySyncService.swift:103`** — replace:

```swift
        let fallbackName = user.displayName ?? user.email ?? "User"
```

with:

```swift
        let fallbackName = AccountDisplay.memberName(displayName: user.displayName, email: user.email)
```

---

## Fix 3 — Settings account row

**`Momsy/Features/Settings/Presentation/Views/SettingsView.swift:277-282`** — replace:

```swift
                        if let email = authManager.firebaseUser?.email, !email.isEmpty {
                            Text(email)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.bbInkMute)
                                .lineLimit(1)
                        }
```

with:

```swift
                        if let subtitle = accountSubtitle {
                            Text(subtitle)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.bbInkMute)
                                .lineLimit(1)
                        }
```

Add a private computed property in `SettingsView` (near `accountSection`):

```swift
    private var accountSubtitle: String? {
        guard let user = authManager.firebaseUser else { return nil }
        if let name = user.displayName, !name.isEmpty { return name }
        if let email = user.email, !email.isEmpty, !AccountDisplay.isPrivateRelay(email) { return email }
        if user.providerData.contains(where: { $0.providerID == "apple.com" }) {
            return lm.strings.settingsAppleAccount
        }
        if user.providerData.contains(where: { $0.providerID == "google.com" }) {
            return lm.strings.settingsGoogleAccount
        }
        return nil
    }
```

Verify `SettingsView` imports `FirebaseAuth` (needed for `providerData`); add the import if missing.

---

## Fix 4 — Localization (all 7 languages)

**`Momsy/Core/Localization/L10n.swift`** — add next to `settingsSignedIn` (line 1332):

```swift
    var settingsAppleAccount: String   { s("Apple account", "Аккаунт Apple", "Apple-Konto", "Cuenta de Apple", "Compte Apple", "Conta Apple", "Apple 账户") }
    var settingsGoogleAccount: String  { s("Google account", "Аккаунт Google", "Google-Konto", "Cuenta de Google", "Compte Google", "Conta Google", "Google 账户") }
```

---

## Unit tests (Swift Testing)

**Create `MomsyTests/Core/Auth/AccountDisplayTests.swift`:**

```swift
import Testing
@testable import Momsy

struct AccountDisplayTests {
    @Test func displayNameWins() {
        #expect(AccountDisplay.memberName(displayName: "Anna", email: "x@privaterelay.appleid.com") == "Anna")
    }

    @Test func relayEmailNeverLeaks() {
        #expect(AccountDisplay.memberName(displayName: nil, email: "jm2kg4hb96@privaterelay.appleid.com") == "User")
        #expect(AccountDisplay.memberName(displayName: "  ", email: "AB@PrivateRelay.AppleID.com") == "User")
    }

    @Test func regularEmailAllowedAsFallback() {
        #expect(AccountDisplay.memberName(displayName: nil, email: "anna@example.com") == "anna@example.com")
    }

    @Test func emptyEverythingFallsBack() {
        #expect(AccountDisplay.memberName(displayName: nil, email: nil) == "User")
        #expect(AccountDisplay.memberName(displayName: "", email: "") == "User")
    }

    @Test func relayDetection() {
        #expect(AccountDisplay.isPrivateRelay("a@privaterelay.appleid.com"))
        #expect(!AccountDisplay.isPrivateRelay("a@appleid.com"))
        #expect(!AccountDisplay.isPrivateRelay("privaterelay.appleid.com@gmail.com"))
    }
}
```

---

## Definition of Done

- [ ] `AccountDisplay.swift` created in `Momsy/Core/Auth/`, Momsy target only
- [ ] `adoptAppleFullNameIfNeeded` added; called after `linkOrSignIn` in `handleAppleCompletion`
- [ ] Both `displayName ?? user.email ?? "User"` fallbacks replaced (`grep -rn "user.email ?? " Momsy/` returns nothing)
- [ ] Settings account row uses `accountSubtitle`; relay address never rendered
- [ ] Two L10n strings added with all 7 languages
- [ ] `AccountDisplayTests` passes
- [ ] All 4 targets build

## Manual QA

1. Fresh simulator. In iOS Settings sign into an Apple ID that has NOT authorized Momsy (or revoke: Settings → Apple ID → Sign in with Apple → Momsy → Stop using).
2. Onboard → Sign in with Apple → choose **Hide My Email** and keep the suggested name.
3. Settings → Account: **expect the user's name**, not `…@privaterelay.appleid.com`.
4. Second device joins the family → Sharing member list shows the name, not the relay address.
5. Sign out, sign in again with the same Apple ID (fullName now nil from Apple): name persists (stored in Firebase profile).
6. Regression — Google sign-in: row shows displayName or real email as before.
7. Existing account that authorized before this fix: row shows "Apple account" (localized), not the relay address.
