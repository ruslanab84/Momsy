# P1: Sync writes await server ack (offline hang) + review fixes for c558fe0 / e97976f

**Scope:** Fixes from the 2026-07-06 code review of commits `c558fe0` (leap personalization) and `e97976f` (leap reminders + history insights). All signatures below verified against HEAD `e97976f`.

**Bundled tasks:**
1. **P1** — `BabySyncService.addLog/setLog` await server ack → offline hang (blocks `recordSkillToDiary` UI)
2. **P2** — `SyncAuthorMetadata.stamp` overwrites original author on edits/replay
3. **P2** — `WeeklyInsightContextBuilder` emits false leap signals when the current week has no tracking data
4. **P3** — `LeapsViewModel.loadHistory` skips age-auto-completed leaps
5. **P3** — leap notifications uncapped (iOS 64 pending-request limit risk)
6. **P3** — family-switch purge leaves stale old-family snapshot in `WidgetDataStore` (widget/Watch)

**Out of scope (verified, no action):**
- Leap check-in purge on account deletion is already covered: keys `local_leap_check_ins_*` match the `"local_"` prefix sweep in `AppContainer.clearAccountScopedDefaults()` (AppContainer.swift:353-360).
- `replayPendingWrites` keeps awaiting server ack — intentional: an entry must be confirmed before it is dequeued.

---

## Task 1 — P1: Drop server-ack await in online sync writes

**File:** `Momsy/Services/Firebase/BabySync/BabySyncService.swift`

**Why:** The async `setData` variants complete only after backend acknowledgment. Offline, the call suspends until connectivity returns. Every `Task { try? await syncRepo.add... }` accumulates a suspended task, and `RecordLeapSkillUseCase.execute` awaits `addDiaryLog` directly — so `LeapsViewModel.recordSkillToDiary` never returns offline, `isRecordingSkill` stays `true`, and the save button in `LeapSkillDiarySheet` stays disabled indefinitely. Firestore already persists writes to its local cache synchronously and syncs later; awaiting the ack buys nothing for fire-and-forget logs.

**Current (line 55-61):**
```swift
func addLog<T: Encodable>(_ log: T, to subcollection: String) async throws {
    guard hasPath else { return }
    let ref = collection(subcollection).document()
    let payload = try await encodedPayloadWithAuthor(log)
    try await ref.setData(payload)
}
```

**Replace with:**
```swift
func addLog<T: Encodable>(_ log: T, to subcollection: String) async throws {
    guard hasPath else { return }
    let ref = collection(subcollection).document()
    let payload = try await encodedPayloadWithAuthor(log)
    // Fire-and-forget: Firestore persists locally and syncs when online.
    // Awaiting the server ack suspends callers indefinitely while offline.
    ref.setData(payload)
}
```

**Current (line 80, last line of `setLog`):**
```swift
        try await collection(subcollection).document(id).setData(payload, merge: true)
```

**Replace with:**
```swift
        collection(subcollection).document(id).setData(payload, merge: true)
```

Keep both function signatures `async throws` (encoding and author lookup still need them); callers are unchanged. Not awaiting selects the synchronous `setData` overloads, so this compiles without ambiguity.

**Do NOT touch** `replayPendingWrites` (line ~212) — it must keep `try await ... setData` so entries are only dequeued after a confirmed write.

---

## Task 2 — P2: `stamp` must fill empty author fields, never overwrite

**File:** `Momsy/Services/Firebase/BabySync/SyncAuthorMetadata.swift`

**Why:** `stamp` currently replaces `addedBy`/`addedByName` whenever the keys exist. Two regressions: (a) a co-parent editing a record becomes its author; (b) `replayPendingWrites` re-stamps queued writes with whoever is signed in at replay time. Intended semantics: `addedBy` = creator.

**Current (lines 22-33):**
```swift
    nonisolated static func stamp(_ payload: [String: Any], author: SyncAuthorIdentity?) -> [String: Any] {
        guard let author, !author.uid.isEmpty else { return payload }

        var stamped = payload
        if stamped.keys.contains(addedByKey) {
            stamped[addedByKey] = author.uid
        }
        if stamped.keys.contains(addedByNameKey) {
            stamped[addedByNameKey] = author.displayName
        }
        return stamped
    }
```

