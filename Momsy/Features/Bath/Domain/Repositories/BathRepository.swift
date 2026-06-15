import Foundation

protocol BathRepository {
    func start() async throws -> BathEntry
    func stop(_ entry: BathEntry) async throws -> BathEntry
    func getEntries(from: Date, to: Date) async throws -> [BathEntry]
    func add(_ entry: BathEntry) async throws
    func upsert(_ entries: [BathEntry]) async throws
    /// Resolves an orphaned open session left by a kill mid-stop: closes it at
    /// `endDate`, or deletes it when `endDate` is nil so it can't inflate totals.
    func resolveOrphan(id: UUID, endDate: Date?) async throws
}
