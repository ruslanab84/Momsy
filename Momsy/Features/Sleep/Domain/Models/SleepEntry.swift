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

extension SleepQuality {
    func localizedLabel(_ strings: L10n) -> String {
        switch self {
        case .good:     return strings.qualityGood
        case .normal:   return strings.qualityNormal
        case .restless: return strings.qualityRestless
        }
    }
}

struct SleepEntry: Identifiable, Codable {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var note: String
    var quality: SleepQuality
    /// Last local mutation time, carried through Firestore for last-write-wins merge.
    /// Optional so old persisted JSON (which predates this field) still decodes.
    var updatedAt: Date?
    /// Session author (Firebase uid / display name), carried through Firestore.
    /// nil on locally created entries — the server stamps the author on upload.
    var startedBy: String?
    var startedByName: String?

    var durationMinutes: Int? {
        guard let end = endDate else { return nil }
        return Int(end.timeIntervalSince(startDate) / 60)
    }

    init(id: UUID = UUID(), startDate: Date = Date(), endDate: Date? = nil,
         note: String = "", quality: SleepQuality = .normal, updatedAt: Date? = Date(),
         startedBy: String? = nil, startedByName: String? = nil) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.quality = quality
        self.updatedAt = updatedAt
        self.startedBy = startedBy
        self.startedByName = startedByName
    }
}