**Replace with:**
```swift
    nonisolated static func stamp(_ payload: [String: Any], author: SyncAuthorIdentity?) -> [String: Any] {
        guard let author, !author.uid.isEmpty else { return payload }

        let existingUid = (payload[addedByKey] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard existingUid.isEmpty else { return payload }

        var stamped = payload
        if stamped.keys.contains(addedByKey) {
            stamped[addedByKey] = author.uid
        }
        if stamped.keys.contains(addedByNameKey) {
            stamped[addedByNameKey] = author.displayName
        }
        return stamped
    }
```

**Tests:** `MomsyTests/Features/Sync/BabySyncBackfillTests.swift`
- Rename `authorStampingOverwritesLogAuthorFields` (line 10) → `authorStampingFillsEmptyAuthorFields`. Its fixture uses empty strings, so it stays green.
- Add:
```swift
    @Test func authorStampingPreservesExistingAuthor() {
        let payload: [String: Any] = ["amountMl": 120, "addedBy": "creator-1", "addedByName": "Mom"]
        let stamped = SyncAuthorMetadata.stamp(
            payload,
            author: SyncAuthorIdentity(uid: "editor-2", displayName: "Dad")
        )
        #expect((stamped["addedBy"] as? String) == "creator-1")
        #expect((stamped["addedByName"] as? String) == "Mom")
    }
```

---

## Task 3 — P2: Guard empty tracking weeks in leap signals

**File:** `Momsy/Features/WeeklyInsights/Data/Builders/WeeklyInsightContextBuilder.swift`

**Why:** If the user stopped tracking this week, `weekSleep`/`weekFeeds` are empty → `current = 0` → `sleepDropped`/`feedingShifted` return `true` → a fabricated "sleep dropped / feedings shifted" signal is injected into the Gemini prompt. No-data must never read as a behavior change. (`LeapsViewModel` already guards this with `recent > 0`; mirror it here.)

**Current (lines 140-151):**
```swift
    private static func sleepDropped(weekSleep: [SleepEntry], prevSleep: [SleepEntry]) -> Bool {
        let current = weekSleep.compactMap(\.durationMinutes).reduce(0, +)
        let previous = prevSleep.compactMap(\.durationMinutes).reduce(0, +)
        guard previous > 0 else { return false }
        return (previous / 7) - (current / 7) >= 30
    }

    private static func feedingShifted(weekFeeds: [FeedingEntry], prevFeeds: [FeedingEntry]) -> Bool {
        guard !prevFeeds.isEmpty else { return false }
        let delta = abs(weekFeeds.count - prevFeeds.count)
        return delta >= 7 || Double(delta) / Double(prevFeeds.count) >= 0.25
    }
```

**Replace with:**
```swift
    private static func sleepDropped(weekSleep: [SleepEntry], prevSleep: [SleepEntry]) -> Bool {
        guard !weekSleep.isEmpty else { return false }
        let current = weekSleep.compactMap(\.durationMinutes).reduce(0, +)
        let previous = prevSleep.compactMap(\.durationMinutes).reduce(0, +)
        guard previous > 0 else { return false }
        return (previous / 7) - (current / 7) >= 30
    }

    private static func feedingShifted(weekFeeds: [FeedingEntry], prevFeeds: [FeedingEntry]) -> Bool {
        guard !weekFeeds.isEmpty, !prevFeeds.isEmpty else { return false }
        let delta = abs(weekFeeds.count - prevFeeds.count)
        return delta >= 7 || Double(delta) / Double(prevFeeds.count) >= 0.25
    }
```

