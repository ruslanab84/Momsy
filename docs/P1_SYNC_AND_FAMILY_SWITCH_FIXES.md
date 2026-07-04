# Task: Two P1 fixes before App Store submission

**Priority:** P1 — silent data loss + cross-family privacy leak.
**Suggested branch:** `fix/p1-watermark-and-family-switch`
**Verified against:** commit `a1d9099` ("Fix paywall subscription compliance").

## Ground rules

1. Where this document diverges from current code, **code wins** — adapt, don't force.
2. Touch only the files listed. No drive-by refactors.
3. Preserve existing style: minimal comments, `// MARK:` sections, no force unwraps.
4. All new decision logic must be **pure static funcs** with unit tests (Swift Testing).
5. Build + full test suite must pass before DoD sign-off.

---

## Task 1 — Advance sync watermarks only after a successful merge

### Problem

`CloudSyncDownloader.fetch(_:dateField:)` persists the new watermark **immediately after fetching**, before the SwiftData `upsert` runs. Every upsert below is wrapped in `try?`. If a fetch succeeds but the save throws (the codebase itself documents "context busy mid-merge"), those documents are **never re-fetched** — permanent silent data loss on that device.

Same pattern for tombstones: the `deletions` watermark is committed **before** `applyDeletions` runs. A failed apply means the deleted entry resurrects on this device forever.

Secondary bug fixed by the same change: on the **first** sync of a collection, a failed `fetchAll` currently still commits a watermark (the epoch floor), permanently downgrading that collection to delta pulls and skipping legacy nil-`updatedAt` docs.

### Files

- `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift` — rewrite `fetch`, add `PendingFetch`, `merge`, `commit`, `watermarkAfterFetch`; rewrite the merge section of `downloadAndMerge`.
- `MomsyTests/Core/BabySync/CloudSyncWatermarkCommitTests.swift` — new.

### Implementation

**1. Add next to `advancedWatermark` in `CloudSyncDownloader`:**

```swift
    /// One collection's fetch result with its watermark commit deferred until the
    /// merge lands. `commitTo == nil` when the fetch itself failed — the previous
    /// watermark must stay untouched so the next sync retries the same window.
    struct PendingFetch<T> {
        let dtos: [T]
        let familyId: String
        let babyId: String
        let collection: String
        let commitTo: Date?
    }

    /// Pure: the watermark to persist after a merge, or nil to leave it as-is.
    /// A failed fetch never commits — in particular a failed FIRST pull must not
    /// write the epoch floor, or the one-time full pull (which captures legacy
    /// nil-`updatedAt` docs) would be skipped forever.
    static func watermarkAfterFetch(fetchSucceeded: Bool, next: Date) -> Date? {
        fetchSucceeded ? next : nil
    }
```

**2. Replace `fetch(_:dateField:)` entirely:**

