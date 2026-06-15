import Foundation

protocol WalkRepository {
    func start() async throws -> WalkEntry
    func stop(_ entry: WalkEntry) async throws -> WalkEntry
    func getEntries(from: Date, to: Date) async throws -> [WalkEntry]
    func add(_ entry: WalkEntry) async throws
    func upsert(_ entries: [WalkEntry]) async throws
    /// Resolves an orphaned open session left by a kill mid-stop: closes it at
    /// `endDate`, or deletes it when `endDate` is nil so it can't inflate totals.
    func resolveOrphan(id: UUID, endDate: Date?) async throws
}
