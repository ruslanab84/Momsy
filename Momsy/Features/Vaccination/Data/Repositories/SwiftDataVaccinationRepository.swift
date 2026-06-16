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
                                          customName: entry.customName, updatedAt: entry.updatedAt))
        try context.save()
    }

    func upsert(_ entries: [VaccinationEntry]) async throws {
        guard !entries.isEmpty else { return }
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<VaccinationRecord>()).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert:
                context.insert(VaccinationRecord(id: entry.id, catalogId: entry.catalogId,
                                                 doneDate: entry.doneDate, notes: entry.notes,
                                                 customName: entry.customName, updatedAt: entry.updatedAt))
                changed = true
            case .update: record?.apply(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<VaccinationRecord>())
        if let rec = all.first(where: { $0.id == id }) {
            context.delete(rec)
            try context.save()
        }
    }

    func applyDeletions(_ ids: Set<UUID>) async throws {
        guard !ids.isEmpty else { return }
        let matches = try context.fetch(FetchDescriptor<VaccinationRecord>()).filter { ids.contains($0.id) }
        guard !matches.isEmpty else { return }
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
