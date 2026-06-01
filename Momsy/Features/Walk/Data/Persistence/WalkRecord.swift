import SwiftData
import Foundation

@Model
final class WalkRecord {
    var id: UUID = UUID()
    var startDate: Date = Date()
    var endDate: Date?

    init(_ entry: WalkEntry) {
        id        = entry.id
        startDate = entry.startDate
        endDate   = entry.endDate
    }

    func toDomain() -> WalkEntry {
        WalkEntry(id: id, startDate: startDate, endDate: endDate)
    }
}
