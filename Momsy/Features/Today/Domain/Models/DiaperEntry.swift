import Foundation

struct DiaperEntry: Identifiable, Codable {
    var id: UUID
    var date: Date

    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}
