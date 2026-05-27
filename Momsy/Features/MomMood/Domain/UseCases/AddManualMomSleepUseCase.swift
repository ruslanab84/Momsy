import Foundation

final class AddManualMomSleepUseCase {
    private let repository: any MomSleepRepository
    init(repository: any MomSleepRepository) { self.repository = repository }

    func execute(startDate: Date, endDate: Date,
                 quality: SleepQuality, note: String) async throws -> SleepEntry {
        let entry = SleepEntry(id: UUID(), startDate: startDate, endDate: endDate,
                               note: note, quality: quality)
        try await repository.add(entry)
        return entry
    }
}
