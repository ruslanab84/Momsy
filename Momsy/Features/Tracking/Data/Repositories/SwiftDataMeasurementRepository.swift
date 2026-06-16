import SwiftData
import Foundation

final class SwiftDataMeasurementRepository: MeasurementRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAll() async throws -> [MeasurementEntry] {
        let all = try context.fetch(FetchDescriptor<MeasurementRecord>())
        return all.uniqued(by: { $0.id }).map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func add(_ entry: MeasurementEntry) async throws {
        context.insert(MeasurementRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [MeasurementEntry]) async throws {
        guard !entries.isEmpty else { return }
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<MeasurementRecord>()).map { ($0.id, $0) },
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
        let all = try context.fetch(FetchDescriptor<MeasurementRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
