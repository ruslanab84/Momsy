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
        context.insert(DiaperRecord(id: entry.id, date: entry.date))
        try context.save()
    }

    func upsert(_ entries: [DiaperEntry]) async throws {
        guard !entries.isEmpty else { return }
        let existing = Set(try context.fetch(FetchDescriptor<DiaperRecord>()).map(\.id))
        var inserted = false
        for entry in entries where !existing.contains(entry.id) {
            context.insert(DiaperRecord(id: entry.id, date: entry.date))
            inserted = true
        }
        if inserted { try context.save() }
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
