import Foundation

final class AddMeasurementUseCase {
    private let repository: MeasurementRepository
    init(repository: MeasurementRepository) { self.repository = repository }

    @discardableResult
    func execute(_ entry: MeasurementEntry) async throws -> MeasurementEntry {
        try await repository.add(entry)
        return entry
    }
}
