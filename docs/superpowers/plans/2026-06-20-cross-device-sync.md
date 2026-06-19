# Cross-Device Sync (Firestore + Auth) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish family-shared cross-device sync — foreground refresh, family-join deeplink with immediate resync, and a write-backfill queue so no log is stranded locally.

**Architecture:** Three independent additions on top of the existing local-first + Firestore sync. (A) A `resyncAll()` entry point on `CloudSyncDownloader`, guarded by a debounce, fired on foreground. (B) A `PendingWritesStore` (mirroring `PendingDeletionsStore`) that captures cloud writes dropped while the family path isn't ready, replayed at sync time. (C) A family-join deeplink handler + a `.familyDidJoin` notification that triggers a one-shot resync, shared by the deeplink and the manual code-entry flow.

**Tech Stack:** Swift, SwiftUI, FirebaseFirestore, FirebaseAuth, Swift Testing, SwiftData.

## Global Constraints

- iOS / SwiftUI app; MVVM + Clean Architecture (Presentation / Domain / Data / Core).
- No Combine for new logic — use `async`/`await`.
- No force unwraps (`!`) in production code; 4-space indent; PascalCase types, camelCase members.
- Tests: Swift Testing (`import Testing`, `@Test`, `#expect`). Suites touching shared `UserDefaults` are `.serialized`.
- Localization strings use `L10n.s(en, ru, de, es, fr, pt)` — all six languages, in that order.
- Build via the `BuildProject` MCP tool; run the `Momsy` test suite in Xcode (⌘U) / via the build tool.
- UserDefaults keys already defined: `kFamilyIdDefaultsKey` = `"familyId_v1"`, `kBabyIdDefaultsKey` = `"babyId_v1"`. Reuse, don't redefine.

---

## File Structure

- **Create** `Momsy/Services/Firebase/BabySync/PendingWritesStore.swift` — persisted queue of dropped cloud writes (Task 1).
- **Modify** `Momsy/Services/Firebase/BabySync/BabySyncService.swift` — enqueue on `!hasPath`, add `replayPendingWrites()` (Task 2).
- **Modify** `Momsy/Services/Firebase/BabySync/BabySyncRepository.swift` — normalize `addLog` writes to idempotent `setLog(id:)` (Task 3).
- **Modify** `Momsy/Core/BabySync/Domain/Protocols/CloudSyncDownloaderProtocol.swift` — add `resyncAll()` (Task 4).
- **Modify** `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift` — `resyncAll()` + debounce helper + replay call (Task 4).
- **Modify** `Momsy/MomsyApp.swift` — foreground resync (Task 5); join deeplink + alert (Task 8).
- **Create** `Momsy/Core/Family/JoinDeeplink.swift` — pure deeplink parser (Task 6).
- **Modify** `Momsy/Core/Family/FamilyManager.swift` — post `.familyDidJoin` after join (Task 7).
- **Modify** `Momsy/Core/DI/AppContainer.swift` — observe `.familyDidJoin` → resync (Task 7).
- **Modify** `Momsy/Core/Localization/L10n.swift` — join-result strings (Task 8).
- **Create** test files under `MomsyTests/Features/Sync/` (Tasks 1, 4, 6).

---

## Task 1: PendingWritesStore

**Files:**
- Create: `Momsy/Services/Firebase/BabySync/PendingWritesStore.swift`
- Test: `MomsyTests/Features/Sync/PendingWritesStoreTests.swift`

**Interfaces:**
- Produces:
  - `final class PendingWritesStore` with `static let shared`, `init(defaults: UserDefaults = .standard)`.
  - `struct PendingWritesStore.Entry { let collection: String; let docId: String; let payload: [String: Any] }`
  - `func add(collection: String, docId: String, payload: [String: Any])`
  - `func all() -> [Entry]`
  - `func remove(docId: String)`
  - `func clear()`
  - `static func plistSafe(_ value: Any) -> Any` — recursively converts Firestore `Timestamp` → `Date`.

- [ ] **Step 1: Write the failing test**

