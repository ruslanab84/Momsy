# Deterministic Daily Tip Algorithm — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace AI/network-based daily tips with a fully offline, deterministic algorithm that evaluates WHO norms and today's context to produce a prioritized, age-personalised tip.

**Architecture:** Five-priority rule chain (alert → situational → care → development → default) evaluated in `DailyTipAlgorithm.evaluate(context:)` which always returns a non-nil `DailyTip`. `DailyContext` gains 8 new fields; the builder populates them synchronously from `logEntries`, with `daysSinceLastStool` injected by the ViewModel (requires async stool repo access). `TodayViewModel` calls the algorithm directly instead of `tipService.fetch()`; `DailyTipService` protocol and its implementations remain untouched.

**Tech Stack:** Swift 5.9, SwiftUI, SwiftData, Swift Testing (not XCTest). All new logic in `Momsy/Features/Today/Algorithm/`.

---

## Pre-flight

### Existing bug: `TodayViewModelTests` missing `stoolRepo` parameter

`TodayViewModel.init` requires `stoolRepo: any StoolRepository`, but the `makeVM()` helper in `TodayViewModelTests.swift` omits it. The test suite therefore does not compile. **This must be fixed in Task 1 before any other task can run tests.**

---

## File Map

| Action | Path |
|--------|------|
| **Modify** | `Momsy/Features/Today/Domain/Models/DailyTip.swift` |
| **Modify** | `Momsy/Features/Today/Domain/Models/DailyContext.swift` |
| **Create** | `Momsy/Features/Today/Algorithm/WhoNorms.swift` |
| **Create** | `Momsy/Features/Today/Algorithm/DailyTipAlgorithm.swift` |
| **Create** | `Momsy/Features/Today/Algorithm/DailyTipRules.swift` |
| **Modify** | `Momsy/Features/Today/Presentation/ViewModel/TodayViewModel.swift` |
| **Modify** | `Momsy/Features/Today/Presentation/Views/TodayView.swift` |
| **Create** | `MomsyTests/Mocks/MockStoolRepository.swift` |
| **Modify** | `MomsyTests/Features/Today/TodayViewModelTests.swift` |
| **Create** | `MomsyTests/Features/Today/DailyTipAlgorithmTests.swift` |

---

## Task 1: Fix compile bug — add MockStoolRepository

The test suite won't compile without this. Fix first.

**Files:**
- Create: `MomsyTests/Mocks/MockStoolRepository.swift`
- Modify: `MomsyTests/Features/Today/TodayViewModelTests.swift`

- [ ] **Step 1: Create MockStoolRepository**

```swift
// MomsyTests/Mocks/MockStoolRepository.swift
import Foundation
@testable import Momsy

final class MockStoolRepository: StoolRepository, @unchecked Sendable {
    var entries: [Date] = []
    var addedDates: [Date] = []

    func add(date: Date) async throws {
        addedDates.append(date)
        entries.append(date)
    }

    func getEntries(from: Date, to: Date) async throws -> [Date] {
        entries.filter { $0 >= from && $0 <= to }
    }
}
```

- [ ] **Step 2: Add stoolRepo to makeVM() in TodayViewModelTests**

In `MomsyTests/Features/Today/TodayViewModelTests.swift`, update the `makeVM()` function signature and body:

```swift
func makeVM(
    repo: MockFeedingRepository = MockFeedingRepository(),
    sleepRepo: MockSleepRepository = MockSleepRepository(),
    diaperRepo: MockDiaperRepository = MockDiaperRepository(),
    stoolRepo: MockStoolRepository = MockStoolRepository(),
    tipService: MockDailyTipService = MockDailyTipService(),
    tipRepository: DailyTipRepository? = nil
) -> TodayViewModel {
    let tipRepo = tipRepository ?? makeTipRepository()
    return TodayViewModel(
        getFeeding: GetFeedingEntriesUseCase(repository: repo),
        getSleep: GetSleepEntriesUseCase(repository: sleepRepo),
        diaperRepo: diaperRepo,
        stoolRepo: stoolRepo,
        quickLogRepo: QuickLogRepository(),
        tipService: tipService,
        tipRepository: tipRepo,
        appState: makeAppState()
    )
}
```

- [ ] **Step 3: Verify tests compile and pass**

```bash
cd /Users/ruslanabdulov/Desktop/Momsy
xcodebuild test -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```

Expected: build succeeds, all existing tests pass.

- [ ] **Step 4: Commit**

```bash
git add MomsyTests/Mocks/MockStoolRepository.swift MomsyTests/Features/Today/TodayViewModelTests.swift
git commit -m "fix(tests): add MockStoolRepository; fix TodayViewModelTests compile error"
```

---

## Task 2: Add TipCategory to DailyTip

**Files:**
- Modify: `Momsy/Features/Today/Domain/Models/DailyTip.swift`

- [ ] **Step 1: Write the failing test**

In `MomsyTests/Features/Today/DailyTipAlgorithmTests.swift` (create the file now, add just this one test):

```swift
// MomsyTests/Features/Today/DailyTipAlgorithmTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("DailyTipAlgorithm")
struct DailyTipAlgorithmTests {

    @Test("DailyTip has default category .defaultTip")
    func dailyTip_defaultCategory() {
        let tip = DailyTip(text: "hello", contextHash: "h")
        #expect(tip.category == .defaultTip)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -10
```

Expected: FAIL — `TipCategory` does not exist yet.

- [ ] **Step 3: Add TipCategory enum and update DailyTip**

Replace the full contents of `Momsy/Features/Today/Domain/Models/DailyTip.swift`:

```swift
import Foundation

enum TipCategory: String, Codable {
    case alert
    case situational
    case care
    case development
    case defaultTip
}

struct DailyTip: Codable {
    let text: String
    let generatedAt: Date
    let contextHash: String
    var isFromCache: Bool
    let category: TipCategory

    init(
        text: String,
        generatedAt: Date = Date(),
        contextHash: String,
        isFromCache: Bool = false,
        category: TipCategory = .defaultTip
    ) {
        self.text = text
        self.generatedAt = generatedAt
        self.contextHash = contextHash
        self.isFromCache = isFromCache
        self.category = category
    }

    var ageLabel: String {
        let mins = Int(-generatedAt.timeIntervalSinceNow / 60)
        if mins < 1  { return "только что" }
        if mins < 60 { return "\(mins) мин назад" }
        return "\(mins / 60) ч назад"
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -10
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Today/Domain/Models/DailyTip.swift \
        MomsyTests/Features/Today/DailyTipAlgorithmTests.swift
git commit -m "feat(tip): add TipCategory enum to DailyTip"
```

---

## Task 3: Extend DailyContext with algorithm fields

`DailyTipAlgorithm` needs 8 fields not currently in `DailyContext`. `DailyContextBuilder` computes 7 of them from `logEntries`; `daysSinceLastStool` is injected as a parameter (requires async repo access handled by the ViewModel).

**Files:**
- Modify: `Momsy/Features/Today/Domain/Models/DailyContext.swift`

- [ ] **Step 1: Write failing tests for new fields**

Add to `MomsyTests/Features/Today/DailyContextBuilderTests.swift` (append at the end, before the closing `}`):

```swift
    @Test("build sets walkCount from .walk entries")
    func build_countsWalkEntries() {
        let walk = LogEntry(time: Date(), kind: .walk, label: "Walk logged")
        let ctx = DailyContextBuilder.build(from: [walk], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.walkCount == 1)
    }

    @Test("build sets bathCount from .bath entries")
    func build_countsBathEntries() {
        let bath1 = LogEntry(time: Date(), kind: .bath, label: "Bath logged")
        let bath2 = LogEntry(time: Date().addingTimeInterval(-3600), kind: .bath, label: "Bath logged")
        let ctx = DailyContextBuilder.build(from: [bath1, bath2], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.bathCount == 2)
    }

    @Test("build sets dayOfYear to non-zero")
    func build_setsDayOfYear() {
        let ctx = DailyContextBuilder.build(from: [], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.dayOfYear > 0)
    }

    @Test("build passes daysSinceLastStool parameter")
    func build_setsDaysSinceLastStool() {
        let ctx = DailyContextBuilder.build(from: [], diaperCount: 0, daysSinceLastStool: 3, appState: makeTestAppState())
        #expect(ctx.daysSinceLastStool == 3)
    }

    @Test("build sets lastFeedDurationMinutes from most recent bottle label")
    func build_setsLastFeedDuration() {
        let entry = feedingEntry(minutesAgo: 10, durationMin: 18, side: "левая")
        let ctx = DailyContextBuilder.build(from: [entry], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.lastFeedDurationMinutes == 18)
    }

    @Test("build populates recentFeedSides from labels")
    func build_setsRecentFeedSides() {
        let e1 = feedingEntry(minutesAgo: 5, durationMin: 15, side: "левая")
        let e2 = feedingEntry(minutesAgo: 120, durationMin: 15, side: "правая")
        let ctx = DailyContextBuilder.build(from: [e1, e2], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.recentFeedSides.count == 2)
        #expect(ctx.recentFeedSides[0] == "левая")
    }
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyContextBuilderTests 2>&1 | tail -10
```

