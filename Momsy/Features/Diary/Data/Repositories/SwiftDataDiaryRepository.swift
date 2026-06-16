import SwiftData
import Foundation

final class SwiftDataDiaryRepository: DiaryRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem] {
        let all = try context.fetch(FetchDescriptor<DiaryItemRecord>())
        return all.filter { $0.date >= from && $0.date <= to }
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ item: StoredDiaryItem) async throws {
        context.insert(DiaryItemRecord(item))
        try context.save()
    }

    func upsert(_ items: [StoredDiaryItem]) async throws {
        guard !items.isEmpty else { return }
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<DiaryItemRecord>()).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for item in items {
            let record = byId[item.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: item.updatedAt) {
            case .insert: context.insert(DiaryItemRecord(item)); changed = true
            case .update: record?.merge(item); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    func update(_ item: StoredDiaryItem) async throws {
        let all = try context.fetch(FetchDescriptor<DiaryItemRecord>())
        guard let record = all.first(where: { $0.id == item.id }) else { return }
        record.apply(item)
        try context.save()
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<DiaryItemRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
