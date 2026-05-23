import Foundation

struct SleepDayPoint: Identifiable {
    let id: Date
    let totalMinutes: Int
    var totalHours: Double { Double(totalMinutes) / 60 }
}

enum SleepQuality: String, Codable, CaseIterable {
    case good = "good"
    case normal = "normal"
    case restless = "restless"
}

struct SleepEntry: Identifiable, Codable {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var note: String
    var quality: SleepQuality

    var durationMinutes: Int? {
        guard let end = endDate else { return nil }
        return Int(end.timeIntervalSince(startDate) / 60)
    }

    init(id: UUID = UUID(), startDate: Date = Date(), endDate: Date? = nil,
         note: String = "", quality: SleepQuality = .normal) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.quality = quality
    }
}
