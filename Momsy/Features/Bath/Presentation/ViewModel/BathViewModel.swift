import SwiftUI
import Combine

@MainActor
final class BathViewModel: ObservableObject {
    @Published var isBathActive = false
    @Published var bathSeconds = 0
    @Published var todayEntries: [BathEntry] = []
    @Published var saveError: String?

    private var activeBathEntry: BathEntry?
    private var timerCancellable: AnyCancellable?
    private var lm: LocalizationManager { .shared }

    private let liveActivity = BathLiveActivityManager()
    private let bathRepository: any BathRepository
    private let quickLogRepo: QuickLogRepository
    private let addManualBathUC: AddManualBathUseCase

    init(bathRepository: any BathRepository, quickLogRepo: QuickLogRepository,
         addManualBath: AddManualBathUseCase) {
        self.bathRepository = bathRepository
        self.quickLogRepo = quickLogRepo
        self.addManualBathUC = addManualBath
        Task {
            await loadTodayEntries()
            if let open = todayEntries.first(where: { $0.endDate == nil }) {
                if case .active = WidgetDataStore.shared.bathState {
                    liveActivity.reattachIfNeeded()
                    activateTimer(entry: open)
                } else {
                    // Orphaned open entry: recover its real end (or discard) — never
                    // stamp `now`, which would record a phantom multi-hour/day bath.
                    await reconcileStaleBath(open)
                    await loadTodayEntries()
                }
            }
        }
    }

    /// Longest plausible single bath; beyond this the recovered end is untrusted.
    private static let maxPlausibleBath: TimeInterval = 6 * 3600

    /// Closes an orphaned open bath at the end derived from the widget's last recorded
    /// duration, or discards it when that is unknown / implausible.
    private func reconcileStaleBath(_ entry: BathEntry) async {
        var recoveredEnd: Date?
        if case .idle(let secs) = WidgetDataStore.shared.bathState, let secs, secs > 0 {
            recoveredEnd = entry.startDate.addingTimeInterval(TimeInterval(secs))
        }
        let end: Date?
        switch StaleSessionReconciler.resolve(
            start: entry.startDate, recoveredEnd: recoveredEnd, maxDuration: Self.maxPlausibleBath
        ) {
        case .close(let at): end = at
        case .discard:       end = nil
        }
        try? await bathRepository.resolveOrphan(id: entry.id, endDate: end)
    }

    var bathTimerString: String {
        let h = bathSeconds / 3600
        let m = (bathSeconds % 3600) / 60
        let s = bathSeconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    var lastBathDurationString: String {
        guard let last = todayEntries.last(where: { $0.endDate != nil }),
              let mins = last.durationMinutes else { return "—" }
        return lm.strings.durationFormatted(mins)
    }

    var lastBathSubtitle: String {
        guard let last = todayEntries.last(where: { $0.endDate != nil }),
              let end = last.endDate else { return lm.strings.noBathYet }
        let mins = max(0, Int(-end.timeIntervalSinceNow / 60))
        if mins == 0 { return lm.strings.justNow }
        if mins < 60 { return lm.strings.minsAgo(mins) }
        return lm.strings.hrAgo(mins / 60)
    }

    var totalBathsToday: String {
        let total = todayEntries.compactMap(\.durationMinutes).reduce(0, +)
        return lm.strings.durationFormatted(total)
    }

    func start() {
        Task {
            do {
                let entry = try await bathRepository.start()
                activateTimer(entry: entry)
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func stop() {
        guard isBathActive, let entry = activeBathEntry else { return }
        timerCancellable?.cancel()
        timerCancellable = nil
        isBathActive = false
        activeBathEntry = nil
        liveActivity.endActivity()
        WidgetDataStore.shared.clearBath(lastDurationSeconds: bathSeconds)
        Task {
            do {
                let finished = try await bathRepository.stop(entry)
                let dur = finished.durationMinutes ?? 1
                let label = lm.strings.bathLogEntry(dur: dur)
                quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .bath, label: label))
                await loadTodayEntries()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    private func activateTimer(entry: BathEntry) {
        activeBathEntry = entry
        isBathActive = true
        bathSeconds = Int(Date().timeIntervalSince(entry.startDate))
        WidgetDataStore.shared.setBathActive(startDate: entry.startDate)
        liveActivity.startActivity(startDate: entry.startDate, babyName: WidgetDataStore.shared.babyName)
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let entry = self.activeBathEntry else { return }
                self.bathSeconds = Int(Date().timeIntervalSince(entry.startDate))
            }
    }

    func logManualEntry(startDate: Date, endDate: Date, note: String) {
        Task {
            do {
                let saved = try await addManualBathUC.execute(startDate: startDate, endDate: endDate)
                let dur = saved.durationMinutes ?? 1
                let label = lm.strings.bathLogEntry(dur: dur)
                quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .bath, label: label))
                if Calendar.current.isDateInToday(saved.startDate) {
                    await loadTodayEntries()
                }
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func syncTimerWithStartDate() {
        guard isBathActive, let entry = activeBathEntry else { return }
        bathSeconds = Int(Date().timeIntervalSince(entry.startDate))
    }

    func loadTodayEntries() async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        if let entries = try? await bathRepository.getEntries(from: start, to: end) {
            todayEntries = entries.sorted { $0.startDate < $1.startDate }
        }
    }

}
