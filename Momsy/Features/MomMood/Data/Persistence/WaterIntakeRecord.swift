import SwiftData
import Foundation

@Model
final class WaterIntakeRecord {
    var id: UUID
    var date: Date
    var amountMl: Int

    init(_ entry: WaterIntakeEntry) {
        id       = entry.id
        date     = entry.date
        amountMl = entry.amountMl
    }

    func toDomain() -> WaterIntakeEntry {
        WaterIntakeEntry(id: id, date: date, amountMl: amountMl)
    }
}