Expected: FAIL — new fields don't exist yet.

- [ ] **Step 3: Update DailyContext struct and DailyContextBuilder**

Replace the full contents of `Momsy/Features/Today/Domain/Models/DailyContext.swift`:

```swift
import Foundation

// MARK: - TimeOfDay

enum TimeOfDay: String {
    case morning, afternoon, evening, night

    static func current() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }

    func displayName(for lang: Language) -> String {
        switch lang {
        case .english:
            switch self {
            case .morning:   return "morning"
            case .afternoon: return "afternoon"
            case .evening:   return "evening"
            case .night:     return "night"
            }
        case .russian:
            switch self {
            case .morning:   return "утро"
            case .afternoon: return "день"
            case .evening:   return "вечер"
            case .night:     return "ночь"
            }
        case .german:
            switch self {
            case .morning:   return "Morgen"
            case .afternoon: return "Nachmittag"
            case .evening:   return "Abend"
            case .night:     return "Nacht"
            }
        }
    }
}

// MARK: - DailyContext

struct DailyContext {
    // Existing fields
    let babyName: String
    let ageMonths: Int
    let ageDays: Int
    let currentLeapName: String?
    let feedingCount: Int
    let totalFeedingMinutes: Int
    let minutesSinceLastFeed: Int?
    let lastFeedSide: String?
    let sleepCount: Int
    let totalSleepMinutes: Int
    let diaperCount: Int
    let timeOfDay: TimeOfDay
    let language: Language

    // New fields for deterministic algorithm
    let hour: Int                        // 0–23
    let minutesSinceLastSleepEnd: Int?   // nil=no sleep today, 0=currently sleeping
    let walkCount: Int
    let bathCount: Int
    let daysSinceLastStool: Int          // 0=today, 1=yesterday, …
    let dayOfYear: Int                   // 1–366 for tip rotation
    let lastFeedDurationMinutes: Int     // 0 if no feeding
    let recentFeedSides: [String]        // last ≤3 non-bottle sides (newest first)

    var contextHash: String {
        "\(language.rawValue)-\(feedingCount)-\(totalFeedingMinutes)-\(sleepCount)-\(totalSleepMinutes)-\(diaperCount)"
    }
}

// MARK: - DailyContextBuilder

enum DailyContextBuilder {

    static func build(
        from entries: [LogEntry],
        diaperCount: Int,
        daysSinceLastStool: Int = 0,
        appState: AppState
    ) -> DailyContext {
        let feedingEntries = entries.filter { $0.kind == .bottle }
        let sleepEntries   = entries.filter { $0.kind == .sleep }

        let feedingCount        = feedingEntries.count
        let totalFeedingMinutes = feedingEntries.reduce(0) { $0 + parseFeedingMinutes($1.label) }
        let minutesSinceLastFeed = feedingEntries.first.map {
            max(0, Int(-$0.time.timeIntervalSinceNow / 60))
        }
        let lastFeedSide = feedingEntries.first.flatMap { parseFeedSide($0.label) }

        let sleepCount        = sleepEntries.count
        let totalSleepMinutes = sleepEntries.reduce(0) { $0 + parseSleepMinutes($1.label) }

        let (ageMonths, ageDays) = babyAge(appState: appState)
        let currentLeapName = currentLeap(ageWeeks: ageWeeks(appState: appState))

        // New fields
        let hour = Calendar.current.component(.hour, from: Date())
        let walkCount = entries.filter { $0.kind == .walk }.count
        let bathCount = entries.filter { $0.kind == .bath }.count
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let lastFeedDurationMinutes = feedingEntries.first.map { parseFeedingMinutes($0.label) } ?? 0
        let recentFeedSides = feedingEntries.prefix(3).compactMap { parseFeedSide($0.label) }
            .filter { !$0.lowercased().contains("bottle") && !$0.contains("Бутылка") }
        let minutesSinceLastSleepEnd = computeMinutesSinceSleepEnd(from: sleepEntries)

        return DailyContext(
            babyName: appState.displayName,
            ageMonths: ageMonths,
            ageDays: ageDays,
            currentLeapName: currentLeapName,
            feedingCount: feedingCount,
            totalFeedingMinutes: totalFeedingMinutes,
            minutesSinceLastFeed: minutesSinceLastFeed,
            lastFeedSide: lastFeedSide,
            sleepCount: sleepCount,
            totalSleepMinutes: totalSleepMinutes,
            diaperCount: diaperCount,
            timeOfDay: .current(),
            language: LocalizationManager.shared.current,
            hour: hour,
            minutesSinceLastSleepEnd: minutesSinceLastSleepEnd,
            walkCount: walkCount,
            bathCount: bathCount,
            daysSinceLastStool: daysSinceLastStool,
            dayOfYear: dayOfYear,
            lastFeedDurationMinutes: lastFeedDurationMinutes,
            recentFeedSides: Array(recentFeedSides)
        )
    }

    // MARK: - Private helpers (existing)

    private static func parseFeedingMinutes(_ label: String) -> Int {
        let pattern = #"·\s*(\d+)\s*(?:min|мин)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)),
              let range = Range(match.range(at: 1), in: label) else { return 0 }
        return Int(label[range]) ?? 0
    }

    private static func parseFeedSide(_ label: String) -> String? {
        let parts = label.components(separatedBy: " · ")
        return parts.last.flatMap { $0.isEmpty ? nil : $0 }
    }

    private static func parseSleepMinutes(_ label: String) -> Int {
        if let enMatch = try? NSRegularExpression(pattern: #"(\d+)h(?:\s*(\d+)m)?"#),
           let m = enMatch.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)) {
            let hours   = m.range(at: 1).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 1))) ?? 0 : 0
            let minutes = m.range(at: 2).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 2))) ?? 0 : 0
            if hours > 0 || minutes > 0 { return hours * 60 + minutes }
        }
        if let ruMatch = try? NSRegularExpression(pattern: #"(\d+)\s*ч(?:\s*(\d+)\s*м)?"#),
           let m = ruMatch.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)) {
            let hours   = m.range(at: 1).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 1))) ?? 0 : 0
            let minutes = m.range(at: 2).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 2))) ?? 0 : 0
            return hours * 60 + minutes
        }
        return 0
    }

    // MARK: - New helper

    private static func computeMinutesSinceSleepEnd(from sleepEntries: [LogEntry]) -> Int? {
        guard let latest = sleepEntries.first else { return nil }
        let durationMinutes = parseSleepMinutes(latest.label)
        if durationMinutes == 0 { return 0 } // currently sleeping
        let endTime = latest.time.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return max(0, Int(-endTime.timeIntervalSinceNow / 60))
    }

    // MARK: - Age helpers (existing)

    private static func babyAge(appState: AppState) -> (months: Int, days: Int) {
        guard let birth = appState.babyProfile?.birthDate else { return (0, 0) }
        let comps = Calendar.current.dateComponents([.month, .day], from: birth, to: Date())
        return (max(0, comps.month ?? 0), max(0, comps.day ?? 0))
    }

    private static func ageWeeks(appState: AppState) -> Int {
        guard let birth = appState.babyProfile?.birthDate else { return 0 }
        let comps = Calendar.current.dateComponents([.weekOfYear], from: birth, to: Date())
        return max(0, comps.weekOfYear ?? 0)
    }

    private static func currentLeap(ageWeeks weeks: Int) -> String? {
        let catalog = DevelopmentLeap.catalog
        let lang = LocalizationManager.shared.lang
        let leap = catalog.first(where: { !$0.isDone && $0.week <= weeks + 4 })
            ?? catalog.last(where: { $0.week <= weeks })
        guard let leap else { return nil }
        return lang == "en" ? leap.nameEn : leap.name
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyContextBuilderTests 2>&1 | tail -10
```

Expected: all DailyContextBuilderTests PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Today/Domain/Models/DailyContext.swift \
        MomsyTests/Features/Today/DailyContextBuilderTests.swift
git commit -m "feat(context): add algorithm fields to DailyContext and DailyContextBuilder"
```

---

## Task 4: Create WhoNorms.swift

**Files:**
- Create: `Momsy/Features/Today/Algorithm/WhoNorms.swift`

- [ ] **Step 1: Write failing tests**

Add to `MomsyTests/Features/Today/DailyTipAlgorithmTests.swift` (in the `@Suite` block):

```swift
    // MARK: - WhoNorms

    @Test("maxFeedingInterval for 0m is 180")
    func whoNorms_feedingInterval_newborn() {
        #expect(WhoNorms.maxFeedingInterval(ageMonths: 0) == 180)
    }

    @Test("maxFeedingInterval for 6m is 270")
    func whoNorms_feedingInterval_6m() {
        #expect(WhoNorms.maxFeedingInterval(ageMonths: 6) == 270)
    }

    @Test("minSleepMinutes for 0m is 840")
    func whoNorms_minSleep_newborn() {
        #expect(WhoNorms.minSleepMinutes(ageMonths: 0) == 840)
    }

    @Test("maxDaysWithoutStool for 1m is 3")
    func whoNorms_stool_1m() {
        #expect(WhoNorms.maxDaysWithoutStool(ageMonths: 1) == 3)
    }

    @Test("awakeWindowMax for 4m is 110")
    func whoNorms_awakeWindow_4m() {
        #expect(WhoNorms.awakeWindowMax(ageMonths: 4) == 110)
    }
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -10
```

Expected: FAIL — `WhoNorms` type does not exist.

- [ ] **Step 3: Create WhoNorms.swift**

```swift
// Momsy/Features/Today/Algorithm/WhoNorms.swift
import Foundation

