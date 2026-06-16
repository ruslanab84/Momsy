@testable import Momsy
import Foundation

final class MockComplementaryFeedingRepository: ComplementaryFeedingRepository {
    var entries: [ComplementaryFoodEntry] = []
    var shouldThrow = false

    func getAll() async throws -> [ComplementaryFoodEntry] {
        if shouldThrow { throw TestError.mock }
        return entries.sorted { $0.date > $1.date }
    }

    func add(_ entry: ComplementaryFoodEntry) async throws {
        if shouldThrow { throw TestError.mock }
        entries.append(entry)
    }

    func upsert(_ newEntries: [ComplementaryFoodEntry]) async throws {
        if shouldThrow { throw TestError.mock }
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }

    func update(_ entry: ComplementaryFoodEntry) async throws {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) { entries[idx] = entry }
    }

    func delete(id: UUID) async throws {
        entries.removeAll { $0.id == id }
    }

    func applyDeletions(_ ids: Set<UUID>) async throws {
        entries.removeAll { ids.contains($0.id) }
    }
}
