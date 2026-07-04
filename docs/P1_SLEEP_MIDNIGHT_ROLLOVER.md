# P1 — Sleep Midnight Rollover: Entry Disappears After Stop

**Repo:** `ruslanab84/Momsy` · verified against `fbc6704`
**Scope:** 2 new files, 4 edits. No schema/DTO changes, no Firestore changes, Watch/Widget untouched.

---

## Root cause (verified)

All "today" windows for sleep are built as `[startOfDay(now), +1 day]` and the repository filters **by `startDate` only**:

```swift
// SwiftDataSleepRepository.getEntries
#Predicate { $0.startDate >= from && $0.startDate <= to && $0.babyId == scope }
```

A sleep started **23:00 yesterday** and stopped **00:01 today** has `startDate` outside today's window. Consequences:

1. **Data "disappears" after stop** (reported). `stop()` appends the entry optimistically, save succeeds — but the very next `loadTodayEntries()` (onAppear, baby publisher, sync-triggered reload) refetches today's window and the entry vanishes from the list, `totalSleepToday`, and "last sleep". The record exists in SwiftData but is invisible; it's credited only to *yesterday's* chart bar.
2. **Relaunch after midnight kills the timer and orphans the entry.** `reloadActiveBabyState` restores the open session only from `todayEntries.first(where: { $0.endDate == nil })` — yesterday-started open entry isn't fetched → timer not restored, `stop()` unreachable (`guard isSleepActive`), the open record stays orphaned with `endDate == nil` forever, while the widget/Live Activity still shows an active timer.
3. **Chart attribution is wrong.** `loadChartData` credits the *full* duration to the start day (`isDate($0.startDate, inSameDayAs: day)`) — a 23:00–07:00 night puts 8h on yesterday's bar; the first day of the 7/30-day window also silently loses sleep that started the day before `periodStart`.
4. `logManualEntry` appends to the list only when `isDateInToday(startDate)` — same off-by-a-day for manual cross-midnight entries.

`StopSleepUseCase` and `SwiftDataSleepRepository.update` (fetch by id) are correct — do not touch them.

## Verified signatures

| Symbol | Location | Shape |
|---|---|---|
| `SleepRepository` | `Features/Sleep/Domain/Repositories/SleepRepository.swift` | protocol: `getEntries(from:to:)`, `add`, `upsert`, `update`, `delete`. Conformers: `SwiftDataSleepRepository`, `LocalSleepRepository`, `MockSleepRepository` (tests), `BabyScopedSleepRepository` (tests) — **use a protocol extension so none of them need edits** |
| `GetSleepEntriesUseCase` | `.../UseCases/GetSleepEntriesUseCase.swift` | `execute(from:to:) -> [SleepEntry]` |
| `SleepEntry` | `.../Models/SleepEntry.swift` | `startDate: Date`, `endDate: Date?`, `durationMinutes` computed from full Dates (midnight-safe) |
| `SleepViewModel` | `.../ViewModel/SleepViewModel.swift` | `loadTodayEntries` (~line 250), `totalSleepToday` (~127), `loadChartData` (~85), `logManualEntry` append (~235), `maxPlausibleSleep = 24h` (~25) |
| `TodayViewModel` | `Features/Today/.../TodayViewModel.swift:201-203` | same `[startOfDay, +1d]` window via `getSleep.execute` |

---

## Task 1 — NEW `Momsy/Features/Sleep/Domain/Services/SleepDayWindow.swift`

Pure, unit-testable day-attribution policy.

```swift
import Foundation

enum SleepDayWindow {

    /// True when [start, end ?? now] intersects [dayStart, dayEnd).
    static func overlaps(start: Date, end: Date?, dayStart: Date, dayEnd: Date, now: Date = Date()) -> Bool {
        let effectiveEnd = end ?? max(now, start)
        return start < dayEnd && effectiveEnd > dayStart
    }

    /// Minutes of a completed interval that fall inside [dayStart, dayEnd).
    static func clippedMinutes(start: Date, end: Date, dayStart: Date, dayEnd: Date) -> Int {
        let s = max(start, dayStart)
        let e = min(end, dayEnd)
        guard e > s else { return 0 }
        return Int(e.timeIntervalSince(s) / 60)
    }
}
```

## Task 2 — EDIT `SleepRepository.swift` — protocol extension (no conformer changes)

Append to the file:

```swift
extension SleepRepository {
    /// Entries whose interval intersects [dayStart, dayEnd), including still-open ones.
    /// Widens the startDate fetch window by `lookback` (longest plausible sleep),
    /// then filters in memory — SwiftData #Predicate can't express the optional
    /// endDate comparison reliably.
    func getEntries(overlapping dayStart: Date, until dayEnd: Date,
                    lookback: TimeInterval = 24 * 3600) async throws -> [SleepEntry] {
        let widened = try await getEntries(from: dayStart.addingTimeInterval(-lookback), to: dayEnd)
        return widened.filter {
            SleepDayWindow.overlaps(start: $0.startDate, end: $0.endDate,
                                    dayStart: dayStart, dayEnd: dayEnd)
        }
    }
}
```

