import Foundation

struct FeedingLog: Identifiable, Equatable {
    let id: String
    let startedAt: Date
    let endedAt: Date?
    let durationMin: Int
    let side: FeedingSide
    let amountMl: Int?
    let addedBy: String
    let addedByName: String
}
