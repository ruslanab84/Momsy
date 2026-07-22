import Foundation

protocol VitaminRepository {
    func add(_ entry: VitaminEntry) async throws
    /// Inserts only entries whose id is not already stored (used by cloud download/merge).
    func upsert(_ entries: [VitaminEntry]) async throws
    func getEntries(from: Date, to: Date) async throws -> [VitaminEntry]
    func loadCategories() -> [String]
    func saveCategories(_ categories: [String])
}
