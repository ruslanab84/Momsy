import Foundation

// TODO: Implement with Firebase SDK. Firestore path: users/{uid}/measurements/{docId}
final class FirestoreMeasurementRepository: MeasurementRepository {
    func getAll() async throws -> [MeasurementEntry] { throw RepositoryError.notImplemented }
    func add(_ entry: MeasurementEntry) async throws { throw RepositoryError.notImplemented }
    func upsert(_ entries: [MeasurementEntry]) async throws { throw RepositoryError.notImplemented }
    func delete(id: UUID) async throws { throw RepositoryError.notImplemented }
}
