import Foundation

struct MomMoodEntry: Identifiable {
    let id: UUID
    let date: Date
    let mood: Int       // 1–5
    let energy: Int     // 1–5
    let note: String
    let epdsScore: Int? // nil = not taken; 0–30 if completed
}
