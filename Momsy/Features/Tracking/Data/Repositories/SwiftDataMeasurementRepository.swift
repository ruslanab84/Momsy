import SwiftData
import Foundation

final class SwiftDataMeasurementRepository: MeasurementRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAll() async throws -> [MeasurementEntry] {
        let all = try context.fetch(FetchDescriptor<MeasurementRecord>())
        return all.uniqued(by: { $0.id }).map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func getEntries(from: Date, to: Date) async throws -> [MeasurementEntry] {
        var descriptor = FetchDescriptor<MeasurementRecord>(
            predicate: #Predicate { $0.date >= from && $0.date <= to }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: MeasurementEntry) async throws {
        context.insert(MeasurementRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [MeasurementEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<MeasurementRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert: context.insert(MeasurementRecord(entry)); changed = true
            case .update: record?.merge(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func delete(id: UUID) async throws {
        var descriptor = FetchDescriptor<MeasurementRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }
}
