import Foundation

// TODO: Implement with Firebase SDK. Firestore path: users/{uid}/temperatureLog/{docId}
final class FirestoreTemperatureRepository: TemperatureRepository {
    func getAll() async throws -> [TemperatureEntry] { throw RepositoryError.notImplemented }
    func getEntries(from: Date, to: Date) async throws -> [TemperatureEntry] { throw RepositoryError.notImplemented }
    func add(_ entry: TemperatureEntry) async throws { throw RepositoryError.notImplemented }
    func delete(id: UUID) async throws { throw RepositoryError.notImplemented }
}
