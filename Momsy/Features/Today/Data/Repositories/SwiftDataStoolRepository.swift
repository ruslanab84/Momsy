import SwiftData
import Foundation

final class SwiftDataStoolRepository: StoolRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func add(date: Date) async throws {
        context.insert(StoolRecord(date: date))
        try context.save()
    }

    func add(id: UUID, date: Date) async throws {
        context.insert(StoolRecord(id: id, date: date))
        try context.save()
    }

    func upsert(_ entries: [StoolEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let existing = Set(try context.fetch(
            FetchDescriptor<StoolRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
        ).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(StoolRecord(id: entry.id, date: entry.date))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func getEntries(from: Date, to: Date) async throws -> [Date] {
        var descriptor = FetchDescriptor<StoolRecord>(
            predicate: #Predicate { $0.date >= from && $0.date <= to }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor)
            .uniqued(by: { $0.id })
            .map(\.date)
    }
}
