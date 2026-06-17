import Foundation

struct LogEntry: Identifiable, Equatable {
    let id = UUID()
    let time: Date
    let kind: BlobKind
    let label: String

    /// Typed duration carried from the source model (feeding/sleep). Avoids
    /// re-parsing it back out of the localized `label`. nil when not applicable
    /// or when the activity is still in progress.
    let durationMinutes: Int?
    /// Localized side display name for feeding entries, captured once at the
    /// source instead of being split out of the composite label.
    let feedSide: String?
    /// True when a feeding was from a bottle — excluded from breast-side rules.
    let isBottleFeed: Bool

    init(
        time: Date,
        kind: BlobKind,
        label: String,
        durationMinutes: Int? = nil,
        feedSide: String? = nil,
        isBottleFeed: Bool = false
    ) {
        self.time = time
        self.kind = kind
        self.label = label
        self.durationMinutes = durationMinutes
        self.feedSide = feedSide
        self.isBottleFeed = isBottleFeed
    }

    var timeString: String { DateFormatter.bbTime.string(from: time) }
}

extension DateFormatter {
    static let bbTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}
