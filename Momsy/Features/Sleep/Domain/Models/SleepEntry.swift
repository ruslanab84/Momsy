import Foundation

struct SleepEntry: Identifiable, Codable {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var note: String

    var durationMinutes: Int? {
        guard let end = endDate else { return nil }
        return Int(end.timeIntervalSince(startDate) / 60)
    }

    init(id: UUID = UUID(), startDate: Date = Date(), endDate: Date? = nil, note: String = "") {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
    }
}