enum WhoNorms {

    /// Maximum feeding interval in minutes before alert triggers.
    static func maxFeedingInterval(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...1: return 180
        case 2:     return 210
        case 3...4: return 240
        case 5...6: return 270
        case 7...12: return 300
        default:    return 360
        }
    }

    /// Minimum total sleep per day in minutes (alert threshold is this minus 90).
    static func minSleepMinutes(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...1: return 840   // 14 h
        case 2...3: return 810   // 13.5 h
        case 4...5: return 780   // 13 h
        case 6...8: return 720   // 12 h
        case 9...12: return 700  // ~11.7 h
        default:    return 660   // 11 h
        }
    }

    /// Max consecutive days without stool before alert triggers.
    static func maxDaysWithoutStool(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...2: return 3
        case 3...6: return 4
        default:    return 5
        }
    }

    /// Maximum awake window in minutes before overtiredness tip triggers.
    static func awakeWindowMax(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0:      return 45
        case 1:      return 60
        case 2:      return 75
        case 3:      return 90
        case 4...5:  return 110
        case 6...7:  return 130
        case 8...9:  return 150
        case 10...12: return 180
        case 13...18: return 240
        default:     return 300
        }
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -10
```

Expected: all WhoNorms tests PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Today/Algorithm/WhoNorms.swift \
        MomsyTests/Features/Today/DailyTipAlgorithmTests.swift
git commit -m "feat(who-norms): add WhoNorms lookup functions"
```

---

## Task 5: Create DailyTipRules.swift (all 5 priorities)

This is the largest file. It contains `AlertRules`, `SituationalRules`, `CareRules`, `DevelopmentRules`, and `DefaultTips` — all as top-level enums returning `DailyTip?`.

**Files:**
- Create: `Momsy/Features/Today/Algorithm/DailyTipRules.swift`

- [ ] **Step 1: Write failing tests for key rules**

Add to `MomsyTests/Features/Today/DailyTipAlgorithmTests.swift`:

```swift
    // MARK: - Alert Rules

    @Test("Alert A fires when minutesSinceLastFeed exceeds maxInterval")
    func alertA_longFeedGap() {
        let ctx = makeContext(ageMonths: 2, minutesSinceLastFeed: 220, hour: 14)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
        #expect(result?.text.contains("220") == false || result?.text.isEmpty == false)
    }

    @Test("Alert A does not fire when feed was recent")
    func alertA_recentFeed_noAlert() {
        let ctx = makeContext(ageMonths: 2, minutesSinceLastFeed: 60, hour: 14)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    @Test("Alert B fires when diaperCount < 4 in evening for age <= 6")
    func alertB_fewDiapers() {
        let ctx = makeContext(ageMonths: 3, diaperCount: 2, hour: 19)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
    }

    @Test("Alert B does not fire for older baby")
    func alertB_olderBaby_noAlert() {
        let ctx = makeContext(ageMonths: 9, diaperCount: 2, hour: 19)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    @Test("Alert C fires when daysSinceLastStool >= alertDays")
    func alertC_noStool() {
        let ctx = makeContext(ageMonths: 4, daysSinceLastStool: 4, hour: 12)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
    }

    @Test("Alert D fires when totalSleepMinutes is critically low in evening")
    func alertD_sleepDeficit() {
        let ctx = makeContext(ageMonths: 4, totalSleepMinutes: 580, hour: 20)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
    }

    // MARK: - Situational Rules

    @Test("SITU C fires when awake too long")
    func situC_longAwake() {
        let ctx = makeContext(ageMonths: 3, minutesSinceLastSleepEnd: 120, hour: 10)
        let result = SituationalRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .situational)
    }

    @Test("SITU D fires in evening without bath for baby >= 1m")
    func situD_noBath() {
        let ctx = makeContext(ageMonths: 4, bathCount: 0, hour: 19)
        let result = SituationalRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .situational)
    }

    @Test("SITU D does not fire in morning")
    func situD_noBath_morning_noAlert() {
        let ctx = makeContext(ageMonths: 4, bathCount: 0, hour: 9)
        let result = SituationalRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    // Helper — builds a minimal context for tests
    private func makeContext(
        ageMonths: Int = 3,
        minutesSinceLastFeed: Int? = nil,
        diaperCount: Int = 7,
        totalSleepMinutes: Int = 750,
        minutesSinceLastSleepEnd: Int? = nil,
        walkCount: Int = 1,
        bathCount: Int = 0,
        daysSinceLastStool: Int = 0,
        hour: Int = 10,
        language: Language = .russian
    ) -> DailyContext {
        DailyContext(
            babyName: "Лёва",
            ageMonths: ageMonths,
            ageDays: 15,
            currentLeapName: nil,
            feedingCount: 6,
            totalFeedingMinutes: 90,
            minutesSinceLastFeed: minutesSinceLastFeed,
            lastFeedSide: nil,
            sleepCount: 3,
            totalSleepMinutes: totalSleepMinutes,
            diaperCount: diaperCount,
            timeOfDay: .morning,
            language: language,
            hour: hour,
            minutesSinceLastSleepEnd: minutesSinceLastSleepEnd,
            walkCount: walkCount,
            bathCount: bathCount,
            daysSinceLastStool: daysSinceLastStool,
            dayOfYear: 148,
            lastFeedDurationMinutes: 15,
            recentFeedSides: []
        )
    }
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -10
```

Expected: FAIL — `AlertRules`, `SituationalRules` not found.

- [ ] **Step 3: Create DailyTipRules.swift**