```swift
// MomsyTests/Features/Sync/PendingWritesStoreTests.swift
import Testing
import Foundation
import FirebaseFirestore
@testable import Momsy

@Suite("PendingWritesStore", .serialized)
struct PendingWritesStoreTests {

    private func freshStore() -> PendingWritesStore {
        let suite = "PendingWritesStoreTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return PendingWritesStore(defaults: defaults)
    }

    @Test func addAndAllRoundTripIncludingTimestamp() {
        let store = freshStore()
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        store.add(collection: "feedingLogs", docId: "abc",
                  payload: ["startedAt": Timestamp(date: date), "amountMl": 90])

        let all = store.all()
        #expect(all.count == 1)
        #expect(all[0].collection == "feedingLogs")
        #expect(all[0].docId == "abc")
        #expect((all[0].payload["startedAt"] as? Date) == date)   // Timestamp normalized to Date
        #expect((all[0].payload["amountMl"] as? Int) == 90)
    }

    @Test func addReplacesSameDocId() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1])
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 2])
        let all = store.all()
        #expect(all.count == 1)
        #expect((all[0].payload["v"] as? Int) == 2)
    }

    @Test func removeDeletesEntry() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1])
        store.add(collection: "sleepLogs", docId: "y", payload: ["v": 2])
        store.remove(docId: "x")
        let all = store.all()
        #expect(all.count == 1)
        #expect(all[0].docId == "y")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run the `PendingWritesStore` suite in Xcode (⌘U).
Expected: FAIL — `PendingWritesStore` is undefined / does not compile.

- [ ] **Step 3: Write minimal implementation**

```swift
// Momsy/Services/Firebase/BabySync/PendingWritesStore.swift
import Foundation
import FirebaseFirestore

/// Local ledger of cloud writes that could not be sent because the family path
/// (`familyId`/`babyId`) wasn't ready yet — the onboarding window. Mirrors
/// `PendingDeletionsStore`: survives launches and is replayed by `BabySyncService`
/// once the path resolves, so a log created before setup still reaches the cloud.
///
/// Payloads are stored plist-safe: Firestore `Timestamp` values are normalized to
/// `Date` (Firestore converts them back to `Timestamp` on `setData`).
final class PendingWritesStore {
    static let shared = PendingWritesStore()

    struct Entry {
        let collection: String
        let docId: String
        let payload: [String: Any]
    }

