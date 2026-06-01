import Foundation

struct TemperatureLog: Identifiable, Equatable {
    let id: String
    let date: Date
    let value: Double
    let note: String
    let addedBy: String
    let addedByName: String
}
