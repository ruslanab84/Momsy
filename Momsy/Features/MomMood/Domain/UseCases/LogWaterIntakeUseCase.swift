import Foundation

final class LogWaterIntakeUseCase {
    private let repository: any WaterIntakeRepository
    init(repository: any WaterIntakeRepository) { self.repository = repository }

    func execute(amountMl: Int, date: Date = Date()) async throws -> WaterIntakeEntry {
        let entry = WaterIntakeEntry(id: UUID(), date: date, amountMl: amountMl)
        try await repository.add(entry)
        return entry
    }
}
