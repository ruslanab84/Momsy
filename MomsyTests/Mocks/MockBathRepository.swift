@testable import Momsy
import Foundation

final class MockBathRepository: BathRepository {
    var entries: [BathEntry] = []

    func start() async throws -> BathEntry { BathEntry(startDate: Date()) }
    func stop(_ entry: BathEntry) async throws -> BathEntry { entry }
    func getEntries(from: Date, to: Date) async throws -> [BathEntry] {
        entries.filter { $0.startDate >= from && $0.startDate < to }
    }
    func add(_ entry: BathEntry) async throws { entries.append(entry) }
    func upsert(_ newEntries: [BathEntry]) async throws {
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }
    func resolveOrphan(id: UUID, endDate: Date?) async throws {}
}
