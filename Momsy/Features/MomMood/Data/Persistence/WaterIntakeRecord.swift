import SwiftData
import Foundation

@Model
final class WaterIntakeRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var amountMl: Int = 0
    var updatedAt: Date?

    init(_ entry: WaterIntakeEntry) {
        id = entry.id
        babyId = ActiveBaby.scope
        apply(entry)
    }

    func apply(_ entry: WaterIntakeEntry) {
        date      = entry.date
        amountMl  = entry.amountMl
        updatedAt = entry.updatedAt
    }

    func toDomain() -> WaterIntakeEntry {
        WaterIntakeEntry(id: id, date: date, amountMl: amountMl, updatedAt: updatedAt)
    }
}
