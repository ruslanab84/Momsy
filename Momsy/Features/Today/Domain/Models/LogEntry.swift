import Foundation

struct LogEntry: Identifiable, Equatable {
    let id = UUID()
    let time: Date
    let kind: BlobKind
    let label: String

    var timeString: String { DateFormatter.bbTime.string(from: time) }
}

extension DateFormatter {
    static let bbTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}