    private let key = "pending_writes_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private var raw: [[String: Any]] {
        get { defaults.array(forKey: key) as? [[String: Any]] ?? [] }
        set { defaults.set(newValue, forKey: key) }
    }

    /// Enqueues a write, replacing any earlier pending write with the same docId so
    /// only the latest payload for an id is kept (matches `setData(merge:)` semantics).
    func add(collection: String, docId: String, payload: [String: Any]) {
        let safe = (Self.plistSafe(payload) as? [String: Any]) ?? [:]
        var items = raw.filter { ($0["docId"] as? String) != docId }
        items.append(["collection": collection, "docId": docId, "payload": safe])
        raw = items
    }

    func all() -> [Entry] {
        raw.compactMap { dict in
            guard
                let collection = dict["collection"] as? String,
                let docId = dict["docId"] as? String,
                let payload = dict["payload"] as? [String: Any]
            else { return nil }
            return Entry(collection: collection, docId: docId, payload: payload)
        }
    }

    func remove(docId: String) {
        raw = raw.filter { ($0["docId"] as? String) != docId }
    }

    func clear() { defaults.removeObject(forKey: key) }

    /// Recursively replaces Firestore `Timestamp` with `Date` so the payload is
    /// plist-codable for UserDefaults persistence.
    static func plistSafe(_ value: Any) -> Any {
        switch value {
        case let ts as Timestamp:       return ts.dateValue()
        case let dict as [String: Any]: return dict.mapValues { plistSafe($0) }
        case let array as [Any]:        return array.map { plistSafe($0) }
        default:                        return value
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run the `PendingWritesStore` suite in Xcode (⌘U).
Expected: PASS (3 tests).

- [ ] **Step 5: Add the new file to the Xcode project & commit**

Add `PendingWritesStore.swift` and `PendingWritesStoreTests.swift` to the `Momsy` / `MomsyTests` targets (matching how `PendingDeletionsStore.swift` is referenced). Build with the `BuildProject` MCP tool to confirm both targets compile.

```bash
git add Momsy/Services/Firebase/BabySync/PendingWritesStore.swift \
        MomsyTests/Features/Sync/PendingWritesStoreTests.swift \
        Momsy.xcodeproj/project.pbxproj
git commit -m "feat(sync): add PendingWritesStore for dropped cloud writes"
```

---

## Task 2: Enqueue dropped writes + replay in BabySyncService

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/BabySyncService.swift:55-58` (`setLog`)
- Modify: `Momsy/Services/Firebase/BabySync/BabySyncService.swift` (add `replayPendingWrites()`)
- Test: `MomsyTests/Features/Sync/BabySyncBackfillTests.swift`

**Interfaces:**
- Consumes: `PendingWritesStore.shared` (Task 1).
- Produces:
  - `BabySyncService.setLog` now enqueues to `PendingWritesStore` when `!hasPath` instead of dropping.
  - `func replayPendingWrites() async` — flushes queued writes when `hasPath`.

- [ ] **Step 1: Write the failing test**

This test drives `setLog` with no family/baby path set, so it never touches the network — it must enqueue instead of dropping.

```swift
// MomsyTests/Features/Sync/BabySyncBackfillTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("BabySyncBackfill", .serialized)
struct BabySyncBackfillTests {

    private struct DummyLog: Encodable { let id: String; let amountMl: Int }

    private func clearPath() {
        UserDefaults.standard.removeObject(forKey: kFamilyIdDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kBabyIdDefaultsKey)
    }

    @Test func setLogEnqueuesWhenPathNotReady() async throws {
        clearPath()
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        let service = BabySyncService()
        try await service.setLog(DummyLog(id: "log-1", amountMl: 120),
                                 id: "log-1", to: "feedingLogs")

        let queued = PendingWritesStore.shared.all()
        #expect(queued.count == 1)
        #expect(queued[0].collection == "feedingLogs")
        #expect(queued[0].docId == "log-1")
        #expect((queued[0].payload["amountMl"] as? Int) == 120)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run the `BabySyncBackfill` suite.
Expected: FAIL — `queued.count` is 0 (current `setLog` returns silently when `!hasPath`).

- [ ] **Step 3: Write the implementation**

Replace `setLog` (lines 55-58):

```swift
    /// Writes a log using the supplied stable id as the Firestore document id.
    /// Making the doc id == local UUID keeps re-pushes idempotent (overwrite, not duplicate)
    /// and lets the download path dedup entries by id. When the family path isn't ready yet
    /// (onboarding window), the write is queued in `PendingWritesStore` and replayed later
    /// instead of being silently dropped.
    func setLog<T: Encodable>(_ log: T, id: String, to subcollection: String) async throws {
        guard !id.isEmpty else { return }
        guard hasPath else {
            let payload = try Firestore.Encoder().encode(log)
            PendingWritesStore.shared.add(collection: subcollection, docId: id, payload: payload)
            return
        }
        try collection(subcollection).document(id).setData(from: log, merge: true)
    }
```

Add `replayPendingWrites()` in the "Deletes & tombstones" region (next to `retryPendingDeletions`):

```swift
    /// Replays cloud writes that were queued while the family path wasn't ready.
    /// Each write targets the CURRENT baby path; the drop window is single-baby
    /// onboarding, so by replay time `babyId` already points to that baby.
    func replayPendingWrites() async {
        guard hasPath else { return }
        for entry in PendingWritesStore.shared.all() {
            do {
                try await collection(entry.collection).document(entry.docId)
                    .setData(entry.payload, merge: true)
                PendingWritesStore.shared.remove(docId: entry.docId)
            } catch {
                // Leave it pending; the next sync retries.
            }
        }
    }
```

- [ ] **Step 4: Run test to verify it passes**

Run the `BabySyncBackfill` suite.
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Services/Firebase/BabySync/BabySyncService.swift \
        MomsyTests/Features/Sync/BabySyncBackfillTests.swift
git commit -m "feat(sync): queue dropped cloud writes and replay when path ready"
```

---

## Task 3: Normalize addLog writes to idempotent setLog

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/BabySyncRepository.swift:22-40`
- Test: extend `MomsyTests/Features/Sync/BabySyncBackfillTests.swift`

**Interfaces:**
- Consumes: `setLog(_:id:to:)` (Task 2); domain logs expose `let id: String` (`FeedingLog`, `SleepLog`, `DiaperLog`, `SymptomLog`, `DiaryLog`).
- Produces: `BabySyncRepository.add{Feeding,Sleep,Diaper,Symptom,Diary}Log` now write via `setLog(id:)` (idempotent + backfill-compatible). Public method signatures are unchanged, so the two call sites (`TodayViewModel.swift:129`, `SymptomViewModel.swift:223`) need no edits.

- [ ] **Step 1: Write the failing test**

Add to `BabySyncBackfillTests`:

```swift
    @Test func addFeedingLogEnqueuesByStableIdWhenPathNotReady() async throws {
        clearPath()
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        let repo = BabySyncRepository(service: BabySyncService())
        let log = FeedingLog(id: "feed-7", startedAt: Date(),
                             durationMin: 10, side: "left", amountMl: 80)
        try await repo.addFeedingLog(log)

        let queued = PendingWritesStore.shared.all()
        #expect(queued.count == 1)
        #expect(queued[0].collection == "feedingLogs")
        #expect(queued[0].docId == "feed-7")   // stable id, not an auto-generated doc id
    }
```

> Note: confirm the `FeedingLog` initializer argument labels against
> `Momsy/Core/BabySync/Domain/Models/FeedingLog.swift` and adjust the literal above to match
> (it has `let id: String`; use the real property set). Do not invent fields.

- [ ] **Step 2: Run test to verify it fails**

Run the `BabySyncBackfill` suite.
Expected: FAIL — `addFeedingLog` currently calls `addLog` (auto doc id), so no enqueue happens (auto-id path doesn't go through the stable-id `setLog`).

- [ ] **Step 3: Write the implementation**

Change the five `addXLog` methods (lines 22-40) from `addLog` to `setLog(id:)`:

```swift
    func addFeedingLog(_ log: FeedingLog) async throws {
        try await service.setLog(FeedingLogDTO(from: log), id: log.id, to: "feedingLogs")
    }

    func addSleepLog(_ log: SleepLog) async throws {
        try await service.setLog(SleepLogDTO(from: log), id: log.id, to: "sleepLogs")
    }

    func addDiaperLog(_ log: DiaperLog) async throws {
        try await service.setLog(DiaperLogDTO(from: log), id: log.id, to: "diaperLogs")
    }

    func addSymptomLog(_ log: SymptomLog) async throws {
        try await service.setLog(SymptomLogDTO(from: log), id: log.id, to: "symptomLogs")
    }

    func addDiaryLog(_ log: DiaryLog) async throws {
        try await service.setLog(DiaryLogDTO(from: log), id: log.id, to: "diaryLogs")
    }
```

- [ ] **Step 4: Run test to verify it passes**

Run the `BabySyncBackfill` suite.
Expected: PASS. Also build with the `BuildProject` MCP tool to confirm the DTO initializers and `log.id` types line up.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Services/Firebase/BabySync/BabySyncRepository.swift \
        MomsyTests/Features/Sync/BabySyncBackfillTests.swift
git commit -m "refactor(sync): make repository cloud writes idempotent by stable id"
```

---

## Task 4: resyncAll() + debounce on CloudSyncDownloader

**Files:**
- Modify: `Momsy/Core/BabySync/Domain/Protocols/CloudSyncDownloaderProtocol.swift`
- Modify: `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift`
- Test: `MomsyTests/Features/Sync/ResyncDebounceTests.swift`

**Interfaces:**
- Consumes: private `downloadAllBabies()`, `service.replayPendingWrites()` (Task 2).
- Produces:
  - `CloudSyncDownloaderProtocol.resyncAll() async`
  - `static func CloudSyncDownloader.shouldSkipResync(isSyncing: Bool, lastSyncAt: Date?, now: Date, minInterval: TimeInterval) -> Bool`

- [ ] **Step 1: Write the failing test**

The debounce decision is a pure static function, so it needs no 18-dependency instance.

```swift
// MomsyTests/Features/Sync/ResyncDebounceTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("ResyncDebounce")
struct ResyncDebounceTests {

    @Test func skipsWhileSyncing() {
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: true, lastSyncAt: nil, now: Date(), minInterval: 8) == true)
    }

    @Test func skipsWithinWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: false, lastSyncAt: now.addingTimeInterval(-3), now: now, minInterval: 8) == true)
    }

    @Test func runsAfterWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: false, lastSyncAt: now.addingTimeInterval(-20), now: now, minInterval: 8) == false)
    }

    @Test func runsWhenNeverSynced() {
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: false, lastSyncAt: nil, now: Date(), minInterval: 8) == false)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run the `ResyncDebounce` suite.
Expected: FAIL — `shouldSkipResync` is undefined.

