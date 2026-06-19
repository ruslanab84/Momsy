import SwiftData
import Foundation

@MainActor
final class SwiftDataVaccinationRepository: VaccinationRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getAll() async throws -> [VaccinationEntry] {
        let scope = ActiveBaby.scope
        let records = try context.fetch(FetchDescriptor<VaccinationRecord>(predicate: #Predicate { $0.babyId == scope }))
        return records.uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func save(_ entry: VaccinationEntry) async throws {
        // Dedup only for catalog entries — custom vaccines (isCustom) each have a unique catalogId
        if !entry.isCustom {
            let catalogId = entry.catalogId
            let scope = ActiveBaby.scope
            var descriptor = FetchDescriptor<VaccinationRecord>(predicate: #Predicate { $0.catalogId == catalogId && $0.babyId == scope })
            descriptor.fetchLimit = 1
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
            }
        }
        context.insert(VaccinationRecord(id: entry.id, catalogId: entry.catalogId,
                                          doneDate: entry.doneDate, notes: entry.notes,
                                          customName: entry.customName, updatedAt: entry.updatedAt))
        try context.save()
    }

    func upsert(_ entries: [VaccinationEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<VaccinationRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
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
        var descriptor = FetchDescriptor<VaccinationRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let rec = try context.fetch(descriptor).first {
            context.delete(rec)
            try context.save()
        }
    }

    func applyDeletions(_ ids: Set<UUID>) async throws {
        guard !ids.isEmpty else { return }
        let idArray = Array(ids)
        let matches = try context.fetch(
            FetchDescriptor<VaccinationRecord>(predicate: #Predicate { idArray.contains($0.id) })
        )
        guard !matches.isEmpty else { return }
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
