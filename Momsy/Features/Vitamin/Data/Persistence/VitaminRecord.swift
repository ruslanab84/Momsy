import SwiftData
import Foundation

@Model
final class VitaminRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var label: String = ""

    init(id: UUID = UUID(), date: Date = Date(), label: String = "") {
        self.id = id
        self.babyId = ActiveBaby.scope
        self.date = date
        self.label = label
    }

    func toDomain() -> VitaminEntry { VitaminEntry(id: id, date: date, label: label) }
}
