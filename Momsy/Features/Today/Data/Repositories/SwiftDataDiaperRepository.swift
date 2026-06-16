import SwiftData
import Foundation

final class SwiftDataDiaperRepository: DiaperRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [DiaperEntry] {
        let all = try context.fetch(FetchDescriptor<DiaperRecord>())
        return all.filter { $0.date >= from && $0.date <= to }
            .uniqued(by: { $0.id }).map { $0.toDomain() }
    }

    func add(_ entry: DiaperEntry) async throws {
        context.insert(DiaperRecord(id: entry.id, date: entry.date, updatedAt: entry.updatedAt))
        try context.save()
    }

    func upsert(_ entries: [DiaperEntry]) async throws {
        guard !entries.isEmpty else { return }
        let byId = Dictionary(
            try context.fetch(FetchDescriptor<DiaperRecord>()).map { ($0.id, $0) },
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

    func removeLatest(on day: Date) async throws {
        let all = try context.fetch(FetchDescriptor<DiaperRecord>())
        let cal = Calendar.current
        let todayEntries = all.filter { cal.isDate($0.date, inSameDayAs: day) }
        guard let latest = todayEntries.max(by: { $0.date < $1.date }) else { return }
        context.delete(latest)
        try context.save()
    }

    func countToday() async throws -> Int {
        let all = try context.fetch(FetchDescriptor<DiaperRecord>())
        return all.uniqued(by: { $0.id }).filter { Calendar.current.isDateInToday($0.date) }.count
    }
}
