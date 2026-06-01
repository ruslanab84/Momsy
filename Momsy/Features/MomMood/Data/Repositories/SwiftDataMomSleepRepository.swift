import SwiftData
import Foundation

final class SwiftDataMomSleepRepository: MomSleepRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        let all = try context.fetch(FetchDescriptor<MomSleepRecord>())
        return all
            .map { $0.toDomain() }
            .filter { $0.startDate >= from && $0.startDate <= to }
            .sorted { $0.startDate < $1.startDate }
    }

    func add(_ entry: SleepEntry) async throws {
        context.insert(MomSleepRecord(entry))
        try context.save()
    }

    func update(_ entry: SleepEntry) async throws {
        let all = try context.fetch(FetchDescriptor<MomSleepRecord>())
        if let record = all.first(where: { $0.id == entry.id }) {
            record.endDate    = entry.endDate
            record.note       = entry.note
            record.qualityRaw = entry.quality.rawValue
            try context.save()
        }
    }

    func upsert(_ entries: [SleepEntry]) async throws {
        guard !entries.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<MomSleepRecord>()).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(MomSleepRecord(entry))
            inserted = true
        }
        if inserted { try context.save() }
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<MomSleepRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
