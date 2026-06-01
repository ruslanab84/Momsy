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

    init(_ entry: PumpingEntry) {
        self.id = entry.id
        self.date = entry.date
        self.durationSeconds = entry.durationSeconds
        self.sideRaw = entry.side.rawValue
        self.volumeML = entry.volumeML
        self.endDate = entry.endDate
    }

    func toDomain() -> PumpingEntry {
        PumpingEntry(
            id: id,
            date: date,
            durationSeconds: durationSeconds,
            side: PumpingSide(rawValue: sideRaw) ?? .left,
            volumeML: volumeML,
            endDate: endDate
        )
    }
}
