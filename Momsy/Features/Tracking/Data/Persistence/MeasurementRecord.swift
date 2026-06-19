import SwiftData
import Foundation

@Model
final class MeasurementRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var dateLabel: String = ""
    var weight: String = ""
    var height: String = ""
    var headCirc: String = ""
    var delta: String = ""
    var visitLabel: String?
    var updatedAt: Date?

    init(_ entry: MeasurementEntry) {
        id = entry.id
        babyId = ActiveBaby.scope
        apply(entry)
    }

    func apply(_ entry: MeasurementEntry) {
        date       = entry.date
        dateLabel  = entry.dateLabel
        weight     = entry.weight
        height     = entry.height
        headCirc   = entry.headCirc
        delta      = entry.delta
        visitLabel = entry.visitLabel
        updatedAt  = entry.updatedAt
    }

    /// Cloud-merge update: overwrites only the fields the synced DTO carries.
    /// `delta` and `visitLabel` are local-only, so they are preserved.
    func merge(_ entry: MeasurementEntry) {
        date      = entry.date
        weight    = entry.weight
        height    = entry.height
        headCirc  = entry.headCirc
        updatedAt = entry.updatedAt
    }

    func toDomain() -> MeasurementEntry {
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM"
        fmt.locale = Locale.current
        let label = fmt.string(from: date)
        return MeasurementEntry(
            id: id, date: date, dateLabel: label, weight: weight,
            height: height, headCirc: headCirc, delta: delta, visitLabel: visitLabel,
            updatedAt: updatedAt
        )
    }
}
