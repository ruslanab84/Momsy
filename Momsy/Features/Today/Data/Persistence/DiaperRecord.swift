import SwiftData
import Foundation

@Model
final class DiaperRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var updatedAt: Date?

    init(id: UUID = UUID(), date: Date = Date(), updatedAt: Date? = nil) {
        self.id = id
        self.date = date
        self.updatedAt = updatedAt
    }

    func apply(_ entry: DiaperEntry) {
        date = entry.date
        updatedAt = entry.updatedAt
    }

    func toDomain() -> DiaperEntry {
        DiaperEntry(id: id, date: date, updatedAt: updatedAt)
    }
}
