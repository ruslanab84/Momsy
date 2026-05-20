import Foundation

final class GetMeasurementsUseCase {
    private let repository: MeasurementRepository
    init(repository: MeasurementRepository) { self.repository = repository }

    func execute() async throws -> [MeasurementEntry] {
        try await repository.getAll()
    }
}
