import SwiftData
import Foundation

@Model
final class WaterIntakeRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var amountMl: Int = 0
    var updatedAt: Date?
    var ownerUID: String = ""
    var ownerName: String = ""

    init(_ entry: WaterIntakeEntry, ownerUID: String = "") {
        id = entry.id
        babyId = ActiveBaby.scope
        self.ownerUID = entry.ownerUID.isEmpty ? ownerUID : entry.ownerUID
        ownerName = entry.ownerName
        apply(entry)
    }

    func apply(_ entry: WaterIntakeEntry) {
        date      = entry.date
        amountMl  = entry.amountMl
        updatedAt = entry.updatedAt
    }

    func merge(_ entry: WaterIntakeEntry) {
        apply(entry)
        ownerUID = entry.ownerUID.isEmpty ? ownerUID : entry.ownerUID
        ownerName = entry.ownerName.isEmpty ? ownerName : entry.ownerName
    }

    func toDomain() -> WaterIntakeEntry {
        WaterIntakeEntry(id: id, date: date, amountMl: amountMl, updatedAt: updatedAt,
                         ownerUID: ownerUID, ownerName: ownerName)
    }
}
