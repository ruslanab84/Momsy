import Foundation

final class StopMomSleepUseCase {
    private let repository: any MomSleepRepository
    init(repository: any MomSleepRepository) { self.repository = repository }

    func execute(_ entry: SleepEntry) async throws -> SleepEntry {
        var updated = entry
        updated.endDate = Date()
        try await repository.update(updated)
        return updated
    }
}
