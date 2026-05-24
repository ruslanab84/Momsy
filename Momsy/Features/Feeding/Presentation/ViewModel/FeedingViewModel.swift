import SwiftUI
import Combine

@MainActor
final class FeedingViewModel: ObservableObject {
    @Published var isFeedingActive = false
    @Published var feedingSeconds = 0
    @Published var feedingSide: FeedingSide = .left
    @Published var saveError: String?
    @Published private(set) var todayEntries: [FeedingEntry] = []

    private var pausedFeedingSeconds = 0
    private let logFeeding: LogFeedingUseCase
    private let getFeeding: GetFeedingEntriesUseCase
    private let timerService: FeedingTimerService
    private let analytics: any AnalyticsServiceProtocol
    private let pushNotifications: any PushNotificationServiceProtocol
    private var lm: LocalizationManager { .shared }

    init(
        logFeeding: LogFeedingUseCase,
        getFeeding: GetFeedingEntriesUseCase,
        timerService: FeedingTimerService,
        analytics: any AnalyticsServiceProtocol,
        pushNotifications: any PushNotificationServiceProtocol
    ) {
        self.logFeeding = logFeeding
        self.getFeeding = getFeeding
        self.timerService = timerService
        self.analytics = analytics
        self.pushNotifications = pushNotifications
    }

    var feedingTimerString: String {
        String(format: "%02d:%02d", feedingSeconds / 60, feedingSeconds % 60)
    }

    var lastFeedAgoString: String {
        guard let last = todayEntries.last else { return "—" }
        let mins = max(0, Int(-last.date.timeIntervalSinceNow / 60))
        if mins < 60 { return lm.strings.minsAgo(mins) }
        let h = mins / 60, m = mins % 60
        return lm.strings.hrsAgoFormatted(h: h, m: m)
    }

    func loadTodayEntries() async {
        todayEntries = (try? await getFeeding.execute(for: Date())) ?? []
    }

    func startFeeding(side: FeedingSide) {
        feedingSide = side
        isFeedingActive = true
        feedingSeconds = 0
        pausedFeedingSeconds = 0
        let startDate = Date()
        WidgetDataStore.shared.setFeedingRunning(effectiveStartDate: startDate, side: side.rawValue)
        analytics.track(.feedingStarted(side: side.rawValue))
        timerService.start(from: startDate) { [weak self] secs in
            Task { @MainActor [weak self] in self?.feedingSeconds = secs }
        }
    }

    func pauseFeeding() {
        guard isFeedingActive else { return }
        isFeedingActive = false
        pausedFeedingSeconds = feedingSeconds
        timerService.stop()
        WidgetDataStore.shared.setFeedingPaused(elapsedSeconds: pausedFeedingSeconds, side: feedingSide.rawValue)
    }

    func resumeFeeding() {
        guard !isFeedingActive else { return }
        isFeedingActive = true
        let effectiveStart = Date().addingTimeInterval(-TimeInterval(pausedFeedingSeconds))
        WidgetDataStore.shared.setFeedingRunning(effectiveStartDate: effectiveStart, side: feedingSide.rawValue)
        timerService.start(from: effectiveStart) { [weak self] secs in
            Task { @MainActor [weak self] in self?.feedingSeconds = secs }
        }
    }

    func stopFeeding(mood: String? = nil) {
        guard isFeedingActive else { return }
        isFeedingActive = false
        timerService.stop()
        WidgetDataStore.shared.clearFeeding(lastFeedingDate: Date())
        let dur = max(1, feedingSeconds / 60)
        let secs = feedingSeconds
        let s = feedingSide
        analytics.track(.feedingStopped(durationMinutes: dur, side: s.rawValue))
        pushNotifications.scheduleFeedingReminder(afterMinutes: 3 * 60)
        Task {
            do {
                let saved = try await logFeeding.execute(durationSeconds: secs, side: s, mood: mood)
                todayEntries.append(saved)
            } catch {
                saveError = error.localizedDescription
            }
        }
    }
}
