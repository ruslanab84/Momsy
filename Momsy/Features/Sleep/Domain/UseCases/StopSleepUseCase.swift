import Foundation

enum StopSleepOutcome {
    /// Session persisted with the given end.
    case saved(SleepEntry)
    /// Session was shorter than the minimum and was deleted locally.
    /// Caller must propagate the delete to the cloud.
    case discarded(SleepEntry)
}

final class StopSleepUseCase {
    enum ShortSessionPolicy {
        case discard
        case save
    }

    /// By default, sessions shorter than this are treated as accidental taps and discarded.
    nonisolated static let minimumDuration: TimeInterval = 60

    private let repository: SleepRepository
    init(repository: SleepRepository) { self.repository = repository }

    func execute(
        _ entry: SleepEntry,
        now: Date = Date(),
        shortSessionPolicy: ShortSessionPolicy = .discard
    ) async throws -> StopSleepOutcome {
        if case .discard = shortSessionPolicy,
           Self.isBelowMinimum(start: entry.startDate, end: now) {
            try await repository.delete(id: entry.id)
            return .discarded(entry)
        }
        var updated = entry
        updated.endDate = now
        updated.updatedAt = now
        try await repository.update(updated)
        return .saved(updated)
    }

    /// Negative durations (clock skew) also count as below minimum.
    nonisolated static func isBelowMinimum(start: Date, end: Date) -> Bool {
        end.timeIntervalSince(start) < minimumDuration
    }
}
