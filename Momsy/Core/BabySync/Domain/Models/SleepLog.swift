import Foundation

struct SleepLog: Identifiable, Equatable {
    let id: String
    let startedAt: Date
    let endedAt: Date?
    let durationMin: Int?
    let quality: SleepQuality
    let addedBy: String
    let addedByName: String
}
