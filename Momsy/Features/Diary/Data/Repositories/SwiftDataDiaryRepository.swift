import SwiftData
import Foundation

@MainActor
final class SwiftDataDiaryRepository: DiaryRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem] {
        var descriptor = FetchDescriptor<DiaryItemRecord>(
            predicate: #Predicate { $0.date >= from && $0.date <= to }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor)
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ item: StoredDiaryItem) async throws {
        context.insert(DiaryItemRecord(item))
        try context.save()
    }

    func upsert(_ items: [StoredDiaryItem]) async throws {
        guard !items.isEmpty else { return }
        let incomingIds = items.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<DiaryItemRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
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
        let id = item.id
        var descriptor = FetchDescriptor<DiaryItemRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        record.apply(item)
        try context.save()
    }

    func delete(id: UUID) async throws {
        var descriptor = FetchDescriptor<DiaryItemRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }
}
