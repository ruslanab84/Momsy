import SwiftData
import Foundation

final class SwiftDataMomSleepRepository: MomSleepRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        var descriptor = FetchDescriptor<MomSleepRecord>(
            predicate: #Predicate { $0.startDate >= from && $0.startDate <= to }
        )
        descriptor.sortBy = [SortDescriptor(\.startDate)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ entry: SleepEntry) async throws {
        context.insert(MomSleepRecord(entry))
        try context.save()
    }

    func update(_ entry: SleepEntry) async throws {
        let id = entry.id
        var descriptor = FetchDescriptor<MomSleepRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            record.apply(entry)
            try context.save()
        }
    }

    func upsert(_ entries: [SleepEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<MomSleepRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert: context.insert(MomSleepRecord(entry)); changed = true
            case .update: record?.merge(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func delete(id: UUID) async throws {
        var descriptor = FetchDescriptor<MomSleepRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }
}
