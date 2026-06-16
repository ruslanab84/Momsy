import Foundation

protocol VaccinationRepository {
    func getAll() async throws -> [VaccinationEntry]
    func save(_ entry: VaccinationEntry) async throws
    func upsert(_ entries: [VaccinationEntry]) async throws
    func delete(id: UUID) async throws
    /// Deletes any locally-stored entries whose id is in `ids` (cloud-tombstoned).
    func applyDeletions(_ ids: Set<UUID>) async throws
}