```swift
// Momsy/Features/Today/Algorithm/DailyTipRules.swift
import Foundation

// MARK: - PRIORITY 1: Alert Rules

enum AlertRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        checkFeedingInterval(context)
        ?? checkDiaperCount(context)
        ?? checkStool(context)
        ?? checkSleepDeficit(context)
    }

    // Alert A: too long since last feed
    private static func checkFeedingInterval(_ ctx: DailyContext) -> DailyTip? {
        guard let mins = ctx.minutesSinceLastFeed else { return nil }
        let maxInt = WhoNorms.maxFeedingInterval(ageMonths: ctx.ageMonths)
        guard mins > maxInt else { return nil }
        let hours = mins / 60
        let maxHours = maxInt / 60
        let text: String
        switch ctx.language {
        case .russian:
            text = "Прошло уже \(hours) ч с кормления. Для \(ctx.ageMonths) мес обычный интервал до \(maxHours) ч — если \(ctx.babyName) не просит сам, попробуйте предложить грудь."
        case .english:
            text = "It's been \(hours) hours since the last feed. For \(ctx.ageMonths) months, the usual interval is up to \(maxHours) h — if \(ctx.babyName) hasn't asked, try offering."
        case .german:
            text = "Es sind bereits \(hours) Stunden seit der letzten Mahlzeit vergangen. Für \(ctx.ageMonths) Monate ist das Intervall normalerweise bis zu \(maxHours) h — biete \(ctx.babyName) die Brust an."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }

    // Alert B: too few wet diapers
    private static func checkDiaperCount(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.diaperCount < 4, ctx.hour >= 18, ctx.ageMonths <= 6 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Сегодня пока \(ctx.diaperCount) подгузника — для \(ctx.ageMonths) мес норма 6–8 в день. Это сигнал о недостаточном питье. Предложите грудь или смесь чаще обычного."
        case .english:
            text = "Only \(ctx.diaperCount) wet diapers so far today — for \(ctx.ageMonths) months the norm is 6–8 per day. This signals insufficient fluid. Offer the breast or formula more often."
        case .german:
            text = "Heute bisher nur \(ctx.diaperCount) Windeln — für \(ctx.ageMonths) Monate sind 6–8 pro Tag normal. Das ist ein Zeichen für zu wenig Trinken. Biete öfter Brust oder Fläschchen an."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }

    // Alert C: no stool for too many days
    private static func checkStool(_ ctx: DailyContext) -> DailyTip? {
        let alertDays = WhoNorms.maxDaysWithoutStool(ageMonths: ctx.ageMonths)
        guard ctx.daysSinceLastStool >= alertDays else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Стула не было \(ctx.daysSinceLastStool) дн. Попробуйте «велосипед»: положите \(ctx.babyName) на спину и аккуратно сгибайте ножки к животику 10–15 раз."
        case .english:
            text = "No stool for \(ctx.daysSinceLastStool) days. Try the «bicycle» exercise: lay \(ctx.babyName) on their back and gently cycle their legs toward the tummy 10–15 times."
        case .german:
            text = "Seit \(ctx.daysSinceLastStool) Tagen kein Stuhl. Versuche die «Fahrrad»-Übung: Lege \(ctx.babyName) auf den Rücken und beuge die Beinchen sanft zum Bauch, 10–15 Mal."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }

    // Alert D: critical sleep deficit (evening only)
    private static func checkSleepDeficit(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.hour >= 19 else { return nil }
        let minSleep = WhoNorms.minSleepMinutes(ageMonths: ctx.ageMonths)
        let threshold = minSleep - 90
        guard ctx.totalSleepMinutes < threshold else { return nil }
        let sleptH = ctx.totalSleepMinutes / 60
        let deficit = (minSleep - ctx.totalSleepMinutes + 59) / 60
        let text: String
        switch ctx.language {
        case .russian:
            text = "Сегодня \(ctx.babyName) спал всего \(sleptH) ч — это на \(deficit) ч меньше нормы. Постарайтесь уложить пораньше — к 19:30–20:00."
        case .english:
            text = "\(ctx.babyName) has only slept \(sleptH) h today — \(deficit) h less than the norm. Try an earlier bedtime — around 19:30–20:00."
        case .german:
            text = "\(ctx.babyName) hat heute nur \(sleptH) Std. geschlafen — \(deficit) Std. weniger als normal. Versuche, früher ins Bett zu gehen — gegen 19:30–20:00."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }
}

// MARK: - PRIORITY 2: Situational Rules

enum SituationalRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        checkJustFed(context)
        ?? checkLongAwake(context)
        ?? checkBathEvening(context)
        ?? checkFirstMorningSleep(context)
        ?? checkBreastSide(context)
        ?? checkNoWalk(context)
    }

    // SITU A: just finished feeding (< 10 min ago, >= 5 min duration)
    private static func checkJustFed(_ ctx: DailyContext) -> DailyTip? {
        guard let minsAgo = ctx.minutesSinceLastFeed,
              minsAgo <= 10,
              ctx.lastFeedDurationMinutes >= 5 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "После кормления подержите \(ctx.babyName) столбиком 10–15 мин — это помогает выйти воздуху и предотвращает срыгивание. Прижмите вертикально к плечу и слегка похлопайте по спинке."
        case .english:
            text = "Hold \(ctx.babyName) upright for 10–15 min after feeding — this helps air escape and prevents spit-up. Press them vertically against your shoulder and gently pat the back."
        case .german:
            text = "Halte \(ctx.babyName) nach dem Stillen 10–15 Min. aufrecht — das hilft, die Luft herauszulassen und verhindert Spucken. Drücke das Baby senkrecht an deine Schulter und klopfe sanft auf den Rücken."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU C: awake too long
    private static func checkLongAwake(_ ctx: DailyContext) -> DailyTip? {
        guard let awakeMins = ctx.minutesSinceLastSleepEnd, awakeMins > 0 else { return nil }
        let awakeMax = WhoNorms.awakeWindowMax(ageMonths: ctx.ageMonths)
        guard awakeMins > awakeMax else { return nil }
        let overshoot = awakeMins - awakeMax
        let text: String
        if overshoot < 30 {
            switch ctx.language {
            case .russian:
                text = "\(ctx.babyName) уже \(awakeMins) мин бодрствует — пора укладывать. Зевота, потирание глаз, взгляд «в никуда» — не пропустите окно засыпания."
            case .english:
                text = "\(ctx.babyName) has been awake for \(awakeMins) min — time to settle down. Watch for yawning, eye-rubbing, or a glazed stare — don't miss the sleep window."
            case .german:
                text = "\(ctx.babyName) ist seit \(awakeMins) Min. wach — es ist Zeit zum Einschlafen. Achte auf Gähnen, Augenreiben oder einen leeren Blick — verpasse das Einschlafffenster nicht."
            }
        } else {
            switch ctx.language {
            case .russian:
                text = "Окно засыпания уже пропущено — \(ctx.babyName) бодрствует \(awakeMins) мин. Переутомление затрудняет засыпание. Приглушите свет, уберите игрушки, начните ритуал сейчас."
            case .english:
                text = "The sleep window has passed — \(ctx.babyName) has been awake \(awakeMins) min. Overtiredness makes sleep harder. Dim the lights, put toys away, and start the bedtime routine now."
            case .german:
                text = "Das Einschlafffenster ist verpasst — \(ctx.babyName) ist seit \(awakeMins) Min. wach. Übermüdung erschwert das Einschlafen. Licht dämpfen, Spielzeug wegräumen, Routine jetzt beginnen."
            }
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU D: evening bath not done yet
    private static func checkBathEvening(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.hour >= 18, ctx.hour <= 21,
              ctx.bathCount == 0,
              ctx.ageMonths >= 1 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Вечернее купание — мощный ритуал сна. Температура воды 36–37°C, длительность 5–10 мин. После купания кожа охлаждается и мелатонин вырабатывается быстрее."
        case .english:
            text = "Evening bath is a powerful sleep ritual. Water temperature 36–37°C, duration 5–10 min. After bathing, the skin cools and melatonin is produced faster."
        case .german:
            text = "Das Abendbad ist ein starkes Einschlafritual. Wassertemperatur 36–37°C, Dauer 5–10 Min. Nach dem Bad kühlt die Haut ab und Melatonin wird schneller produziert."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU E: first morning nap window
    private static func checkFirstMorningSleep(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.hour >= 7, ctx.hour <= 10,
              ctx.sleepCount == 0 else { return nil }
        let awakeMax = WhoNorms.awakeWindowMax(ageMonths: ctx.ageMonths)
        guard let awakeMins = ctx.minutesSinceLastSleepEnd,
              awakeMins > Int(Double(awakeMax) * 0.7) else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Первый утренний сон — самый важный для \(ctx.babyName). Для \(ctx.ageMonths) мес он должен начинаться примерно через \(awakeMax) мин после пробуждения. Следите за первыми зевками."
        case .english:
            text = "The first morning nap is the most important for \(ctx.babyName). For \(ctx.ageMonths) months it should start about \(awakeMax) min after waking up. Watch for the first yawns."
        case .german:
            text = "Der erste Morgenschlaf ist für \(ctx.babyName) der wichtigste. Mit \(ctx.ageMonths) Monaten sollte er etwa \(awakeMax) Min. nach dem Aufwachen beginnen. Achte auf die ersten Gähnzeichen."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU F: repeatedly feeding from same side
    private static func checkBreastSide(_ ctx: DailyContext) -> DailyTip? {
        let sides = ctx.recentFeedSides
        guard sides.count >= 3 else { return nil }
        let prefix3 = Array(sides.prefix(3))
        guard Set(prefix3).count == 1 else { return nil } // all same side
        let side = prefix3[0]
        let isLeft = side.contains("лев") || side.lowercased().contains("left") || side.lowercased().contains("links")
        let text: String
        switch ctx.language {
        case .russian:
            let other = isLeft ? "правую" : "левую"
            text = "Последние 3 кормления с одной стороны. Предложите \(other) грудь — равномерная нагрузка поддерживает лактацию и предотвращает застой."
        case .english:
            let other = isLeft ? "right" : "left"
            text = "The last 3 feeds were from the same side. Try the \(other) breast — balanced feeding supports lactation and prevents engorgement."
        case .german:
            let other = isLeft ? "rechte" : "linke"
            text = "Die letzten 3 Stillmahlzeiten waren auf der gleichen Seite. Biete die \(other) Brust an — gleichmäßiges Stillen unterstützt die Laktation und verhindert Stauungen."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU G: no walk during daytime
    private static func checkNoWalk(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.walkCount == 0,
              ctx.hour >= 10, ctx.hour <= 16,
              ctx.ageMonths >= 1 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Прогулка на свежем воздухе регулирует циркадные ритмы \(ctx.babyName). Дневной свет снижает выработку мелатонина и улучшает ночной сон. Даже 20–30 минут на улице дают эффект."
        case .english:
            text = "Fresh air walks regulate \(ctx.babyName)'s circadian rhythm. Daylight suppresses melatonin and improves night sleep. Even 20–30 minutes outside makes a difference."
        case .german:
            text = "Spaziergänge an der frischen Luft regulieren den Tagesrhythmus von \(ctx.babyName). Tageslicht unterdrückt Melatonin und verbessert den Nachtschlaf. Schon 20–30 Minuten draußen helfen."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }
}

// MARK: - PRIORITY 3: Care Rules (always returns a tip)

enum CareRules {

    static func evaluate(context: DailyContext) -> DailyTip {
        let pool = carePool(ageMonths: context.ageMonths, language: context.language)
        let idx = context.dayOfYear % pool.count
        let text = pool[idx].replacingOccurrences(of: "[name]", with: context.babyName)
        return DailyTip(text: text, contextHash: context.contextHash, category: .care)
    }

    private static func carePool(ageMonths age: Int, language lang: Language) -> [String] {
        switch age {
        case 0:      return newbornPool(lang)
        case 1...2:  return pool1_2m(lang)
        case 3...5:  return pool3_5m(lang)
        case 6...8:  return pool6_8m(lang)
        case 9...11: return pool9_11m(lang)
        case 12...17: return pool12_17m(lang)
        default:     return pool18_24m(lang)
        }
    }

    // MARK: Pools

    private static func newbornPool(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Пупочная ранка заживает 10–14 дней. Обрабатывайте хлоргексидином 1–2 раза в день после купания, держите сухой.",
            "Новорождённый слышит голос мамы с рождения — разговаривайте спокойным голосом, это формирует нейронные связи.",
            "Время на животике — 2–3 раза в день по 1–2 мин, только пока [name] бодрствует. Укрепляет шею и готовит к перевороту.",
            "Пеленание помогает некоторым новорождённым спать дольше — руки вдоль тела, бёдра свободно, не туго.",
            "Контакт кожа-к-коже 1–2 часа в день стабилизирует температуру, дыхание и сердцебиение [name]."
        ]
        case .english: return [
            "The umbilical wound heals in 10–14 days. Clean with chlorhexidine 1–2 times a day after bathing and keep it dry.",
            "Newborns recognise mum's voice from birth — talking in a calm tone builds neural connections.",
            "Tummy time 2–3 times a day for 1–2 min while [name] is awake strengthens the neck and prepares for rolling.",
            "Swaddling helps some newborns sleep longer — arms along the body, hips free, not too tight.",
            "Skin-to-skin contact for 1–2 hours a day stabilises [name]'s temperature, breathing, and heart rate."
        ]
        case .german: return [
            "Die Nabelwunde heilt in 10–14 Tagen. Reinige sie 1–2-mal täglich nach dem Bad mit Chlorhexidin und halte sie trocken.",
            "Neugeborene erkennen die Stimme der Mutter von Geburt an — ruhiges Sprechen baut neuronale Verbindungen auf.",
            "Bauchlage 2–3-mal täglich für 1–2 Min., nur wenn [name] wach ist, stärkt den Nacken und bereitet auf das Drehen vor.",
            "Pucken kann manchen Neugeborenen helfen, länger zu schlafen — Arme am Körper, Hüften frei, nicht zu fest.",
            "Hautkontakt 1–2 Stunden täglich stabilisiert die Temperatur, Atmung und den Herzrhythmus von [name]."
        ]
        }
    }

    private static func pool1_2m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Газики — норма. Лёгкий массаж животика по часовой стрелке и поза «тигр на ветке» (животиком на руке) помогают.",
            "Для стула попробуйте упражнение «велосипед»: аккуратно вращайте ножки в воздухе 10–15 раз.",
            "Сосательный рефлекс самый сильный сейчас. Пустышка между кормлениями — помощь в самоуспокоении.",
            "Колики чаще всего достигают пика в 6 нед. Белый шум, покачивание и поза на животе хорошо помогают.",
            "Чёрно-белые книжки и карточки — идеальная игрушка для [name]. Контраст стимулирует зрительную кору."
        ]
        case .english: return [
            "Gas is normal. A gentle clockwise tummy massage and the «tiger-on-the-branch» position (tummy on arm) help.",
            "For bowel movements try the bicycle exercise: gently pedal [name]'s legs in the air 10–15 times.",
            "The sucking reflex is at its peak now. A pacifier between feeds supports self-soothing.",
            "Colic typically peaks around 6 weeks. White noise, rocking, and the tummy-down position work well.",
            "Black-and-white books and cards are the perfect toy for [name] — contrast strongly stimulates the visual cortex."
        ]
        case .german: return [
            "Blähungen sind normal. Eine sanfte Bauchmassage im Uhrzeigersinn und die «Tiger-auf-dem-Ast»-Haltung helfen.",
            "Für den Stuhlgang: Fahrradbewegungen — die Beinchen von [name] sanft 10–15-mal in der Luft kreisen.",
            "Der Saugreflex ist jetzt am stärksten. Ein Schnuller zwischen den Mahlzeiten unterstützt die Selbstberuhigung.",
            "Koliken erreichen häufig in der 6. Woche ihren Höhepunkt. Weißes Rauschen, Schaukeln und Bauchlage helfen gut.",
            "Schwarz-weiße Bücher und Karten sind das ideale Spielzeug für [name] — Kontrast regt die Sehrinde stark an."
        ]
        }
    }

    private static func pool3_5m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Чёрно-белые карточки и книжки стимулируют зрительную кору. 10–15 минут разглядывания картинок — отличная тренировка.",
            "Массаж всего тела 5–10 мин перед купанием улучшает сон [name]. Движения от центра к конечностям.",
            "Время на животике — до 30 мин в день суммарно. Подкладывайте валик под грудь — это облегчает удержание головы.",
            "Прорезыватели скоро понадобятся — охладите силиконовый в холодильнике (не в морозилке). Первые зубки у многих в 4–7 мес.",
            "Погремушки и хватательные игрушки тренируют моторику. Меняйте руку при подаче игрушки — обе стороны должны работать.",
            "Для развития концентрации покажите [name] собственное отражение в зеркале — в этом возрасте это вызывает живой интерес."
        ]
        case .english: return [
            "Black-and-white cards and books stimulate the visual cortex. 10–15 minutes of looking at pictures is excellent training.",
            "A 5–10 min full-body massage before the bath improves [name]'s sleep. Move from the centre out to the limbs.",
            "Tummy time up to 30 min per day in total. Roll a towel under the chest — it makes holding the head up easier.",
            "Teethers will soon be needed — chill a silicone one in the fridge (not freezer). First teeth often appear at 4–7 months.",
            "Rattles and grasping toys train motor skills. Alternate the hand you offer toys to — both sides need practice.",
            "Show [name] their reflection in a mirror for focus development — at this age it sparks immediate interest."
        ]
        case .german: return [
            "Schwarz-weiße Karten und Bücher stimulieren die Sehrinde. 10–15 Minuten Bilderbetrachten ist ein ausgezeichnetes Training.",
            "Eine 5–10-minütige Ganzkörpermassage vor dem Bad verbessert den Schlaf von [name]. Bewegungen vom Zentrum zu den Gliedmaßen.",
            "Bauchlage bis zu 30 Min. täglich. Rolle ein Handtuch unter die Brust — das erleichtert das Kopfheben.",
            "Beißringe werden bald gebraucht — kühle einen Silikon-Ring im Kühlschrank (nicht Gefrierfach). Erste Zähne oft mit 4–7 Mon.",
            "Rasseln und Greifspielzeug trainieren die Motorik. Wechsle die Hand beim Anbieten von Spielzeug — beide Seiten brauchen Übung.",
            "Zeige [name] sein Spiegelbild — in diesem Alter weckt das sofort Interesse und fördert die Konzentration."
        ]
        }
    }

    private static func pool6_8m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Прикорм вводите постепенно: одно новое блюдо раз в 3 дня, маленькими порциями. Овощи лучше фруктов в начале.",
            "Стимулируйте ползание: положите игрушку чуть дальше досягаемости [name]. Ползание развивает оба полушария одновременно.",
            "Речевое развитие: называйте всё что делаете вслух. «Сейчас едим», «берём ложку» — словарный запас формируется с 6 мес.",
            "Пинцетный захват (большой + указательный) формируется в 8–9 мес. Предлагайте маленькие мягкие кусочки еды для тренировки.",
            "Игра в «ку-ку» — не просто веселье. Она учит [name] концепции постоянства объектов: «мама уходит и возвращается»."
        ]
        case .english: return [
            "Introduce solids gradually: one new food every 3 days in small portions. Vegetables before fruit is a good starting order.",
            "Encourage crawling: place a toy just out of [name]'s reach. Crawling develops both hemispheres simultaneously.",
            "Speech development: narrate everything you do. «We're eating now», «picking up the spoon» — vocabulary builds from 6 months.",
            "The pincer grasp (thumb + index) develops at 8–9 months. Offer small, soft pieces of food for practice.",
            "Peek-a-boo is more than fun. It teaches [name] object permanence: «mummy leaves and comes back»."
        ]
        case .german: return [
            "Beikost schrittweise einführen: alle 3 Tage ein neues Lebensmittel in kleinen Mengen. Gemüse vor Obst ist ein guter Start.",
            "Kriechen anregen: lege ein Spielzeug knapp außer Reichweite von [name]. Krabbeln entwickelt beide Gehirnhälften gleichzeitig.",
            "Sprachentwicklung: kommentiere alles laut. «Jetzt essen wir», «nehmen den Löffel» — der Wortschatz baut sich ab 6 Mon. auf.",
            "Der Pinzettengriff (Daumen + Zeigefinger) entwickelt sich mit 8–9 Mon. Biete kleine, weiche Bissen zum Üben an.",
            "Kuckuckspiele sind mehr als Spaß. Sie lehren [name] Objektpermanenz: «Mama geht weg und kommt zurück»."
        ]
        }
    }

    private static func pool9_11m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Первые шаги начинаются с хождения вдоль опоры. Не держите [name] за руки постоянно — нужен баланс самостоятельности.",
            "Речь: понимание слов опережает произношение. В 9–10 мес понимает «нет», «дай», «иди». Говорите медленно и чётко.",
            "Ночные пробуждения в 9–10 мес — нормальный регресс сна. Это связано с новыми двигательными навыками. Пройдёт за 2–4 нед.",
            "Стаканчик с носиком — хорошее время вводить. В 12 мес ВОЗ рекомендует отказаться от ночного кормления при нормальном весе.",
            "Сортеры, стаканчики, коробки с крышками — лучшие игрушки для [name]. Концепция «внутри/снаружи» активно формируется."
        ]
        case .english: return [
            "First steps begin with cruising along furniture. Don't always hold [name]'s hands — independent balance needs practice.",
            "Speech: comprehension precedes production. At 9–10 months [name] understands «no», «give», «come». Speak slowly and clearly.",
            "Night wakings at 9–10 months are a normal sleep regression linked to new motor skills. It passes in 2–4 weeks.",
            "A sippy cup is a good time to introduce. By 12 months the WHO recommends dropping night feeds at normal weight.",
            "Sorters, stacking cups, boxes with lids — the best toys for [name] right now. The «inside/outside» concept is forming."
        ]
        case .german: return [
            "Erste Schritte beginnen mit Laufen entlang von Möbeln. Halte [name] nicht immer an den Händen — Balance braucht Eigenständigkeit.",
            "Sprache: Verstehen geht dem Sprechen voraus. Mit 9–10 Mon. versteht [name] «nein», «gib», «komm». Langsam und deutlich sprechen.",
            "Nächtliches Aufwachen mit 9–10 Mon. ist eine normale Schlafregression durch neue Motorikfortschritte. Dauert 2–4 Wochen.",
            "Ein Schnabelbecher eignet sich jetzt gut. Ab 12 Mon. empfiehlt die WHO, bei normalem Gewicht auf Nachtmahlzeiten zu verzichten.",
            "Sortierer, Stapelbecher, Dosen mit Deckel — die besten Spielzeuge für [name]. Das Konzept «innen/außen» entwickelt sich gerade."
        ]
        }
    }

    private static func pool12_17m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Кризис 1 года — нормальное явление. Истерики от бессилия, а не манипуляция. Спокойная реакция родителя — лучший ответ.",
            "Словарный запас: 12 мес — 1–3 слова, 18 мес — 10–50 слов. Если к 18 мес нет 10 слов — консультация логопеда.",
            "Один дневной сон — переход обычно в 15–18 мес. Не торопите: ранний переход ведёт к перевозбуждению и плохому ночному сну.",
            "Рисование пальцами, лепка из теста развивают мелкую моторику и речь одновременно. 10 мин в день достаточно."
        ]
        case .english: return [
            "The one-year crisis is normal. Tantrums come from frustration, not manipulation. A calm parental response is the best reply.",
            "Vocabulary: 1–3 words at 12 months, 10–50 words at 18 months. Fewer than 10 words by 18 months: consult a speech therapist.",
            "The transition to one nap usually happens at 15–18 months. Don't rush it — early transition leads to over-stimulation and poor night sleep.",
            "Finger painting and dough modelling develop fine motor skills and speech at the same time. Ten minutes a day is enough."
        ]
        case .german: return [
            "Die Einjahres-Krise ist normal. Wutausbrüche kommen aus Hilflosigkeit, nicht aus Manipulation. Ruhige elterliche Reaktion ist die beste Antwort.",
            "Wortschatz: 1–3 Wörter mit 12 Mon., 10–50 Wörter mit 18 Mon. Weniger als 10 Wörter mit 18 Mon.: Logopäden konsultieren.",
            "Der Übergang zu einem Mittagsschlaf erfolgt meist mit 15–18 Mon. Nicht überstürzen — zu früher Übergang führt zu Überreizung.",
            "Malen mit Fingern und Kneten mit Teig entwickeln Feinmotorik und Sprache gleichzeitig. Zehn Minuten täglich genügen."
        ]
        }
    }

    private static func pool18_24m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Параллельная игра (рядом, но не вместе) — норма для этого возраста [name]. Социальная игра с ровесниками придёт позже, к 3 годам.",
            "2-словные фразы к 2 годам — ориентир развития речи. «Мама, дай», «хочу пить» — хороший знак. Нет фраз — к логопеду.",
            "Готовность к горшку появляется в 18–24 мес. Признаки: сухой подгузник 2 ч подряд, [name] указывает на горшок."
        ]
        case .english: return [
            "Parallel play (near but not together) is normal at [name]'s age. Social play with peers develops later, around 3 years.",
            "Two-word phrases by age 2 are a speech milestone. «Mummy, give», «want drink» are good signs. No phrases: see a speech therapist.",
            "Potty readiness appears at 18–24 months. Signs: dry nappy for 2 h in a row, [name] points to the potty."
        ]
        case .german: return [
            "Parallelspiel (nebeneinander, aber nicht miteinander) ist in [name]s Alter normal. Soziales Spiel mit Gleichaltrigen kommt später, um das 3. Jahr.",
            "Zweiwortsätze bis zum 2. Geburtstag sind ein Sprachmeilenstein. «Mama, gib», «will trinken» sind gute Zeichen. Keine Sätze: Logopäden aufsuchen.",
            "Die Töpfchenbereitschaft zeigt sich mit 18–24 Mon. Zeichen: trockene Windel 2 Std. am Stück, [name] zeigt auf den Topf."
        ]
        }
    }
}

// MARK: - PRIORITY 4: Development (leap) Rules — fallback, usually unreachable

enum DevelopmentRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        guard let leapName = context.currentLeapName else { return nil }
        let text = leapTip(for: leapName, name: context.babyName, language: context.language)
        return DailyTip(text: text, contextHash: context.contextHash, category: .development)
    }

    private static func leapTip(for leapName: String, name: String, language: Language) -> String {
        // Match by localised leap name or English fallback
        switch language {
        case .russian:
            return russianLeapTip(leapName: leapName, name: name)
        case .english:
            return englishLeapTip(leapName: leapName, name: name)
        case .german:
            return germanLeapTip(leapName: leapName, name: name)
        }
    }

    private static func russianLeapTip(leapName: String, name: String) -> String {
        switch leapName {
        case _ where leapName.contains("ощущен") || leapName.contains("Senses"):
            return "Разговаривайте спокойным голосом и избегайте резких звуков — слуховая система \(name) ещё настраивается."
        case _ where leapName.contains("узор") || leapName.contains("Pattern"):
            return "Покажите \(name) чёрно-белые карточки с геометрическими фигурами. Мозг ищет паттерны — контраст стимулирует зрительную кору сильнее всего."
        case _ where leapName.contains("движен") || leapName.contains("Transition"):
            return "Время на животике каждый день — \(name) тренирует контроль над телом. Подкладывайте под грудь свёрнутое одеяло."
        case _ where leapName.contains("событ") || leapName.contains("Event"):
            return "В скачок причинно-следственных связей игрушки «нажми — звук» — лучшие. \(name) открывает: «мои действия меняют мир»."
        case _ where leapName.contains("отношен") || leapName.contains("Relation"):
            return "Тревога разлуки сейчас — не каприз, а норма. Игра «ку-ку» помогает \(name) понять: мама уходит и возвращается."
        case _ where leapName.contains("категор") || leapName.contains("Categor"):
            return "Сортеры, стаканчики разного размера — идеальные игрушки. \(name) классифицирует мир: большой/маленький, внутри/снаружи."
        case _ where leapName.contains("последоват") || leapName.contains("Sequence"):
            return "Простые ритуалы помогают \(name) понять «что будет дальше». Одна и та же последовательность перед сном снижает тревогу."
        case _ where leapName.contains("програм") || leapName.contains("Program"):
            return "Первые «нет» и протесты — признак здоровой независимости. Давайте \(name) простой выбор: «красная или синяя кружка?»"
        case _ where leapName.contains("принцип") || leapName.contains("Principle"):
            return "«Почему?» и «нет» — главные слова этого этапа. Объясняйте коротко: «горячо — нельзя, больно»."
        case _ where leapName.contains("систем") || leapName.contains("System"):
            return "Ролевые игры расцветают сейчас. Маленькая кухня, инструменты — \(name) строит модель мира."
        default:
            return "Скачок развития — это временно. Чаще обнимайте \(name) и отвечайте на сигналы — это лучшая поддержка."
        }
    }

    private static func englishLeapTip(leapName: String, name: String) -> String {
        switch leapName {
        case _ where leapName.contains("Sense") || leapName.contains("ощущен"):
            return "Speak in a calm voice and avoid sudden sounds — \(name)'s auditory system is still calibrating."
        case _ where leapName.contains("Pattern") || leapName.contains("узор"):
            return "Show \(name) black-and-white geometric cards. The brain seeks patterns — contrast stimulates the visual cortex most powerfully."
        case _ where leapName.contains("Transition") || leapName.contains("движен"):
            return "Daily tummy time — \(name) is practising body control. Roll a blanket under the chest for support."
        case _ where leapName.contains("Event") || leapName.contains("событ"):
            return "During this cause-and-effect leap, «press-and-sound» toys are best. \(name) is discovering: «my actions change the world»."
        case _ where leapName.contains("Relation") || leapName.contains("отношен"):
            return "Separation anxiety now is not a whim — it's normal. Peek-a-boo helps \(name) learn: mummy leaves and comes back."
        case _ where leapName.contains("Categor") || leapName.contains("категор"):
            return "Sorters and stacking cups of different sizes are ideal toys. \(name) is classifying the world: big/small, inside/outside."
        case _ where leapName.contains("Sequence") || leapName.contains("последоват"):
            return "Simple rituals help \(name) predict «what comes next». A consistent bedtime sequence reduces anxiety."
        case _ where leapName.contains("Program") || leapName.contains("програм"):
            return "First «nos» and protests are a sign of healthy independence. Give \(name) simple choices: «red or blue cup?»"
        case _ where leapName.contains("Principle") || leapName.contains("принцип"):
            return "«Why?» and «no» are the key words of this stage. Keep explanations short: «hot — not allowed, it hurts»."
        case _ where leapName.contains("System") || leapName.contains("систем"):
            return "Role play is blossoming now. A toy kitchen or tools — \(name) is building a model of the world."
        default:
            return "A developmental leap is temporary. Hug \(name) more often and respond to their signals — that's the best support."
        }
    }

    private static func germanLeapTip(leapName: String, name: String) -> String {
        switch leapName {
        case _ where leapName.contains("Senses") || leapName.contains("Sinne"):
            return "Sprich ruhig und vermeide plötzliche Geräusche — \(name)s Hörsystem kalibriert sich noch."
        case _ where leapName.contains("Pattern") || leapName.contains("Muster"):
            return "Zeige \(name) schwarz-weiße geometrische Karten. Das Gehirn sucht Muster — Kontrast stimuliert die Sehrinde am stärksten."
        case _ where leapName.contains("Transition") || leapName.contains("Übergang"):
            return "Tägliche Bauchlage — \(name) übt Körperkontrolle. Rolle eine Decke unter die Brust zur Unterstützung."
        case _ where leapName.contains("Event") || leapName.contains("Ereignis"):
            return "Beim Ursache-Wirkungs-Sprung sind «Drück-und-Ton»-Spielzeuge am besten. \(name) entdeckt: «meine Handlungen verändern die Welt»."
        case _ where leapName.contains("Relation") || leapName.contains("Beziehung"):
            return "Trennungsangst ist jetzt keine Laune — es ist normal. Kuckuckspiele helfen \(name) zu verstehen: Mama geht und kommt wieder."
        case _ where leapName.contains("Categor") || leapName.contains("Kategor"):
            return "Sortierer und Stapelbecher verschiedener Größen sind ideale Spielzeuge. \(name) klassifiziert: groß/klein, drinnen/draußen."
        default:
            return "Ein Entwicklungssprung ist vorübergehend. Umarme \(name) öfter und reagiere auf Signale — das ist die beste Unterstützung."
        }
    }
}

// MARK: - PRIORITY 5: Default Tips (ultimate fallback)

enum DefaultTips {

    static func evaluate(context: DailyContext) -> DailyTip {
        let pool = tips(for: context.language)
        let idx = context.dayOfYear % pool.count
        let text = pool[idx].replacingOccurrences(of: "[name]", with: context.babyName)
        return DailyTip(text: text, contextHash: context.contextHash, category: .defaultTip)
    }

    private static func tips(for lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Зрительный контакт во время кормления укрепляет привязанность и стимулирует развитие мозга [name].",
            "Пение колыбельных формирует музыкальный слух и речевые центры. Ритм и мелодия важнее идеального голоса.",
            "Объятия и тактильный контакт снижают кортизол. Лучшее «лекарство» сегодня — просто подержать [name] на руках.",
            "Читайте вслух с первых дней. Ритм речи и интонации строят основу для будущего чтения и развития речи.",
            "Называйте эмоции [name]: «ты расстроен», «ты радуешься» — эмоциональный интеллект начинается с первых месяцев жизни."
        ]
        case .english: return [
            "Eye contact during feeding strengthens attachment and stimulates [name]'s brain development.",
            "Singing lullabies builds musical hearing and speech centres. Rhythm and melody matter more than a perfect voice.",
            "Hugs and touch lower cortisol levels. The best «medicine» today is simply holding [name] in your arms.",
            "Read aloud from the very first days. The rhythm of speech and intonation lay the foundation for future reading.",
            "Name [name]'s emotions: «you're upset», «you're happy» — emotional intelligence begins in the first months of life."
        ]
        case .german: return [
            "Blickkontakt beim Stillen stärkt die Bindung und fördert die Gehirnentwicklung von [name].",
            "Das Singen von Schlafliedern baut musikalisches Gehör und Sprachzentren auf. Rhythmus und Melodie sind wichtiger als eine perfekte Stimme.",
            "Umarmungen und Körperkontakt senken den Cortisolspiegel. Das beste «Medikament» heute ist, [name] einfach auf dem Arm zu halten.",
            "Vorlesen von den ersten Tagen an — der Sprachrhythmus und Intonationen legen das Fundament für zukünftiges Lesen.",
            "[name]s Gefühle benennen: «du bist traurig», «du freust dich» — emotionale Intelligenz beginnt in den ersten Lebensmonaten."
        ]
        }
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -15
```

