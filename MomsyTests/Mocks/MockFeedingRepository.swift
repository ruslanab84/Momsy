@testable import Momsy
import Foundation

final class MockFeedingRepository: FeedingRepository {
    var entries: [FeedingEntry] = []
    var shouldThrow = false

    func getEntries(for date: Date) async throws -> [FeedingEntry] {
        if shouldThrow { throw TestError.mock }
        let cal = Calendar.current
        return entries.filter { cal.isDate($0.date, inSameDayAs: date) }
    }

    func getEntries(from: Date, to: Date) async throws -> [FeedingEntry] {
        if shouldThrow { throw TestError.mock }
        return entries.filter { $0.date >= from && $0.date < to }
    }

    func add(_ entry: FeedingEntry) async throws {
        if shouldThrow { throw TestError.mock }
        entries.append(entry)
    }

    func delete(id: UUID) async throws {
        entries.removeAll { $0.id == id }
    }
}
