import Foundation

protocol MeasurementRepository {
    func getAll() async throws -> [MeasurementEntry]
    func getEntries(from: Date, to: Date) async throws -> [MeasurementEntry]
    func add(_ entry: MeasurementEntry) async throws
    func upsert(_ entries: [MeasurementEntry]) async throws
    func delete(id: UUID) async throws
}

extension MeasurementRepository {
    func getEntries(from: Date, to: Date) async throws -> [MeasurementEntry] {
        try await getAll().filter { $0.date >= from && $0.date <= to }
    }
}
