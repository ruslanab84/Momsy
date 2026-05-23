import Foundation

protocol VaccinationRepository {
    func getAll() async throws -> [VaccinationEntry]
    func save(_ entry: VaccinationEntry) async throws
    func delete(id: UUID) async throws
}
