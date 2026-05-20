import Foundation

protocol MeasurementRepository {
    func getAll() async throws -> [MeasurementEntry]
    func add(_ entry: MeasurementEntry) async throws
    func delete(id: UUID) async throws
}
