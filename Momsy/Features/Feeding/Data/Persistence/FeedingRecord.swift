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

    init(_ entry: FeedingEntry) {
        id              = entry.id
        date            = entry.date
        durationSeconds = entry.durationSeconds
        sideRaw         = entry.side.rawValue
        mood            = entry.mood
        milliliters     = entry.milliliters
    }

    func toDomain() -> FeedingEntry {
        FeedingEntry(
            id: id, date: date, durationSeconds: durationSeconds,
            side: FeedingSide(rawValue: sideRaw) ?? .left,
            mood: mood,
            milliliters: milliliters
        )
    }
}
