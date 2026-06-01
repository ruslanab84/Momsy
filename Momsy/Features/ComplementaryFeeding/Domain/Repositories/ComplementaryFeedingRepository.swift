import Foundation

protocol ComplementaryFeedingRepository {
    func getAll() async throws -> [ComplementaryFoodEntry]
    func add(_ entry: ComplementaryFoodEntry) async throws
    func upsert(_ entries: [ComplementaryFoodEntry]) async throws
    func update(_ entry: ComplementaryFoodEntry) async throws
    func delete(id: UUID) async throws
}
