import Foundation

// TODO: Implement with Firebase SDK. Firestore path: users/{uid}/leapsProgress/{leapId}
final class FirestoreLeapsRepository: LeapsRepository {
    func getAllProgress() async throws -> [LeapProgress] { throw RepositoryError.notImplemented }
    func saveProgress(_ progress: LeapProgress) async throws { throw RepositoryError.notImplemented }
    func resetProgress(id: Int) async throws { throw RepositoryError.notImplemented }
}
