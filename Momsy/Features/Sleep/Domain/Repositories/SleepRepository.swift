import Foundation

protocol SleepRepository {
    func getEntries(from: Date, to: Date) async throws -> [SleepEntry]
    func add(_ entry: SleepEntry) async throws
    /// Inserts only entries whose id is not already stored (used by cloud download/merge).
    func upsert(_ entries: [SleepEntry]) async throws
    func update(_ entry: SleepEntry) async throws
    func delete(id: UUID) async throws
}
