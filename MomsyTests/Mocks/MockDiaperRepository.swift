@testable import Momsy
import Foundation

final class MockDiaperRepository: DiaperRepository {
    var entries: [DiaperEntry] = []
    var shouldThrow = false

    func getEntries(from: Date, to: Date) async throws -> [DiaperEntry] {
        if shouldThrow { throw TestError.mock }
        return entries.filter { $0.date >= from && $0.date <= to }
    }

    func add(_ entry: DiaperEntry) async throws {
        if shouldThrow { throw TestError.mock }
        entries.append(entry)
    }

    func upsert(_ newEntries: [DiaperEntry]) async throws {
        if shouldThrow { throw TestError.mock }
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }

    func removeLatest(on day: Date) async throws {
        if shouldThrow { throw TestError.mock }
        let cal = Calendar.current
        let todayEntries = entries.filter { cal.isDate($0.date, inSameDayAs: day) }
        if let latest = todayEntries.max(by: { $0.date < $1.date }),
           let idx = entries.firstIndex(where: { $0.id == latest.id }) {
            entries.remove(at: idx)
        }
    }

    func countToday() async throws -> Int {
        if shouldThrow { throw TestError.mock }
        return entries.filter { Calendar.current.isDateInToday($0.date) }.count
    }
}
