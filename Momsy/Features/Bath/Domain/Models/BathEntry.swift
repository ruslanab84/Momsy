import Foundation

struct BathEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var startDate: Date
    var endDate: Date?

    var durationMinutes: Int? {
        guard let end = endDate else { return nil }
        return max(1, Int(end.timeIntervalSince(startDate) / 60))
    }
}
