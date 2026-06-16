import Foundation

protocol DiaperRepository {
    func getEntries(from: Date, to: Date) async throws -> [DiaperEntry]
    func add(_ entry: DiaperEntry) async throws
    /// Inserts only entries whose id is not already stored (used by cloud download/merge).
    func upsert(_ entries: [DiaperEntry]) async throws
    /// Removes the latest entry on `day`, returning its id so the delete can be
    /// propagated to the cloud (nil if there was nothing to remove).
    @discardableResult
    func removeLatest(on day: Date) async throws -> UUID?
    func countToday() async throws -> Int
    /// Deletes any locally-stored entries whose id is in `ids` (cloud-tombstoned).
    func applyDeletions(_ ids: Set<UUID>) async throws
}
