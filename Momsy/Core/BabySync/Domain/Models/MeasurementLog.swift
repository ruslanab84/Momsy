import Foundation

struct MeasurementLog: Identifiable, Equatable {
    let id: String
    let date: Date
    let weight: String
    let height: String
    let headCirc: String
    let addedBy: String
    let addedByName: String
}
