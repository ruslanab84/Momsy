import SwiftUI
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var isFeedingActive = false
    @Published var feedingSeconds = 0
    @Published var feedingSide: FeedingSide = .left
    @Published var diaperCount: Int
    @Published var logEntries: [LogEntry] = []

    private let logFeeding: LogFeedingUseCase
    private let getFeeding: GetFeedingEntriesUseCase
    private let diaperUC: DiaperUseCase
    private let timerService: FeedingTimerService

    init(logFeeding: LogFeedingUseCase,
         getFeeding: GetFeedingEntriesUseCase,
         diaperUC: DiaperUseCase,
         timerService: FeedingTimerService) {
        self.logFeeding = logFeeding
        self.getFeeding = getFeeding
        self.diaperUC = diaperUC
        self.timerService = timerService
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
        guard let last = logEntries.first(where: { $0.kind == .bottle }) else {
            return lm.t("—", "—")
        }
        let mins = max(0, Int(-last.time.timeIntervalSinceNow / 60))
        if mins < 60 { return lm.t("\(mins) min ago", "\(mins) мин назад") }
        let h = mins / 60, m = mins % 60
        return lm.lang == "en"
            ? (m == 0 ? "\(h)h ago" : "\(h)h \(m)min ago")
            : (m == 0 ? "\(h) ч назад" : "\(h) ч \(m) мин назад")
    }

    func startFeeding(side: FeedingSide) {
        feedingSide = side
        isFeedingActive = true
        feedingSeconds = 0
        timerService.start { [weak self] secs in
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
        var label = lm.t("Feeding · \(dur) min · \(side)", "Кормление · \(dur) мин · \(side)")
        if let m = mood { label += " · \(m)" }
        let secs = feedingSeconds
        let s = feedingSide
        Task { try? await logFeeding.execute(durationSeconds: secs, side: s, mood: mood) }
        addEntry(LogEntry(time: Date(), kind: .bottle, label: label))
    }

    func logDiaper() {
        let lm = LocalizationManager.shared
        let count = diaperUC.increment()
        diaperCount = count
        addEntry(LogEntry(time: Date(), kind: .drop,
                          label: lm.t("Diaper #\(count) · wet", "Подгузник #\(count) · мокрый")))
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
        let lm = LocalizationManager.shared
        addEntry(LogEntry(time: Date(), kind: .sleep,
                          label: lm.t("Sleep · started", "Сон · начало")))
    }

    func logSymptom() {
        let lm = LocalizationManager.shared
        addEntry(LogEntry(time: Date(), kind: .heart,
                          label: lm.t("Symptom · recorded", "Симптом · записан")))
    }

    private func feedingLabel(_ entry: FeedingEntry) -> String {
        let lm = LocalizationManager.shared
        let side = entry.side.displayName(lang: lm.lang).lowercased()
        return lm.t("Feeding · \(entry.durationMinutes) min · \(side)",
                    "Кормление · \(entry.durationMinutes) мин · \(side)")
    }

    private func addEntry(_ entry: LogEntry) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            logEntries.insert(entry, at: 0)
        }
    }
}
