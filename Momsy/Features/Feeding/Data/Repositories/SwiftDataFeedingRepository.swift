import SwiftData
import Foundation

final class SwiftDataFeedingRepository: FeedingRepository {
    private let context: ModelContext
    private let calendar = Calendar.current

    init(context: ModelContext) { self.context = context }

    func getEntries(for date: Date) async throws -> [FeedingEntry] {
        let all = try context.fetch(FetchDescriptor<FeedingRecord>())
        return all.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func getEntries(from: Date, to: Date) async throws -> [FeedingEntry] {
        let all = try context.fetch(FetchDescriptor<FeedingRecord>())
        return all.filter { $0.date >= from && $0.date <= to }
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: FeedingEntry) async throws {
        context.insert(FeedingRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [FeedingEntry]) async throws {
        guard !entries.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<FeedingRecord>()).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(FeedingRecord(entry))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<FeedingRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
