@testable import Momsy
import Foundation

final class MockVitaminRepository: VitaminRepository {
    var entries: [VitaminEntry] = []

    func add(_ entry: VitaminEntry) async throws { entries.append(entry) }
    func upsert(_ newEntries: [VitaminEntry]) async throws {
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }
    func getEntries(from: Date, to: Date) async throws -> [VitaminEntry] {
        entries.filter { $0.date >= from && $0.date < to }
    }
}
