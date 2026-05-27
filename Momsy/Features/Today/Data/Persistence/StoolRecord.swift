import SwiftData
import Foundation

@Model
final class StoolRecord {
    var id: UUID
    var date: Date

    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}
