import Foundation

// TODO: Implement with Firebase SDK. Firestore path: users/{uid}/diaryEntries/{docId}
final class FirestoreDiaryRepository: DiaryRepository {
    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem] { throw RepositoryError.notImplemented }
    func add(_ item: StoredDiaryItem) async throws { throw RepositoryError.notImplemented }
    func update(_ item: StoredDiaryItem) async throws { throw RepositoryError.notImplemented }
    func delete(id: UUID) async throws { throw RepositoryError.notImplemented }
}
