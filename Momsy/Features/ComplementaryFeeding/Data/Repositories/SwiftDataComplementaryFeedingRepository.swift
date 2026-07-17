import SwiftData
import Foundation

@MainActor
final class SwiftDataComplementaryFeedingRepository: ComplementaryFeedingRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getAll() async throws -> [ComplementaryFoodEntry] {
        let scope = ActiveBaby.scope
        let records = try context.fetch(FetchDescriptor<ComplementaryFoodRecord>(predicate: #Predicate { $0.babyId == scope }))
        return records.map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func getEntries(from: Date, to: Date) async throws -> [ComplementaryFoodEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<ComplementaryFoodRecord>(
            predicate: #Predicate { $0.date >= from && $0.date < to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ entry: ComplementaryFoodEntry) async throws {
        context.insert(ComplementaryFoodRecord(
            id: entry.id, date: entry.date, foodName: entry.foodName,
            category: entry.category.rawValue, reaction: entry.reaction.rawValue,
            isAllergen: entry.isAllergen, notes: entry.notes,
            updatedAt: entry.updatedAt
        ))
        try context.save()
    }

    func upsert(_ entries: [ComplementaryFoodEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<ComplementaryFoodRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
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
                context.insert(ComplementaryFoodRecord(
                    id: entry.id, date: entry.date, foodName: entry.foodName,
                    category: entry.category.rawValue, reaction: entry.reaction.rawValue,
                    isAllergen: entry.isAllergen, notes: entry.notes,
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
        let id = entry.id
        var descriptor = FetchDescriptor<ComplementaryFoodRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let rec = try context.fetch(descriptor).first else { return }
        rec.apply(entry)
        try context.save()
    }

    func delete(id: UUID) async throws {
        var descriptor = FetchDescriptor<ComplementaryFoodRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let rec = try context.fetch(descriptor).first else { return }
        context.delete(rec)
        try context.save()
    }

    func applyDeletions(_ ids: Set<UUID>) async throws {
        guard !ids.isEmpty else { return }
        let idArray = Array(ids)
        let matches = try context.fetch(
            FetchDescriptor<ComplementaryFoodRecord>(predicate: #Predicate { idArray.contains($0.id) })
        )
        guard !matches.isEmpty else { return }
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