Expected: all alert and situational tests PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Today/Algorithm/DailyTipRules.swift \
        MomsyTests/Features/Today/DailyTipAlgorithmTests.swift
git commit -m "feat(tip-rules): implement all 5 priority rule chains with RU/EN/DE tip content"
```

---

## Task 6: Create DailyTipAlgorithm.swift

**Files:**
- Create: `Momsy/Features/Today/Algorithm/DailyTipAlgorithm.swift`

- [ ] **Step 1: Write the spec's example as a failing test**

Add to `MomsyTests/Features/Today/DailyTipAlgorithmTests.swift`:

```swift
    @Test("evaluate never returns empty text")
    func evaluate_alwaysHasText() {
        let ctx = makeContext(ageMonths: 3)
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(!tip.text.isEmpty)
    }

    @Test("spec example: 4m baby at 18:30 → evening bath tip")
    func evaluate_specExample_bathTip() {
        // age=4, hour=18, minutesSinceLastFeed=150, diaperCount=7,
        // totalSleepMinutes=700, minutesSinceLastSleepEnd=95, bathCount=0, walkCount=1
        // Expected: SITU D — bath tip (category .situational)
        let ctx = makeContext(
            ageMonths: 4,
            minutesSinceLastFeed: 150,
            diaperCount: 7,
            totalSleepMinutes: 700,
            minutesSinceLastSleepEnd: 95,
            walkCount: 1,
            bathCount: 0,
            daysSinceLastStool: 1,
            hour: 18
        )
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(tip.category == .situational)
        #expect(tip.text.contains("купан") || tip.text.contains("bath") || tip.text.contains("Bad"))
    }

    @Test("evaluate returns .alert when feed interval exceeded")
    func evaluate_alertCategory_whenFeedLate() {
        let ctx = makeContext(ageMonths: 1, minutesSinceLastFeed: 200, hour: 15)
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(tip.category == .alert)
    }

    @Test("evaluate returns .care when no conditions fire")
    func evaluate_careCategory_whenIdle() {
        // All alerts and situationals suppressed: good feed, sleep, diapers; midday; bath done; walk done
        let ctx = makeContext(
            ageMonths: 4,
            minutesSinceLastFeed: 90,
            diaperCount: 7,
            totalSleepMinutes: 700,
            minutesSinceLastSleepEnd: 60,
            walkCount: 1,
            bathCount: 1,
            daysSinceLastStool: 0,
            hour: 12
        )
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(tip.category == .care)
    }
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -10
```

Expected: FAIL — `DailyTipAlgorithm` does not exist.

- [ ] **Step 3: Create DailyTipAlgorithm.swift**

```swift
// Momsy/Features/Today/Algorithm/DailyTipAlgorithm.swift
import Foundation

