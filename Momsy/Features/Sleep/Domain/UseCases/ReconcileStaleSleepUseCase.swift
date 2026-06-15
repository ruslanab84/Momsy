import Foundation

/// Resolves an orphaned open sleep session recovered at launch: closes it at the
/// recovered real end, or deletes it when no trustworthy end is known. Never stamps
/// `now` — see `StaleSessionReconciler`.
final class ReconcileStaleSleepUseCase {
    private let repository: SleepRepository
    init(repository: SleepRepository) { self.repository = repository }

    /// - Parameter end: the recovered true end time, or `nil` to delete the orphan.
    func execute(_ entry: SleepEntry, end: Date?) async throws {
        if let end {
            var fixed = entry
            fixed.endDate = end
            try await repository.update(fixed)
        } else {
            try await repository.delete(id: entry.id)
        }
    }
}