- [ ] **Step 3: Write the implementation**

In `CloudSyncDownloader`, add stored guards near `private var hasRun = false` (line 30):

```swift
    private var hasRun = false
    private var isSyncing = false
    private var lastSyncAt: Date?
```

Add the pure helper (e.g. just above `downloadAndMergeWhenReady`):

```swift
    /// Pure debounce/reentrancy decision, extracted for testability.
    static func shouldSkipResync(isSyncing: Bool,
                                 lastSyncAt: Date?,
                                 now: Date,
                                 minInterval: TimeInterval) -> Bool {
        if isSyncing { return true }
        if let last = lastSyncAt, now.timeIntervalSince(last) < minInterval { return true }
        return false
    }
```

Add `resyncAll()`:

```swift
    /// Foreground / post-join refresh. Re-pulls every child in the roster, skipping the
    /// one-time launch work (migration, legacy purge, `hasRun` gate). Debounced so a
    /// background→foreground bounce or an overlap with launch download is a no-op.
    @MainActor
    func resyncAll() async {
        if Self.shouldSkipResync(isSyncing: isSyncing, lastSyncAt: lastSyncAt,
                                 now: Date(), minInterval: 8) { return }
        guard FamilyManager.shared.familyId != nil else { return }
        isSyncing = true
        defer { isSyncing = false; lastSyncAt = Date() }
        await service.replayPendingWrites()
        await downloadAllBabies()
    }
```

