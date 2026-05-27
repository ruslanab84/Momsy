import Foundation

final class AddManualSleepUseCase {
    private let repository: SleepRepository
    init(repository: SleepRepository) { self.repository = repository }

    func execute(startDate: Date, endDate: Date, quality: SleepQuality, note: String) async throws -> SleepEntry {
        let entry = SleepEntry(startDate: startDate, endDate: endDate, note: note, quality: quality)
        try await repository.add(entry)
        return entry
    }
}
