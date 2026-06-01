import SwiftData
import Foundation

@Model
final class BathRecord {
    var id: UUID = UUID()
    var startDate: Date = Date()
    var endDate: Date?

    init(_ entry: BathEntry) {
        id        = entry.id
        startDate = entry.startDate
        endDate   = entry.endDate
    }

    func toDomain() -> BathEntry {
        BathEntry(id: id, startDate: startDate, endDate: endDate)
    }
}
