import SwiftData
import Foundation

final class SwiftDataComplementaryFeedingRepository: ComplementaryFeedingRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getAll() async throws -> [ComplementaryFoodEntry] {
        let records = try context.fetch(FetchDescriptor<ComplementaryFoodRecord>())
        return records.map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func add(_ entry: ComplementaryFoodEntry) async throws {
        context.insert(ComplementaryFoodRecord(
            id: entry.id, date: entry.date, foodName: entry.foodName,
            category: entry.category.rawValue, reaction: entry.reaction.rawValue,
            isAllergen: entry.isAllergen, notes: entry.notes, photoPath: entry.photoPath,
            updatedAt: entry.updatedAt
        ))
        try context.save()
    }

    func upsert(_ entries: [ComplementaryFoodEntry]) async throws {
        guard !entries.isEmpty else { return }
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<ComplementaryFoodRecord>()).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert:
                context.insert(ComplementaryFoodRecord(
                    id: entry.id, date: entry.date, foodName: entry.foodName,
                    category: entry.category.rawValue, reaction: entry.reaction.rawValue,
                    isAllergen: entry.isAllergen, notes: entry.notes, photoPath: entry.photoPath,
                    updatedAt: entry.updatedAt
                ))
                changed = true
            case .update: record?.apply(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func update(_ entry: ComplementaryFoodEntry) async throws {
        let all = try context.fetch(FetchDescriptor<ComplementaryFoodRecord>())
        guard let rec = all.first(where: { $0.id == entry.id }) else { return }
        rec.apply(entry)
        try context.save()
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<ComplementaryFoodRecord>())
        guard let rec = all.first(where: { $0.id == id }) else { return }
        context.delete(rec)
        try context.save()
    }

    func applyDeletions(_ ids: Set<UUID>) async throws {
        guard !ids.isEmpty else { return }
        let matches = try context.fetch(FetchDescriptor<ComplementaryFoodRecord>()).filter { ids.contains($0.id) }
        guard !matches.isEmpty else { return }
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
