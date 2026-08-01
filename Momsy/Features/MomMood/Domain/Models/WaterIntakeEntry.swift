import Foundation

struct WaterIntakeEntry: Identifiable {
    let id: UUID
    let date: Date
    let amountMl: Int
    var updatedAt: Date? = Date()
    let ownerUID: String
    let ownerName: String

    init(id: UUID, date: Date, amountMl: Int, updatedAt: Date? = Date(),
         ownerUID: String = "", ownerName: String = "") {
        self.id = id
        self.date = date
        self.amountMl = amountMl
        self.updatedAt = updatedAt
        self.ownerUID = ownerUID
        self.ownerName = ownerName
    }
}
