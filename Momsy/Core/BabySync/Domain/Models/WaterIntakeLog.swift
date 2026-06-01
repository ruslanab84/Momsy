import Foundation

struct WaterIntakeLog: Identifiable, Equatable {
    let id: String
    let date: Date
    let amountMl: Int
    let addedBy: String
    let addedByName: String
}
