import SwiftData
import Foundation

final class SwiftDataWaterIntakeRepository: WaterIntakeRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func add(_ entry: WaterIntakeEntry) async throws {
        context.insert(WaterIntakeRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [WaterIntakeEntry]) async throws {
        guard !entries.isEmpty else { return }
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<WaterIntakeRecord>()).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert: context.insert(WaterIntakeRecord(entry)); changed = true
            case .update: record?.apply(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func getEntries(from: Date, to: Date) async throws -> [WaterIntakeEntry] {
        let all = try context.fetch(FetchDescriptor<WaterIntakeRecord>())
        return all
            .map { $0.toDomain() }
            .filter { $0.date >= from && $0.date <= to }
            .sorted { $0.date < $1.date }
    }
}
