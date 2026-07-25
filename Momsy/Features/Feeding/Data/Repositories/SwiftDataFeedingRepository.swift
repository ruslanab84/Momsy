import SwiftData
import Foundation

@MainActor
final class SwiftDataFeedingRepository: FeedingRepository {
    private let context: ModelContext
    private let calendar = Calendar.current

    init(context: ModelContext) { self.context = context }

    func getEntries(for date: Date) async throws -> [FeedingEntry] {
        let start = calendar.startOfDay(for: date)
        guard let next = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<FeedingRecord>(
            predicate: #Predicate { $0.date >= start && $0.date < next && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func getEntries(from: Date, to: Date) async throws -> [FeedingEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<FeedingRecord>(
            predicate: #Predicate { $0.date >= from && $0.date < to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: FeedingEntry) async throws {
        context.insert(FeedingRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [FeedingEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<FeedingRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert: context.insert(FeedingRecord(entry)); changed = true
            case .update: record?.merge(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func delete(id: UUID) async throws {
        var descriptor = FetchDescriptor<FeedingRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }
}
