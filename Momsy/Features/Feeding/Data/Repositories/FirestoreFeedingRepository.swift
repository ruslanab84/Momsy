import Foundation

// TODO: Implement with Firebase SDK. Firestore path: users/{uid}/feedingEntries/{docId}
final class FirestoreFeedingRepository: FeedingRepository {
    func getEntries(for date: Date) async throws -> [FeedingEntry] { throw RepositoryError.notImplemented }
    func getEntries(from: Date, to: Date) async throws -> [FeedingEntry] { throw RepositoryError.notImplemented }
    func add(_ entry: FeedingEntry) async throws { throw RepositoryError.notImplemented }
    func delete(id: UUID) async throws { throw RepositoryError.notImplemented }
}
