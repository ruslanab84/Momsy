import Foundation

final class LogFeedingUseCase {
    private let repository: FeedingRepository
    init(repository: FeedingRepository) { self.repository = repository }

    @discardableResult
    func execute(
        durationSeconds: Int,
        side: FeedingSide,
        mood: String? = nil,
        milliliters: Int? = nil,
        date: Date = Date()
    ) async throws -> FeedingEntry {
        let entry = FeedingEntry(date: date, durationSeconds: durationSeconds,
                                 side: side, mood: mood, milliliters: milliliters)
        try await repository.add(entry)
        return entry
    }
}
