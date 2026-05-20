import Foundation

final class StopSleepUseCase {
    private let repository: SleepRepository
    init(repository: SleepRepository) { self.repository = repository }

    func execute(_ entry: SleepEntry) async throws -> SleepEntry {
        var updated = entry
        updated.endDate = Date()
        try await repository.update(updated)
        return updated
    }
}
