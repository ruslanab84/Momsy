import SwiftData
import Foundation

@MainActor
final class SwiftDataSleepRepository: SleepRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<SleepRecord>(
            predicate: #Predicate { $0.startDate >= from && $0.startDate < to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.startDate)]
        return try context.fetch(descriptor).uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: SleepEntry) async throws {
        context.insert(SleepRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [SleepEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<SleepRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert: context.insert(SleepRecord(entry)); changed = true
            case .update: record?.merge(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func update(_ entry: SleepEntry) async throws {
        let id = entry.id
        var descriptor = FetchDescriptor<SleepRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        record.apply(entry)
        try context.save()
    }

    func delete(id: UUID) async throws {
        var descriptor = FetchDescriptor<SleepRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }
}
