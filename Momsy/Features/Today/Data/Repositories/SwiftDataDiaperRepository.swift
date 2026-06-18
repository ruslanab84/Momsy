import SwiftData
import Foundation

@MainActor
final class SwiftDataDiaperRepository: DiaperRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [DiaperEntry] {
        var descriptor = FetchDescriptor<DiaperRecord>(
            predicate: #Predicate { $0.date >= from && $0.date <= to }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor)
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: DiaperEntry) async throws {
        context.insert(DiaperRecord(id: entry.id, date: entry.date, updatedAt: entry.updatedAt))
        try context.save()
    }

    func upsert(_ entries: [DiaperEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<DiaperRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert:
                context.insert(DiaperRecord(id: entry.id, date: entry.date, updatedAt: entry.updatedAt))
                changed = true
            case .update: record?.apply(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }

    @discardableResult
    func removeLatest(on day: Date) async throws -> UUID? {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        guard let next = cal.date(byAdding: .day, value: 1, to: start) else { return nil }
        var descriptor = FetchDescriptor<DiaperRecord>(
            predicate: #Predicate { $0.date >= start && $0.date < next }
        )
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        descriptor.fetchLimit = 1
        guard let latest = try context.fetch(descriptor).first else { return nil }
        let removedId = latest.id
        context.delete(latest)
        try context.save()
        return removedId
    }

    func countToday() async throws -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        guard let next = cal.date(byAdding: .day, value: 1, to: start) else { return 0 }
        let descriptor = FetchDescriptor<DiaperRecord>(
            predicate: #Predicate { $0.date >= start && $0.date < next }
        )
        return try context.fetchCount(descriptor)
    }

    func applyDeletions(_ ids: Set<UUID>) async throws {
        guard !ids.isEmpty else { return }
        let idArray = Array(ids)
        let matches = try context.fetch(
            FetchDescriptor<DiaperRecord>(predicate: #Predicate { idArray.contains($0.id) })
        )
        guard !matches.isEmpty else { return }
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