Built on `getEntries(from:to:)`, so baby scoping and all four conformers keep working unchanged.

## Task 3 — EDIT `GetSleepEntriesUseCase.swift`

```swift
func executeOverlapping(from: Date, to: Date) async throws -> [SleepEntry] {
    try await repository.getEntries(overlapping: from, until: to)
}
```

## Task 4 — EDIT `SleepViewModel.swift` (4 spots)

4a. `loadTodayEntries(expectedBabyId:)` — one line, `execute` → `executeOverlapping`:

```swift
try await getSleepUC.executeOverlapping(from: start, to: end)
```

This alone fixes disappearance (1) **and** the relaunch-after-midnight restore (2): the yesterday-started open entry now lands in `todayEntries`, so `reloadActiveBabyState` finds it and reattaches the timer.

4b. `totalSleepToday` — clip to today so a 23:00–07:00 night contributes only its today-portion:

```swift
var totalSleepToday: String {
    let cal = Calendar.current
    let dayStart = cal.startOfDay(for: Date())
    let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? Date()
    let total = todayEntries.reduce(0) { acc, e in
        guard let end = e.endDate else { return acc }
        return acc + SleepDayWindow.clippedMinutes(start: e.startDate, end: end,
                                                   dayStart: dayStart, dayEnd: dayEnd)
    }
    return lm.strings.durationFormatted(total)
}
```

4c. `loadChartData(expectedBabyId:)` — overlapping fetch + per-day clipping (night sleep now splits across the two correct bars; first bar of the period no longer loses pre-period starts):

```swift
let entries = (try? await withBabyScope(expectedBabyId) {
    try await getSleepUC.executeOverlapping(from: periodStart, to: Date())
}) ?? []
guard isCurrentBaby(expectedBabyId) else { return }
let completed = entries.filter { $0.endDate != nil }
sleepDays = (0..<dayCount).compactMap { offset in
    guard let day = cal.date(byAdding: .day, value: offset, to: periodStart),
          let next = cal.date(byAdding: .day, value: 1, to: day) else { return nil }
    let mins = completed.reduce(0) { acc, e in
        guard let end = e.endDate else { return acc }
        return acc + SleepDayWindow.clippedMinutes(start: e.startDate, end: end,
                                                   dayStart: day, dayEnd: next)
    }
    return SleepDayPoint(id: day, totalMinutes: mins)
}
```

4d. `logManualEntry` — replace the append condition:

```swift
let cal = Calendar.current
let dayStart = cal.startOfDay(for: Date())
let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? Date()
if SleepDayWindow.overlaps(start: saved.startDate, end: saved.endDate,
                           dayStart: dayStart, dayEnd: dayEnd) {
    todayEntries.append(saved)
    todayEntries.sort { $0.startDate < $1.startDate }
}
```

## Task 5 — EDIT `TodayViewModel.swift` (~line 203)

```swift
guard let sleeps = try? await getSleep.executeOverlapping(from: startOfDay, to: endOfDay) else { return }
```

If the row label downstream (`sleepLabel`) formats times, no change needed — full Dates render correctly.

## Task 6 — NEW `MomsyTests/Features/Sleep/SleepDayWindowTests.swift`