```swift
    /// Incremental fetch: full pull on first sync of a collection (captures legacy `nil`-`updatedAt`
    /// docs that a `>=` range query would exclude), delta thereafter. The per-`(family, baby,
    /// collection)` watermark is NOT advanced here — the caller commits it via `merge`/`commit`
    /// only after the local upsert succeeds, so a failed save re-pulls the same window.
    private func fetch<T: Decodable & CloudSyncTimestamped>(_ collection: String,
                                                            dateField: String) async -> PendingFetch<T> {
        let scope = service.currentScope()
        let previous = watermarks.watermark(family: scope.familyId, baby: scope.babyId,
                                            collection: collection)
        var dtos: [T] = []
        var fetchSucceeded = false
        do {
            if let previous {
                dtos = try await service.fetchChanged(from: collection, since: previous)
            } else {
                dtos = try await service.fetchAll(from: collection, dateField: dateField)
            }
            fetchSucceeded = true
        } catch {
            // Transient failure: keep the previous watermark; retried next sync.
        }
        let maxObserved = dtos.compactMap { $0.updatedAt?.dateValue() }.max()
        let next = Self.advancedWatermark(previous: previous, maxObserved: maxObserved)
        return PendingFetch(dtos: dtos, familyId: scope.familyId, babyId: scope.babyId,
                            collection: collection,
                            commitTo: Self.watermarkAfterFetch(fetchSucceeded: fetchSucceeded,
                                                               next: next))
    }
```

**3. Add the merge/commit helpers (below `fetch`):**

```swift
    /// Merges one collection and, only on success, advances its watermark. A throwing
    /// upsert leaves the watermark untouched so the same delta is re-pulled next sync.
    @MainActor
    private func merge<DTO, Entry>(_ fetched: PendingFetch<DTO>,
                                   map: (DTO) -> Entry?,
                                   upsert: ([Entry]) async throws -> Void) async {
        let entries = fetched.dtos.compactMap(map)
        do {
            try await upsert(entries)
            commit(fetched)
        } catch {
            // Watermark not advanced; this window is retried on the next sync.
        }
    }

    @MainActor
    private func commit<DTO>(_ fetched: PendingFetch<DTO>) {
        guard let date = fetched.commitTo else { return }
        watermarks.set(family: fetched.familyId, baby: fetched.babyId,
                       collection: fetched.collection, to: date)
    }
```

**4. Rewrite the body of `downloadAndMerge(recordQuickLogs:)`.** The `async let` block stays structurally identical — only the bound type changes because `fetch` now returns `PendingFetch<T>`:

```swift
    @MainActor
    private func downloadAndMerge(recordQuickLogs: Bool = true) async {
        // Fetch all collections concurrently (network runs off the main actor).
        async let feedingFetch:  PendingFetch<FeedingLogDTO>     = fetch("feedingLogs",     dateField: "startedAt")
        async let sleepFetch:    PendingFetch<SleepLogDTO>       = fetch("sleepLogs",       dateField: "startedAt")
        async let diaperFetchA:  PendingFetch<DiaperLogDTO>      = fetch("diaperLogs",      dateField: "loggedAt")
        async let stoolFetchA:   PendingFetch<QuickEventLogDTO>  = fetch("stoolLogs",       dateField: "loggedAt")
        async let walkFetchA:    PendingFetch<QuickEventLogDTO>  = fetch("walkLogs",        dateField: "loggedAt")
        async let bathFetchA:    PendingFetch<QuickEventLogDTO>  = fetch("bathLogs",        dateField: "loggedAt")
        async let vitaminFetchA: PendingFetch<QuickEventLogDTO>  = fetch("vitaminLogs",     dateField: "loggedAt")
        async let pumpingFetchA: PendingFetch<PumpingLogDTO>     = fetch("pumpingLogs",     dateField: "date")
        async let diaryFetch:    PendingFetch<DiaryLogDTO>       = fetch("diaryLogs",       dateField: "date")
        async let measureFetch:  PendingFetch<MeasurementLogDTO> = fetch("measurementLogs", dateField: "date")
        async let vaccineFetch:  PendingFetch<VaccinationLogDTO> = fetch("vaccinationLogs", dateField: "doneDate")
        async let foodFetch:     PendingFetch<FoodDiaryLogDTO>   = fetch("foodDiaryLogs",   dateField: "date")
        async let tempFetch:     PendingFetch<TemperatureLogDTO> = fetch("temperatureLogs", dateField: "date")
        async let momSleepFetch: PendingFetch<SleepLogDTO>       = fetch("momSleepLogs",    dateField: "startedAt")
        async let waterFetch:    PendingFetch<WaterIntakeLogDTO> = fetch("waterIntakeLogs", dateField: "date")
        async let leapFetch:     PendingFetch<LeapLogDTO>        = fetch("leapLogs",        dateField: "completedDate")
        async let visitFetch:    PendingFetch<DoctorVisitLogDTO> = fetch("doctorVisitLogs", dateField: "date")

        // Reconcile deletes before merging: retry our own unsent deletes, then gather
        // every tombstoned id so the merge neither resurrects nor re-inserts a deleted
        // entry. Pending-local ids are unioned in so an in-flight delete is honoured
        // even before its tombstone round-trips.
        await service.retryPendingDeletions()

        // Incremental tombstone pull. The `deletions` watermark is committed only after
        // `applyDeletions` below succeeds — a failed apply must re-pull the same
        // tombstones, or the deleted entry resurrects on this device forever.
        let tombScope = service.currentScope()
        let tombWatermark = watermarks.watermark(family: tombScope.familyId, baby: tombScope.babyId,
                                                 collection: "deletions")
        let tombstones = try? await service.fetchTombstones(since: tombWatermark)
        let tombstonedIds = Set((tombstones ?? []).compactMap { UUID(uuidString: $0.id) })
        let deletedIds = tombstonedIds.union(PendingDeletionsStore.shared.ids())

        // Raw fetch results needed twice (entry merge + quick-log strip).
        let stoolFetch   = await stoolFetchA
        let walkFetch    = await walkFetchA
        let bathFetch    = await bathFetchA
        let vitaminFetch = await vitaminFetchA
        let diaperFetch  = await diaperFetchA
        let pumpingFetch = await pumpingFetchA

        // Merge into SwiftData on the main actor (shared context is main-actor owned).
        // Each collection commits its own watermark iff its upsert did not throw.
        await merge(await feedingFetch,  map: Self.feedingEntry)     { try await self.feedingRepo.upsert($0) }
        await merge(await sleepFetch,    map: Self.sleepEntry)       { try await self.sleepRepo.upsert($0) }
        await merge(diaperFetch,         map: Self.diaperEntry)      { entries in
            try await self.diaperRepo.upsert(entries.filter { !deletedIds.contains($0.id) })
        }
        await merge(stoolFetch,          map: Self.stoolEntry)       { try await self.stoolRepo.upsert($0) }
        await merge(await diaryFetch,    map: Self.diaryItem)        { try await self.diaryRepo.upsert($0) }
        await merge(walkFetch,           map: Self.walkEntry)        { try await self.walkRepo.upsert($0) }
        await merge(bathFetch,           map: Self.bathEntry)        { try await self.bathRepo.upsert($0) }
        await merge(pumpingFetch,        map: Self.pumpingEntry)     { try await self.pumpingRepo.upsert($0) }
        await merge(await measureFetch,  map: Self.measurementEntry) { try await self.measurementRepo.upsert($0) }
        await merge(await vaccineFetch,  map: Self.vaccinationEntry) { entries in
            try await self.vaccinationRepo.upsert(entries.filter { !deletedIds.contains($0.id) })
        }
        await merge(await foodFetch,     map: Self.foodEntry)        { entries in
            try await self.foodDiaryRepo.upsert(entries.filter { !deletedIds.contains($0.id) })
        }
        await merge(await tempFetch,     map: Self.temperatureEntry) { try await self.temperatureRepo.upsert($0) }
        await merge(await momSleepFetch, map: Self.momSleepEntry)    { try await self.momSleepRepo.upsert($0) }
        await merge(await waterFetch,    map: Self.waterIntakeEntry) { try await self.waterIntakeRepo.upsert($0) }
        await merge(await leapFetch,     map: Self.leapProgress)     { try await self.leapsRepo.upsert($0) }
        await merge(await visitFetch,    map: Self.doctorVisit)      { try await self.doctorVisitRepo.upsert($0) }

        // Quick-log "today" strip. `appendUnique` cannot throw; vitamins have no
        // entry repo, so their watermark commits here.
        if recordQuickLogs {
            let quickEventDTOs = walkFetch.dtos + bathFetch.dtos + vitaminFetch.dtos + stoolFetch.dtos
            let quickToday = quickEventDTOs.compactMap(Self.todayQuickLog)
                + diaperFetch.dtos.compactMap(Self.todayDiaperQuickLog)
                + pumpingFetch.dtos.compactMap(Self.todayPumpingQuickLog)
            quickToday.forEach { quickLogRepo.appendUnique($0) }
        }
        commit(vitaminFetch)

        // Propagate deletes made on other devices: remove any local row whose id was
        // explicitly tombstoned. Only ever deletes ids we have a tombstone for.
        var deletionsApplied = true
        if !deletedIds.isEmpty {
            do {
                try await diaperRepo.applyDeletions(deletedIds)
                try await vaccinationRepo.applyDeletions(deletedIds)
                try await foodDiaryRepo.applyDeletions(deletedIds)
                quickLogRepo.remove(ids: deletedIds)
            } catch {
                deletionsApplied = false
            }
        }
        if deletionsApplied, let tombstones {
            let maxTomb = tombstones.map(\.deletedAt).max()
            let nextTomb = Self.advancedWatermark(previous: tombWatermark, maxObserved: maxTomb)
            watermarks.set(family: tombScope.familyId, baby: tombScope.babyId,
                           collection: "deletions", to: nextTomb)
        }

        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
    }
```

**Behavior preserved:** per-collection error isolation (one failed upsert never blocks the others), upsert order, `deletedIds` filtering on the three delete-capable collections, `recordQuickLogs` semantics, final notification.
**Behavior changed (intended):** watermarks commit after their merge; failed fetch or failed first pull commits nothing; failed `applyDeletions` re-pulls the same tombstones next sync (idempotent by design).

---

## Task 2 — Purge local data when switching between families

### Problem

`BabyRecord` carries no family scoping and nothing purges local data on a family switch (`AppContainer.observeFamilyJoin` only nils `ActiveBaby.currentId`). After joining family B while previously in family A:

1. `getAllProfiles()` still returns family A's children → they appear in the baby picker.
2. Selecting one triggers `switchActiveBaby` → `resyncActiveBaby` → `syncBabyProfile`, whose `else if let local` branch **uploads family A's child profile into family B's Firestore** — visible to every member of family B. All subsequent logs follow.
3. The `maxChildren` cap counts these ghosts.
4. `PendingDeletionsStore` is not family-stamped: queued deletes replay stray tombstones into family B.

First-ever join (previous family == nil) must **not** purge — locally created solo-mode data legitimately backfills into the first family.

### Files

- `Momsy/Core/Family/FamilySwitchPolicy.swift` — new, pure.
- `Momsy/Core/Family/FamilyManager.swift` — carry the previous family id in the `familyDidJoin` notification.
- `Momsy/Core/DI/AppContainer.swift` — shared `SyncWatermarkStore`, purge routine, updated join observer.
- `MomsyTests/Core/Family/FamilySwitchPolicyTests.swift` — new.

### Implementation

**1. New `Momsy/Core/Family/FamilySwitchPolicy.swift`:**

```swift
import Foundation

/// Decides whether locally cached family data must be wiped after a join.
enum FamilySwitchPolicy {
    /// True only when moving between two different, real families. A first-ever
    /// join (no previous family) keeps local solo-mode data so it backfills into
    /// the joined family; rejoining the same family is a no-op.
    static func shouldPurgeLocalData(previousFamilyId: String?, newFamilyId: String) -> Bool {
        guard let previous = previousFamilyId, !previous.isEmpty else { return false }
        return previous != newFamilyId
    }
}
```

**2. `FamilyManager.swift`.** Add near `static let familyDidJoin` (line ~17):

```swift
    static let previousFamilyIdUserInfoKey = "previousFamilyId"
```

In `joinFamily(code:uid:force:)`, capture the pre-switch id **before** the roster detach block (before the `if let previous = familyId, previous != targetFamilyId` at ~line 173):

```swift
        let previousFamilyId = familyId
```

Replace the final notification post (~line 191):

```swift
        NotificationCenter.default.post(
            name: .familyDidJoin, object: nil,
            userInfo: previousFamilyId.map { [Self.previousFamilyIdUserInfoKey: $0] }
        )
```

**3. `AppContainer.swift`.**

Add a shared watermark store and pass it to the downloader (currently the downloader silently constructs its own via the default parameter):

```swift
    let syncWatermarks = SyncWatermarkStore()
```

In the `CloudSyncDownloader(...)` construction add the final argument:

```swift
        doctorVisitRepo: doctorVisitRepository,
        watermarks: syncWatermarks
    )
