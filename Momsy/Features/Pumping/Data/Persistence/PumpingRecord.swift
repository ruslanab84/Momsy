import Foundation
import SwiftData

@Model
final class PumpingRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var durationSeconds: Int = 0
    var sideRaw: String = ""
    var volumeML: Int = 0
    var endDate: Date?
    var updatedAt: Date?

    init(_ entry: PumpingEntry) {
        self.id = entry.id
        apply(entry)
    }

    func apply(_ entry: PumpingEntry) {
        date = entry.date
        durationSeconds = entry.durationSeconds
        sideRaw = entry.side.rawValue
        volumeML = entry.volumeML
        endDate = entry.endDate
        updatedAt = entry.updatedAt
    }

    func toDomain() -> PumpingEntry {
        PumpingEntry(
            id: id,
            date: date,
            durationSeconds: durationSeconds,
            side: PumpingSide(rawValue: sideRaw) ?? .left,
            volumeML: volumeML,
            endDate: endDate,
            updatedAt: updatedAt
        )
    }
}
