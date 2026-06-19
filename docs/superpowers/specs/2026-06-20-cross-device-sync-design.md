# Cross-Device Sync — Finishing Firestore + Auth

**Date:** 2026-06-20
**Branch:** feat/vitamins-named-entry-sheet
**Status:** Approved design, ready for implementation plan

## Goal

Make family-shared cross-device sync feel real. Today's sync is already
write-complete and pulls all children on cold launch with LWW merge + tombstones,
but it only runs once per cold launch, the family-join flow doesn't close end to
end, and writes made before the family is ready are silently lost. This design
closes those three gaps. Family access is the second-most-important reason users
choose the app, so it must be competitive.

## Current state (already built — not in scope to change)

- **Auth:** anonymous fallback on launch (stable uid → familyId), Apple + Google
  sign-in linked to the anonymous account, GDPR account deletion. `AuthManager`
  drives `FamilyManager.setup` on every auth state change.
- **Write path:** every feature view model writes to Firestore idempotently by
  stable id via `BabySyncService.setLog`, for all collections. Deletes propagate
  via tombstones + `PendingDeletionsStore` with retry.
- **Read path:** on cold launch `CloudSyncDownloader.downloadAndMergeWhenReady()`
  migrates the legacy tree, discovers the roster, and pulls every child with an
  LWW merge (`updatedAt`) that respects tombstones.
- **Family:** invite-code generation, `FamilyManager.joinFamily(code:uid:)`,
  members roster, Firestore rules enforcing per-family isolation.

## Out of scope (explicitly deferred)

- Realtime Firestore snapshot listeners (foreground-refresh is the chosen model).
- Firebase Storage rules + durable photo identity (security_audit.md #1/#2).
- Removing the legacy `babies/{familyId}` tree.

## Sync freshness model

**Foreground-refresh**, not realtime listeners. A resync runs when the app
returns to foreground and immediately after a family is joined. This covers the
"partner added a log, I see it next time I open the app" experience cheaply (reads
only on open) and is minimally invasive.

---

## Component A — Foreground refresh

**Problem:** sync runs exactly once per cold launch (`hasRun` guard in
`downloadAndMergeWhenReady`). Returning to foreground (`scenePhase == .active`)
does not resync, so another family member's changes only appear after a full
relaunch.

**Design:**

- Add `CloudSyncDownloader.resyncAll()` that reuses the private
  `downloadAllBabies()` but skips the one-time work: no
  `migrateFromFamilyPathIfNeeded()`, no `hasRun` gate, no
  `purgeLegacyQuickLogsOnce()`. It pulls profile + logs for every child in the
  roster, leaving the active child selected last (same ordering as launch).
- Add reentrancy + debounce guards on `CloudSyncDownloader`:
  - `private var isSyncing = false`
  - `private var lastSyncAt: Date?`
  - `resyncAll()` returns early if `isSyncing` is true or `lastSyncAt` is within
    ~8 seconds. `downloadAndMergeWhenReady()` and `resyncActiveBaby()` set the
    same guards so the three entry points never overlap.
- Wire in `MomsyApp`: inside the existing `.onChange(of: scenePhase)`, on
  `.active`, run `Task { await container.cloudSyncDownloader.resyncAll() }`
  alongside the existing widget reload / weekly-report calls.
- `.onChange(of:)` does not fire for the initial scene value, so the cold-launch
  `.task` download is not duplicated by the first `.active`; the debounce guard
  is belt-and-suspenders for the background→foreground round trip.
- Expose `resyncAll()` on `CloudSyncDownloaderProtocol` so the app and tests can
  call it.

**Units touched:** `CloudSyncDownloader`, `CloudSyncDownloaderProtocol`,
`MomsyApp`.

---

## Component B — Join deeplink + immediate resync

**Problem:** `momsy://join?code=` is never handled (the two `onOpenURL` handlers
cover only Google sign-in and tab selection). After a join — both the deeplink
path and the manual code entry in `SharingView` — `familyId` is swapped but the
joined family's existing data is not pulled until the next relaunch.

**Design:**

- Handle the join deeplink in `MomsyApp.onOpenURL`: when `url.host == "join"`,
  read the `code` query item, ensure an anonymous uid exists
  (`signInAnonymouslyIfNeeded()`), then call
  `FamilyManager.shared.joinFamily(code:uid:)`.
- Introduce one shared post-join step used by **both** the deeplink and
  `SharingViewModel.joinFamily()`:
  1. After `familyId` changes, clear `ActiveBaby.currentId` so
     `downloadAllBabies()` adopts the joined family's roster (rather than leaving
     the active pointer on the joiner's pre-join local baby, which has no data in
     the new family).
  2. `await cloudSyncDownloader.resyncAll()`.
  3. Post `.cloudSyncDidMerge`.

  This lives on `AppContainer` (e.g. `joinFamily(code:) async throws`) so both
  call sites share identical behavior and the downloader dependency.
