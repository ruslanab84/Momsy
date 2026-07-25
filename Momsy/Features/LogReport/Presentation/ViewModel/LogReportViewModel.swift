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
        return items.filter { overlaps($0, dayStart: dayStart, dayEnd: dayEnd) }
    }

    func timelineSegments(on day: Date) -> [LogReportTimelineSegment] {
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return items.compactMap { item in
            let isInstant = item.end == nil
            let end = item.end ?? item.start
            guard overlaps(item, dayStart: dayStart, dayEnd: dayEnd) else { return nil }
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

    private func overlaps(_ item: LogReportItem, dayStart: Date, dayEnd: Date) -> Bool {
        if let end = item.end {
            return item.start < dayEnd && end > dayStart
        }
        return item.start >= dayStart && item.start < dayEnd
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
