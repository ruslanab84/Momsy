import SwiftData
import Foundation

@Model
final class StoolRecord {
    var id: UUID = UUID()
    var date: Date = Date()

    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}
