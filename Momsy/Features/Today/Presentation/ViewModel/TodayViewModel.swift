import SwiftUI
import Combine

final class TodayViewModel: ObservableObject {
    @Published var isFeedingActive = false
    @Published var feedingSeconds = 0
    @Published var feedingSide: FeedingSide = .left
    @Published var diaperCount = 5
    @Published var logEntries: [LogEntry]

    private var timerCancellable: AnyCancellable?
    private var lm: LocalizationManager { .shared }

    init() {
        let cal = Calendar.current
        let today = Date()
        func ts(_ h: Int, _ m: Int) -> Date {
            cal.date(bySettingHour: h, minute: m, second: 0, of: today) ?? today
        }
        logEntries = [
            LogEntry(time: ts(6, 42), kind: .bottle, tone: .bbCoral,  label: "Feeding · 15 min · right"),
            LogEntry(time: ts(5, 10), kind: .sleep,  tone: .bbLilac,  label: "Wake-up · slept 4h 12min"),
            LogEntry(time: ts(4, 55), kind: .drop,   tone: .bbSky,    label: "Diaper · wet"),
            LogEntry(time: ts(1,  8), kind: .bottle, tone: .bbCoral,  label: "Feeding · 22 min · left"),
        ]
    }

    var feedingTimerString: String {
        String(format: "%02d:%02d", feedingSeconds / 60, feedingSeconds % 60)
    }

    var lastFeedAgoString: String {
        guard let last = logEntries.first(where: { $0.kind == .bottle }) else {
            return lm.t("—", "—")
        }
        let mins = max(0, Int(-last.time.timeIntervalSinceNow / 60))
        if mins < 60 { return lm.t("\(mins) min ago", "\(mins) мин назад") }
        let h = mins / 60, m = mins % 60
        if lm.lang == "en" {
            return m == 0 ? "\(h)h ago" : "\(h)h \(m)min ago"
        } else {
            return m == 0 ? "\(h) ч назад" : "\(h) ч \(m) мин назад"
        }
    }

    func startFeeding(side: FeedingSide) {
        feedingSide = side
        isFeedingActive = true
        feedingSeconds = 0
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.feedingSeconds += 1 }
    }

    func stopFeeding(mood: String? = nil) {
        guard isFeedingActive else { return }
        isFeedingActive = false
        timerCancellable?.cancel()
        timerCancellable = nil
        let dur = max(1, feedingSeconds / 60)
        let side = feedingSide.displayName(lang: lm.lang).lowercased()
        var label = lm.t("Feeding · \(dur) min · \(side)", "Кормление · \(dur) мин · \(side)")
        if let m = mood { label += " · \(m)" }
        addEntry(LogEntry(time: Date(), kind: .bottle, tone: .bbCoral, label: label))
    }

    func logDiaper() {
        diaperCount += 1
        addEntry(LogEntry(time: Date(), kind: .drop, tone: .bbSky,
                          label: lm.t("Diaper #\(diaperCount) · wet", "Подгузник #\(diaperCount) · мокрый")))
    }

    func removeDiaper() {
        guard diaperCount > 0 else { return }
        diaperCount -= 1
        if let idx = logEntries.firstIndex(where: { $0.kind == .drop }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                logEntries.remove(at: idx)
            }
        }
    }

    func logSleep() {
        addEntry(LogEntry(time: Date(), kind: .sleep, tone: .bbLilac,
                          label: lm.t("Sleep · started", "Сон · начало")))
    }

    func logSymptom() {
        addEntry(LogEntry(time: Date(), kind: .heart, tone: .bbRose,
                          label: lm.t("Symptom · recorded", "Симптом · записан")))
    }

    private func addEntry(_ entry: LogEntry) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            logEntries.insert(entry, at: 0)
        }
    }
}
