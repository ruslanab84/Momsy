@testable import Momsy
import Foundation

final class MockSleepRepository: SleepRepository {
    var entries: [SleepEntry] = []
    var shouldThrow = false
    var throwOnUpdate = false

    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        if shouldThrow { throw TestError.mock }
        return entries.filter { $0.startDate >= from && $0.startDate < to }
    }

    func add(_ entry: SleepEntry) async throws {
        if shouldThrow { throw TestError.mock }
        entries.append(entry)
    }

    func update(_ entry: SleepEntry) async throws {
        if throwOnUpdate { throw TestError.mock }
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
        }
    }

    func delete(id: UUID) async throws {
        entries.removeAll { $0.id == id }
    }
}
