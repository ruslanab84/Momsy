import Foundation

protocol DiaperRepository {
    func getEntries(from: Date, to: Date) async throws -> [DiaperEntry]
    func add(_ entry: DiaperEntry) async throws
    /// Inserts only entries whose id is not already stored (used by cloud download/merge).
    func upsert(_ entries: [DiaperEntry]) async throws
    func removeLatest(on day: Date) async throws
    func countToday() async throws -> Int
}
