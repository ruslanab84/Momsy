import Foundation

struct DiaperEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    /// Last local mutation time, carried through Firestore for last-write-wins merge.
    var updatedAt: Date?

    init(id: UUID = UUID(), date: Date = Date(), updatedAt: Date? = Date()) {
        self.id = id
        self.date = date
        self.updatedAt = updatedAt
    }
}
