import SwiftData
import Foundation

@MainActor
final class SwiftDataWalkRepository: WalkRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func start() async throws -> WalkEntry {
        let entry = WalkEntry(startDate: Date())
        context.insert(WalkRecord(entry))
        try context.save()
        return entry
    }

    func stop(_ entry: WalkEntry) async throws -> WalkEntry {
        var finished = entry
        finished.endDate = Date()
        let id = entry.id
        var descriptor = FetchDescriptor<WalkRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            record.endDate = finished.endDate
            try context.save()
        }
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [WalkEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<WalkRecord>(
            predicate: #Predicate { $0.startDate >= from && $0.startDate < to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.startDate)]
        return try context.fetch(descriptor).uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: WalkEntry) async throws {
        context.insert(WalkRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [WalkEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let existing = Set(try context.fetch(
            FetchDescriptor<WalkRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
        ).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(WalkRecord(entry))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func resolveOrphan(id: UUID, endDate: Date?) async throws {
        var descriptor = FetchDescriptor<WalkRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        if let endDate {
            record.endDate = endDate
        } else {
            context.delete(record)
        }
        try context.save()
    }
}
