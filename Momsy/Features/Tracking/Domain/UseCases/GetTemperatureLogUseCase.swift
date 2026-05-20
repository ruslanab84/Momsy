import Foundation

final class GetTemperatureLogUseCase {
    private let repository: TemperatureRepository
    init(repository: TemperatureRepository) { self.repository = repository }

    func execute() async throws -> [TemperatureEntry] {
        try await repository.getAll()
    }
}
