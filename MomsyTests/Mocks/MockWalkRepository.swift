@testable import Momsy
import Foundation

final class MockWalkRepository: WalkRepository {
    var entries: [WalkEntry] = []

    func start() async throws -> WalkEntry { WalkEntry(startDate: Date()) }
    func stop(_ entry: WalkEntry) async throws -> WalkEntry { entry }
    func getEntries(from: Date, to: Date) async throws -> [WalkEntry] {
        entries.filter { $0.startDate >= from && $0.startDate < to }
    }
    func add(_ entry: WalkEntry) async throws { entries.append(entry) }
    func upsert(_ newEntries: [WalkEntry]) async throws {
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }
    func resolveOrphan(id: UUID, endDate: Date?) async throws {}
}
