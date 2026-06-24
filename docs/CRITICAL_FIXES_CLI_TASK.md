# CRITICAL_FIXES — pre-launch P0 task brief

**For:** Claude Code CLI · branch `main` · repo `ruslanab84/Momsy`
**Scope:** three launch-blocking issues found in code review of commit `b992f9b`.
**Out of scope (tracked separately):** paywall legal links (#4), dead purchase button (#5), EPDS crisis screen (#6), family-shared photo paths (#7). Do **not** touch those here.

Each fix extracts the risky decision into a **pure, unit-tested function** and keeps Firestore I/O thin. Paste the code verbatim; identifiers match the current tree.

---

## FIX 1 — Account deletion must not wipe a co-parent's data (P0, data loss)

**Problem.** `FirestoreAccountEraser.deleteCloudData` (in `Core/Account/DeleteAccountUseCase.swift`) calls `RosterErasure.eraseAll` (erases **every** child's log tree) and `FamilyManager.deleteFamilyAndUserDocs` (deletes **all** member docs + the family doc) for **any** user who taps "delete account". `firestore.rules` permits it (`allow update, delete: if belongsToFamily(familyId)`). So a co-parent deleting their account erases the shared babies' health logs, evicts the other parent, and deletes the family. The remaining parent is left with a `familyId` pointing at nothing.

**Required behavior.** On account deletion, remove **only** the caller's own membership + their `users/{uid}` doc. Tear down shared baby data and the family doc **only when the caller is the last remaining member**.

### 1a. New file — `Momsy/Core/Family/AccountErasureGate.swift`

```swift
import Foundation

/// Decides whether "delete account" may tear down *shared* family data (every
/// child's cloud log tree + the family document) or must be scoped to the caller's
/// own membership. Shared data may only be destroyed when the caller is the last
/// remaining member — otherwise erasing it is data loss for a co-parent (and, under
/// GDPR, processing another person's data without basis), not right-to-erasure.
///
/// Pure and synchronous so the policy is unit-tested without Firestore.
enum AccountErasureGate {
    static func mayTearDownSharedData(memberIds: [String], callerUid: String) -> Bool {
        // `allSatisfy` on an empty roster returns true: an empty/orphaned family has
        // no co-parent to harm, so tearing it down is safe.
        memberIds.allSatisfy { $0 == callerUid }
    }
}
```

### 1b. Edit — `Momsy/Core/Family/FamilyManager.swift`

**Delete** the entire `deleteFamilyAndUserDocs(uid:)` method and **replace** it with the two methods below:

```swift
/// True when the caller is the only remaining member (or the roster is empty).
/// Gates whether account deletion may tear down shared family data.
func isSoleMember(uid: String) async throws -> Bool {
    guard let familyId else { return true }
    let snap = try await db.collection("families").document(familyId)
        .collection("members").getDocuments()
    let ids = snap.documents.map { $0.documentID }
    return AccountErasureGate.mayTearDownSharedData(memberIds: ids, callerUid: uid)
}

/// Removes the caller's own membership and their `users/{uid}` doc. When
/// `tearDownSharedFamily` is true (caller is the sole member) the family doc itself
/// is also deleted; otherwise the family and co-parents' memberships are left intact.
/// Call while still authenticated (rules require it) and before `reset()`. The order
/// matters: `users/{uid}` is deleted LAST so membership-based rules still authorise
/// the family/member deletes above it.
func leaveFamily(uid: String, tearDownSharedFamily: Bool) async throws {
    if let familyId {
        let familyRef = db.collection("families").document(familyId)
        try await familyRef.collection("members").document(uid).delete()
        if tearDownSharedFamily {
            try await familyRef.delete()
        }
    }
    try await db.collection("users").document(uid).delete()
}
```

### 1c. Edit — `Momsy/Core/Account/DeleteAccountUseCase.swift`

Replace the body of `FirestoreAccountEraser.deleteCloudData(uid:)`:

```swift
struct FirestoreAccountEraser: CloudAccountEraser {
    let babySync: BabySyncService

    func deleteCloudData(uid: String) async throws {
        // Shared baby data + the family doc are torn down ONLY when the caller is the
        // last member. A co-parent's deletion must leave the family and its logs intact.
        let soleMember = try await FamilyManager.shared.isSoleMember(uid: uid)
        if soleMember {
            try await RosterErasure.eraseAll(using: babySync, locallyActiveId: ActiveBaby.currentId)
        }
        try await FamilyManager.shared.leaveFamily(uid: uid, tearDownSharedFamily: soleMember)
    }
}
```

> `RosterErasure`, `BabyRosterDataEraser`, `CloudAccountEraser`, `AccountAuthProtocol`, and `DeleteAccountUseCase` itself are unchanged. `DeleteAccountUseCase.execute()` still calls `photoStorage.deleteAll()` — that erases only the caller's own `users/{uid}/…` photos and is correct on account deletion; leave it.

### 1d. Defense-in-depth — `firestore.rules` (recommended, low risk)

Tighten the members rule so a member can delete **only their own** membership doc, removing a griefing vector where any member can evict others. Replace the `members` block inside `match /families/{familyId}`:

```
match /members/{memberId} {
  allow read:   if belongsToFamily(familyId);
  // Create/update: any member (manage roster names) or the joining user themselves.
  allow create, update: if belongsToFamily(familyId)
                        || (isSignedIn() && memberId == request.auth.uid && isFamilyMember(familyId));
  // Delete: only your own membership doc.
  allow delete: if isSignedIn() && memberId == request.auth.uid;
}
```

Deploy: `firebase deploy --only firestore:rules`.

---

## FIX 2 — `joinFamily` silently orphans the caller's existing family (P0, data loss)

**Problem.** Every user is auto-assigned their own family on first auth (`setup` → `else` branch). When such a user joins another family by invite, `joinFamily` overwrites `users/{uid}.familyId` with no guard. If their original family already has a child set up, that data is orphaned in the cloud (unreachable on a new device). No warning.

**Required behavior.** When joining a **different** family while the caller still has their **own** child set up, throw a distinct error so the UI can confirm; on confirmation (`force: true`), proceed. Detach the old membership first so no dangling member doc is left.

### 2a. New file — `Momsy/Core/Family/FamilyJoinGuard.swift`

```swift
import Foundation

/// Joining a *different* family while the caller still has their own family data would
/// orphan that data (a separate cloud tree that does not migrate). This policy decides
/// when explicit user confirmation is required first. Pure so it is unit-tested directly.
enum FamilyJoinGuard {
    static func requiresConfirmation(
        currentFamilyId: String?,
        targetFamilyId: String,
        currentFamilyHasData: Bool,
        force: Bool
    ) -> Bool {
        guard !force else { return false }
        guard let currentFamilyId, currentFamilyId != targetFamilyId else { return false }
        return currentFamilyHasData
    }
}
```

### 2b. Edit — `Momsy/Core/Family/FamilyManager.swift`

Add the new error case:

```swift
enum FamilyError: LocalizedError {
    case noFamilyId
    case invalidOrExpiredCode
    case wouldAbandonExistingFamily

    var errorDescription: String? {
        switch self {
        case .noFamilyId:                 return "Family not set up. Please sign in."
        case .invalidOrExpiredCode:       return "This invite code is invalid or has expired."
        case .wouldAbandonExistingFamily: return "You already belong to a family."
        }
    }
}
```

Add a private helper:

```swift
/// Whether the caller's current family already has a child profile (data that would
/// be orphaned by switching families). One cheap, capped read.
private func currentFamilyHasData() async throws -> Bool {
    guard let familyId else { return false }
    let snap = try await db.collection("families").document(familyId)
        .collection("babies").limit(to: 1).getDocuments()
    return !snap.documents.isEmpty
}
```

Replace `joinFamily(code:uid:)` with:

```swift
func joinFamily(code: String, uid: String, force: Bool = false) async throws {
    let trimmed = code.trimmingCharacters(in: .whitespaces).uppercased()
    let inviteDoc = try await db.collection("invites").document(trimmed).getDocument()
    guard
        let data = inviteDoc.data(),
        let targetFamilyId = data["familyId"] as? String,
        let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue(),
        expiresAt > Date()
    else { throw FamilyError.invalidOrExpiredCode }

    // Already in the target family — idempotent no-op.
    if familyId == targetFamilyId { isReady = true; return }

    // Only pay for the data read when actually switching to a different family.
    let switchingFamily = (familyId != nil && familyId != targetFamilyId)
    let hasData = switchingFamily ? try await currentFamilyHasData() : false
    if FamilyJoinGuard.requiresConfirmation(
        currentFamilyId: familyId, targetFamilyId: targetFamilyId,
        currentFamilyHasData: hasData, force: force
    ) {
        throw FamilyError.wouldAbandonExistingFamily
    }

    // Detach from the previous roster BEFORE repointing users/{uid}.familyId,
    // otherwise the rules no longer authorise deleting the old membership doc.
    if let previous = familyId, previous != targetFamilyId {
        try? await db.collection("families").document(previous)
            .collection("members").document(uid).delete()
    }

    try await db.collection("users").document(uid)
        .setData(["familyId": targetFamilyId], merge: true)

    let displayName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "User"
    try await db.collection("families").document(targetFamilyId)
        .collection("members").document(uid)
        .setData(["name": displayName, "joinedAt": Timestamp(date: Date())], merge: true)

    persist(familyId: targetFamilyId, ownerUid: uid)
    isReady = true
    NotificationCenter.default.post(name: .familyDidJoin, object: nil)
}
```

> The post-join resync (`AppContainer.observeFamilyJoin`: `ActiveBaby.currentId = nil` → `forceResyncAll()`) is unchanged.
> **Design note:** a child *profile* counts as "data", so a co-parent who completed onboarding before joining will see one confirmation dialog — this is the safe default (over-warn rather than silently lose data). If you later want to warn only on real logged activity, change `currentFamilyHasData()` to probe a log subcollection instead.
> If a deep-link/`onOpenURL` path also calls `joinFamily`, route it through the same `force` handling.

### 2c. Edit — `Momsy/Features/Sharing/Presentation/ViewModel/SharingViewModel.swift`

Add a published flag near the other join state:

```swift
@Published var showJoinConfirm = false
```

Replace `joinFamily()` and add the confirm handler:

```swift
func joinFamily(force: Bool = false) {
    guard !joinCode.trimmingCharacters(in: .whitespaces).isEmpty else { return }
    guard let uid = Auth.auth().currentUser?.uid else {
        joinError = "Please sign in first."
        return
    }
    isJoining = true
    joinError = nil
    Task {
        do {
            try await FamilyManager.shared.joinFamily(code: joinCode, uid: uid, force: force)
            joinCode = ""
            joinSuccess = true
            await loadMembers()
        } catch FamilyError.wouldAbandonExistingFamily {
            showJoinConfirm = true   // UI confirms, then calls confirmJoinReplacingFamily()
        } catch {
            joinError = error.localizedDescription
        }
        isJoining = false
        if joinSuccess {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            joinSuccess = false
        }
    }
}

func confirmJoinReplacingFamily() {
    showJoinConfirm = false
    joinFamily(force: true)
}
```

### 2d. Edit — `Momsy/Features/Sharing/Presentation/Views/SharingView.swift`

Attach an alert to the `joinCard` view. Add this modifier on the outer container of the `joinCard` computed property (after its final `.clipShape(...)`):

```swift
.alert(loc.strings.joinReplaceTitle, isPresented: $vm.showJoinConfirm) {
    Button(loc.strings.joinReplaceConfirm, role: .destructive) { vm.confirmJoinReplacingFamily() }
    Button(loc.strings.cancel, role: .cancel) { }
} message: {
    Text(loc.strings.joinReplaceMessage)
}
```

### 2e. Edit — `Momsy/Core/Localization/L10n.swift`

Add next to the existing `joinFamilyTitle` (~line 528). Keep the 6-arg `s(en, ru, de, es, fr, pt)` order:

```swift
var joinReplaceTitle: String   { s("Join this family?", "Присоединиться к этой семье?", "Dieser Familie beitreten?", "¿Unirse a esta familia?", "Rejoindre cette famille ?", "Juntar-se a esta família?") }
var joinReplaceMessage: String { s("You already have a child set up. Joining a new family won't move your current data over — it will stay only on this device. Continue?", "У вас уже добавлен ребёнок. При входе в новую семью текущие данные не перенесутся и останутся только на этом устройстве. Продолжить?", "Du hast bereits ein Kind eingerichtet. Beim Beitritt zu einer neuen Familie werden deine aktuellen Daten nicht übertragen und bleiben nur auf diesem Gerät. Fortfahren?", "Ya tienes un bebé configurado. Al unirte a una familia nueva, tus datos actuales no se transferirán y quedarán solo en este dispositivo. ¿Continuar?", "Vous avez déjà un enfant configuré. En rejoignant une nouvelle famille, vos données actuelles ne seront pas transférées et resteront uniquement sur cet appareil. Continuer ?", "Já tens um bebé configurado. Ao juntar-te a uma nova família, os teus dados atuais não serão transferidos e ficarão apenas neste dispositivo. Continuar?") }
var joinReplaceConfirm: String { s("Join anyway", "Всё равно войти", "Trotzdem beitreten", "Unirse igualmente", "Rejoindre quand même", "Juntar mesmo assim") }
```

---

## FIX 3 — Privacy manifest contradicts reality (App Review / privacy-label accuracy)

**Problem.** `Momsy/PrivacyInfo.xcprivacy` describes baby health data and the parent's EPDS depression score as *"mirrored to the user's private, encrypted iCloud (CloudKit private database)"* and marks them `Linked = false`. The app removed CloudKit — that data is synced to **Firebase (Cloud Firestore)** under the user's Firebase Auth account, so it **is linked** to the user's identity. `PRIVACY.md` is already accurate; only the manifest drifted.

> The `.xcprivacy` collected-data block is documentation; the **App Store Connect → App Privacy** questionnaire is the enforced source of truth for the privacy label. Fix both.

### 3a. Edit — `Momsy/PrivacyInfo.xcprivacy`

Four targeted replacements (each `old` string is unique in the file).

**(i)** Health comment:
```
		<!-- Baby health data: feeding logs, sleep records, temperature, growth
		     measurements, diaper/stool, vaccinations. Stored locally and mirrored
		     to the user's private, encrypted iCloud (CloudKit private database). -->
```
→
```
		<!-- Baby health data: feeding logs, sleep records, temperature, growth
		     measurements, diaper/stool, vaccinations. Stored locally (SwiftData) and
		     synced to the developer's Firebase backend (Cloud Firestore) under the
		     user's Firebase Auth account — therefore linked to the user's identity. -->
```

**(ii)** Health `Linked` flag:
```
			<string>NSPrivacyCollectedDataTypeHealth</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
```
→
```
			<string>NSPrivacyCollectedDataTypeHealth</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<true/>
```

**(iii)** Sensitive comment + `Linked` flag:
```
		<!-- Parent mental-health data: EPDS postpartum-depression screening score
		     (MomMoodRecord.epdsScore) and mood/well-being entries. Sensitive; stored
		     locally and mirrored to the user's private, encrypted iCloud. -->
```
→
```
		<!-- Parent mental-health data: EPDS postpartum-depression screening score
		     (MomMoodRecord.epdsScore) and mood/well-being entries. Sensitive; stored
		     locally and synced to the developer's Firebase backend (Cloud Firestore)
		     under the user's Firebase Auth account — linked to the user's identity. -->
```
and:
```
			<string>NSPrivacyCollectedDataTypeSensitiveInfo</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
```
→
```
			<string>NSPrivacyCollectedDataTypeSensitiveInfo</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<true/>
```

**(iv)** Name `Linked` flag (name is stored in Firestore under the uid):
```
			<string>NSPrivacyCollectedDataTypeName</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
```
→
```
			<string>NSPrivacyCollectedDataTypeName</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<true/>
```

> Leave `NSPrivacyCollectedDataTypePhotosOrVideos` (already `Linked = true`). The `NSPrivacyCollectedDataTypeOtherUserContent` ("AI chat messages") entry now overstates collection because free-form AI chat was removed — overstating is the privacy-safe direction, so leaving it is acceptable; remove it only if you confirm no free-text reaches Gemini. `NSPrivacyTracking` stays `false`.

### 3b. Manual — App Store Connect → App Privacy (cannot be done from code)

Set the questionnaire to match `PRIVACY.md`:

| Data type | Collected | Linked to user | Used for tracking | Purpose |
|---|---|---|---|---|
| Health & Fitness (baby logs) | Yes | **Yes** | No | App Functionality |
| Sensitive Info (EPDS / mood) | Yes | **Yes** | No | App Functionality |
| Name (baby name) | Yes | **Yes** | No | App Functionality |
| Photos or Videos (diary) | Yes | **Yes** | No | App Functionality |
| User ID (Firebase Auth uid) | Yes | **Yes** | No | App Functionality |

Third-party sharing: declare data is processed by **Google Firebase** (and **Google Gemini** for tips) as a **service provider / processor**, not shared for their own purposes. `PRIVACY.md` already names them and the in-app deletion path — no change needed there.

---

## Unit tests (Swift Testing — matches existing `import Testing` / `@Suite` / `#expect`)

### New — `MomsyTests/Features/Sharing/AccountErasureGateTests.swift`
```swift
import Testing
@testable import Momsy

@Suite("AccountErasureGate")
struct AccountErasureGateTests {
    @Test("sole member may tear down shared data")
    func soleMember() {
        #expect(AccountErasureGate.mayTearDownSharedData(memberIds: ["me"], callerUid: "me"))
    }
    @Test("member with a co-parent may NOT tear down shared data")
    func withCoParent() {
        #expect(!AccountErasureGate.mayTearDownSharedData(memberIds: ["me", "partner"], callerUid: "me"))
    }
    @Test("empty roster treated as sole — nobody else to harm")
    func emptyRoster() {
        #expect(AccountErasureGate.mayTearDownSharedData(memberIds: [], callerUid: "me"))
    }
    @Test("roster of only other members may NOT tear down")
    func othersOnly() {
        #expect(!AccountErasureGate.mayTearDownSharedData(memberIds: ["a", "b"], callerUid: "me"))
    }
    @Test("caller plus others may NOT tear down")
    func callerPlusOthers() {
        #expect(!AccountErasureGate.mayTearDownSharedData(memberIds: ["me", "a", "b"], callerUid: "me"))
    }
}
```

### New — `MomsyTests/Features/Sharing/FamilyJoinGuardTests.swift`
```swift
import Testing
@testable import Momsy

@Suite("FamilyJoinGuard")
struct FamilyJoinGuardTests {
    @Test("no current family → no confirmation")
    func noFamily() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: nil, targetFamilyId: "F2", currentFamilyHasData: true, force: false))
    }
    @Test("re-joining the same family → no confirmation")
    func sameFamily() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F1", currentFamilyHasData: true, force: false))
    }
    @Test("different family with existing data, not forced → confirmation")
    func differentWithData() {
        #expect(FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F2", currentFamilyHasData: true, force: false))
    }
    @Test("forced bypasses the guard")
    func forced() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F2", currentFamilyHasData: true, force: true))
    }
    @Test("different family but no existing data → no confirmation")
    func differentNoData() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F2", currentFamilyHasData: false, force: false))
    }
}
```

---

## Definition of Done

- [ ] `AccountErasureGate.swift` and `FamilyJoinGuard.swift` added under `Core/Family/`.
- [ ] `FamilyManager`: `deleteFamilyAndUserDocs` removed; `isSoleMember` + `leaveFamily` added; `joinFamily(force:)` + `currentFamilyHasData()` added; `FamilyError.wouldAbandonExistingFamily` added.
- [ ] `FirestoreAccountEraser.deleteCloudData` gates `RosterErasure.eraseAll` and family teardown on `isSoleMember`.
- [ ] `SharingViewModel`: `showJoinConfirm`, `joinFamily(force:)`, `confirmJoinReplacingFamily()`.
- [ ] `SharingView`: confirmation `.alert` wired to `joinCard`.
- [ ] L10n: `joinReplaceTitle` / `joinReplaceMessage` / `joinReplaceConfirm` added in all 6 languages.
- [ ] `PrivacyInfo.xcprivacy`: 2 comments corrected, `Linked` flipped to `true` for Health / SensitiveInfo / Name.
- [ ] `firestore.rules`: member `delete` restricted to own doc; `firebase deploy --only firestore:rules` run.
- [ ] Both test suites added; **full suite green** (was 210/210 — must stay green plus the new tests).
- [ ] Manual: App Store Connect App Privacy answers updated per the table in 3b.

### Manual QA (two devices, two accounts, one shared family)
- [ ] Device B (co-parent) deletes account → Device A still sees all baby logs; A's family intact.
- [ ] Last remaining member deletes account → cloud baby tree + family doc fully erased.
- [ ] User with a child set up enters an invite code → confirmation dialog appears; Cancel keeps current family; "Join anyway" switches and re-syncs.
- [ ] Fresh install joining during onboarding (no child yet) → no dialog, joins directly.
