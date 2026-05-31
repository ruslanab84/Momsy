import Foundation

protocol DiaryRepository {
    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem]
    func add(_ item: StoredDiaryItem) async throws
    /// Inserts only items whose id is not already stored (used by cloud download/merge).
    func upsert(_ items: [StoredDiaryItem]) async throws
    func update(_ item: StoredDiaryItem) async throws
    func delete(id: UUID) async throws
}
