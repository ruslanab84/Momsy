import Foundation

final class GetSleepEntriesUseCase {
    private let repository: SleepRepository
    init(repository: SleepRepository) { self.repository = repository }

    func execute(from: Date, to: Date) async throws -> [SleepEntry] {
        try await repository.getEntries(from: from, to: to)
    }

    func executeOverlapping(from: Date, to: Date) async throws -> [SleepEntry] {
        try await repository.getEntries(overlapping: from, until: to)
    }
}
