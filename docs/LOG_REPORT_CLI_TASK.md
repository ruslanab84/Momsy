# LOG_REPORT_CLI_TASK — Новый «Report» в разделе Doctor (день / неделя / месяц)

Проверено против `ruslanab84/Momsy` HEAD `0a79505` (свежий клон). Все пути и номера строк — из актуального кода.

## Цель

Новый экран **Report** в разделе Doctor, отображающий все данные, попадающие в «Today so far» (`TodayViewModel.loadTodayEntries`, `TodayViewModel.swift:162–188`): кормление, сон, подгузники, стул, прогулки, купание, витамины, сцеживание. Три режима: **день** (выбор в календаре), **неделя** (таймлайн-сетка 7 дней × 24 ч, как в Huckleberry), **месяц** (сетка месяца + список за выбранный день). Данные — только из локальной SwiftData-базы.

Пункт меню — в `DoctorMenuView` **сразу после AI-отчёта** (строка `WeeklyInsightView`, `DoctorMenuView.swift:52–59`), перед «Отчёт для педиатра».

## Аудит источников (проверено)

| Источник Today so far | SwiftData | Range-fetch |
|---|---|---|
| Кормление | ✅ `FeedingRecord` | `FeedingRepository.getEntries(from:to:)` |
| Сон | ✅ `SleepRecord` | `SleepRepository.getEntries(overlapping:until:)` (extension) |
| Подгузник | ✅ `DiaperRecord` | `DiaperRepository.getEntries(from:to:)` |
| Стул | ✅ `StoolRecord` | `StoolRepository.getEntries(from:to:) -> [Date]` |
| Прогулка | ✅ `WalkRecord` | `WalkRepository.getEntries(from:to:)` |
| Купание | ✅ `BathRecord` | `BathRepository.getEntries(from:to:)` |
| Сцеживание | ✅ `PumpingRecord` | `PumpingRepository.getEntries(from:to:)` |
| **Витамины** | ❌ **нет** — только UserDefaults (сегодня) + Firestore | — |

