import SwiftData
import Foundation

@MainActor
final class SwiftDataTemperatureRepository: TemperatureRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAll() async throws -> [TemperatureEntry] {
        let scope = ActiveBaby.scope
        let all = try context.fetch(FetchDescriptor<TemperatureRecord>(predicate: #Predicate { $0.babyId == scope }))
        return all.map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func getEntries(from: Date, to: Date) async throws -> [TemperatureEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<TemperatureRecord>(
            predicate: #Predicate { $0.date >= from && $0.date <= to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ entry: TemperatureEntry) async throws {
        context.insert(TemperatureRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [TemperatureEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<TemperatureRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert: context.insert(TemperatureRecord(entry)); changed = true
            case .update: record?.apply(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func delete(id: UUID) async throws {
        var descriptor = FetchDescriptor<TemperatureRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }
}
