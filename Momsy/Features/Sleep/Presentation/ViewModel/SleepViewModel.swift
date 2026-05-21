import SwiftUI
import Combine

@MainActor
final class SleepViewModel: ObservableObject {
    @Published var isSleepActive = false
    @Published var sleepSeconds = 0
    @Published var todayEntries: [SleepEntry] = []
    @Published var selectedQuality: SleepQuality = .normal

    private var activeSleepEntry: SleepEntry?
    private var timerCancellable: AnyCancellable?
    private var lm: LocalizationManager { .shared }

    private let startSleepUC: StartSleepUseCase
    private let stopSleepUC: StopSleepUseCase
    private let getSleepUC: GetSleepEntriesUseCase

    init(startSleep: StartSleepUseCase, stopSleep: StopSleepUseCase, getSleep: GetSleepEntriesUseCase) {
        self.startSleepUC = startSleep
        self.stopSleepUC = stopSleep
        self.getSleepUC = getSleep
        Task { await loadTodayEntries() }
    }

    var sleepTimerString: String {
        let h = sleepSeconds / 3600
        let m = (sleepSeconds % 3600) / 60
        let s = sleepSeconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    var lastSleepDurationString: String {
        guard let last = todayEntries.last(where: { $0.endDate != nil }),
              let mins = last.durationMinutes else { return "—" }
        return formatMinutes(mins)
    }

    var lastSleepSubtitle: String {
        guard let last = todayEntries.last(where: { $0.endDate != nil }),
              let end = last.endDate else { return lm.strings.noSleepYet }
        let mins = max(0, Int(-end.timeIntervalSinceNow / 60))
        if mins == 0 { return lm.strings.justNow }
        if mins < 60 { return lm.strings.minsAgo(mins) }
        return lm.strings.hrAgo(mins / 60)
    }

    var totalSleepToday: String {
        let total = todayEntries.compactMap(\.durationMinutes).reduce(0, +)
        if total == 0 { return "0 \(lm.strings.unitMin)" }
        return formatMinutes(total)
    }

    func start() {
        Task {
            guard let entry = try? await startSleepUC.execute() else { return }
            activeSleepEntry = entry
            isSleepActive = true
            sleepSeconds = 0
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self, let entry = self.activeSleepEntry else { return }
                    self.sleepSeconds = Int(Date().timeIntervalSince(entry.startDate))
                }
        }
    }

    func stop() {
        guard isSleepActive, var entry = activeSleepEntry else { return }
        timerCancellable?.cancel()
        timerCancellable = nil
        entry.quality = selectedQuality
        isSleepActive = false
        activeSleepEntry = nil
        Task {
            _ = try? await stopSleepUC.execute(entry)
            await loadTodayEntries()
        }
    }

    func loadTodayEntries() async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        if let entries = try? await getSleepUC.execute(from: start, to: end) {
            todayEntries = entries.sorted { $0.startDate < $1.startDate }
        }
    }

    private func formatMinutes(_ mins: Int) -> String {
        if mins < 60 { return "\(mins) \(lm.strings.unitMin)" }
        let h = mins / 60, m = mins % 60
        return lm.strings.sleepDurationFormatted(h: h, m: m)
    }
}
