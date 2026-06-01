import Foundation

struct PumpingLog: Identifiable, Equatable {
    let id: String
    let date: Date
    let durationSeconds: Int
    let side: String
    let volumeML: Int
    let endDate: Date?
    let addedBy: String
    let addedByName: String
}
