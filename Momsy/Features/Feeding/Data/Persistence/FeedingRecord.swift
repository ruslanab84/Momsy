import SwiftData
import Foundation

@Model
final class FeedingRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var durationSeconds: Int = 0
    var sideRaw: String = ""
    var mood: String?
    var milliliters: Int?
    var updatedAt: Date?

    init(_ entry: FeedingEntry) {
        id = entry.id
        apply(entry)
    }

    func apply(_ entry: FeedingEntry) {
        date            = entry.date
        durationSeconds = entry.durationSeconds
        sideRaw         = entry.side.rawValue
        mood            = entry.mood
        milliliters     = entry.milliliters
        updatedAt       = entry.updatedAt
    }

    /// Cloud-merge update: overwrites only the fields the synced DTO carries.
    /// `mood` is local-only (never synced), so it is preserved.
    func merge(_ entry: FeedingEntry) {
        date            = entry.date
        durationSeconds = entry.durationSeconds
        sideRaw         = entry.side.rawValue
        milliliters     = entry.milliliters
        updatedAt       = entry.updatedAt
    }

    func toDomain() -> FeedingEntry {
        FeedingEntry(
            id: id, date: date, durationSeconds: durationSeconds,
            side: FeedingSide(rawValue: sideRaw) ?? .left,
            mood: mood,
            milliliters: milliliters,
            updatedAt: updatedAt
        )
    }
}
