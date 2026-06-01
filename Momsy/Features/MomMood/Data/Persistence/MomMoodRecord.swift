import SwiftData
import Foundation

@Model
final class MomMoodRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var mood: Int = 0
    var energy: Int = 0
    var note: String = ""
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
