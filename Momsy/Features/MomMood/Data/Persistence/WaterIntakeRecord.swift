import SwiftData
import Foundation

@Model
final class WaterIntakeRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var amountMl: Int = 0

    init(_ entry: WaterIntakeEntry) {
        id       = entry.id
        date     = entry.date
        amountMl = entry.amountMl
    }

    func toDomain() -> WaterIntakeEntry {
        WaterIntakeEntry(id: id, date: date, amountMl: amountMl)
    }
}
