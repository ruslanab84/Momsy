import SwiftData
import Foundation

@Model
final class TemperatureRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var dateLabel: String = ""
    var timeLabel: String = ""
    var value: Double = 0
    var note: String = ""
    var updatedAt: Date?

    init(_ entry: TemperatureEntry) {
        id = entry.id
        babyId = ActiveBaby.scope
        apply(entry)
    }

    func apply(_ entry: TemperatureEntry) {
        date      = entry.date
        dateLabel = entry.dateLabel
        timeLabel = entry.timeLabel
        value     = entry.value
        note      = entry.note
        updatedAt = entry.updatedAt
    }

    func toDomain() -> TemperatureEntry {
        TemperatureEntry(id: id, date: date, dateLabel: dateLabel,
                         timeLabel: timeLabel, value: value, note: note,
                         updatedAt: updatedAt)
    }
}
