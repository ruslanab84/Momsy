import Foundation

final class GetWaterIntakeUseCase {
    private let repository: any WaterIntakeRepository
    init(repository: any WaterIntakeRepository) { self.repository = repository }

    func execute(from: Date, to: Date) async throws -> [WaterIntakeEntry] {
        try await repository.getEntries(from: from, to: to)
    }
}
