import SwiftData
import Foundation

final class SwiftDataPumpingRepository: PumpingRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func start(side: PumpingSide) async throws -> PumpingEntry {
        let entry = PumpingEntry(
            id: UUID(),
            date: Date(),
            durationSeconds: 0,
            side: side,
            volumeML: 0,
            endDate: nil
        )
        context.insert(PumpingRecord(entry))
        try context.save()
        return entry
    }

    func stop(_ entry: PumpingEntry, volumeML: Int) async throws -> PumpingEntry {
        var finished = entry
        let now = Date()
        finished.endDate = now
        finished.durationSeconds = max(1, Int(now.timeIntervalSince(entry.date)))
        finished.volumeML = volumeML
        let id = entry.id
        var descriptor = FetchDescriptor<PumpingRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            record.endDate = finished.endDate
            record.durationSeconds = finished.durationSeconds
            record.volumeML = volumeML
            try context.save()
        }
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [PumpingEntry] {
        var descriptor = FetchDescriptor<PumpingRecord>(
            predicate: #Predicate { $0.date >= from && $0.date < to && $0.endDate != nil }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor)
            .uniqued(by: { $0.id })
            .map { $0.toDomain() }
    }

    func logManual(date: Date, durationMinutes: Int, side: PumpingSide, volumeML: Int) async throws -> PumpingEntry {
        let duration = max(1, durationMinutes) * 60
        let entry = PumpingEntry(
            id: UUID(),
            date: date,
            durationSeconds: duration,
            side: side,
            volumeML: volumeML,
            endDate: date.addingTimeInterval(TimeInterval(duration))
        )
        context.insert(PumpingRecord(entry))
        try context.save()
        return entry
    }

    func upsert(_ entries: [PumpingEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<PumpingRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert: context.insert(PumpingRecord(entry)); changed = true
            case .update: record?.apply(entry); changed = true
            case .skip:   break
            }
        }
        if changed { try context.save() }
    }
}
