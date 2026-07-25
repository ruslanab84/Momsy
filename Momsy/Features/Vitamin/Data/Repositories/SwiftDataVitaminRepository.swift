import SwiftData
import Foundation

@MainActor
final class SwiftDataVitaminRepository: VitaminRepository {
    private let context: ModelContext
    private let defaults: UserDefaults

    private var categoriesKey: String {
        "local_vitamin_categories_\(ActiveBaby.scope.uuidString)"
    }

    init(context: ModelContext, defaults: UserDefaults = .standard) {
        self.context = context
        self.defaults = defaults
    }

    func add(_ entry: VitaminEntry) async throws {
        context.insert(VitaminRecord(id: entry.id, date: entry.date, label: entry.label))
        try context.save()
    }

    func upsert(_ entries: [VitaminEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let existing = Set(try context.fetch(
            FetchDescriptor<VitaminRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
        ).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(VitaminRecord(id: entry.id, date: entry.date, label: entry.label))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func getEntries(from: Date, to: Date) async throws -> [VitaminEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<VitaminRecord>(
            predicate: #Predicate { $0.date >= from && $0.date < to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func loadCategories() -> [String] {
        defaults.stringArray(forKey: categoriesKey) ?? []
    }

    func saveCategories(_ categories: [String]) {
        defaults.set(categories, forKey: categoriesKey)
    }
}
