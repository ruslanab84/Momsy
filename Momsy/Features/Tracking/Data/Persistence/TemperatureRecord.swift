import SwiftData
import Foundation

@Model
final class TemperatureRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var dateLabel: String = ""
    var timeLabel: String = ""
    var value: Double = 0
    var note: String = ""

    init(_ entry: TemperatureEntry) {
        id        = entry.id
        date      = entry.date
        dateLabel = entry.dateLabel
        timeLabel = entry.timeLabel
        value     = entry.value
        note      = entry.note
    }

    func toDomain() -> TemperatureEntry {
        TemperatureEntry(id: id, date: date, dateLabel: dateLabel,
                         timeLabel: timeLabel, value: value, note: note)
    }
}
