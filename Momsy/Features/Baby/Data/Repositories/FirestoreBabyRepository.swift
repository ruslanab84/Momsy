import Foundation

// TODO: Implement with Firebase SDK. Firestore path: users/{uid}/babyProfile
final class FirestoreBabyRepository: BabyRepository {
    func getProfile() async throws -> BabyProfile? {
        throw RepositoryError.notImplemented
    }

    func saveProfile(_ profile: BabyProfile) async throws {
        throw RepositoryError.notImplemented
    }
}
