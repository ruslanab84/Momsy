import SwiftData
import Foundation

@Model
final class SleepRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var startDate: Date = Date()
    var endDate: Date?
    var note: String = ""
    var qualityRaw: String = ""
    var updatedAt: Date?
    var startedBy: String?
    var startedByName: String?

    init(_ entry: SleepEntry) {
        id = entry.id
        babyId = ActiveBaby.scope
        apply(entry)
    }

    func apply(_ entry: SleepEntry) {
        startDate     = entry.startDate
        endDate       = entry.endDate
        note          = entry.note
        qualityRaw    = entry.quality.rawValue
        updatedAt     = entry.updatedAt
        startedBy     = entry.startedBy
        startedByName = entry.startedByName
    }

    /// Cloud-merge update: overwrites only the fields the synced DTO carries.
    /// `note` is local-only (never synced), so it is preserved.
    func merge(_ entry: SleepEntry) {
        startDate     = entry.startDate
        endDate       = entry.endDate
        qualityRaw    = entry.quality.rawValue
        updatedAt     = entry.updatedAt
        startedBy     = entry.startedBy
        startedByName = entry.startedByName
    }

    func toDomain() -> SleepEntry {
        SleepEntry(
            id: id, startDate: startDate, endDate: endDate, note: note,
            quality: SleepQuality(rawValue: qualityRaw) ?? .normal,
            updatedAt: updatedAt,
            startedBy: startedBy, startedByName: startedByName
        )
    }
}
