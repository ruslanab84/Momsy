import Foundation
import Testing
@testable import Momsy

struct StopSleepUseCaseTests {

    // MARK: — Pure threshold logic

    @Test func below60SecondsIsBelowMinimum() {
        let start = Date()
        #expect(StopSleepUseCase.isBelowMinimum(start: start, end: start.addingTimeInterval(59)))
    }

    @Test func exactly60SecondsIsNotBelowMinimum() {
        let start = Date()
        #expect(!StopSleepUseCase.isBelowMinimum(start: start, end: start.addingTimeInterval(60)))
    }

    @Test func negativeDurationIsBelowMinimum() {
        let start = Date()
        #expect(StopSleepUseCase.isBelowMinimum(start: start, end: start.addingTimeInterval(-30)))
    }

    // MARK: — Use case behavior

    @Test func shortSessionIsDeletedAndReportedDiscarded() async throws {
        let repo = MockSleepRepository()
        let start = Date().addingTimeInterval(-10)
        let entry = SleepEntry(startDate: start)
        repo.entries = [entry]

        let outcome = try await StopSleepUseCase(repository: repo).execute(entry)

        guard case .discarded(let discarded) = outcome else {
            Issue.record("Expected .discarded, got \(outcome)")
            return
        }
        #expect(discarded.id == entry.id)
        #expect(repo.entries.isEmpty)
    }

    @Test func normalSessionIsSavedWithEndAndUpdatedAt() async throws {
        let repo = MockSleepRepository()
        let start = Date().addingTimeInterval(-1800)
        let entry = SleepEntry(startDate: start, updatedAt: start)
        repo.entries = [entry]
        let now = Date()

        let outcome = try await StopSleepUseCase(repository: repo).execute(entry, now: now)

        guard case .saved(let saved) = outcome else {
            Issue.record("Expected .saved, got \(outcome)")
            return
        }
        #expect(saved.endDate == now)
        #expect(saved.updatedAt == now)
        #expect(repo.entries.first?.endDate == now)
    }

    @Test func shortSessionCanBeSavedWhenDeletionIsNotAllowed() async throws {
        let repo = MockSleepRepository()
        let now = Date()
        let entry = SleepEntry(startDate: now.addingTimeInterval(-10))
        repo.entries = [entry]

        let outcome = try await StopSleepUseCase(repository: repo).execute(
            entry,
            now: now,
            shortSessionPolicy: .save
        )

        guard case .saved(let saved) = outcome else {
            Issue.record("Expected .saved when short-session deletion is disabled")
            return
        }
        #expect(saved.endDate == now)
        #expect(repo.entries.first?.endDate == now)
    }

    @Test func boundarySessionAtExactlyMinimumIsSaved() async throws {
        let repo = MockSleepRepository()
        let now = Date()
        let entry = SleepEntry(startDate: now.addingTimeInterval(-StopSleepUseCase.minimumDuration))
        repo.entries = [entry]

        let outcome = try await StopSleepUseCase(repository: repo).execute(entry, now: now)

        guard case .saved = outcome else {
            Issue.record("Expected .saved at exact threshold")
            return
        }
        #expect(repo.entries.count == 1)
    }
}
