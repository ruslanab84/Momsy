import Foundation

final class StartSleepUseCase {
    private let repository: SleepRepository
    init(repository: SleepRepository) { self.repository = repository }

    func execute(note: String = "") async throws -> SleepEntry {
        let entry = SleepEntry(startDate: Date(), note: note)
        try await repository.add(entry)
        return entry
    }
}
