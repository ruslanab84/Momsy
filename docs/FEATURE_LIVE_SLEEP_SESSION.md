# FEATURE — Live shared sleep session across co-parent devices

**Repo state verified against:** main @ `2b279c6`
**Priority:** P2 (UX/product), no data-loss risk in current behavior

## Goal

When parent A taps sleep **start**, parent B sees the running session within seconds — same timer, attributed "Started by {name}", with no start button offered. If B managed to tap start inside the sync race window, the duplicate is merged away with an alert. Either parent can **stop** the session; the other device's timer, widget, and Live Activity close in real time.

## Current state (verified)

- `start()` writes **only** to SwiftData. `pushSleepToFirestore` fires only in `stop()`, `logManualEntry` (`SleepViewModel.swift:233,307`) and the Watch stop path (`QuickLogCoordinator.swift:128`). Open entries never reach Firestore.
- The receive side already half-works: `CloudSyncDownloader.sleepEntry` (`:445`) accepts `endedAt == nil`; `reloadActiveBabyState` (`SleepViewModel.swift:395-410`) finds the open entry and restores a running timer via `restoreOpenSession`.
- **Blocker 1:** `restoreOpenSession` judges staleness by the **local** `WidgetDataStore.sleepState` — a co-parent's live session has no local widget state on this device and would be classified as an orphan → `.discard` → deleted. Domain models carry no ownership (`addedBy` is stamped in Firestore by `SyncAuthorMetadata` but dropped in the DTO→`SleepEntry` mapping).
- **Blocker 2:** no realtime delivery. The downloader is watermark polling on `scenePhase == .active`; `SleepViewModel` does not observe `.cloudSyncDidMerge`.
- Verified enablers: `setLog` uses `setData(merge: true)` with idempotent doc id == entry UUID (`BabySyncService.swift:68-82`); `SyncAuthorMetadata.stamp` **preserves a non-empty existing `addedBy`** (`SyncAuthorMetadata.swift`, `guard existingUid.isEmpty`); `CloudSyncDownloader` posts `.cloudSyncDidMerge` itself after merges (`:247,380`); listener plumbing precedent exists (`BabySyncService.streamLogs`, `:379`); deletion tombstones exist (`deleteLog` + `PendingDeletionsStore`, `:130,172`).

**No Firestore rules changes**: `sleepLogs` lives under `families/{f}/babies/{b}/**`, already covered by `belongsToFamily`. The listener query is a single-field range on `updatedAt` — auto-indexed.

---

## Phase A — Push the open entry on start

### A1. `SleepViewModel.finishStartPersistence` (~`:243`)

