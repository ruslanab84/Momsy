import SwiftData
import Foundation

@MainActor
final class SwiftDataBathRepository: BathRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func start() async throws -> BathEntry {
        let entry = BathEntry(startDate: Date())
        context.insert(BathRecord(entry))
        try context.save()
        return entry
    }

    func stop(_ entry: BathEntry) async throws -> BathEntry {
        var finished = entry
        finished.endDate = Date()
        let id = entry.id
        var descriptor = FetchDescriptor<BathRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            record.endDate = finished.endDate
            try context.save()
        }
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [BathEntry] {
        var descriptor = FetchDescriptor<BathRecord>(
            predicate: #Predicate { $0.startDate >= from && $0.startDate < to }
        )
        descriptor.sortBy = [SortDescriptor(\.startDate)]
        return try context.fetch(descriptor).uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: BathEntry) async throws {
        context.insert(BathRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [BathEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let existing = Set(try context.fetch(
            FetchDescriptor<BathRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
        ).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(BathRecord(entry))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func resolveOrphan(id: UUID, endDate: Date?) async throws {
        var descriptor = FetchDescriptor<BathRecord>(predicate: #Predicate { $0.id == id })
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
