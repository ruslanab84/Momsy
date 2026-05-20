import Foundation

final class LogFeedingUseCase {
    private let repository: FeedingRepository
    init(repository: FeedingRepository) { self.repository = repository }

    @discardableResult
    func execute(durationSeconds: Int, side: FeedingSide, mood: String? = nil) async throws -> FeedingEntry {
        let entry = FeedingEntry(date: Date(), durationSeconds: durationSeconds, side: side, mood: mood)
        try await repository.add(entry)
        return entry
    }
}
