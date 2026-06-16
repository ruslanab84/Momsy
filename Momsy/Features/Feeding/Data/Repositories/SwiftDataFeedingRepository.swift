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
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<FeedingRecord>()).map { ($0.id, $0) },
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
        let all = try context.fetch(FetchDescriptor<FeedingRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