Единственный пробел персистентности — **витамины** → Часть A. Симптом в Today so far не попадает (`TodayViewModel.logSymptom()` нигде не вызывается — проверено grep'ом) → вне скоупа.

---

# Часть A — Локальная персистентность витаминов

## A1. Новый файл `Momsy/Features/Vitamin/Domain/Models/VitaminEntry.swift`

```swift
import Foundation

struct VitaminEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var label: String
}
```

## A2. Новый файл `Momsy/Features/Vitamin/Domain/Repositories/VitaminRepository.swift`

```swift
import Foundation

protocol VitaminRepository {
    func add(_ entry: VitaminEntry) async throws
    /// Inserts only entries whose id is not already stored (used by cloud download/merge).
    func upsert(_ entries: [VitaminEntry]) async throws
    func getEntries(from: Date, to: Date) async throws -> [VitaminEntry]
}
```

## A3. Новый файл `Momsy/Features/Vitamin/Data/Persistence/VitaminRecord.swift`

По образцу `StoolRecord`/`DiaperRecord` (default-значения обязательны для лёгкой миграции):

```swift
import SwiftData
import Foundation

@Model
final class VitaminRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var label: String = ""

    init(id: UUID = UUID(), date: Date = Date(), label: String = "") {
        self.id = id
        self.babyId = ActiveBaby.scope
        self.date = date
        self.label = label
    }

    func toDomain() -> VitaminEntry { VitaminEntry(id: id, date: date, label: label) }
}
```

## A4. Новый файл `Momsy/Features/Vitamin/Data/Repositories/SwiftDataVitaminRepository.swift`

```swift
import SwiftData
import Foundation

@MainActor
final class SwiftDataVitaminRepository: VitaminRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func add(_ entry: VitaminEntry) async throws {
        context.insert(VitaminRecord(id: entry.id, date: entry.date, label: entry.label))
        try context.save()
    }

    func upsert(_ entries: [VitaminEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let existing = Set(try context.fetch(
            FetchDescriptor<VitaminRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
        ).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(VitaminRecord(id: entry.id, date: entry.date, label: entry.label))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func getEntries(from: Date, to: Date) async throws -> [VitaminEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<VitaminRecord>(
            predicate: #Predicate { $0.date >= from && $0.date <= to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }
}
```

## A5. `Momsy/Core/Persistence/AppPersistence.swift`

**Строка 11** — бамп информационной версии:

```swift
// БЫЛО
    private static let schemaVersion = "v22"
// СТАЛО
    private static let schemaVersion = "v23"
```

**Строки 62–82** (`makeSchema`) — добавить после `WeeklyInsightRecord.self,` (строка 81):

```swift
            WeeklyInsightRecord.self,
            VitaminRecord.self,
```

Добавление новой модели — лёгкая миграция, стор не пересоздаётся.

## A6. `Momsy/Features/Vitamin/Presentation/ViewModel/VitaminViewModel.swift`

Инжект репозитория + запись в SwiftData при добавлении. Diff:

```swift
// БЫЛО (строки 12–17)
    private let quickLogRepo: QuickLogRepository

    init(quickLogRepo: QuickLogRepository) {
        self.quickLogRepo = quickLogRepo
        loadToday()
    }
// СТАЛО
    private let quickLogRepo: QuickLogRepository
    private let vitaminRepo: any VitaminRepository

    init(quickLogRepo: QuickLogRepository, vitaminRepo: any VitaminRepository) {
        self.quickLogRepo = quickLogRepo
        self.vitaminRepo = vitaminRepo
        loadToday()
    }
```

В `add()` — после `quickLogRepo.append(entry)` (строка 29):

```swift
        quickLogRepo.append(entry)
        Task { try? await vitaminRepo.add(VitaminEntry(id: entry.id, date: entry.time, label: label)) }
```

## A7. `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift`

Витамины ко-родителя теперь должны попадать в локальную базу (иначе в отчёте будут только сегодняшние).

1. **Строка 19** — после `private let pumpingRepo: any PumpingRepository` добавить:

```swift
    private let vitaminRepo: any VitaminRepository
```

2. **Init** — параметр после `pumpingRepo: any PumpingRepository,` (строка 44) и присваивание после `self.pumpingRepo = pumpingRepo` (строка 64):

```swift
         vitaminRepo: any VitaminRepository,
```
```swift
        self.vitaminRepo = vitaminRepo
```

3. **Merge** — после строки `await merge(pumpingFetch, map: Self.pumpingEntry) { ... }` (строка ~362) добавить:

```swift
        await merge(vitaminFetch,        map: Self.vitaminEntry)      { try await self.vitaminRepo.upsert($0) }
```

4. **Удалить** строку 384 `commit(vitaminFetch)` (watermark теперь коммитится через `merge`, как у остальных коллекций) и поправить комментарий на строках 375–376:

```swift
// БЫЛО
        // Quick-log "today" strip. `appendUnique` cannot throw; vitamins have no
        // entry repo, so their watermark commits here.
// СТАЛО
        // Quick-log "today" strip. `appendUnique` cannot throw.
```

5. **Маппинг** — рядом с `walkEntry(_:)` добавить:

```swift
    private static func vitaminEntry(_ dto: QuickEventLogDTO) -> VitaminEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return VitaminEntry(id: uuid, date: log.loggedAt, label: log.label)
    }
```

Тесты `SleepLiveSyncServiceTests` используют `SpyCloudSyncDownloader` (протокол) — правка init их не ломает (проверено).

---

# Часть B — Фича LogReport

Новая папка `Momsy/Features/LogReport/` (synchronized groups — pbxproj трогать не нужно).

## B1. `Momsy/Features/LogReport/Domain/Models/LogReportModels.swift`

```swift
import Foundation

enum LogReportMode: Int, CaseIterable, Identifiable {
    case day, week, month
    var id: Self { self }
}

struct LogReportItem: Identifiable, Equatable {
    let id: String
    let kind: BlobKind
    let label: String
    let start: Date
    let end: Date?
}

struct LogReportTimelineSegment: Identifiable {
    let id: String
    let kind: BlobKind
    let startMinute: Int
    let endMinute: Int
    let isInstant: Bool
}
```

## B2. `Momsy/Features/LogReport/Domain/UseCases/GetLogReportEntriesUseCase.swift`

Лейблы — теми же L10n-функциями, что и в Today so far (`feedingLogEntry`, `sleepLogEntry`, `diaperLogEntry(count:)`, `stoolLogged`, `walkLogged`, `bathLogged`, `pumpingLogEntry(dur:ml:)` — все проверены в `L10n.swift`).

```swift
import Foundation

final class GetLogReportEntriesUseCase {
    private let feedingRepo: any FeedingRepository
    private let sleepRepo: any SleepRepository
    private let diaperRepo: any DiaperRepository
    private let stoolRepo: any StoolRepository
    private let walkRepo: any WalkRepository
    private let bathRepo: any BathRepository
    private let pumpingRepo: any PumpingRepository
    private let vitaminRepo: any VitaminRepository

    init(feedingRepo: any FeedingRepository,
         sleepRepo: any SleepRepository,
         diaperRepo: any DiaperRepository,
         stoolRepo: any StoolRepository,
         walkRepo: any WalkRepository,
         bathRepo: any BathRepository,
         pumpingRepo: any PumpingRepository,
         vitaminRepo: any VitaminRepository) {
        self.feedingRepo = feedingRepo
        self.sleepRepo = sleepRepo
        self.diaperRepo = diaperRepo
        self.stoolRepo = stoolRepo
        self.walkRepo = walkRepo
        self.bathRepo = bathRepo
        self.pumpingRepo = pumpingRepo
        self.vitaminRepo = vitaminRepo
    }

    /// Every local log whose activity overlaps [from, to), newest first.
    func execute(from: Date, to: Date) async -> [LogReportItem] {
        let lm = LocalizationManager.shared
        let cal = Calendar.current

        let feedings = (try? await feedingRepo.getEntries(from: from, to: to)) ?? []
        let sleeps   = (try? await sleepRepo.getEntries(overlapping: from, until: to)) ?? []
        let diapers  = (try? await diaperRepo.getEntries(from: from, to: to)) ?? []
        let stools   = (try? await stoolRepo.getEntries(from: from, to: to)) ?? []
        let walks    = (try? await walkRepo.getEntries(from: from, to: to)) ?? []
        let baths    = (try? await bathRepo.getEntries(from: from, to: to)) ?? []
        let pumpings = (try? await pumpingRepo.getEntries(from: from, to: to)) ?? []
        let vitamins = (try? await vitaminRepo.getEntries(from: from, to: to)) ?? []

        let feedingItems = feedings.map { entry -> LogReportItem in
            let side = entry.side.displayName(lang: lm.lang).lowercased()
            let end = entry.durationSeconds > 0
                ? entry.date.addingTimeInterval(TimeInterval(entry.durationSeconds))
                : nil
            return LogReportItem(id: "feeding:\(entry.id.uuidString)", kind: .bottle,
                                 label: lm.strings.feedingLogEntry(dur: entry.durationMinutes, side: side),
                                 start: entry.date, end: end)
        }

        let sleepItems = sleeps.map { entry -> LogReportItem in
            let label: String
            if let mins = entry.durationMinutes {
                label = lm.strings.sleepLogEntry(dur: lm.strings.sleepDurationFormatted(h: mins / 60, m: mins % 60))
            } else {
                label = lm.strings.sleepStarted
            }
            return LogReportItem(id: "sleep:\(entry.id.uuidString)", kind: .sleep,
                                 label: label, start: entry.startDate, end: entry.endDate)
        }

        // Diapers keep the per-day running number used in "Today so far".
        let diaperItems = Dictionary(grouping: diapers) { cal.startOfDay(for: $0.date) }
            .values
            .flatMap { day in
                day.sorted { $0.date < $1.date }.enumerated().map { index, entry in
                    LogReportItem(id: "diaper:\(entry.id.uuidString)", kind: .drop,
                                  label: lm.strings.diaperLogEntry(count: index + 1),
                                  start: entry.date, end: nil)
                }
            }

        let stoolItems = stools.map {
            LogReportItem(id: "stool:\(Int($0.timeIntervalSince1970))", kind: .stool,
                          label: lm.strings.stoolLogged, start: $0, end: nil)
        }
        let walkItems = walks.map {
            LogReportItem(id: "walk:\($0.id.uuidString)", kind: .walk,
                          label: lm.strings.walkLogged, start: $0.startDate, end: $0.endDate)
        }
        let bathItems = baths.map {
            LogReportItem(id: "bath:\($0.id.uuidString)", kind: .bath,
                          label: lm.strings.bathLogged, start: $0.startDate, end: $0.endDate)
        }
        let pumpingItems = pumpings.map { entry -> LogReportItem in
            let end = entry.endDate ?? entry.date.addingTimeInterval(TimeInterval(entry.durationSeconds))
            return LogReportItem(id: "pump:\(entry.id.uuidString)", kind: .pump,
                                 label: lm.strings.pumpingLogEntry(dur: entry.durationMinutes, ml: entry.volumeML),
                                 start: entry.date, end: end)
        }
        let vitaminItems = vitamins.map {
            LogReportItem(id: "vitamin:\($0.id.uuidString)", kind: .vitamin,
                          label: $0.label.isEmpty ? lm.strings.vitaminsGiven : $0.label,
                          start: $0.date, end: nil)
        }

        return (feedingItems + sleepItems + diaperItems + stoolItems
                + walkItems + bathItems + pumpingItems + vitaminItems)
            .sorted { $0.start > $1.start }
    }
}
```

## B3. `Momsy/Features/LogReport/Presentation/ViewModel/LogReportViewModel.swift`

```swift
import SwiftUI
import Combine

@MainActor
final class LogReportViewModel: ObservableObject {
    @Published var mode: LogReportMode = .day
    @Published var selectedDate: Date = Date()
    @Published private(set) var items: [LogReportItem] = []

    private let getEntries: GetLogReportEntriesUseCase
    private let calendar = Calendar.current

    init(getEntries: GetLogReportEntriesUseCase) {
        self.getEntries = getEntries
    }

    // MARK: - Range

    var range: (from: Date, to: Date) {
        switch mode {
        case .day:
            let start = calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return (start, end)
        case .week:
            let interval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)
                ?? DateInterval(start: calendar.startOfDay(for: selectedDate), duration: 7 * 86_400)
            return (interval.start, interval.end)
        case .month:
            let interval = calendar.dateInterval(of: .month, for: selectedDate)
                ?? DateInterval(start: calendar.startOfDay(for: selectedDate), duration: 30 * 86_400)
            return (interval.start, interval.end)
        }
    }

    var weekDays: [Date] {
        let start = range.from
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    /// Month grid: leading nils pad the first weekday, then every day of the month.
    var monthDays: [Date?] {
        let start = range.from
        guard let dayCount = calendar.range(of: .day, in: .month, for: start)?.count else { return [] }
        let weekday = calendar.component(.weekday, from: start)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        let days = (0..<dayCount).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        return Array(repeating: nil, count: leading) + days
    }

    var periodTitle: String {
        let formatter = DateFormatter()
        switch mode {
        case .day:
            formatter.dateStyle = .medium
            return formatter.string(from: selectedDate)
        case .week:
            formatter.dateFormat = "d MMM"
            let from = formatter.string(from: range.from)
            let to = formatter.string(from: range.to.addingTimeInterval(-1))
            return "\(from) – \(to)"
        case .month:
            formatter.dateFormat = "LLLL yyyy"
            return formatter.string(from: selectedDate).capitalized
        }
    }

    // MARK: - Loading

    func load() async {
        let bounds = range
        items = await getEntries.execute(from: bounds.from, to: bounds.to)
    }

    func shift(_ delta: Int) {
        let component: Calendar.Component
        switch mode {
        case .day:   component = .day
        case .week:  component = .weekOfYear
        case .month: component = .month
        }
        selectedDate = calendar.date(byAdding: component, value: delta, to: selectedDate) ?? selectedDate
    }

    // MARK: - Per-day slices

    func items(on day: Date) -> [LogReportItem] {
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return items.filter { item in
            let end = item.end ?? item.start
            return item.start < dayEnd && end >= dayStart
        }
    }

    func timelineSegments(on day: Date) -> [LogReportTimelineSegment] {
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return items.compactMap { item in
            let isInstant = item.end == nil
            let end = item.end ?? item.start
            guard item.start < dayEnd, end >= dayStart else { return nil }
            let clippedStart = max(item.start, dayStart)
            let clippedEnd = min(end, dayEnd)
            let startMinute = Int(clippedStart.timeIntervalSince(dayStart) / 60)
            let endMinute = max(startMinute + 1, Int(clippedEnd.timeIntervalSince(dayStart) / 60))
            return LogReportTimelineSegment(
                id: "\(item.id):\(Int(dayStart.timeIntervalSince1970))",
                kind: item.kind,
                startMinute: min(startMinute, 1_439),
                endMinute: min(endMinute, 1_440),
                isInstant: isInstant
            )
        }
    }

    func kinds(on day: Date) -> [BlobKind] {
        var seen: [BlobKind] = []
        for item in items(on: day) where !seen.contains(item.kind) {
            seen.append(item.kind)
            if seen.count == 3 { break }
        }
        return seen
    }
}
```

## B4. `Momsy/Features/LogReport/Presentation/Views/LogReportView.swift`

```swift
import SwiftUI

struct LogReportView: View {
    @StateObject private var vm: LogReportViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeLogReportViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                modeChips
                if vm.mode == .day {
                    dayPickerCard
                } else {
                    periodNavigator
                }
                content
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .onChange(of: vm.mode) { _, _ in Task { await vm.load() } }
        .onChange(of: vm.selectedDate) { _, _ in Task { await vm.load() } }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: loc.strings.logReportTitle)
            Text(loc.strings.logReportSub)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Mode

    private var modeChips: some View {
        HStack(spacing: 8) {
            chip(loc.strings.logReportDay, mode: .day)
            chip(loc.strings.reportPeriodWeek, mode: .week)
            chip(loc.strings.reportPeriodMonth, mode: .month)
            Spacer()
        }
    }

    private func chip(_ title: String, mode: LogReportMode) -> some View {
        Button { vm.mode = mode } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(vm.mode == mode ? .white : .bbInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(vm.mode == mode ? Color.bbCoralDeep : Color.bbCard)
                .clipShape(Capsule())
                .bbShadowSoft()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Period controls

    private var dayPickerCard: some View {
        HStack {
            Text(vm.periodTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Spacer()
            DatePicker("", selection: $vm.selectedDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
        }
        .bbCard(pad: 12)
    }

    private var periodNavigator: some View {
        HStack {
            navButton("chevron.left") { vm.shift(-1) }
            Spacer()
            Text(vm.periodTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
                .contentTransition(.interpolate)
            Spacer()
            navButton("chevron.right") { vm.shift(1) }
        }
        .bbCard(pad: 12)
    }

    private func navButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.bbInkSoft)
                .frame(width: 34, height: 34)
                .background(Color.bbCream)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch vm.mode {
        case .day:
            LogReportDayList(items: vm.items, emptyText: loc.strings.logReportEmpty)
        case .week:
            LogReportWeekTimeline(vm: vm)
            selectedDayList
        case .month:
            LogReportMonthGrid(vm: vm)
            selectedDayList
        }
    }

    private var selectedDayList: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: vm.periodTitleForSelectedDay)
            LogReportDayList(items: vm.items(on: vm.selectedDate),
                             emptyText: loc.strings.logReportEmpty)
        }
    }
}

private extension LogReportViewModel {
    var periodTitleForSelectedDay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
}
```

## B5. `Momsy/Features/LogReport/Presentation/Views/LogReportDayList.swift`

Стиль строк — как в `AllTodayEntriesView.entryRow` (проверено):

```swift
import SwiftUI

struct LogReportDayList: View {
    let items: [LogReportItem]
    let emptyText: String

    var body: some View {
        VStack(spacing: 10) {
            if items.isEmpty {
                Text(emptyText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .bbCard(pad: 14)
            } else {
                ForEach(items) { item in
                    row(item)
                }
            }
        }
    }

    private func row(_ item: LogReportItem) -> some View {
        HStack(spacing: 12) {
            Text(DateFormatter.bbTime.string(from: item.start))
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.bbInkMute)
                .frame(width: 44, alignment: .leading)
            CuteBlobView(kind: item.kind, size: 32, tone: item.kind.defaultTone)
            Text(item.label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInk)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .bbShadowSoft()
    }
}
```

## B6. `Momsy/Features/LogReport/Presentation/Views/LogReportWeekTimeline.swift`

Таймлайн 7 × 24 ч как на референсе: длительные события — блоки цвета `kind.defaultTone`, мгновенные (подгузник/стул/витамин) — тонкие штрихи. Тап по колонке выбирает день.

```swift
import SwiftUI

struct LogReportWeekTimeline: View {
    @ObservedObject var vm: LogReportViewModel

    private let hourHeight: CGFloat = 24
    private var timelineHeight: CGFloat { hourHeight * 24 }
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 8) {
            weekHeader
            HStack(alignment: .top, spacing: 0) {
                hourAxis
                ForEach(vm.weekDays, id: \.self) { day in
                    dayColumn(day)
                }
            }
            .frame(height: timelineHeight)
        }
        .bbCard(pad: 14)
    }

    // MARK: - Header

    private var weekHeader: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: 34)
            ForEach(vm.weekDays, id: \.self) { day in
                let selected = calendar.isDate(day, inSameDayAs: vm.selectedDate)
                VStack(spacing: 2) {
                    Text(weekdayLabel(day))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                    Text("\(calendar.component(.day, from: day))")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(selected ? .white : .bbInk)
                        .frame(width: 26, height: 26)
                        .background(selected ? Color.bbCoralDeep : .clear)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { vm.selectedDate = day }
            }
        }
    }

    // MARK: - Axis & columns

    private var hourAxis: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(stride(from: 0, through: 22, by: 2)), id: \.self) { hour in
                Text(String(format: "%02d", hour))
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.bbInkMute)
                    .offset(y: CGFloat(hour) * hourHeight - 5)
            }
        }
        .frame(width: 34, height: timelineHeight, alignment: .topLeading)
    }

    private func dayColumn(_ day: Date) -> some View {
        let selected = calendar.isDate(day, inSameDayAs: vm.selectedDate)
        return ZStack(alignment: .top) {
            gridLines
            if selected {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.bbCoral.opacity(0.08))
            }
            GeometryReader { geo in
                ForEach(vm.timelineSegments(on: day)) { segment in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(segment.kind.defaultTone)
                        .frame(
                            width: max(4, geo.size.width - 6),
                            height: segment.isInstant
                                ? 3
                                : max(4, CGFloat(segment.endMinute - segment.startMinute) / 60 * hourHeight)
                        )
                        .offset(x: 3, y: CGFloat(segment.startMinute) / 60 * hourHeight)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { vm.selectedDate = day }
    }

    private var gridLines: some View {
        ZStack(alignment: .top) {
            ForEach(0..<13, id: \.self) { step in
                Rectangle()
                    .fill(Color.bbInkMute.opacity(0.12))
                    .frame(height: 0.5)
                    .offset(y: CGFloat(step) * hourHeight * 2)
            }
        }
    }

    private func weekdayLabel(_ day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day)
    }
}
```

## B7. `Momsy/Features/LogReport/Presentation/Views/LogReportMonthGrid.swift`

```swift
import SwiftUI

struct LogReportMonthGrid: View {
    @ObservedObject var vm: LogReportViewModel

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(vm.monthDays.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
        .bbCard(pad: 14)
    }

    private func dayCell(_ day: Date) -> some View {
        let selected = calendar.isDate(day, inSameDayAs: vm.selectedDate)
        let kinds = vm.kinds(on: day)
        return VStack(spacing: 3) {
            Text("\(calendar.component(.day, from: day))")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(selected ? .white : .bbInk)
                .frame(width: 28, height: 28)
                .background(selected ? Color.bbCoralDeep : .clear)
                .clipShape(Circle())
            HStack(spacing: 2) {
                ForEach(kinds, id: \.self) { kind in
                    Circle()
                        .fill(kind.defaultTone)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture { vm.selectedDate = day }
    }
}
```

---

# Часть C — Интеграция

## C1. `Momsy/Core/DI/AppContainer.swift`

1. **Строка 33** — после `lazy var pumpingRepository ...`:

```swift
    lazy var vitaminRepository: any VitaminRepository                            = SwiftDataVitaminRepository(context: context)
```

2. **Вызов CloudSyncDownloader** (строки 48–72) — после `pumpingRepo: pumpingRepository,` (строка 59):

```swift
            vitaminRepo: vitaminRepository,
```

3. **Строки 517–519** — обновить фабрику:

```swift
    func makeVitaminViewModel() -> VitaminViewModel {
        VitaminViewModel(quickLogRepo: quickLogRepository, vitaminRepo: vitaminRepository)
    }
```

4. После `makeReportViewModel()` (закрывающая `}` на строке 502) добавить:

```swift
    lazy var getLogReportEntries = GetLogReportEntriesUseCase(
        feedingRepo: feedingRepository,
        sleepRepo: sleepRepository,
        diaperRepo: diaperRepository,
        stoolRepo: stoolRepository,
        walkRepo: walkRepository,
        bathRepo: bathRepository,
        pumpingRepo: pumpingRepository,
        vitaminRepo: vitaminRepository
    )

    func makeLogReportViewModel() -> LogReportViewModel {
        LogReportViewModel(getEntries: getLogReportEntries)
    }
```

## C2. `Momsy/Features/Doctor/Presentation/Views/DoctorMenuView.swift`

Вставка между строкой AI-отчёта (`WeeklyInsightView`, строки 52–59) и строкой педиатра. Diff:

```swift
// БЫЛО (строки 60–68)
                        Divider().padding(.leading, 60)
                        DoctorMenuRow(
                            destination: ReportView(container: container),
// СТАЛО
                        Divider().padding(.leading, 60)
                        DoctorMenuRow(
                            destination: LogReportView(container: container),
                            icon: "calendar.badge.clock",
                            iconColor: .bbCoralDeep,
                            iconBg: Color.bbCoral.opacity(0.2),
                            title: lm.strings.logReportTitle,
                            sub: lm.strings.logReportSub
                        )
                        Divider().padding(.leading, 60)
                        DoctorMenuRow(
                            destination: ReportView(container: container),
```

## C3. `Momsy/Core/Localization/L10n.swift`

Перед закрывающей `}` файла (строка 1566), после блока Notifications. `reportPeriodWeek`/`reportPeriodMonth` переиспользуются (строки 820, 822) — новых ключей всего 4:

```swift
    // MARK: — Log Report (Doctor)
    var logReportTitle: String { s("Report", "Отчёт", "Bericht", "Informe", "Rapport", "Relatório", "报告") }
    var logReportSub: String   { s("All entries — day, week, month", "Все записи — день, неделя, месяц", "Alle Einträge — Tag, Woche, Monat", "Todos los registros — día, semana, mes", "Toutes les entrées — jour, semaine, mois", "Todos os registos — dia, semana, mês", "全部记录——日、周、月") }
    var logReportDay: String   { s("Day", "День", "Tag", "Día", "Jour", "Dia", "日") }
    var logReportEmpty: String { s("No entries for this period", "Нет записей за этот период", "Keine Einträge für diesen Zeitraum", "No hay registros en este período", "Aucune entrée pour cette période", "Sem registos neste período", "此时段暂无记录") }
```

---

# Часть D — Тесты (Swift Testing)

## D1. Новые моки в `MomsyTests/Mocks/`

`MockWalkRepository.swift`:

```swift
@testable import Momsy
import Foundation

final class MockWalkRepository: WalkRepository {
    var entries: [WalkEntry] = []

    func start() async throws -> WalkEntry { WalkEntry(startDate: Date()) }
    func stop(_ entry: WalkEntry) async throws -> WalkEntry { entry }
    func getEntries(from: Date, to: Date) async throws -> [WalkEntry] {
        entries.filter { $0.startDate >= from && $0.startDate < to }
    }
    func add(_ entry: WalkEntry) async throws { entries.append(entry) }
    func upsert(_ newEntries: [WalkEntry]) async throws {
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }
    func resolveOrphan(id: UUID, endDate: Date?) async throws {}
}
```

`MockBathRepository.swift` — идентично для `BathRepository`/`BathEntry`.

`MockPumpingRepository.swift`:

```swift
@testable import Momsy
import Foundation

final class MockPumpingRepository: PumpingRepository {
    var entries: [PumpingEntry] = []

    func start(side: PumpingSide) async throws -> PumpingEntry {
        PumpingEntry(id: UUID(), date: Date(), durationSeconds: 0, side: side, volumeML: 0)
    }
    func stop(_ entry: PumpingEntry, volumeML: Int) async throws -> PumpingEntry { entry }
    func getEntries(from: Date, to: Date) async throws -> [PumpingEntry] {
        entries.filter { $0.date >= from && $0.date < to }
    }
    func logManual(date: Date, durationMinutes: Int, side: PumpingSide, volumeML: Int) async throws -> PumpingEntry {
        let entry = PumpingEntry(id: UUID(), date: date, durationSeconds: durationMinutes * 60,
                                 side: side, volumeML: volumeML)
        entries.append(entry)
        return entry
    }
    func upsert(_ newEntries: [PumpingEntry]) async throws {
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }
}
```

`MockVitaminRepository.swift`:

```swift
@testable import Momsy
import Foundation

final class MockVitaminRepository: VitaminRepository {
    var entries: [VitaminEntry] = []

    func add(_ entry: VitaminEntry) async throws { entries.append(entry) }
    func upsert(_ newEntries: [VitaminEntry]) async throws {
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }
    func getEntries(from: Date, to: Date) async throws -> [VitaminEntry] {
        entries.filter { $0.date >= from && $0.date < to }
    }
}
```

## D2. `MomsyTests/Features/LogReport/LogReportViewModelTests.swift`

```swift
import Testing
import Foundation
@testable import Momsy

@MainActor
struct LogReportViewModelTests {

    private func makeSUT() -> (LogReportViewModel, MockFeedingRepository, MockSleepRepository,
                               MockDiaperRepository, MockVitaminRepository) {
        let feeding = MockFeedingRepository()
        let sleep = MockSleepRepository()
        let diaper = MockDiaperRepository()
        let vitamin = MockVitaminRepository()
        let useCase = GetLogReportEntriesUseCase(
            feedingRepo: feeding, sleepRepo: sleep,
            diaperRepo: diaper, stoolRepo: MockStoolRepository(),
            walkRepo: MockWalkRepository(), bathRepo: MockBathRepository(),
            pumpingRepo: MockPumpingRepository(), vitaminRepo: vitamin
        )
        return (LogReportViewModel(getEntries: useCase), feeding, sleep, diaper, vitamin)
    }

    @Test func dayModeAggregatesAllSourcesNewestFirst() async {
        let (vm, feeding, sleep, _, vitamin) = makeSUT()
        let now = Date()
        feeding.entries = [FeedingEntry(date: now.addingTimeInterval(-3_600), durationSeconds: 600)]
        sleep.entries = [SleepEntry(startDate: now.addingTimeInterval(-7_200),
                                    endDate: now.addingTimeInterval(-5_400))]
        vitamin.entries = [VitaminEntry(date: now.addingTimeInterval(-600), label: "Vitamins · D3")]

        vm.mode = .day
        vm.selectedDate = now
        await vm.load()

        #expect(vm.items.count == 3)
        #expect(vm.items.first?.kind == .vitamin)
        #expect(vm.items.last?.kind == .sleep)
    }

    @Test func vitaminEntriesComeFromLocalRepository() async {
        let (vm, _, _, _, vitamin) = makeSUT()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        vitamin.entries = [VitaminEntry(date: yesterday, label: "Vitamins · given")]

        vm.mode = .day
        vm.selectedDate = yesterday
        await vm.load()

        #expect(vm.items.contains { $0.kind == .vitamin })
    }

    @Test func diaperLabelsAreNumberedPerDayAscending() async {
        let (vm, _, _, diaper, _) = makeSUT()
        let dayStart = Calendar.current.startOfDay(for: Date())
        diaper.entries = [
            DiaperEntry(date: dayStart.addingTimeInterval(10 * 3_600)),
            DiaperEntry(date: dayStart.addingTimeInterval(8 * 3_600)),
        ]

        vm.mode = .day
        vm.selectedDate = dayStart
        await vm.load()

        let diapers = vm.items.filter { $0.kind == .drop }.sorted { $0.start < $1.start }
        #expect(diapers.first?.label.contains("#1") == true)
        #expect(diapers.last?.label.contains("#2") == true)
    }

    @Test func weekRangeSpansSevenDays() {
        let (vm, _, _, _, _) = makeSUT()
        vm.mode = .week
        #expect(vm.weekDays.count == 7)
        let bounds = vm.range
        #expect(Int(bounds.to.timeIntervalSince(bounds.from)) == 7 * 86_400)
    }

    @Test func sleepCrossingMidnightAppearsInBothDayColumns() async {
        let (vm, _, sleep, _, _) = makeSUT()
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        sleep.entries = [SleepEntry(startDate: yesterday.addingTimeInterval(23 * 3_600),
                                    endDate: today.addingTimeInterval(3_600))]

        vm.mode = .week
        vm.selectedDate = today
        await vm.load()

        // The same session yields a clipped segment on both days of the timeline.
        #expect(!vm.timelineSegments(on: yesterday).isEmpty || !vm.weekDays.contains(yesterday))
        #expect(!vm.timelineSegments(on: today).isEmpty)
    }
}
```

Примечание к последнему тесту: если `yesterday` попадает в предыдущую неделю, сегмент за вчера не грузится — условие это учитывает. `MockSleepRepository.getEntries(from:to:)` фильтрует по `startDate`, поэтому extension `getEntries(overlapping:until:)` (lookback 24 ч) корректно захватит сессию.

---

# Definition of Done

- [ ] `VitaminRecord` в схеме (`AppPersistence.swift`), `schemaVersion = "v23"`, приложение стартует на сторе от v22 без пересоздания
- [ ] `VitaminViewModel.add()` пишет в SwiftData; после перезапуска на следующий день витамин виден в новом Report
- [ ] `CloudSyncDownloader` апсертит `vitaminLogs` в `VitaminRecord`; `commit(vitaminFetch)` удалён; поведение quick-log strip не изменилось
- [ ] Новый пункт «Report» в Doctor стоит между AI-отчётом и «Отчёт для педиатра»; остальные пункты не тронуты
- [ ] Режим «День»: выбор даты, список записей в стиле Today so far, пустое состояние
- [ ] Режим «Неделя»: 7 колонок × 24 ч, блоки по `defaultTone`, штрихи для мгновенных событий, сон через полночь режется по колонкам, тап по дню показывает список ниже
- [ ] Режим «Месяц»: сетка с точками типов, тап по дню показывает список ниже, переключение месяцев стрелками
- [ ] 4 новых ключа L10n заполнены для всех 7 языков; переиспользованы `reportPeriodWeek`/`reportPeriodMonth`
- [ ] Никакие другие экраны/функции не изменены (Today, Vitamin sheet UX, sync-поведение walk/bath/stool/diaper)
- [ ] `xcodebuild test -scheme Momsy` зелёный, включая новые `LogReportViewModelTests`

# Manual QA (симулятор)

1. Залогировать за сегодня: кормление, сон, подгузник, стул, прогулку, купание, витамин (с именем), сцеживание.
2. Doctor → Report: пункт стоит сразу после «Отчёт за неделю (AI)». Открыть.
3. «День» (сегодня): все 8 записей присутствуют, лейблы совпадают с Today so far, подгузники нумеруются.
4. «Неделя»: блоки сна/кормления/прогулки на сегодняшней колонке в правильные часы; тап по вчерашней колонке — пустой список.
5. Начать сон в 23:50, завершить в 00:40 (сменить время устройства или вручную): в недельном таймлайне сегмент есть в обеих колонках.
6. «Месяц»: у сегодняшней даты точки типов; листание на прошлый месяц — пустая сетка без крэша.
7. Перезапустить приложение, сменить дату устройства на +1 день: в «День» за вчера витамин остался (SwiftData, не UserDefaults).
8. Сменить язык на RU/DE: заголовок, чипы, пустое состояние локализованы.
9. Второй родитель добавляет витамин → после синка он появляется в Report на первом устройстве (день витамина).
10. Переключить активного ребёнка: Report показывает только записи выбранного ребёнка.
