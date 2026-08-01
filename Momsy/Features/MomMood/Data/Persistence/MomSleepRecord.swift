import SwiftData
import Foundation

@Model
final class MomSleepRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var startDate: Date = Date()
    var endDate: Date?
    var note: String = ""
    var qualityRaw: String = ""
    var updatedAt: Date?
    var ownerUID: String = ""
    var ownerName: String = ""

    init(_ entry: SleepEntry, ownerUID: String = "") {
        id = entry.id
        babyId = ActiveBaby.scope
        self.ownerUID = entry.startedBy ?? ownerUID
        ownerName = entry.startedByName ?? ""
        apply(entry)
    }

    func apply(_ entry: SleepEntry) {
        startDate  = entry.startDate
        endDate    = entry.endDate
        note       = entry.note
        qualityRaw = entry.quality.rawValue
        updatedAt  = entry.updatedAt
    }

    /// Cloud-merge update: overwrites only the fields the synced DTO carries.
    /// `note` is local-only (never synced), so it is preserved.
    func merge(_ entry: SleepEntry) {
        startDate  = entry.startDate
        endDate    = entry.endDate
        qualityRaw = entry.quality.rawValue
        updatedAt  = entry.updatedAt
        ownerUID   = entry.startedBy ?? ownerUID
        ownerName  = entry.startedByName ?? ownerName
    }

    func toDomain() -> SleepEntry {
        SleepEntry(
            id: id,
            startDate: startDate,
            endDate: endDate,
            note: note,
            quality: SleepQuality(rawValue: qualityRaw) ?? .normal,
            updatedAt: updatedAt,
            startedBy: ownerUID.isEmpty ? nil : ownerUID,
            startedByName: ownerName.isEmpty ? nil : ownerName
        )
    }
}
