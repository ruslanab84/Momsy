import Foundation

protocol DiaryRepository {
    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem]
    func add(_ item: StoredDiaryItem) async throws
    func update(_ item: StoredDiaryItem) async throws
    func delete(id: UUID) async throws
}
