import SwiftData
import Foundation

@Model
final class VaccinationRecord {
    var id: UUID
    var catalogId: Int
    var doneDate: Date
    var notes: String

    init(id: UUID = UUID(), catalogId: Int, doneDate: Date, notes: String = "") {
        self.id = id
        self.catalogId = catalogId
        self.doneDate = doneDate
        self.notes = notes
    }

    func toDomain() -> VaccinationEntry {
        VaccinationEntry(id: id, catalogId: catalogId, doneDate: doneDate, notes: notes)
    }
}
