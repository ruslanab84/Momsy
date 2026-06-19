import SwiftData
import Foundation

@Model
final class BathRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var startDate: Date = Date()
    var endDate: Date?

    init(_ entry: BathEntry) {
        id        = entry.id
        babyId    = ActiveBaby.scope
        startDate = entry.startDate
        endDate   = entry.endDate
    }

    func toDomain() -> BathEntry {
        BathEntry(id: id, startDate: startDate, endDate: endDate)
    }
}
