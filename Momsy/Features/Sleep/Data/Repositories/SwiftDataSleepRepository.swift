import SwiftData
import Foundation

final class SwiftDataSleepRepository: SleepRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        let all = try context.fetch(FetchDescriptor<SleepRecord>())
        return all.filter { $0.startDate >= from && $0.startDate <= to }
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: SleepEntry) async throws {
        context.insert(SleepRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [SleepEntry]) async throws {
        guard !entries.isEmpty else { return }
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<SleepRecord>()).map { ($0.id, $0) },
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
        let all = try context.fetch(FetchDescriptor<SleepRecord>())
        guard let record = all.first(where: { $0.id == entry.id }) else { return }
        record.apply(entry)
        try context.save()
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<SleepRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