enum DailyTipAlgorithm {

    /// Evaluate context and return the highest-priority tip. Never returns nil.
    static func evaluate(context: DailyContext) -> DailyTip {
        if let alert = AlertRules.evaluate(context: context)        { return alert }
        if let situ  = SituationalRules.evaluate(context: context)  { return situ }
        return CareRules.evaluate(context: context)
        // Priority 4 (DevelopmentRules) and 5 (DefaultTips) are reachable only if
        // CareRules.evaluate() were to fail — which it can't since every age group has a pool.
        // They exist as documented safety fallbacks per spec section 4.2.
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/DailyTipAlgorithmTests 2>&1 | tail -15
```

Expected: all `DailyTipAlgorithmTests` PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Today/Algorithm/DailyTipAlgorithm.swift \
        MomsyTests/Features/Today/DailyTipAlgorithmTests.swift
git commit -m "feat(algorithm): implement DailyTipAlgorithm.evaluate() — deterministic tip engine"
```

---

## Task 7: Update TodayViewModel to use the algorithm

**Files:**
- Modify: `Momsy/Features/Today/Presentation/ViewModel/TodayViewModel.swift`

- [ ] **Step 1: Update the failing TodayViewModel tip tests**

The existing tip tests (`fetchDailyTipIfNeeded_setsDailyTip`, `fetchDailyTipIfNeeded_leavesDailyTipNil_onError`, `fetchDailyTipIfNeeded_skipsSecondCall_withinSession`) now need to reflect the new behaviour — `tipService` is no longer called; the algorithm computes immediately. Update the three tip tests in `MomsyTests/Features/Today/TodayViewModelTests.swift`:

Replace the `// MARK: - Daily Tip` section (lines 150–194) with:

```swift
    // MARK: - Daily Tip (deterministic algorithm)

    @Test("fetchDailyTipIfNeeded sets dailyTip using deterministic algorithm")
    func fetchDailyTipIfNeeded_setsDailyTip() async {
        let vm = makeVM()
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.dailyTip != nil)
        #expect(vm.dailyTip?.text.isEmpty == false)
        #expect(vm.isTipLoading == false)
    }

    @Test("fetchDailyTipIfNeeded does not re-run algorithm on second call in same session")
    func fetchDailyTipIfNeeded_skipsSecondCall_withinSession() async {
        let vm = makeVM()
        await vm.fetchDailyTipIfNeeded()
        let firstText = vm.dailyTip?.text

        await vm.fetchDailyTipIfNeeded()
        #expect(vm.dailyTip?.text == firstText)
    }

    @Test("fetchDailyTipIfNeeded always sets isTipLoading to false after running")
    func fetchDailyTipIfNeeded_resetsLoadingState() async {
        let vm = makeVM()
        await vm.fetchDailyTipIfNeeded()
        #expect(vm.isTipLoading == false)
    }

    @Test("refreshTip forces a new evaluation")
    func refreshTip_forcesNewEvaluation() async {
        let vm = makeVM()
        await vm.fetchDailyTipIfNeeded()
        let firstHash = vm.dailyTip?.contextHash

        await vm.refreshTip()
        #expect(vm.dailyTip?.contextHash != nil)
        // Context hash may be the same (same day, same entries) — just assert tip is still set
        #expect(vm.dailyTip?.text.isEmpty == false)
    }
```

- [ ] **Step 2: Run tests to verify they fail (old implementation)**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/TodayViewModelTests 2>&1 | tail -15
```

Expected: FAIL — `fetchDailyTipIfNeeded_setsDailyTip` fails because old code depends on `tipService`, which returns a fixed stub not produced by the algorithm. And `refreshTip_forcesNewEvaluation` fails because `refreshTip()` hasn't been updated yet.

- [ ] **Step 3: Replace fetchDailyTipIfNeeded and add stool helper in TodayViewModel**

In `Momsy/Features/Today/Presentation/ViewModel/TodayViewModel.swift`, replace the `// MARK: - Daily Tip` block (lines 68–88) with:

```swift
    // MARK: - Daily Tip

    func fetchDailyTipIfNeeded() async {
        guard !hasFetchedThisSession else { return }
        await updateTip()
        hasFetchedThisSession = true
    }

    func refreshTip() async {
        hasFetchedThisSession = false
        await fetchDailyTipIfNeeded()
    }

    private func updateTip() async {
        let stoolDays = await computeDaysSinceLastStool()
        let ctx = DailyContextBuilder.build(
            from: logEntries,
            diaperCount: diaperCount,
            daysSinceLastStool: stoolDays,
            appState: appState
        )
        isTipLoading = true
        dailyTip = DailyTipAlgorithm.evaluate(context: ctx)
        isTipLoading = false
    }

    private func computeDaysSinceLastStool() async -> Int {
        let cal = Calendar.current
        // Search up to 10 days back to find last stool date
        for daysBack in 0..<10 {
            guard let from = cal.date(byAdding: .day, value: -daysBack, to: cal.startOfDay(for: Date())),
                  let to   = cal.date(byAdding: .day, value: 1, to: from) else { continue }
            let entries = (try? await stoolRepo.getEntries(from: from, to: to)) ?? []
            if !entries.isEmpty { return daysBack }
        }
        return 0 // unknown / treat as recent
    }
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing MomsyTests/TodayViewModelTests 2>&1 | tail -15
```

Expected: all TodayViewModelTests PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Today/Presentation/ViewModel/TodayViewModel.swift \
        MomsyTests/Features/Today/TodayViewModelTests.swift
git commit -m "feat(vm): replace Gemini tip fetch with DailyTipAlgorithm; add stool days helper"
```

---

## Task 8: Update TodayView — category-aware tip card

Remove the hardcoded "AI" badge. Show an icon and accent colour based on `dailyTip?.category`. The loading shimmer becomes effectively invisible since the algorithm is near-instant, but is kept for the brief async gap.

**Files:**
- Modify: `Momsy/Features/Today/Presentation/Views/TodayView.swift`

- [ ] **Step 1: Replace `aiTipCard` and `aiTipBody` in TodayView**

Locate the `// MARK: - AI Tip Card` section (around line 360) and replace `aiTipCard` and `aiTipBody` with:

```swift
    // MARK: - Daily Tip Card

    private var dailyTipCard: some View {
        HStack(alignment: .top, spacing: 10) {
            tipBadge

            VStack(alignment: .leading, spacing: 4) {
                Text(loc.strings.tipOfDay)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                tipBody
            }
        }
        .bbCard(pad: 14, bg: tipCardBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(tipAccentColor)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var tipBadge: some View {
        let (icon, bg) = tipBadgeStyle
        return RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(bg)
            .frame(width: 28, height: 28)
            .overlay(
                Text(icon)
                    .font(.system(size: 14))
            )
    }

    private var tipBadgeStyle: (icon: String, bg: Color) {
        switch vm.dailyTip?.category {
        case .alert:       return ("⚠️", Color.bbCoral)
        case .situational: return ("💡", Color.bbButter)
        case .care:        return ("🌿", Color.bbMint)
        case .development: return ("⭐", Color.bbLilac)
        case .defaultTip, .none: return ("💛", Color.bbButter)
        }
    }

    private var tipCardBackground: Color {
        vm.dailyTip?.category == .alert ? Color.bbCoral.opacity(0.12) : Color.bbCreamSoft
    }

    private var tipAccentColor: Color {
        switch vm.dailyTip?.category {
        case .alert:       return .bbCoralDeep
        case .situational: return .bbButterDeep
        case .care:        return .bbMintDeep
        case .development: return .bbLilacDeep
        case .defaultTip, .none: return .bbButterDeep
        }
    }

    @ViewBuilder
    private var tipBody: some View {
        if vm.isTipLoading && vm.dailyTip == nil {
            Text("...")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .redacted(reason: .placeholder)
        } else if let tip = vm.dailyTip {
            Text(tip.text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(loc.strings.leapContrastsTip(name: appState.displayName))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
```

Also update the `body` property where `aiTipCard` is referenced — change it to `dailyTipCard`:

Find the line `aiTipCard` in the `mainCards` or top-level `body` (approximately line 58) and rename it to `dailyTipCard`.

- [ ] **Step 2: Verify build compiles (colours are confirmed to exist)**

All colours used (`bbCoral`, `bbCoralDeep`, `bbMint`, `bbMintDeep`, `bbButter`, `bbLilac`) are defined in `Momsy/Core/DesignSystem/DesignSystem.swift` lines 20–27 — no extra imports needed.

- [ ] **Step 3: Build and verify no compile errors**

```bash
xcodebuild build -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "error:|Build succeeded"
```

Expected: `Build succeeded`.

- [ ] **Step 4: Run all tests**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5
```

Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add Momsy/Features/Today/Presentation/Views/TodayView.swift
git commit -m "feat(ui): category-aware tip card — replace AI badge with icon + accent colour per TipCategory"
```

---

## Verification

End-to-end check after all tasks are complete:

1. **Run full test suite** — all tests pass, no regressions:
   ```bash
   xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
     -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5
   ```

2. **Verify offline** — disconnect simulator from network; launch app; confirm tip card shows text immediately with no spinner and no network activity in logs.

3. **Alert tip** — set baby birth date to today in the app; set `minutesSinceLastFeed` to a large value by not logging any feeding. Confirm the tip card shows an alert-styled card (coral/rose tint + `⚠️` badge).

4. **Care tip rotation** — run the spec's example through the algorithm manually:
   - age=4, hour=18, minutesSinceLastFeed=150, diaperCount=7, totalSleepMinutes=700, minutesSinceLastSleepEnd=95, bathCount=0, walkCount=1 → should return `category: .situational` (bath tip).

5. **No hardcoded aiTipText** — confirm the word "AI" no longer appears as a badge label in TodayView source.

---

## Notes

- **SITU B (active feeding > 25 min) is intentionally skipped.** The condition requires `isFeedingActive` and `feedingActiveMinutes` from `FeedingTimerService`, which is not available in `DailyContext`. This can be added in a follow-up by injecting timer state into the context.
- `DevelopmentRules` and `DefaultTips` are implemented per spec (DoD requires all 5 priorities exist) but are unreachable in production because `CareRules.evaluate()` always returns a tip. They serve as documented safety fallbacks.
- `tipService` remains in `TodayViewModel.init` to avoid breaking `AppContainer` and existing test infrastructure. The service is no longer called for production tip delivery.
- German (`de`) texts follow the same structure as Russian and English. All 3 languages are fully implemented.
- `computeDaysSinceLastStool()` scans up to 10 days back. If no stool entries exist at all (user never logged), returns 0 (safe default — no false alert).
