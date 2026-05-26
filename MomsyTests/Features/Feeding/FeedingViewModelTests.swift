import Testing
@testable import Momsy
import Foundation

@Suite("FeedingViewModel", .serialized)
@MainActor
struct FeedingViewModelTests {

    func makeVM(repo: MockFeedingRepository = MockFeedingRepository()) -> FeedingViewModel {
        FeedingViewModel(
            logFeeding: LogFeedingUseCase(repository: repo),
            getFeeding: GetFeedingEntriesUseCase(repository: repo),
            timerService: FeedingTimerService(),
            analytics: MockAnalyticsService(),
            pushNotifications: MockPushNotificationService()
        )
    }

    // MARK: - logManualEntry

    @Test("logManualEntry appends entry to todayEntries when date is today")
    func manualEntryAppendsToToday() async throws {
        let repo = MockFeedingRepository()
        let vm = makeVM(repo: repo)

        vm.logManualEntry(date: Date(), durationMinutes: 12, side: .left, mood: nil)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.todayEntries.count == 1)
        #expect(vm.todayEntries[0].durationSeconds == 12 * 60)
        #expect(vm.todayEntries[0].side == .left)
    }

    @Test("logManualEntry does NOT append to todayEntries when date is yesterday")
    func manualEntrySkipsYesterday() async throws {
        let repo = MockFeedingRepository()
        let vm = makeVM(repo: repo)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        vm.logManualEntry(date: yesterday, durationMinutes: 10, side: .right, mood: nil)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.todayEntries.isEmpty)
        #expect(repo.entries.count == 1)
    }

    @Test("logManualEntry persists mood note")
    func manualEntryPersistsMood() async throws {
        let repo = MockFeedingRepository()
        let vm = makeVM(repo: repo)

        vm.logManualEntry(date: Date(), durationMinutes: 5, side: .bottle, mood: "спокоен")
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(repo.entries[0].mood == "спокоен")
    }

    @Test("logManualEntry sets saveError on repository failure")
    func manualEntryPropagatesError() async throws {
        let repo = MockFeedingRepository()
        repo.shouldThrow = true
        let vm = makeVM(repo: repo)

        vm.logManualEntry(date: Date(), durationMinutes: 8, side: .left, mood: nil)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.saveError != nil)
    }

    @Test("logManualEntry keeps todayEntries sorted ascending by date")
    func manualEntryMaintainsSortOrder() async throws {
        let repo = MockFeedingRepository()
        let vm = makeVM(repo: repo)
        let now = Date()
        let earlier = now.addingTimeInterval(-3600)

        vm.logManualEntry(date: now, durationMinutes: 10, side: .left, mood: nil)
        try await Task.sleep(nanoseconds: 50_000_000)
        vm.logManualEntry(date: earlier, durationMinutes: 8, side: .right, mood: nil)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.todayEntries[0].date <= vm.todayEntries[1].date)
    }
}