```swift
import Testing
import Foundation
@testable import Momsy

@Suite struct SleepDayWindowTests {

    // Fixed UTC calendar for determinism.
    private static let cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    private func date(_ d: Int, _ h: Int, _ m: Int = 0) -> Date {
        Self.cal.date(from: DateComponents(year: 2026, month: 7, day: d, hour: h, minute: m))!
    }

    private var dayStart: Date { date(4, 0) }
    private var dayEnd: Date { date(5, 0) }

    @Test func crossMidnightSleepOverlapsBothDays() {
        let s = date(3, 23), e = date(4, 0, 1)
        #expect(SleepDayWindow.overlaps(start: s, end: e, dayStart: date(3, 0), dayEnd: date(4, 0)))
        #expect(SleepDayWindow.overlaps(start: s, end: e, dayStart: dayStart, dayEnd: dayEnd))
    }

    @Test func openEntryFromYesterdayOverlapsToday() {
        let now = date(4, 0, 30)
        #expect(SleepDayWindow.overlaps(start: date(3, 23), end: nil,
                                        dayStart: dayStart, dayEnd: dayEnd, now: now))
    }

    @Test func endedBeforeTodayDoesNotOverlap() {
        #expect(!SleepDayWindow.overlaps(start: date(3, 20), end: date(3, 22),
                                         dayStart: dayStart, dayEnd: dayEnd))
    }

    @Test func endExactlyAtDayStartDoesNotOverlap() {
        #expect(!SleepDayWindow.overlaps(start: date(3, 23), end: dayStart,
                                         dayStart: dayStart, dayEnd: dayEnd))
    }

    @Test func clippingSplitsNightSleepCorrectly() {
        let s = date(3, 23), e = date(4, 0, 1)   // 23:00 → 00:01
        #expect(SleepDayWindow.clippedMinutes(start: s, end: e, dayStart: date(3, 0), dayEnd: date(4, 0)) == 60)
        #expect(SleepDayWindow.clippedMinutes(start: s, end: e, dayStart: dayStart, dayEnd: dayEnd) == 1)
    }

    @Test func clippingFullyInsideDayEqualsDuration() {
        #expect(SleepDayWindow.clippedMinutes(start: date(4, 13), end: date(4, 14, 30),
                                              dayStart: dayStart, dayEnd: dayEnd) == 90)
    }

    @Test func clippingOutsideDayIsZero() {
        #expect(SleepDayWindow.clippedMinutes(start: date(3, 20), end: date(3, 22),
                                              dayStart: dayStart, dayEnd: dayEnd) == 0)
    }
}

@Suite struct SleepRepositoryOverlapTests {

    private final class StubRepo: SleepRepository {
        var stored: [SleepEntry] = []
        var lastFrom: Date?
        func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
            lastFrom = from
            return stored.filter { $0.startDate >= from && $0.startDate <= to }
        }
        func add(_ entry: SleepEntry) async throws {}
        func upsert(_ entries: [SleepEntry]) async throws {}
        func update(_ entry: SleepEntry) async throws {}
        func delete(id: UUID) async throws {}
    }

    private static let cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    private func date(_ d: Int, _ h: Int, _ m: Int = 0) -> Date {
        Self.cal.date(from: DateComponents(year: 2026, month: 7, day: d, hour: h, minute: m))!
    }

    @Test func overlappingFetchIncludesCrossMidnightAndOpenEntries() async throws {
        let repo = StubRepo()
        let crossing = SleepEntry(startDate: date(3, 23), endDate: date(4, 0, 1))
        let open     = SleepEntry(startDate: date(3, 22), endDate: nil)
        let old      = SleepEntry(startDate: date(3, 18), endDate: date(3, 19))
        let today    = SleepEntry(startDate: date(4, 13), endDate: date(4, 14))
        repo.stored = [crossing, open, old, today]

        let result = try await repo.getEntries(overlapping: date(4, 0), until: date(5, 0))
        let ids = Set(result.map(\.id))
        #expect(ids.contains(crossing.id))
        #expect(ids.contains(open.id))
        #expect(ids.contains(today.id))
        #expect(!ids.contains(old.id))
        #expect(repo.lastFrom == date(3, 0))   // 24h lookback applied
    }
}
```

If `SleepEntry.init` argument labels differ from `(startDate:endDate:)`, match the actual memberwise init (`note`, `quality` have defaults — verified).

---

## Definition of Done

- [ ] All targets build; `MockSleepRepository` / `BabyScopedSleepRepository` compile **without edits** (extension-based)
- [ ] `SleepDayWindowTests` and `SleepRepositoryOverlapTests` pass
- [ ] Existing `SleepViewModelTests` pass unchanged (or updated only where day-clipping legitimately changes expected totals)
- [ ] `loadTodayEntries`, `TodayViewModel`, chart, `totalSleepToday`, `logManualEntry` all use overlap/clipping — `grep -n "isDateInToday(saved.startDate)" Momsy/Features/Sleep/` → 0 hits
- [ ] Forecast engine untouched (it keys off last sleep end, not day buckets)
- [ ] Watch target verification: confirm `MomsyWatch` reads timer state only via `WidgetDataStore` (no day-window sleep queries of its own); if it has any, apply the same overlap fix

## Manual QA (simulator, change device time in Settings → General → Date & Time)

1. **Reported repro:** set clock 23:58 → start timer → wait past 00:01 → stop. Entry stays in today's list after leaving/reopening the screen; `totalSleepToday` shows only the after-midnight minutes; yesterday's chart bar gets the pre-midnight minutes. ✅
2. **Relaunch after midnight:** start 23:58 → cross midnight → kill app → relaunch. Timer restored and ticking, Live Activity consistent; stop works; entry saved. ✅
3. **Manual cross-midnight entry:** add manual sleep 23:00→00:30 — appears in today's list immediately, chart splits 60/30. ✅
4. **Regression:** ordinary daytime nap (13:00–14:30) — list, total, chart identical to before. ✅
5. **Co-parent sync:** stop after midnight → entry appears on second device with correct start/end (Firestore path uses full Dates, unaffected). ✅
6. **Chart period edge:** sleep that started the evening before the 7-day window start shows its in-window minutes on the first bar. ✅
