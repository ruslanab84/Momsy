import Foundation

// TODO: Implement with Firebase SDK. Firestore path: users/{uid}/sleepEntries/{docId}
final class FirestoreSleepRepository: SleepRepository {
    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] { throw RepositoryError.notImplemented }
    func add(_ entry: SleepEntry) async throws { throw RepositoryError.notImplemented }
    func update(_ entry: SleepEntry) async throws { throw RepositoryError.notImplemented }
    func delete(id: UUID) async throws { throw RepositoryError.notImplemented }
}
