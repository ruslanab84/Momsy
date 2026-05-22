import SwiftData
import Foundation

@Model
final class SleepRecord {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var note: String
    var qualityRaw: String

    init(_ entry: SleepEntry) {
        id         = entry.id
        startDate  = entry.startDate
        endDate    = entry.endDate
        note       = entry.note
        qualityRaw = entry.quality.rawValue
    }

    func toDomain() -> SleepEntry {
        SleepEntry(
            id: id, startDate: startDate, endDate: endDate, note: note,
            quality: SleepQuality(rawValue: qualityRaw) ?? .normal
        )
    }
}
