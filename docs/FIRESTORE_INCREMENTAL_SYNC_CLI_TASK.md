# FIRESTORE_INCREMENTAL_SYNC_CLI_TASK

**Goal:** Stop re-downloading the entire baby-log history on every launch / foreground.
Make `CloudSyncDownloader` pull **only documents changed since the last sync** using a
per-`(family, baby, collection)` high-water mark keyed on a **server** `updatedAt`.

**Why:** `CloudSyncDownloader.downloadAndMerge()` fetches all 17 log collections via
`BabySyncService.fetchAll(from:dateField:)` **without `since:`**, so each run reads up to
500 docs/collection + up to 1000 tombstones. It runs on every launch
(`downloadAndMergeWhenReady`), every foreground (`resyncAll`, 8 s debounce), every profile
switch (`resyncActiveBaby`) and every join (`forceResyncAll`). Result: the whole dataset is
re-read ~15×/day from a single test device (observed: 3.7K reads vs 33 writes, ratio ≈112:1).

**No Firestore index changes required.** Every query filters and orders on the **same single
field** (`updatedAt`), which the automatic single-field index already covers. (Same as the
existing `fetchAll(since:)`, which filters+orders on one date field.)

---

## Definition of Done (read first)

- [ ] After first post-deploy launch, a second relaunch with **no new data** produces **≈0
      Firestore reads** for logs (only the small per-collection boundary re-reads + profile doc).