- Surface the outcome to the user: app-level state driving a small alert —
  "Joined the family" / "Invalid or expired code". Reuse existing `FamilyError`
  messages and `L10n` strings (e.g. `joinFamilyTitle`); add success/failure
  strings if missing, in all 6 supported languages.

**Units touched:** `MomsyApp`, `AppContainer`, `SharingViewModel` (route through
the shared step), `L10n` (strings if needed).

---

## Component C — Write backfill

**Problem:** `BabySyncService.setLog` / `addLog` guard on `hasPath` and silently
`return` when `familyId`/`babyId` aren't ready yet (the onboarding window). The
local SwiftData row persists but never reaches the cloud — there is no backfill.
(Offline writes while `hasPath == true` are already queued and replayed by
Firestore's `PersistentCacheSettings`, so only the `!hasPath` drop matters.)

**Design:**

- New `PendingWritesStore`, mirroring `PendingDeletionsStore`
  (UserDefaults-backed, `@MainActor`-free, shared singleton). Stores an array of
  pending writes: `(collection: String, docId: String, payload: [String: Any])`.
  - `payload` is the Firestore-encoded dictionary produced by
    `Firestore.Encoder().encode(dto)`, with `Timestamp` values normalized to
    `Date` recursively (nested maps/arrays included) so it round-trips through a
    plist. `Date` is restored to `Timestamp` automatically by Firestore on
    `setData`.
  - Persist as a plist `Data` blob under a versioned UserDefaults key.
  - API: `add(collection:docId:payload:)`, `all() -> [(String, String, [String: Any])]`,
    `remove(docId:)`, `clear()`.
- In `BabySyncService.setLog`, replace the silent `!hasPath` return with: encode
  the DTO, normalize timestamps, and enqueue via `PendingWritesStore`. When
  `hasPath` is true, behave exactly as today.
- Add `BabySyncService.replayPendingWrites()`: for each queued entry, write
  `collection(entry.collection).document(entry.docId).setData(entry.payload, merge: true)`;
  on success remove it; on failure leave it for the next pass. Guard on `hasPath`.
- Call `replayPendingWrites()` at the start of both `downloadAndMergeWhenReady()`
  and `resyncAll()`, next to the existing `retryPendingDeletions()`.
- Normalize the remaining auto-id `addLog` cloud writes
  (`BabySyncRepository.addFeedingLog` / `addSleepLog` / `addDiaperLog` /
  `addSymptomLog` / `addDiaryLog`) to `setLog(_:id:to:)` keyed by the record's
  stable id, so every cloud write is idempotent and backfill-compatible. Update
  the few call sites that use these methods.

**Accepted limitation:** replay writes to the *current* path. The drop window is
single-baby onboarding, so by replay time `babyId` already points to that baby.
Pending writes are not tagged with a family/baby snapshot (none exists at enqueue
time).

**Units touched:** new `PendingWritesStore`, `BabySyncService`,
`BabySyncRepository` (+ its `addLog` call sites in view models / `CloudSyncDownloader`
wiring as needed).

---

## Testing

Swift Testing, in-memory, matching existing `MomsyTests` patterns.

- `PendingWritesStore`: enqueue → `all()` round-trips collection/docId/payload,
  including `Date` fields surviving plist persistence; `remove` and `clear`.
- `BabySyncService`: `setLog` with `!hasPath` enqueues instead of dropping;
  `replayPendingWrites` flushes and clears on success (against a mock/fake write
  surface).
- `CloudSyncDownloader.resyncAll`: debounce/reentrancy — a second call within the
  window and a call while `isSyncing` are no-ops (via a fake `BabySyncService`).
- Join: `momsy://join?code=ABC` parses to the right code; the shared post-join
  step clears active baby and triggers a resync (via a spy downloader).

## Risks

- **Double sync on launch** if `.onChange(of: scenePhase)` ever fires for the
  initial value on some OS version — mitigated by the debounce guard.
- **Timestamp normalization** is the trickiest part of Component C; it must
  recurse nested maps/arrays. Covered by a round-trip test.
- **Join repoint** could briefly show an empty active child before the resync
  lands; `.cloudSyncDidMerge` reload resolves it.
