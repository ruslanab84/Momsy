import SwiftData
import Foundation

@Model
final class MomMoodRecord {
    var id: UUID
    var date: Date
    var mood: Int
    var energy: Int
    var note: String
    var epdsScore: Int?

    init(id: UUID = UUID(), date: Date = Date(),
         mood: Int, energy: Int, note: String, epdsScore: Int? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.energy = energy
        self.note = note
        self.epdsScore = epdsScore
    }

    func toDomain() -> MomMoodEntry {
        MomMoodEntry(id: id, date: date, mood: mood, energy: energy, note: note, epdsScore: epdsScore)
    }
}