Insert the push right after the `pendingStart*` bookkeeping, **before** `guard isCurrentBaby(babyId)` (the push belongs to the session's baby scope even if the visible baby changed mid-start):

```swift
        pushSleepToFirestore(saved, babyId: babyId)
```

### A2. Both `pushSleepToFirestore` copies must carry ownership

`SleepViewModel.swift:279` and `QuickLogCoordinator.swift:162` currently send `addedBy: ""` — with `setData(merge: true)`, a stop pushed by the co-parent would let the server re-stamp **them** as author. Change both:

```swift
            addedBy:     entry.startedBy ?? "",
            addedByName: entry.startedByName ?? "",
```

Behavior: A's start push sends `""` → server stamps A (existing mechanism). B's stop push sends A's uid (carried on the synced entry) → `stamp`'s non-empty guard preserves A. (Optional follow-up, not now: extract the duplicated helper.)

### A3. Watch start path — `QuickLogCoordinator.swift:96`

```swift
                let started = try await startSleepUC.execute()
```
then push it exactly like the stop path at `:128` does (`pushSleepToFirestore(started, babyId: babyId)`; `babyId` is in scope there).

Offline note: `setLog` already queues via the SDK / `PendingWritesStore` — an offline start surfaces on B when A comes online. Expected, no extra handling.

---

## Phase B — Ownership in the domain

### B1. `SleepEntry` (`Momsy/Features/Sleep/Domain/Models/SleepEntry.swift`)

Append two optional fields (Codable-safe for old persisted JSON — same pattern as the existing `updatedAt` comment) and two defaulted init params **at the end** of the init (call sites use labels; nothing breaks):

```swift
    /// Session author (Firebase uid / display name), carried through Firestore.
    /// nil on locally created entries — the server stamps the author on upload.
    var startedBy: String?
    var startedByName: String?
```

### B2. `SleepRecord` (`Momsy/Features/Sleep/Data/Persistence/SleepRecord.swift`)

Add `var startedBy: String?` and `var startedByName: String?` (optional ⇒ SwiftData lightweight migration). Wire through `apply(_:)`, `merge(_:)`, `toDomain()`.

### B3. `CloudSyncDownloader.sleepEntry` (`:445`)

```swift
        return SleepEntry(id: uuid, startDate: log.startedAt, endDate: log.endedAt,
                          note: "", quality: log.quality, updatedAt: log.updatedAt,
                          startedBy: log.addedBy.isEmpty ? nil : log.addedBy,
                          startedByName: log.addedByName.isEmpty ? nil : log.addedByName)
```

Do **not** touch `momSleepEntry` — mom sleep is personal, out of scope.

### B4. `currentUid` injection into `SleepViewModel`

Add to the VM (matching the `@MainActor` closure precedent in `OnboardingViewModel`):

```swift
    private let currentUid: @MainActor () -> String?
```

init gains `currentUid: @MainActor @escaping () -> String?` (last param). `AppContainer.makeSleepViewModel`:

```swift
                       currentUid: { [weak authManager] in authManager?.currentUID })
```

### B5. Pure ownership policy — new file `Momsy/Features/Sleep/Domain/Services/SleepSessionOwnership.swift`

```swift
import Foundation

/// Ownership and lifecycle policy for open sleep sessions shared across devices.
/// Pure so it is unit-tested directly (see StaleSessionReconciler / FamilyJoinGuard).
enum SleepSessionOwnership {
    static func isRemoteOwned(startedBy: String?, currentUid: String?) -> Bool {
        guard let startedBy, !startedBy.isEmpty else { return false }
        guard let currentUid, !currentUid.isEmpty else { return true }
        return startedBy != currentUid
    }

    /// A co-parent's open session is mirrored while plausible; an implausibly old one
    /// is left alone — only the owning device has the signals to reconcile it.
    static func shouldMirrorRemoteOpen(start: Date, now: Date, maxDuration: TimeInterval) -> Bool {
        now.timeIntervalSince(start) < maxDuration
    }
}
```

---

## Phase C — Never reconcile a co-parent's live session

Replace `restoreOpenSession` (`SleepViewModel.swift:409-421`) with:

```swift
    private func restoreOpenSession(_ entry: SleepEntry, babyId: UUID?, reconcileStaleOpenSession: Bool) async {
        if SleepSessionOwnership.isRemoteOwned(startedBy: entry.startedBy, currentUid: currentUid()) {
            // A co-parent's live session: this device has no local signals to judge
            // staleness, so it must never reconcile it — only mirror it while plausible.
            if SleepSessionOwnership.shouldMirrorRemoteOpen(
                start: entry.startDate, now: Date(), maxDuration: Self.maxPlausibleSleep
            ) {
                activateTimer(entry: entry, babyId: babyId)
            }
            return
        }
        if !reconcileStaleOpenSession {
            activateTimer(entry: entry, babyId: babyId)
            return
        }
        if case .active = WidgetDataStore.shared.sleepState(for: babyId) {
            liveActivity.reattachIfNeeded()
            activateTimer(entry: entry, babyId: babyId)
        } else {
            await reconcileStaleSleep(entry, babyId: babyId)
            await loadTodayEntries(expectedBabyId: babyId)
        }
    }
```

Mirroring goes through the existing `activateTimer`, so B also gets the widget state and a Live Activity for free. **Phase F falls out of this**: B's `stop()` operates on the mirrored `activeSleepEntry`, closes it with real duration, and the push preserves A's authorship (A2).

---

## Phase D — Realtime trigger

### D1. `BabySyncService` — add next to `streamLogs` (`:379`)

```swift
    /// Fires once per SERVER write to `subcollection` newer than `since`. The initial
    /// snapshot is empty (0 reads) — this is a change trigger, not a data source; the
    /// consumer runs the watermark downloader to actually merge. Local pending echoes
    /// are ignored so a device does not resync in response to its own writes.
    func streamLogUpdates(from subcollection: String, since: Date) -> AsyncStream<Void> {
        guard hasPath else { return AsyncStream { $0.finish() } }
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let listener = collection(subcollection)
                .whereField("updatedAt", isGreaterThan: Timestamp(date: since))
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot, !snapshot.documentChanges.isEmpty else { return }
                    guard !snapshot.metadata.hasPendingWrites else { return }
                    continuation.yield(())
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }
```

### D2. New file `Momsy/Services/Firebase/BabySync/SleepLiveSyncService.swift`

```swift
import Foundation

/// Foreground-only realtime trigger for co-parent sleep updates. Listens to the active
/// baby's `sleepLogs` for server writes newer than attach time and runs the watermark
/// downloader, which merges and posts `.cloudSyncDidMerge` for the UI. Costs ~0 reads
/// at attach (the query starts empty) and one snapshot per co-parent write.
@MainActor
final class SleepLiveSyncService {
    private let downloader: CloudSyncDownloader
    private var streamTask: Task<Void, Never>?

    init(downloader: CloudSyncDownloader) { self.downloader = downloader }

    func start() {
        stop()
        streamTask = Task { [weak self] in
            let stream = BabySyncService().streamLogUpdates(from: "sleepLogs", since: Date())
            for await _ in stream {
                guard !Task.isCancelled, let self else { return }
                try? await Task.sleep(for: .milliseconds(300))
                await self.downloader.resyncAll()
            }
        }
    }

    func stop() {
        streamTask?.cancel()
        streamTask = nil
    }

    func restart() { start() }
}
```

### D3. Lifecycle hooks

- `AppContainer`: `lazy var sleepLiveSync = SleepLiveSyncService(downloader: cloudSyncDownloader)`.
- `MomsyApp` scenePhase handler (verified block at `.onChange(of: scenePhase)`): add `container.sleepLiveSync.start()` inside `phase == .active`, and an `else { container.sleepLiveSync.stop() }` branch.
- `AppContainer.switchActiveBaby(to:)` — `sleepLiveSync.restart()` at the end (listener path is baby-scoped).
- `AppContainer.observeFamilyJoin` (`:114-133`) — `self.sleepLiveSync.restart()` after `forceResyncAll()`.

---

## Phase E — Merge handling in the ViewModel

### E1. Duplicate policy — new file `Momsy/Features/Sleep/Domain/Services/DuplicateOpenSessionPolicy.swift`

```swift
import Foundation

/// Resolves the race where both parents start within the sync window: the earliest
/// open session (tie-broken by id) is canonical; each device discards only its OWN
/// later near-duplicates, so no device ever deletes the co-parent's data.
enum DuplicateOpenSessionPolicy {
    static func canonical(_ open: [SleepEntry]) -> SleepEntry? {
        open.min { ($0.startDate, $0.id.uuidString) < ($1.startDate, $1.id.uuidString) }
    }

    static func ownDiscards(
        _ open: [SleepEntry], canonical: SleepEntry,
        currentUid: String?, window: TimeInterval
    ) -> [SleepEntry] {
        open.filter {
            $0.id != canonical.id
            && !SleepSessionOwnership.isRemoteOwned(startedBy: $0.startedBy, currentUid: currentUid)
            && $0.startDate.timeIntervalSince(canonical.startDate) < window
        }
    }
}
```

(Own open entries **beyond** the window are not duplicates — they stay for the existing stale-orphan reconcile.)

### E2. `SleepViewModel` — merge observer

New state: `@Published var coParentSessionNotice: String?`, constant `private static let duplicateStartWindow: TimeInterval = 180`, an observer token, and `observeCloudMerges()` called at the end of `init` (remove the observer in `deinit`):

```swift
    private func observeCloudMerges() {
        mergeObserver = NotificationCenter.default.addObserver(
            forName: .cloudSyncDidMerge, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in await self?.handleCloudMerge() }
        }
    }

    private func handleCloudMerge() async {
        let babyId = currentBabyId
        await loadTodayEntries(expectedBabyId: babyId)
        guard isCurrentBaby(babyId), !Task.isCancelled else { return }

        // 1. Remote close: the session this device shows got an endDate elsewhere.
        if let active = activeSleepEntry,
           let merged = todayEntries.first(where: { $0.id == active.id }),
           merged.endDate != nil {
            endLocalSessionPresentation(babyId: activeSleepBabyId ?? babyId)
        }

        // 2. Race duplicates: keep the earliest, drop own extras, tell the user.
        let open = todayEntries.filter { $0.endDate == nil }
        if open.count > 1, let canonical = DuplicateOpenSessionPolicy.canonical(open) {
            let discards = DuplicateOpenSessionPolicy.ownDiscards(
                open, canonical: canonical, currentUid: currentUid(), window: Self.duplicateStartWindow
            )
            for dup in discards {
                try? await withBabyScope(babyId) {
                    try await reconcileStaleSleepUC.execute(dup, end: nil)   // local delete
                    try await BabySyncService().deleteLog(id: dup.id.uuidString, from: "sleepLogs")
                }
                if activeSleepEntry?.id == dup.id {
                    endLocalSessionPresentation(babyId: babyId)
                }
            }
            if !discards.isEmpty {
                coParentSessionNotice = duplicateNotice(for: canonical)
                await loadTodayEntries(expectedBabyId: babyId)
            }
        }

        // 3. Adopt / refresh the single open session, or clean a stale widget mirror.
        if let openEntry = todayEntries.first(where: { $0.endDate == nil }) {
            if activeSleepEntry?.id != openEntry.id {
                await restoreOpenSession(openEntry, babyId: babyId, reconcileStaleOpenSession: false)
            }
        } else if !isSleepActive, case .active = WidgetDataStore.shared.sleepState(for: babyId) {
            WidgetDataStore.shared.clearSleep(lastDurationSeconds: 0, babyId: babyId)
            liveActivity.endActivity()
        }

        await loadChartData(expectedBabyId: babyId)
        await refreshForecast(expectedBabyId: babyId)
    }

    private func endLocalSessionPresentation(babyId: UUID?) {
        timerTask?.cancel(); timerTask = nil
        liveActivity.endActivity()
        WidgetDataStore.shared.clearSleep(lastDurationSeconds: sleepSeconds, babyId: babyId)
        activeSleepEntry = nil
        activeSleepBabyId = nil
        isSleepActive = false
        sleepSeconds = 0
    }

    private func duplicateNotice(for canonical: SleepEntry) -> String {
        if let name = canonical.startedByName, !name.isEmpty,
           SleepSessionOwnership.isRemoteOwned(startedBy: canonical.startedBy, currentUid: currentUid()) {
            return lm.strings.sleepAlreadyTrackedBy(name)
        }
        return lm.strings.sleepAlreadyTrackedGeneric
    }
```

### E3. UI — attribution + alert (`SleepView.swift`)

VM computed property:

```swift
    var activeSessionAttribution: String? {
        guard let entry = activeSleepEntry,
              SleepSessionOwnership.isRemoteOwned(startedBy: entry.startedBy, currentUid: currentUid()),
              let name = entry.startedByName, !name.isEmpty else { return nil }
        return lm.strings.sleepStartedBy(name)
    }
```

In `SleepView`: a secondary-styled `Text(attribution)` under the running timer when non-nil, and an `.alert` bound to `coParentSessionNotice` (follow the existing `saveError` alert pattern in that view).

### E4. Localization — `L10n.swift`, follow `LOCALIZATION_RULES.md` conventions

```swift
    func sleepStartedBy(_ name: String) -> String { s("Started by \(name)", "Начал(а): \(name)", "Gestartet von \(name)", "Iniciado por \(name)", "Démarré par \(name)", "Iniciado por \(name)", "由\(name)开始") }
    func sleepAlreadyTrackedBy(_ name: String) -> String { s("Sleep is already being tracked — started by \(name).", "Сон уже отслеживается — начал(а) \(name).", "Schlaf wird bereits erfasst – gestartet von \(name).", "El sueño ya se está registrando: iniciado por \(name).", "Le sommeil est déjà suivi — démarré par \(name).", "O sono já está a ser registado — iniciado por \(name).", "睡眠已在记录中——由\(name)开始。") }
    var sleepAlreadyTrackedGeneric: String { s("Sleep is already being tracked on another device.", "Сон уже отслеживается на другом устройстве.", "Schlaf wird bereits auf einem anderen Gerät erfasst.", "El sueño ya se está registrando en otro dispositivo.", "Le sommeil est déjà suivi sur un autre appareil.", "O sono já está a ser registado noutro dispositivo.", "睡眠已在另一台设备上记录。") }
```

---

## Out of scope (explicitly)

- `momSleepLogs` (personal, no co-parent semantics).
- Realtime listeners for other log types (the `streamLogUpdates` + `SleepLiveSyncService` pattern is reusable later).
- DRY extraction of the two `pushSleepToFirestore` copies (both are updated in A2; unification is follow-up).

## Tests (Swift Testing)

`MomsyTests/Features/Sleep/SleepSessionOwnershipTests.swift`:
- `isRemoteOwned`: nil/empty owner → false; owner == uid → false; owner != uid → true; owner set + currentUid nil → true.
- `shouldMirrorRemoteOpen`: just under / just over `maxDuration` boundary.

`MomsyTests/Features/Sleep/DuplicateOpenSessionPolicyTests.swift`:
- `canonical`: earliest wins; equal `startDate` tie-broken by id.
- `ownDiscards`: excludes canonical; excludes remote-owned entries; excludes own entries beyond the window; includes own near-duplicates.

## Definition of Done

- [ ] Start on device A creates the open `sleepLogs/{id}` doc in Firestore (endedAt absent), author stamped
- [ ] `SleepEntry`/`SleepRecord` carry `startedBy`/`startedByName`; downloader maps them; lightweight migration verified on an upgrade install
- [ ] Remote-owned open sessions are mirrored (≤24h) and never reconciled/deleted by the non-owner
- [ ] Foreground listener drives merge on both devices; detached on background; reattached on baby switch and family join
- [ ] Remote stop closes timer, widget, and Live Activity on the other device; authorship preserved on B-stops
- [ ] Race duplicates collapse to the earliest with a localized alert on the loser; both local and cloud copies of the duplicate removed
- [ ] New pure-logic tests pass; full suite green; `Momsy`, `MomsyWatch`, widget targets build

## Manual QA (two simulators, one family)

1. A and B foregrounded on the Sleep screen. A taps start → within ~2s B shows the running timer + "Начал(а): {A}", start control gone.
2. B backgrounded during A's start → B foregrounds → session appears via the scenePhase resync.
3. A taps stop → B's timer stops within ~2s; the completed entry appears in both lists with identical duration.
4. **F:** A starts; B taps stop → closed on both; A's Live Activity dismissed; duration correct; in Firestore `addedBy` is still A.
5. **Race:** disconnect B's network; A starts; B taps start; reconnect B → B shows the "already tracked — started by {A}" alert; exactly one session (A's, the earliest) remains on both devices and in Firestore.
6. **Stale remote:** in Firebase console, set an open entry's `startedAt` to 30h ago → B does not show a timer and does not delete the doc.
7. Watch: start from Watch quick-log → co-parent's phone mirrors the session.
8. Regression: single-device start/stop offline→online; midnight-spanning session; baby switch during an active session; forecast unaffected by an open entry.
