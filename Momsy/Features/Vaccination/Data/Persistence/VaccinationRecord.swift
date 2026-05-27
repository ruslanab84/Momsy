import SwiftData
import Foundation

@Model
final class VaccinationRecord {
    var id: UUID
    var catalogId: Int
    var doneDate: Date
    var notes: String
    var customName: String?

    init(id: UUID = UUID(), catalogId: Int, doneDate: Date, notes: String = "", customName: String? = nil) {
        self.id = id
        self.catalogId = catalogId
        self.doneDate = doneDate
        self.notes = notes
        self.customName = customName
    }

    func toDomain() -> VaccinationEntry {
        VaccinationEntry(id: id, catalogId: catalogId, doneDate: doneDate, notes: notes, customName: customName)
    }
}
