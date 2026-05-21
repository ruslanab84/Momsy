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
    private let quickLogRepo: QuickLogRepository
    private let timerService: FeedingTimerService
    private let analytics: any AnalyticsServiceProtocol
    private let pushNotifications: any PushNotificationServiceProtocol

    init(logFeeding: LogFeedingUseCase,
         getFeeding: GetFeedingEntriesUseCase,
         diaperUC: DiaperUseCase,
         quickLogRepo: QuickLogRepository,
         timerService: FeedingTimerService,
         analytics: any AnalyticsServiceProtocol = LogAnalyticsService(),
         pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared) {
        self.logFeeding = logFeeding
        self.getFeeding = getFeeding
        self.diaperUC = diaperUC
        self.quickLogRepo = quickLogRepo
        self.timerService = timerService
        self.analytics = analytics
        self.pushNotifications = pushNotifications
        self.diaperCount = diaperUC.count
    }

    func loadTodayEntries() async {
        let feedings = (try? await getFeeding.execute(for: Date())) ?? []
        let feedingEntries: [LogEntry] = feedings.map {
            LogEntry(time: $0.date, kind: .bottle, label: feedingLabel($0))
        }
        let quickEntries: [LogEntry] = quickLogRepo.load().map {
            LogEntry(time: $0.time, kind: $0.kind, label: $0.label)
        }
        let merged = (feedingEntries + quickEntries).sorted { $0.time > $1.time }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            logEntries = merged
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
        let label = lm.strings.diaperLogEntry(count: count)
        quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .drop, label: label))
        addEntry(LogEntry(time: Date(), kind: .drop, label: label))
    }

    func removeDiaper() {
        diaperCount = diaperUC.decrement()
        quickLogRepo.removeLast(kind: .drop)
        if let idx = logEntries.firstIndex(where: { $0.kind == .drop }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                logEntries.remove(at: idx)
            }
        }
    }

    func logWalk() {
        let label = LocalizationManager.shared.strings.walkLogged
        quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .walk, label: label))
        addEntry(LogEntry(time: Date(), kind: .walk, label: label))
    }

    func logBath() {
        let label = LocalizationManager.shared.strings.bathLogged
        quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .bath, label: label))
        addEntry(LogEntry(time: Date(), kind: .bath, label: label))
    }

    func logVitamins() {
        let label = LocalizationManager.shared.strings.vitaminsGiven
        quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .vitamin, label: label))
        addEntry(LogEntry(time: Date(), kind: .vitamin, label: label))
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
