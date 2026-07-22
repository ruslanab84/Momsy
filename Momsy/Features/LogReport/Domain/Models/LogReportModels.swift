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
