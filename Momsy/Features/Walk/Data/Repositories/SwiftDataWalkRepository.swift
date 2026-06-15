import SwiftData
import Foundation

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
        let all = try context.fetch(FetchDescriptor<WalkRecord>())
        if let record = all.first(where: { $0.id == entry.id }) {
            record.endDate = finished.endDate
            try context.save()
        }
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [WalkEntry] {
        let all = try context.fetch(FetchDescriptor<WalkRecord>())
        return all.filter { $0.startDate >= from && $0.startDate < to }
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: WalkEntry) async throws {
        context.insert(WalkRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [WalkEntry]) async throws {
        guard !entries.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<WalkRecord>()).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(WalkRecord(entry))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func resolveOrphan(id: UUID, endDate: Date?) async throws {
        let all = try context.fetch(FetchDescriptor<WalkRecord>())
        guard let record = all.first(where: { $0.id == id }) else { return }
        if let endDate {
            record.endDate = endDate
        } else {
            context.delete(record)
        }
        try context.save()
    }
}