```

Replace `observeFamilyJoin()`:

```swift
    /// After a join, drop the active-baby pointer so the downloader adopts the joined
    /// family's roster, then re-pull everything. When the join SWITCHED families, wipe
    /// the old family's local cache first — otherwise its children stay in the picker
    /// and `syncBabyProfile` would re-upload them into the new family.
    private func observeFamilyJoin() {
        familyJoinObserver = NotificationCenter.default.addObserver(
            forName: .familyDidJoin, object: nil, queue: .main) { [weak self] note in
            guard let self else { return }
            let previous = note.userInfo?[FamilyManager.previousFamilyIdUserInfoKey] as? String
            Task { @MainActor in
                if let newFamily = FamilyManager.shared.familyId,
                   FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: previous,
                                                           newFamilyId: newFamily) {
                    self.purgeLocalData(previousFamilyId: previous ?? "")
                }
                ActiveBaby.currentId = nil
                await self.cloudSyncDownloader.forceResyncAll()
                NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
            }
        }
    }
```

Add below it:

```swift
    /// Removes every locally cached child and log of the family being left so nothing
    /// from it can surface in the picker or be re-uploaded into the joined family.
    /// The old family's watermarks are reset too: the local rows backing that delta
    /// are gone, so a later re-join must start from a clean full pull. Queued cloud
    /// deletes are dropped — replaying them would write stray tombstones into the
    /// new family's tree.
    @MainActor
    private func purgeLocalData(previousFamilyId: String) {
        let records = (try? context.fetch(FetchDescriptor<BabyRecord>())) ?? []
        for record in records {
            BabyLogBackfill.deleteLogs(forBaby: record.id, context: context)
            PendingWritesStore.shared.removeAll(forBaby: record.id)
            if !previousFamilyId.isEmpty {
                syncWatermarks.reset(family: previousFamilyId, baby: record.id.uuidString)
            }
            context.delete(record)
        }
        try? context.save()
        PendingDeletionsStore.shared.clear()
        Task { await appState.load() }
    }
