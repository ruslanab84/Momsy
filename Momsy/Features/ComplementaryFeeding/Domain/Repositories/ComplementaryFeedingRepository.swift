import Foundation

protocol ComplementaryFeedingRepository {
    func getAll() async throws -> [ComplementaryFoodEntry]
    func getEntries(from: Date, to: Date) async throws -> [ComplementaryFoodEntry]
    func add(_ entry: ComplementaryFoodEntry) async throws
    func upsert(_ entries: [ComplementaryFoodEntry]) async throws
    func update(_ entry: ComplementaryFoodEntry) async throws
    func delete(id: UUID) async throws
    /// Deletes any locally-stored entries whose id is in `ids` (cloud-tombstoned).
    func applyDeletions(_ ids: Set<UUID>) async throws
}

extension ComplementaryFeedingRepository {
    func getEntries(from: Date, to: Date) async throws -> [ComplementaryFoodEntry] {
        try await getAll().filter { $0.date >= from && $0.date < to }
    }
}
