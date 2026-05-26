import SwiftUI
import Combine

@MainActor
final class FeedingViewModel: ObservableObject {
    @Published var isFeedingActive = false
    @Published var feedingSeconds = 0
    @Published var feedingSide: FeedingSide = .left
    @Published var saveError: String?
    @Published var feedingSessionExists: Bool = false
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
        feedingSessionExists = true
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
        guard isFeedingActive || feedingSessionExists else { return }
        isFeedingActive = false
        feedingSessionExists = false
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

    func logManualEntry(date: Date, durationMinutes: Int, side: FeedingSide, mood: String?) {
        Task {
            do {
                let saved = try await logFeeding.execute(
                    durationSeconds: max(60, durationMinutes * 60),
                    side: side,
                    mood: mood,
                    date: date
                )
                if Calendar.current.isDateInToday(saved.date) {
                    todayEntries.append(saved)
                    todayEntries.sort { $0.date < $1.date }
                }
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    /// Called on FeedingView appear — resumes an existing session from WidgetDataStore
    /// (e.g. after app relaunch) or starts a fresh one if none exists.
    func restoreOrStartFeeding(side: FeedingSide) {
        switch WidgetDataStore.shared.feedingState {
        case .running(let effectiveStartDate, let sideRaw):
            feedingSide = FeedingSide(rawValue: sideRaw) ?? side
            isFeedingActive = true
            feedingSessionExists = true
            let elapsed = max(0, Int(Date().timeIntervalSince(effectiveStartDate)))
            feedingSeconds = elapsed
            pausedFeedingSeconds = 0
            timerService.start(from: effectiveStartDate) { [weak self] secs in
                Task { @MainActor [weak self] in self?.feedingSeconds = secs }
            }
        case .paused(let elapsedSeconds, let sideRaw):
            feedingSide = FeedingSide(rawValue: sideRaw) ?? side
            isFeedingActive = false
            feedingSessionExists = true
            feedingSeconds = elapsedSeconds
            pausedFeedingSeconds = elapsedSeconds
        default:
            startFeeding(side: side)
        }
    }

    /// Called on scenePhase → .active — restarts the in-process timer from the
    /// stored effectiveStartDate so elapsed time is accurate after backgrounding.
    func syncTimerWithStartDate() {
        guard isFeedingActive else { return }
        guard case .running(let effectiveStartDate, _) = WidgetDataStore.shared.feedingState else { return }
        timerService.start(from: effectiveStartDate) { [weak self] secs in
            Task { @MainActor [weak self] in self?.feedingSeconds = secs }
        }
    }
}
