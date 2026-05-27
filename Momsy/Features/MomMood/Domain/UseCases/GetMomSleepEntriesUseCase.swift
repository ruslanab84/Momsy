import Foundation

final class GetMomSleepEntriesUseCase {
    private let repository: any MomSleepRepository
    init(repository: any MomSleepRepository) { self.repository = repository }

    func execute(from: Date, to: Date) async throws -> [SleepEntry] {
        try await repository.getEntries(from: from, to: to)
    }
}