**Test:** `MomsyTests/Features/WeeklyInsights/WeeklyInsightContextBuilderTests.swift` (mocks range-filter, verified). Add:
```swift
    @Test("empty tracking week does not produce leap signals")
    func emptyWeekNoLeapSignals() async throws {
        let (start, end) = window()
        let sleepRepo = MockSleepRepository()
        sleepRepo.entries = [sleep(start.addingTimeInterval(-3 * 86_400), minutes: 600)]
        let feedingRepo = MockFeedingRepository()
        feedingRepo.entries = (0..<20).map {
            FeedingEntry(date: start.addingTimeInterval(-Double($0 + 1) * 3600), durationSeconds: 600)
        }

        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: start, weekEnd: end,
            birthDate: Calendar.current.date(byAdding: .weekOfYear, value: -18, to: end),
            language: .english,
            sleepRepo: sleepRepo, feedingRepo: feedingRepo,
            foodRepo: MockComplementaryFeedingRepository(), diaperRepo: MockDiaperRepository()
        )

        #expect(stats.leapSignals.isEmpty)
    }
```

---

## Task 4 — P3: Include age-auto-completed leaps in history

**File:** `Momsy/Features/Leaps/Presentation/ViewModel/LeapsViewModel.swift`

**Why:** Leaps completed automatically by age (`isDone` set in `loadLeaps` via `leap.week <= ageWeeks`) have no `LeapProgress` record, so the current loop filter drops them — their check-ins never appear in history, although `historySummary`'s inner guard expects them.

**Current (line 285):**
```swift
        for leap in leaps where progressByID[leap.id] != nil || leap.isCurrent {
```

**Replace with:**
```swift
        for leap in leaps where leap.isDone || leap.isCurrent {
```

`historySummary` already returns `nil` for done leaps with neither check-ins nor a progress record, so nothing empty leaks into the UI.

---

## Task 5 — P3: Cap scheduled leap notifications

**File:** `Momsy/Features/Leaps/Domain/UseCases/ScheduleLeapNotificationsUseCase.swift`

**Why:** 10 pending leaps × 4 requests = 40, plus vaccinations, feeding, diary, weekly report — close to the iOS limit of 64 pending local notifications, past which iOS silently keeps only the soonest. Scheduling the next 3 leaps (≤ 12 requests) is enough; the set rolls forward on every `loadLeaps`.

**Change:** add `maxScheduledLeaps` and replace the loop's done-guard.

```swift
final class ScheduleLeapNotificationsUseCase {
    private let pushNotifications: any PushNotificationServiceProtocol
    private let calendar: Calendar
    private let maxScheduledLeaps: Int

    init(
        pushNotifications: any PushNotificationServiceProtocol,
        calendar: Calendar = .current,
        maxScheduledLeaps: Int = 3
    ) {
        self.pushNotifications = pushNotifications
        self.calendar = calendar
        self.maxScheduledLeaps = maxScheduledLeaps
    }

    func execute(
        leaps: [DevelopmentLeap],
        birthDate: Date,
        language: Language,
        now: Date = Date()
    ) {
        let upcomingIDs = Set(
            leaps.filter { !$0.isDone }
                .sorted { $0.week < $1.week }
                .prefix(maxScheduledLeaps)
                .map(\.id)
        )
        for leap in leaps {
            guard upcomingIDs.contains(leap.id) else {
                pushNotifications.cancelLeapNotification(leapID: leap.id)
                continue
            }
            // ...existing scheduling body unchanged from here...
```

The rest of `execute` (startDate/peakDate/skillsDate/soonDate computation and the four `if ... > now` blocks) stays as-is. Done leaps fall out of `upcomingIDs`, so they are cancelled exactly as before.

**Mock:** `MomsyTests/Mocks/MockPushNotificationService.swift` — extend:
```swift
    var scheduledLeapStartIDs: [Int] = []
    var cancelledLeapIDs: [Int] = []

    func scheduleLeapNotification(leapID: Int, name: String, startDate: Date) { scheduledLeapStartIDs.append(leapID) }
    func cancelLeapNotification(leapID: Int) { cancelledLeapIDs.append(leapID) }
```
(Replace the existing empty-body implementations of these two methods; keep all other members.)