Mark the launch path as a sync too, so foreground refresh won't overlap it. In `downloadAndMergeWhenReady()` set the guards (after `hasRun = true`, line 81):

```swift
        hasRun = true
        isSyncing = true
        defer { isSyncing = false; lastSyncAt = Date() }
```

Add to the protocol:

```swift
    /// Re-pulls every child in the roster (foreground / post-join). Debounced.
    func resyncAll() async
```

- [ ] **Step 4: Run test to verify it passes**

Run the `ResyncDebounce` suite.
Expected: PASS (4 tests). Build with the `BuildProject` MCP tool.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift \
        Momsy/Core/BabySync/Domain/Protocols/CloudSyncDownloaderProtocol.swift \
        MomsyTests/Features/Sync/ResyncDebounceTests.swift
git commit -m "feat(sync): add debounced resyncAll for foreground refresh"
```

---

## Task 5: Trigger foreground resync in MomsyApp

**Files:**
- Modify: `Momsy/MomsyApp.swift:71-76`

**Interfaces:**
- Consumes: `container.cloudSyncDownloader.resyncAll()` (Task 4).

- [ ] **Step 1: Implement the wiring**

Update the `scenePhase` handler (lines 71-76):

```swift
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WidgetCenter.shared.reloadAllTimelines()
                Task { await container.cloudSyncDownloader.resyncAll() }
                Task { await maybeGenerateWeeklyReport() }
            }
        }