```

If `PendingWritesStore.removeAll(forBaby:)` differs in name/signature, use the existing API from `deleteChild(id:)` — code wins over this doc.

---

## Unit tests (Swift Testing, pure only)

**`MomsyTests/Core/Family/FamilySwitchPolicyTests.swift`:**

```swift
import Testing
@testable import Momsy

@Suite("FamilySwitchPolicy")
struct FamilySwitchPolicyTests {

    @Test("first-ever join keeps local solo-mode data")
    func firstJoin() {
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: nil, newFamilyId: "B") == false)
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: "", newFamilyId: "B") == false)
    }

    @Test("rejoining the same family is a no-op")
    func sameFamily() {
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: "A", newFamilyId: "A") == false)
    }

    @Test("switching between two real families purges")
    func realSwitch() {
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: "A", newFamilyId: "B") == true)
    }
}
```

**`MomsyTests/Core/BabySync/CloudSyncWatermarkCommitTests.swift`:**

```swift
import Testing
import Foundation
@testable import Momsy

@Suite("CloudSyncDownloader watermark commit")
struct CloudSyncWatermarkCommitTests {

    @Test("failed fetch never commits — even the epoch floor on a first pull")
    func failedFetchCommitsNothing() {
        let floor = CloudSyncDownloader.advancedWatermark(previous: nil, maxObserved: nil)
        #expect(CloudSyncDownloader.watermarkAfterFetch(fetchSucceeded: false, next: floor) == nil)
    }

