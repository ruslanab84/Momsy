import Foundation

final class GetFeedingEntriesUseCase {
    private let repository: FeedingRepository
    init(repository: FeedingRepository) { self.repository = repository }

    func execute(for date: Date = Date()) async throws -> [FeedingEntry] {
        try await repository.getEntries(for: date)
    }

    func execute(from: Date, to: Date) async throws -> [FeedingEntry] {
        try await repository.getEntries(from: from, to: to)
    }
}