- [ ] Editing an old entry (old event date, new `updatedAt`) on device B still syncs to device A.
- [ ] A log written offline (queued in `PendingWritesStore`) replays online with a **server**
      `updatedAt` (verify the doc's `updatedAt` ≈ replay time, not enqueue time).
- [ ] First launch after deploy still performs a one-time **full** pull per collection (captures
      legacy docs with `nil` `updatedAt`), then goes incremental.
- [ ] All new unit tests pass; existing sync tests still pass (some DTO-init tests may need the
      `updatedAt`-default assertion relaxed — see Part B).
- [ ] No regression to per-baby routing: watermark is keyed per `(familyId, babyId)` and uses the
      same override-aware id resolution as `BabySyncService`.

---

## Scope — files touched

**New files**
- `Momsy/Services/Firebase/BabySync/SyncWatermarkStore.swift`
- `Momsy/Services/Firebase/BabySync/CloudSyncTimestamped.swift`
- `MomsyTests/Features/Sync/SyncWatermarkStoreTests.swift`
- `MomsyTests/Features/Sync/WatermarkAdvanceTests.swift`

**Edited**
- `Momsy/Services/Firebase/BabySync/BabySyncService.swift` — add `fetchChanged`, `currentScope`,
  `fetchTombstones(since:)`; stamp `updatedAt` server-side on the queued-write path.
- `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift` — watermark-aware `fetch()`,
  incremental tombstones.
- 14 `*+DTO.swift` files — `updatedAt` → `@ServerTimestamp` (see Part B table).

**Not touched**
- `AppContainer.swift` — `SyncWatermarkStore` is defaulted inside `CloudSyncDownloader.init`.
- `streamLogs` / `streamLogsByField` listeners — already bounded (`limit: 50`) and correctly torn
  down; not the cost driver. Leave as-is.

---

## Design decisions (lock these in)

1. **Key on `updatedAt` (modification time), never the event date.** An entry created last month
   and edited today keeps its old `startedAt`/`loggedAt`/`date`. Filtering by the event field would
   silently drop the edit. `fetchAll(since:)` filters on the event field — do **not** reuse it for
   the delta; add `fetchChanged` filtering on `updatedAt`.
2. **`updatedAt` must be a server timestamp.** The watermark compares values written by potentially
   different devices. Client clocks skew; a device whose clock runs fast would persist a watermark
   ahead of real time and skip another device's writes. `@ServerTimestamp` makes every write use one
   monotonic clock. (Part B.)
3. **Order ascending, drain forward.** `fetchChanged` orders `updatedAt` **ascending** with a limit.
   If >limit docs changed since last sync (rare; mostly the first full seed), the batch is the
   *oldest* slice `[wm, t_max]`; we advance the watermark to `t_max` and the next sync continues
   from there. Descending would advance past, and permanently skip, the un-returned older slice.
4. **Idempotent boundary.** Query uses `>=` (not `>`) so a doc whose `updatedAt` exactly equals the
   stored watermark is re-read. Harmless: merges are idempotent upserts keyed by stable UUID.
5. **First run = full pull.** A collection with no stored watermark does one full `fetchAll`
   (current behaviour) so legacy docs with `nil` `updatedAt` are captured (a `>=` range query
   excludes docs missing the field). Then the watermark is seeded and subsequent runs go incremental.
6. **Empty / all-legacy seed → epoch floor.** If the first pull yields no usable `updatedAt`, seed
   the watermark to `Date(timeIntervalSince1970: 0)`. Next sync's `>= epoch` returns every stamped
   doc once (self-correcting: it then advances to the real max), with no clock-skew risk.
7. **Watermark scope = `(familyId, babyId, collection)`.** Independent per collection (gap-free under
   truncation) and per child (the downloader loops the roster via `ActiveBaby.syncTargetOverride`).

---

# Part A — Incremental reads

## A1. `CloudSyncTimestamped.swift` (new)

A protocol so the generic fetch can compute the max `updatedAt` of a batch. Every fetched DTO already
has (or, per Part B, gains) `var updatedAt: Timestamp?`, so conformance is a one-line extension each.

```swift
// Momsy/Services/Firebase/BabySync/CloudSyncTimestamped.swift
import FirebaseFirestore

/// A synced log DTO carrying a last-write-wins modification stamp. Used by the incremental
/// downloader to advance the per-collection high-water mark. `updatedAt` is server-assigned
/// (`@ServerTimestamp`) on write and may be `nil` for legacy docs written before the field existed.
protocol CloudSyncTimestamped {
    var updatedAt: Timestamp? { get }
}

extension FeedingLogDTO:     CloudSyncTimestamped {}
extension SleepLogDTO:       CloudSyncTimestamped {}
extension DiaperLogDTO:      CloudSyncTimestamped {}
extension QuickEventLogDTO:  CloudSyncTimestamped {}
extension PumpingLogDTO:     CloudSyncTimestamped {}
extension DiaryLogDTO:       CloudSyncTimestamped {}
extension MeasurementLogDTO: CloudSyncTimestamped {}
extension VaccinationLogDTO: CloudSyncTimestamped {}
extension FoodDiaryLogDTO:   CloudSyncTimestamped {}
extension TemperatureLogDTO: CloudSyncTimestamped {}
extension WaterIntakeLogDTO: CloudSyncTimestamped {}
extension LeapLogDTO:        CloudSyncTimestamped {}
extension DoctorVisitLogDTO: CloudSyncTimestamped {}
```

## A2. `SyncWatermarkStore.swift` (new)

Pure, `UserDefaults`-backed, unit-testable. One plist-safe dictionary `[collection: epochSeconds]`
per `(family, baby)`. Multiple `BabySyncService` instances exist in `AppContainer`; backing this in
`UserDefaults` keeps them consistent (same pattern as `PendingWritesStore`).

```swift
// Momsy/Services/Firebase/BabySync/SyncWatermarkStore.swift
import Foundation

/// Per-`(family, baby, collection)` high-water mark for incremental cloud sync.
/// Stores the greatest `updatedAt` (server time) merged for a collection so the next pull
/// fetches only newer documents. Backed by `UserDefaults`; injectable for tests.
final class SyncWatermarkStore {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private func bucketKey(_ family: String, _ baby: String) -> String {
        "babysync_watermarks_v1_\(family)_\(baby)"
    }

    private func bucket(_ family: String, _ baby: String) -> [String: Double] {
        defaults.dictionary(forKey: bucketKey(family, baby)) as? [String: Double] ?? [:]
    }

    /// The stored watermark for a collection, or `nil` if this collection has never synced under
    /// this `(family, baby)` (→ caller does a one-time full pull).
    func watermark(family: String, baby: String, collection: String) -> Date? {
        guard !family.isEmpty, !baby.isEmpty else { return nil }
        guard let seconds = bucket(family, baby)[collection] else { return nil }
        return Date(timeIntervalSince1970: seconds)
    }

    /// Sets the watermark unconditionally. No-op when the path isn't ready.
    func set(family: String, baby: String, collection: String, to date: Date) {
        guard !family.isEmpty, !baby.isEmpty else { return }
        var dict = bucket(family, baby)
        dict[collection] = date.timeIntervalSince1970
        defaults.set(dict, forKey: bucketKey(family, baby))
    }

    /// Clears every watermark for a `(family, baby)` — call on full cloud erasure so a re-add
    /// re-seeds from a clean full pull.
    func reset(family: String, baby: String) {
        guard !family.isEmpty, !baby.isEmpty else { return }
        defaults.removeObject(forKey: bucketKey(family, baby))
    }
}
```

## A3. `BabySyncService` — `fetchChanged`, `currentScope`, `fetchTombstones(since:)`

Add to `BabySyncService`. `currentScope()` exposes the same override-aware ids the service already
resolves, so the downloader keys watermarks identically to the path being read/written.

```swift
// MARK: - Incremental reads (ADD to BabySyncService, near the existing Reads section)

/// The `(familyId, babyId)` this service currently targets — honours a background sync's
/// `ActiveBaby.syncTargetOverride`. Used to scope the sync watermark to the right child.
func currentScope() -> (familyId: String, babyId: String) { (familyId, babyId) }

/// Fetches only documents whose server `updatedAt` is at/after `since`, oldest-first.
/// Single-field range+order on `updatedAt` (auto-indexed). `>=` re-reads the boundary doc;
/// the merge upsert is idempotent. Ascending order drains a >limit backlog forward without gaps.
func fetchChanged<T: Decodable>(from subcollection: String,
                                since: Date,
                                limit: Int = 500) async throws -> [T] {
    guard hasPath else { return [] }
    let snapshot = try await collection(subcollection)
        .whereField("updatedAt", isGreaterThanOrEqualTo: Timestamp(date: since))
        .order(by: "updatedAt", descending: false)
        .limit(to: limit)
        .getDocuments()
    return snapshot.documents.compactMap { try? $0.data(as: T.self) }
}
```

Replace the existing `fetchTombstones` with a `since`-aware overload (keep the old signature as a
thin wrapper so nothing else breaks):

```swift
/// Tombstoned ids deleted on any device, optionally only those at/after `since`.
func fetchTombstones(since: Date?, limit: Int = 1000) async throws -> [(id: String, deletedAt: Date)] {
    guard hasPath else { return [] }
    var query: Query = collection("deletions")
        .order(by: "deletedAt", descending: false)
        .limit(to: limit)
    if let since {
        query = collection("deletions")
            .whereField("deletedAt", isGreaterThanOrEqualTo: Timestamp(date: since))
            .order(by: "deletedAt", descending: false)
            .limit(to: limit)
    }
    let snapshot = try await query.getDocuments()
    return snapshot.documents.compactMap { doc in
        guard let ts = doc.data()["deletedAt"] as? Timestamp else { return nil }
        return (doc.documentID, ts.dateValue())
    }
}

/// Back-compat: ids only, no incremental filter.
func fetchTombstones(limit: Int = 1000) async throws -> [String] {
    try await fetchTombstones(since: nil, limit: limit).map(\.id)
}
```

Update the queued-write path so replay stamps a **server** `updatedAt` (see Part B for why the
sentinel must be stripped at enqueue). In `setLog`, replace the enqueue branch:

```swift
guard hasPath else {
    var payload = try Firestore.Encoder().encode(log)
    // `@ServerTimestamp updatedAt` encodes to a FieldValue sentinel that UserDefaults can't
    // persist. Drop it here; `replayPendingWrites` re-stamps with a fresh serverTimestamp.
    payload.removeValue(forKey: "updatedAt")
    PendingWritesStore.shared.add(collection: subcollection, docId: id,
                                  payload: payload, familyId: familyId, babyId: babyId)
    return
}
```

And in `replayPendingWrites`, stamp on send:

```swift
do {
    var payload = entry.payload
    payload["updatedAt"] = FieldValue.serverTimestamp()
    try await ActiveBaby.$syncTargetOverride.withValue(targetUUID) {
        try await collection(entry.collection).document(entry.docId)
            .setData(payload, merge: true)
    }
    PendingWritesStore.shared.remove(docId: entry.docId)
} catch {
    // Leave it pending; the next sync retries.
}
```

## A4. `CloudSyncDownloader` — watermark-aware `fetch()`

Inject a defaulted store and replace the `fetch()` helper. Add the pure `advancedWatermark` math.

In the property list:

```swift
private let watermarks: SyncWatermarkStore
```

In `init`, add a defaulted parameter (place it last so the existing call site in `AppContainer`
compiles unchanged):

```swift
init(service: BabySyncService,
     feedingRepo: any FeedingRepository,
     /* …all existing repos, unchanged… */
     doctorVisitRepo: any DoctorVisitRepository,
     watermarks: SyncWatermarkStore = SyncWatermarkStore()) {
    self.service = service
    // …existing assignments…
    self.watermarks = watermarks
}
```

Replace the existing `fetch(_:dateField:)`:

```swift
/// Per-collection watermark math. Never moves backward; falls back to the epoch floor so an
/// empty/all-legacy first pull doesn't repeat a full pull forever. Pure → unit-tested.
static func advancedWatermark(previous: Date?, maxObserved: Date?) -> Date {
    let floor = Date(timeIntervalSince1970: 0)
    let candidate = maxObserved ?? previous ?? floor
    if let previous { return max(previous, candidate) }
    return candidate
}

/// Incremental fetch: full pull on first sync of a collection (captures legacy `nil`-`updatedAt`
/// docs), delta thereafter. Advances the per-`(family, baby, collection)` watermark by the max
/// server `updatedAt` merged.
private func fetch<T: Decodable & CloudSyncTimestamped>(_ collection: String,
                                                        dateField: String) async -> [T] {
    let scope = service.currentScope()
    let previous = watermarks.watermark(family: scope.familyId, baby: scope.babyId,
                                        collection: collection)

    let dtos: [T]
    if let previous {
        dtos = (try? await service.fetchChanged(from: collection, since: previous)) ?? []
    } else {
        dtos = (try? await service.fetchAll(from: collection, dateField: dateField)) ?? []
    }

    let maxObserved = dtos.compactMap { $0.updatedAt?.dateValue() }.max()
    let next = Self.advancedWatermark(previous: previous, maxObserved: maxObserved)
    watermarks.set(family: scope.familyId, baby: scope.babyId, collection: collection, to: next)
    return dtos
}
```

> The 17 `async let … = fetch(…)` call sites in `downloadAndMerge` are unchanged — they already pass
> concrete DTO types that now conform to `CloudSyncTimestamped`.

## A5. Incremental tombstones in `downloadAndMerge`

Replace the tombstone block. Reuse the watermark store under the reserved key `"deletions"`.

```swift
// Reconcile deletes incrementally: only pull tombstones newer than last seen.
await service.retryPendingDeletions()

let scope = service.currentScope()
let tombWatermark = watermarks.watermark(family: scope.familyId, baby: scope.babyId,
                                         collection: "deletions")
let tombstones = (try? await service.fetchTombstones(since: tombWatermark)) ?? []
let tombstonedIds = Set(tombstones.compactMap { UUID(uuidString: $0.id) })
let deletedIds = tombstonedIds.union(PendingDeletionsStore.shared.ids())

let maxTomb = tombstones.map(\.deletedAt).max()
let nextTomb = Self.advancedWatermark(previous: tombWatermark, maxObserved: maxTomb)
watermarks.set(family: scope.familyId, baby: scope.babyId, collection: "deletions", to: nextTomb)
```

> `deletedIds` now only contains *recent* tombstones, which is correct: a tombstone older than the
> watermark was already applied on a previous sync. `applyDeletions` is idempotent (deleting an
> already-absent row is a no-op).

## A6. (optional) Clear watermarks on full erasure

In `BabySyncService.deleteAllData()`, after the existing deletes, drop the scope's watermarks so a
re-add of the family re-seeds cleanly:

```swift
SyncWatermarkStore().reset(family: familyId, baby: babyId)
```

---

# Part B — Server timestamps (multi-device correctness)

Switch every **synced log** DTO's `updatedAt` to `@ServerTimestamp` (default `nil`). On write, a `nil`
`@ServerTimestamp` is encoded as `FieldValue.serverTimestamp()`, so `setData(from:merge:)` stamps
server time. On read it decodes to the resolved `Timestamp` (or `nil` while a local write is pending).
The queued-write path is handled in A3 (strip at enqueue, re-stamp at replay).

`@ServerTimestamp` ships in `FirebaseFirestore` (already imported in every DTO that uses `@DocumentID`).

### B1. DTOs that already have `updatedAt` — change the declaration

In each file below, replace:
```swift
var updatedAt: Timestamp? = Timestamp(date: Date())
```
with:
```swift
@ServerTimestamp var updatedAt: Timestamp?
```
If the `init(from:)` assigns `updatedAt`, delete that assignment (it must stay `nil` to trigger the
server stamp).

| File |
|------|
| `Models/FeedingLog+DTO.swift` |
| `Models/SleepLog+DTO.swift` |
| `Models/DiaperLog+DTO.swift` |
| `Models/PumpingLog+DTO.swift` |
| `Models/DiaryLog+DTO.swift` |
| `Models/MeasurementLog+DTO.swift` |
| `Models/VaccinationLog+DTO.swift` |
| `Models/FoodDiaryLog+DTO.swift` |
| `Models/TemperatureLog+DTO.swift` |
| `Models/WaterIntakeLog+DTO.swift` |

### B2. DTOs missing `updatedAt` — add the property

Add this field (after the last `let` property, before `init`) in each file below:
```swift
@ServerTimestamp var updatedAt: Timestamp?
```

| File | DTO | Notes |
|------|-----|-------|
| `Models/QuickEventLog+DTO.swift` | `QuickEventLogDTO` | backs stool/walk/bath/vitamin |
| `Models/LeapLog+DTO.swift` | `LeapLogDTO` | keyed by Int `leapId`, still gets a stamp |
| `Models/DoctorVisitLog+DTO.swift` | `DoctorVisitLogDTO` | |
| `Models/SymptomLog+DTO.swift` | `SymptomLogDTO` | written but not in the merge path; stamp for consistency |

> `init(from:)` is unchanged in all of B1/B2 — leaving `updatedAt` unset keeps it `nil` so the server
> stamps it.

---

# Part C — (optional, ship-now mitigation, independent of A/B)

Until incremental sync lands, cut the foreground re-pull cost by widening the resync debounce.
With Part A this matters far less (foreground pull becomes a delta), but it's a safe one-liner.

In `CloudSyncDownloader.resyncAll()`, raise the interval (e.g. 8 → 300 s):
```swift
if Self.shouldSkipResync(isSyncing: isSyncing, lastSyncAt: lastSyncAt,
                         now: Date(), minInterval: 300) { return }
```

---

# Tests (Swift Testing — match existing `MomsyTests/Features/Sync` style)

## `SyncWatermarkStoreTests.swift` (new)

```swift
// MomsyTests/Features/Sync/SyncWatermarkStoreTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("SyncWatermarkStore", .serialized)
struct SyncWatermarkStoreTests {

    private func freshStore() -> SyncWatermarkStore {
        let suite = "SyncWatermarkStoreTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return SyncWatermarkStore(defaults: defaults)
    }

    @Test func nilUntilSet() {
        let store = freshStore()
        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == nil)
    }

    @Test func setAndReadRoundTrip() {
        let store = freshStore()
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == d)
    }

    @Test func scopedPerCollectionFamilyBaby() {
        let store = freshStore()
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        #expect(store.watermark(family: "f", baby: "b", collection: "sleepLogs") == nil)
        #expect(store.watermark(family: "f", baby: "x", collection: "feedingLogs") == nil)
        #expect(store.watermark(family: "g", baby: "b", collection: "feedingLogs") == nil)
    }

    @Test func emptyScopeIsNoOp() {
        let store = freshStore()
        store.set(family: "", baby: "b", collection: "feedingLogs", to: Date())
        #expect(store.watermark(family: "", baby: "b", collection: "feedingLogs") == nil)
    }

    @Test func resetClearsBucket() {
        let store = freshStore()
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        store.reset(family: "f", baby: "b")
        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == nil)
    }
}
```

## `WatermarkAdvanceTests.swift` (new)

```swift
// MomsyTests/Features/Sync/WatermarkAdvanceTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("WatermarkAdvance")
struct WatermarkAdvanceTests {
    private let epoch = Date(timeIntervalSince1970: 0)
    private let t1 = Date(timeIntervalSince1970: 1_700_000_000)
    private let t2 = Date(timeIntervalSince1970: 1_700_000_500)

    @Test func firstPullWithDataSeedsToMax() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: nil, maxObserved: t1) == t1)
    }

    @Test func firstPullEmptyFallsToEpochFloor() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: nil, maxObserved: nil) == epoch)
    }

    @Test func incrementalAdvancesForward() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: t1, maxObserved: t2) == t2)
    }

    @Test func neverMovesBackward() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: t2, maxObserved: t1) == t2)
    }

    @Test func emptyDeltaKeepsPrevious() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: t1, maxObserved: nil) == t1)
    }
}
```

> `fetchChanged` and the per-baby loop are integration-level (need live Firestore) and are out of
> scope for unit tests — the pure decision points (`advancedWatermark`, store scoping) are covered
> above, mirroring how `shouldSkipResync` / `replayTargetBabyId` are tested.

---

# Manual QA script

1. **Baseline reads.** Firebase Console → Firestore → Usage. Note current Reads.
2. **First launch (deploy).** Launch the app once with existing data. Expect a normal full pull
   (one-time legacy seed). Note Reads delta.
3. **Quiet relaunch.** Kill and relaunch 3–5× without adding data. **Expect ≈0 log reads** per
   relaunch (only profile doc + boundary docs). Confirm Reads stays nearly flat.
4. **Edit-old-entry propagation.** On device B, edit a feeding from last week. On device A,
   foreground the app. The edit appears, and Reads on A increases by ~1 doc, not the whole history.
5. **Offline write → replay stamp.** Airplane mode on device A, log a feeding, go online, foreground.
   In the Console, open that doc: `updatedAt` ≈ replay time (server), `id` == local UUID.
6. **Delete propagation.** Delete an entry on B; on A it disappears, and the tombstone read count is
   bounded (only new tombstones, not 1000).

---

# Non-goals

- Moving ongoing sync onto persistent snapshot listeners (a separate architecture change).
- Pagination of >500-doc collections in a single pull (pre-existing 500 cap is preserved; the
  ascending watermark drains a backlog across subsequent syncs).
- Changing `BabyProfile+DTO` (profile is a single-doc compare, not range-queried).
- `symptomLogs` is intentionally written-but-not-merged today; this task only stamps its `updatedAt`,
  it does not add it to the download path.
