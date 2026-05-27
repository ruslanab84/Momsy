import Foundation

final class StartMomSleepUseCase {
    private let repository: any MomSleepRepository
    init(repository: any MomSleepRepository) { self.repository = repository }

    func execute(note: String = "") async throws -> SleepEntry {
        let entry = SleepEntry(startDate: Date(), note: note)
        try await repository.add(entry)
        return entry
    }
}
