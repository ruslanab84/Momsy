import SwiftData
import Foundation

@Model
final class FeedingRecord {
    var id: UUID
    var date: Date
    var durationSeconds: Int
    var sideRaw: String
    var mood: String?

    init(_ entry: FeedingEntry) {
        id              = entry.id
        date            = entry.date
        durationSeconds = entry.durationSeconds
        sideRaw         = entry.side.rawValue
        mood            = entry.mood
    }

    func toDomain() -> FeedingEntry {
        FeedingEntry(
            id: id, date: date, durationSeconds: durationSeconds,
            side: FeedingSide(rawValue: sideRaw) ?? .left,
            mood: mood
        )
    }
}