**New test file:** `MomsyTests/Features/Leaps/ScheduleLeapNotificationsUseCaseTests.swift`
```swift
import Testing
@testable import Momsy
import Foundation

@Suite("ScheduleLeapNotificationsUseCase")
struct ScheduleLeapNotificationsUseCaseTests {

    @Test("schedules only the next N pending leaps and cancels the rest")
    func capsPendingLeaps() {
        let mock = MockPushNotificationService()
        let sut = ScheduleLeapNotificationsUseCase(pushNotifications: mock, maxScheduledLeaps: 3)
        let birthDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

        let leaps = DevelopmentLeap.catalog.map { leap -> DevelopmentLeap in
            var copy = leap
            copy.isDone = (leap.id == 1)
            copy.isCurrent = false
            return copy
        }

        sut.execute(leaps: leaps, birthDate: birthDate, language: .english)

        #expect(Set(mock.scheduledLeapStartIDs) == Set([2, 3, 4]))
        #expect(mock.cancelledLeapIDs.contains(1))
        #expect(mock.cancelledLeapIDs.contains(5))
        #expect(!mock.scheduledLeapStartIDs.contains(5))
    }
}
```

---

## Task 6 — P3: Clear widget snapshot on family switch

**File:** `Momsy/Core/DI/AppContainer.swift`

**Why:** `purgeLocalData` wipes SwiftData records, pending writes, and watermarks, but not the app-group store backing the widget and Watch. After leaving/switching a family, the widget keeps showing the old family's last snapshot (baby name, running feeding timer, today counters) — data the user may no longer have access to. `eraseLocalData()` already calls `clearAll()` (line 320); mirror it here. `clearAll()` reloads widget timelines internally (WidgetDataStore.swift:246), so no extra `WidgetCenter` call is needed.

**Current (tail of `purgeLocalData`, lines 152-155):**
```swift
        try? context.save()
        PendingDeletionsStore.shared.clear()
        Task { await appState.load() }
    }
```

**Replace with:**
```swift
        try? context.save()
        PendingDeletionsStore.shared.clear()
        WidgetDataStore.shared.clearAll()
        Task { await appState.load() }
    }
```

A feeding Live Activity started under the old family is out of scope: it ends on the next quick-log interaction, and `clearAll()` resets the shared state it reads from.

---

## Definition of Done

- [ ] `addLog`/`setLog` no longer await the online `setData`; signatures unchanged; `replayPendingWrites` untouched
- [ ] `SyncAuthorMetadata.stamp` fills only empty `addedBy`; renamed test + `authorStampingPreservesExistingAuthor` green
- [ ] `sleepDropped`/`feedingShifted` guard empty current-week data; `emptyWeekNoLeapSignals` green
- [ ] `loadHistory` iterates `leap.isDone || leap.isCurrent`
- [ ] Leap notifications capped via `maxScheduledLeaps = 3`; new use-case test green
- [ ] `purgeLocalData` clears `WidgetDataStore`; widget resets after family switch
- [ ] Full unit test suite green (Swift Testing, Momsy scheme)
- [ ] No new user-facing strings (no localization changes required)

## Manual QA

**1. Offline skill save (P1):**
1. Simulator, signed-in profile with active family. Disable Mac network (Wi-Fi off).
2. Leaps → skills sheet → enter a skill → save.
3. Expect: success message within ~1s, button re-enabled, milestone visible in Diary.
4. Re-enable network → entry appears in Firestore `diaryLogs` and on the co-parent simulator.

**2. Author preservation (P2):**
1. Two simulators, same family (parents A and B).
2. A logs a feeding → Firestore doc has A's `addedBy/addedByName`.
3. B edits that feeding (change duration) → after sync, `addedBy/addedByName` still A.

**3. Offline queue replay regression:**
1. Fresh install, complete onboarding offline (no family path yet), log one entry.
2. Go online, sign in / join family → entry replays into the correct baby path with `addedBy` of the signed-in creator, `updatedAt` server-stamped, watermark advances (existing two-simulator watermark check still passes).

**4. Notification cap (P3):**
1. Profile with a newborn (all leaps pending), open Leaps.
2. Debug-log `UNUserNotificationCenter.current().getPendingNotificationRequests` count: leap requests ≤ 12, only leaps 1-3.

**5. Widget after family switch (P3):**
1. Simulator with the Momsy widget on the home screen, family A active with a logged feeding.
2. Join family B (real switch).
3. Widget must not show family A's baby name/timer; after resync it shows family B's data (or the empty state).
