import SwiftData
import Foundation

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
        let all = try context.fetch(FetchDescriptor<BathRecord>())
        if let record = all.first(where: { $0.id == entry.id }) {
            record.endDate = finished.endDate
            try context.save()
        }
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [BathEntry] {
        let all = try context.fetch(FetchDescriptor<BathRecord>())
        return all.filter { $0.startDate >= from && $0.startDate < to }
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: BathEntry) async throws {
        context.insert(BathRecord(entry))
        try context.save()
    }

    func upsert(_ entries: [BathEntry]) async throws {
        guard !entries.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<BathRecord>()).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(BathRecord(entry))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func resolveOrphan(id: UUID, endDate: Date?) async throws {
        let all = try context.fetch(FetchDescriptor<BathRecord>())
        guard let record = all.first(where: { $0.id == id }) else { return }
        if let endDate {
            record.endDate = endDate
        } else {
            context.delete(record)
        }
        try context.save()
    }
}
