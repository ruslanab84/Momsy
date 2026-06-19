import SwiftData
import Foundation

@Model
final class StoolRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()

    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.babyId = ActiveBaby.scope
        self.date = date
    }
}
