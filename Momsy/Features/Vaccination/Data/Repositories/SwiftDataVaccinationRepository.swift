import SwiftData
import Foundation

final class SwiftDataVaccinationRepository: VaccinationRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getAll() async throws -> [VaccinationEntry] {
        let records = try context.fetch(FetchDescriptor<VaccinationRecord>())
        return records.map { $0.toDomain() }
    }

    func save(_ entry: VaccinationEntry) async throws {
        let all = try context.fetch(FetchDescriptor<VaccinationRecord>())
        if let existing = all.first(where: { $0.catalogId == entry.catalogId }) {
            context.delete(existing)
        }
        context.insert(VaccinationRecord(id: entry.id, catalogId: entry.catalogId,
                                          doneDate: entry.doneDate, notes: entry.notes))
        try context.save()
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<VaccinationRecord>())
        if let rec = all.first(where: { $0.id == id }) {
            context.delete(rec)
            try context.save()
        }
    }
}