```

> `.onChange(of:)` does not fire for the scene's initial value, so the cold-launch
> `.task` download (line 61) is not duplicated; `resyncAll`'s debounce is the backstop.

- [ ] **Step 2: Build**

Build with the `BuildProject` MCP tool.
Expected: build succeeds.

- [ ] **Step 3: Manual verification**

On two simulators/devices signed into the same family: add a feeding on device A, background and re-foreground device B → the new feeding appears on B without a relaunch. Confirm re-foregrounding twice within 8s does not double-fetch (debounce).

- [ ] **Step 4: Commit**

```bash
git add Momsy/MomsyApp.swift
git commit -m "feat(sync): resync all children on foreground"
```

---

## Task 6: JoinDeeplink parser

**Files:**
- Create: `Momsy/Core/Family/JoinDeeplink.swift`
- Test: `MomsyTests/Features/Sync/JoinDeeplinkTests.swift`

**Interfaces:**
- Produces: `enum JoinDeeplink { static func code(from url: URL) -> String? }` — returns the trimmed, uppercased invite code for `momsy://join?code=…`, else `nil`.

- [ ] **Step 1: Write the failing test**

```swift
// MomsyTests/Features/Sync/JoinDeeplinkTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("JoinDeeplink")
struct JoinDeeplinkTests {

    @Test func parsesValidJoinURL() {
        let url = URL(string: "momsy://join?code=momsy-abc123")!
        #expect(JoinDeeplink.code(from: url) == "MOMSY-ABC123")
    }

    @Test func nilForWrongHost() {
        #expect(JoinDeeplink.code(from: URL(string: "momsy://feeding?code=x")!) == nil)
    }

    @Test func nilWhenCodeMissing() {
        #expect(JoinDeeplink.code(from: URL(string: "momsy://join")!) == nil)
    }

    @Test func nilForWrongScheme() {
        #expect(JoinDeeplink.code(from: URL(string: "https://join?code=x")!) == nil)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run the `JoinDeeplink` suite.
Expected: FAIL — `JoinDeeplink` undefined.

- [ ] **Step 3: Write the implementation**

```swift
// Momsy/Core/Family/JoinDeeplink.swift
import Foundation

