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
            isAllergen: entry.isAllergen, notes: entry.notes, photoPath: entry.photoPath
        ))
        try context.save()
    }

    func upsert(_ entries: [ComplementaryFoodEntry]) async throws {
        guard !entries.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<ComplementaryFoodRecord>()).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(ComplementaryFoodRecord(
                id: entry.id, date: entry.date, foodName: entry.foodName,
                category: entry.category.rawValue, reaction: entry.reaction.rawValue,
                isAllergen: entry.isAllergen, notes: entry.notes, photoPath: entry.photoPath
            ))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func update(_ entry: ComplementaryFoodEntry) async throws {
        let all = try context.fetch(FetchDescriptor<ComplementaryFoodRecord>())
        guard let rec = all.first(where: { $0.id == entry.id }) else { return }
        rec.foodName = entry.foodName
        rec.category = entry.category.rawValue
        rec.reaction = entry.reaction.rawValue
        rec.isAllergen = entry.isAllergen
        rec.notes = entry.notes
        rec.photoPath = entry.photoPath
        try context.save()
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<ComplementaryFoodRecord>())
        guard let rec = all.first(where: { $0.id == id }) else { return }
        context.delete(rec)
        try context.save()
    }
}
