import SwiftData
import Foundation

final class SwiftDataDiaryRepository: DiaryRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem] {
        let all = try context.fetch(FetchDescriptor<DiaryItemRecord>())
        return all.filter { $0.date >= from && $0.date <= to }.map { $0.toDomain() }
    }

    func add(_ item: StoredDiaryItem) async throws {
        context.insert(DiaryItemRecord(item))
        try context.save()
    }

    func upsert(_ items: [StoredDiaryItem]) async throws {
        guard !items.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<DiaryItemRecord>()).map(\.id))
        var inserted = false
        for item in items where !existing.contains(item.id) {
            context.insert(DiaryItemRecord(item))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func update(_ item: StoredDiaryItem) async throws {
        let all = try context.fetch(FetchDescriptor<DiaryItemRecord>())
        guard let record = all.first(where: { $0.id == item.id }) else { return }
        record.date        = item.date
        record.kindRaw     = item.kind.rawValue
        record.text        = item.text
        record.toneHex     = item.toneHex
        record.isMilestone = item.isMilestone
        record.iconName    = item.iconName
        record.photoPath   = item.photoPath
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
