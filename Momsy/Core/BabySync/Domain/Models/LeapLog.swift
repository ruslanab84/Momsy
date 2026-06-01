import Foundation

struct LeapLog: Identifiable, Equatable {
    /// Firestore doc id — the leap's catalog id as a string (stable, idempotent).
    let id: String
    let leapId: Int
    let isDone: Bool
    let completedDate: Date?
    let addedBy: String
    let addedByName: String
}
