import SwiftUI
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var isFeedingActive = false
    @Published var feedingSeconds = 0
    @Published var feedingSide: FeedingSide = .left
    private var feedingStartDate: Date?
    private var pausedFeedingSeconds = 0
    @Published var diaperCount: Int
    @Published var logEntries: [LogEntry] = []

    private let logFeeding: LogFeedingUseCase
    private let getFeeding: GetFeedingEntriesUseCase
    private let diaperUC: DiaperUseCase
    private let timerService: FeedingTimerService
    private let analytics: any AnalyticsServiceProtocol
    private let pushNotifications: any PushNotificationServiceProtocol

    init(logFeeding: LogFeedingUseCase,
         getFeeding: GetFeedingEntriesUseCase,
         diaperUC: DiaperUseCase,
         timerService: FeedingTimerService,
         analytics: any AnalyticsServiceProtocol = LogAnalyticsService(),
         pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared) {
        self.logFeeding = logFeeding
        self.getFeeding = getFeeding
        self.diaperUC = diaperUC
        self.timerService = timerService
        self.analytics = analytics
        self.pushNotifications = pushNotifications
        self.diaperCount = diaperUC.count
    }

    func loadTodayEntries() async {
        let all = (try? await getFeeding.execute(for: Date())) ?? []
        let mapped: [LogEntry] = all
            .sorted { $0.date > $1.date }
            .map { LogEntry(time: $0.date, kind: .bottle, label: feedingLabel($0)) }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            logEntries = mapped
        }
    }

    var feedingTimerString: String {
        String(format: "%02d:%02d", feedingSeconds / 60, feedingSeconds % 60)
    }

    var lastFeedAgoString: String {
        let lm = LocalizationManager.shared
        guard let last = logEntries.first(where: { $0.kind == .bottle }) else { return "—" }
        let mins = max(0, Int(-last.time.timeIntervalSinceNow / 60))
        if mins < 60 { return lm.strings.minsAgo(mins) }
        let h = mins / 60, m = mins % 60
        return lm.strings.hrsAgoFormatted(h: h, m: m)
    }

    func startFeeding(side: FeedingSide) {
        feedingSide = side
        isFeedingActive = true
        feedingSeconds = 0
        pausedFeedingSeconds = 0
        let startDate = Date()
        feedingStartDate = startDate
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
    }

    func resumeFeeding() {
        guard !isFeedingActive else { return }
        isFeedingActive = true
        let effectiveStart = Date().addingTimeInterval(-TimeInterval(pausedFeedingSeconds))
        feedingStartDate = effectiveStart
        timerService.start(from: effectiveStart) { [weak self] secs in
            Task { @MainActor [weak self] in self?.feedingSeconds = secs }
        }
    }

    func stopFeeding(mood: String? = nil) {
        guard isFeedingActive else { return }
        isFeedingActive = false
        timerService.stop()
        let lm = LocalizationManager.shared
        let dur = max(1, feedingSeconds / 60)
        let side = feedingSide.displayName(lang: lm.lang).lowercased()
        var label = lm.strings.feedingLogEntry(dur: dur, side: side)
        if let m = mood { label += " · \(m)" }
        let secs = feedingSeconds
        let s = feedingSide
        analytics.track(.feedingStopped(durationMinutes: dur, side: s.rawValue))
        pushNotifications.scheduleFeedingReminder(afterMinutes: 3 * 60)
        Task { try? await logFeeding.execute(durationSeconds: secs, side: s, mood: mood) }
        addEntry(LogEntry(time: Date(), kind: .bottle, label: label))
    }

    func logDiaper() {
        let lm = LocalizationManager.shared
        let count = diaperUC.increment()
        diaperCount = count
        addEntry(LogEntry(time: Date(), kind: .drop, label: lm.strings.diaperLogEntry(count: count)))
    }

    func removeDiaper() {
        diaperCount = diaperUC.decrement()
        if let idx = logEntries.firstIndex(where: { $0.kind == .drop }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                logEntries.remove(at: idx)
            }
        }
    }

    func logSleep() {
        addEntry(LogEntry(time: Date(), kind: .sleep, label: LocalizationManager.shared.strings.sleepStarted))
    }

    func logSymptom() {
        addEntry(LogEntry(time: Date(), kind: .heart, label: LocalizationManager.shared.strings.symptomRecorded))
    }

    private func feedingLabel(_ entry: FeedingEntry) -> String {
        let lm = LocalizationManager.shared
        let side = entry.side.displayName(lang: lm.lang).lowercased()
        return lm.strings.feedingLogEntry(dur: entry.durationMinutes, side: side)
    }

    private func addEntry(_ entry: LogEntry) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            logEntries.insert(entry, at: 0)
        }
    }
}
