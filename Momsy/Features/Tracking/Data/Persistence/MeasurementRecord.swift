import SwiftData
import Foundation

@Model
final class MeasurementRecord {
    var id: UUID
    var date: Date
    var dateLabel: String
    var weight: String
    var height: String
    var headCirc: String
    var delta: String
    var visitLabel: String?

    init(_ entry: MeasurementEntry) {
        id         = entry.id
        date       = entry.date
        dateLabel  = entry.dateLabel
        weight     = entry.weight
        height     = entry.height
        headCirc   = entry.headCirc
        delta      = entry.delta
        visitLabel = entry.visitLabel
    }

    func toDomain() -> MeasurementEntry {
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM"
        fmt.locale = Locale.current
        let label = fmt.string(from: date)
        return MeasurementEntry(
            id: id, date: date, dateLabel: label, weight: weight,
            height: height, headCirc: headCirc, delta: delta, visitLabel: visitLabel
        )
    }
}
