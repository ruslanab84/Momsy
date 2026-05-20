import Foundation

protocol TemperatureRepository {
    func getAll() async throws -> [TemperatureEntry]
    func getEntries(from: Date, to: Date) async throws -> [TemperatureEntry]
    func add(_ entry: TemperatureEntry) async throws
    func delete(id: UUID) async throws
}
