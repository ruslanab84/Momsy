import SwiftData
import Foundation

final class SwiftDataVaccinationRepository: VaccinationRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getAll() async throws -> [VaccinationEntry] {
        let records = try context.fetch(FetchDescriptor<VaccinationRecord>())
        return records.uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func save(_ entry: VaccinationEntry) async throws {
        let all = try context.fetch(FetchDescriptor<VaccinationRecord>())
        // Dedup only for catalog entries — custom vaccines (isCustom) each have a unique catalogId
        if !entry.isCustom, let existing = all.first(where: { $0.catalogId == entry.catalogId }) {
            context.delete(existing)
        }
        context.insert(VaccinationRecord(id: entry.id, catalogId: entry.catalogId,
                                          doneDate: entry.doneDate, notes: entry.notes,
                                          customName: entry.customName))
        try context.save()
    }

    func upsert(_ entries: [VaccinationEntry]) async throws {
        guard !entries.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<VaccinationRecord>()).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(VaccinationRecord(id: entry.id, catalogId: entry.catalogId,
                                             doneDate: entry.doneDate, notes: entry.notes,
                                             customName: entry.customName))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<VaccinationRecord>())
        if let rec = all.first(where: { $0.id == id }) {
            context.delete(rec)
            try context.save()
        }
    }
}