    @Test("successful fetch commits the advanced watermark")
    func successCommitsNext() {
        let prev = Date(timeIntervalSince1970: 1_000)
        let seen = Date(timeIntervalSince1970: 2_000)
        let next = CloudSyncDownloader.advancedWatermark(previous: prev, maxObserved: seen)
        #expect(CloudSyncDownloader.watermarkAfterFetch(fetchSucceeded: true, next: next) == seen)
    }

    @Test("successful empty delta re-commits the previous watermark, not the floor")
    func emptyDeltaKeepsPrevious() {
        let prev = Date(timeIntervalSince1970: 5_000)
        let next = CloudSyncDownloader.advancedWatermark(previous: prev, maxObserved: nil)
        #expect(CloudSyncDownloader.watermarkAfterFetch(fetchSucceeded: true, next: next) == prev)
    }
}
```

If `PendingFetch` / helpers end up `private`, raise to internal (default) — the test target uses `@testable`.

---

## Definition of Done

- [ ] `fetch` returns `PendingFetch`; no `watermarks.set` call remains inside `fetch`.
- [ ] Every collection's watermark is written only via `merge`/`commit` after a non-throwing upsert.
- [ ] `deletions` watermark is written only after `applyDeletions` completes without throwing, and only when the tombstone fetch itself succeeded.
- [ ] No `try? upsert` remains in `downloadAndMerge` (error isolation now lives in `merge`).
- [ ] `FamilySwitchPolicy` exists; `familyDidJoin` carries `previousFamilyId`; `AppContainer` purges on real switch only.
- [ ] Downloader receives the container's `syncWatermarks` instance (no default-constructed store in production wiring).
- [ ] New tests pass; full existing suite passes; project builds with zero new warnings.
- [ ] No changes outside the listed files.

## Manual QA script

**Watermark (one device):**
1. Log a feeding, force-quit, relaunch → entry present (baseline).
2. Airplane mode → foreground/background the app → back online → relaunch → no data loss, no duplicate entries.
3. On a second device edit a week-old feeding → first device foreground after 5+ min → edit arrives (regression check on `updatedAt` watermarking).

**Family switch (two simulators, accounts A and B):**
1. Device 1: family A with child "Anna", several logs.
2. Device 2: family B (different account) with child "Boris"; generate invite.
3. Device 1: join family B via link → confirm the abandon dialog.
4. Device 1 expectations: picker shows **only Boris**; no "Anna" anywhere; Today shows Boris's data after sync.
5. Device 2 (family B) expectation: **no "Anna" profile ever appears** in Firestore console under `families/B/babies` or in the app.
6. Device 1: fresh-join back to a new invite for family A → full history re-downloads (watermark reset check).
7. First-ever-join regression: fresh install, create child locally solo, then join a family → local child **is** backfilled into it (purge must NOT fire).
