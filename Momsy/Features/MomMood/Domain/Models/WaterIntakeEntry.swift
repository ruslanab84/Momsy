import Foundation

struct WaterIntakeEntry: Identifiable {
    let id: UUID
    let date: Date
    let amountMl: Int
    var updatedAt: Date? = Date()
}