/// Parses the family-invite deeplink `momsy://join?code=XXXX`.
enum JoinDeeplink {
    /// The normalized invite code (trimmed, uppercased) for a join URL, else `nil`.
    static func code(from url: URL) -> String? {
        guard url.scheme == "momsy", url.host == "join" else { return nil }
        let raw = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "code" }?
            .value
        let normalized = raw?.trimmingCharacters(in: .whitespaces).uppercased()
        return (normalized?.isEmpty == false) ? normalized : nil
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run the `JoinDeeplink` suite.
Expected: PASS (4 tests).

- [ ] **Step 5: Add to project & commit**

Add both files to the `Momsy` / `MomsyTests` targets.

```bash
git add Momsy/Core/Family/JoinDeeplink.swift \
        MomsyTests/Features/Sync/JoinDeeplinkTests.swift \
        Momsy.xcodeproj/project.pbxproj
git commit -m "feat(sync): add JoinDeeplink parser for momsy://join"
```

---

## Task 7: Resync after any family join

**Files:**
- Modify: `Momsy/Core/Family/FamilyManager.swift` (add notification name + post after join)
- Modify: `Momsy/Core/DI/AppContainer.swift` (observe → resync)

**Interfaces:**
- Consumes: `cloudSyncDownloader.resyncAll()` (Task 4); `ActiveBaby.currentId` (`Momsy/Core/Family/ActiveBaby.swift`).
- Produces: `Notification.Name.familyDidJoin`, posted by `FamilyManager.joinFamily` after `familyId` is persisted. Observed once by `AppContainer`.

Both the manual code-entry flow (`SharingViewModel.joinFamily` → `FamilyManager.joinFamily`) and the deeplink (Task 8 → `FamilyManager.joinFamily`) go through this single post-join path, so neither call site needs bespoke resync logic.

- [ ] **Step 1: Add the notification name and post it**

In `FamilyManager.swift`, add near the top (after imports):

```swift
extension Notification.Name {
    /// Posted after the caller joins an existing family, so the app re-pulls that
    /// family's data (the joined family's logs aren't local yet).
    static let familyDidJoin = Notification.Name("familyDidJoin")
}
```

At the end of `joinFamily(code:uid:)`, after `isReady = true` (line 99):

```swift
        persist(familyId: targetFamilyId)
        isReady = true
        NotificationCenter.default.post(name: .familyDidJoin, object: nil)
    }
```

- [ ] **Step 2: Observe in AppContainer**

In `AppContainer`, add a stored token and an observer registered from `init`:

```swift
    private var familyJoinObserver: NSObjectProtocol?

    /// After a join, drop the active-baby pointer so the downloader adopts the joined
    /// family's roster, then re-pull everything.
    private func observeFamilyJoin() {
        familyJoinObserver = NotificationCenter.default.addObserver(
            forName: .familyDidJoin, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                ActiveBaby.currentId = nil
                await self.cloudSyncDownloader.resyncAll()
                NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
            }
        }
    }
```

Call `observeFamilyJoin()` at the end of `AppContainer.init`. (If `AppContainer` has no explicit `init`, add one that calls it; match the existing `@MainActor` isolation on the type.)

- [ ] **Step 3: Build**

Build with the `BuildProject` MCP tool.
Expected: build succeeds (watch for `@MainActor` isolation on the closure — the `Task { @MainActor in … }` hop handles it).

- [ ] **Step 4: Manual verification**

Device B (no data) enters device A's invite code in Settings → Sharing. Expected: B immediately pulls A's family roster + logs without relaunch; the active child becomes one of the joined family's children.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Core/Family/FamilyManager.swift Momsy/Core/DI/AppContainer.swift
git commit -m "feat(sync): re-pull family data immediately after joining"
```

---

## Task 8: Join deeplink handler + result alert

**Files:**
- Modify: `Momsy/MomsyApp.swift` (onOpenURL + alert state)
- Modify: `Momsy/Core/Localization/L10n.swift` (join-result strings)

**Interfaces:**
- Consumes: `JoinDeeplink.code(from:)` (Task 6); `FamilyManager.shared.joinFamily(code:uid:)`; `container.authManager.signInAnonymouslyIfNeeded()`; `container.authManager.firebaseUser`. The successful join posts `.familyDidJoin` (Task 7), which drives the resync.

- [ ] **Step 1: Add localized strings**

In `L10n.swift`, add (order: en, ru, de, es, fr, pt):

```swift
    var joinSuccessTitle: String { s("Joined the family", "Вы в семье", "Familie beigetreten", "Te uniste a la familia", "Famille rejointe", "Entrou na família") }
    var joinSuccessMessage: String { s("You now share data with your family.", "Теперь вы делитесь данными с семьёй.", "Sie teilen jetzt Daten mit Ihrer Familie.", "Ahora compartes datos con tu familia.", "Vous partagez désormais des données avec votre famille.", "Agora você compartilha dados com sua família.") }
    var joinFailedTitle: String { s("Couldn’t join", "Не удалось присоединиться", "Beitritt fehlgeschlagen", "No se pudo unir", "Impossible de rejoindre", "Não foi possível entrar") }
    var joinFailedMessage: String { s("This invite code is invalid or has expired.", "Этот код приглашения недействителен или истёк.", "Dieser Einladungscode ist ungültig oder abgelaufen.", "Este código de invitación no es válido o ha caducado.", "Ce code d’invitation est invalide ou a expiré.", "Este código de convite é inválido ou expirou.") }
```

- [ ] **Step 2: Add alert state + deeplink handling in MomsyApp**

Add the alert enum (top level of the file, outside the struct):

```swift
private enum JoinAlert: Identifiable {
    case success, failure
    var id: Int { self == .success ? 0 : 1 }
}
```

Add state to `MomsyApp`:

```swift
    @State private var joinAlert: JoinAlert?
```

Replace the `onOpenURL` block (lines 65-69):

```swift
                .onOpenURL { url in
#if canImport(GoogleSignIn)
                    GIDSignIn.sharedInstance.handle(url)
#endif
                    guard let code = JoinDeeplink.code(from: url) else { return }
                    Task { @MainActor in
                        await container.authManager.signInAnonymouslyIfNeeded()
                        guard let uid = container.authManager.firebaseUser?.uid else {
                            joinAlert = .failure; return
                        }
                        do {
                            try await FamilyManager.shared.joinFamily(code: code, uid: uid)
                            joinAlert = .success     // resync is driven by .familyDidJoin (Task 7)
                        } catch {
                            joinAlert = .failure
                        }
                    }
                }
                .alert(item: $joinAlert) { alert in
                    switch alert {
                    case .success:
                        return Alert(title: Text(localization.strings.joinSuccessTitle),
                                     message: Text(localization.strings.joinSuccessMessage),
                                     dismissButton: .default(Text("OK")))
                    case .failure:
                        return Alert(title: Text(localization.strings.joinFailedTitle),
                                     message: Text(localization.strings.joinFailedMessage),
                                     dismissButton: .default(Text("OK")))
                    }
                }
```

> The `.alert(item:)` and the `.onOpenURL` modifiers attach to `ContentView()` inside
> `WindowGroup`, alongside the existing `.task`/`.onOpenURL`. Keep one `onOpenURL` —
> merge the Google-sign-in and join handling into the single block shown above.

- [ ] **Step 3: Build**

Build with the `BuildProject` MCP tool.
Expected: build succeeds.

- [ ] **Step 4: Manual verification**

Tap a `momsy://join?code=MOMSY-XXXXXX` link (valid + invalid). Expected: success alert + data pulled on a valid code; failure alert on an invalid/expired code. Confirm a `momsy://feeding` link still selects the Today tab (existing `MainTabView` handler) and does not show a join alert.

- [ ] **Step 5: Commit**

```bash
git add Momsy/MomsyApp.swift Momsy/Core/Localization/L10n.swift
git commit -m "feat(sync): handle momsy://join deeplink with result alert"
```

---

## Final verification

- [ ] Run the full `Momsy` test suite (⌘U / `BuildProject` tool). Expected: all suites pass, including the new `Sync` suites.
- [ ] `git log --oneline -8` shows the eight task commits + the design commit.
- [ ] Run `graphify update .` to refresh the knowledge graph (per project rules).

---

## Self-Review (completed during authoring)

**Spec coverage:**
- Component A (foreground refresh) → Tasks 4, 5. ✔
- Component B (write backfill) → Tasks 1, 2, 3. ✔
- Component C (join deeplink + immediate resync) → Tasks 6, 7, 8. ✔
- Tests called for in the spec → Tasks 1 (store round-trip incl. dates), 2 (enqueue), 4 (debounce), 6 (deeplink parse). ✔
- Out-of-scope items (realtime listeners, storage rules, legacy tree) → intentionally absent. ✔

**Type consistency:** `resyncAll()`, `shouldSkipResync(...)`, `replayPendingWrites()`, `PendingWritesStore.Entry`/`add`/`all`/`remove`/`clear`/`plistSafe`, `JoinDeeplink.code(from:)`, `Notification.Name.familyDidJoin` are used with identical signatures across the tasks that define and consume them.

**Known assumptions to confirm during execution (not placeholders):**
- `FeedingLog`/`SymptomLog`/etc. initializer labels in Task 3's test literal — verify against the domain model file before running.
- Test target links `FirebaseFirestore` (needed for `Timestamp` in Task 1's test) — it imports Firebase elsewhere; confirm on first test build.
- `AppContainer` init isolation — match the existing `@MainActor` pattern when adding `observeFamilyJoin()`.
