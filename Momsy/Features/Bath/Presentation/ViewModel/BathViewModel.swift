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

    private let bathRepository: any BathRepository
    private let quickLogRepo: QuickLogRepository

    init(bathRepository: any BathRepository, quickLogRepo: QuickLogRepository) {
        self.bathRepository = bathRepository
        self.quickLogRepo = quickLogRepo
        Task { await loadTodayEntries() }
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
        return formatMinutes(mins)
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
        if total == 0 { return "0 \(lm.strings.unitMin)" }
        return formatMinutes(total)
    }

    func start() {
        Task {
            do {
                let entry = try await bathRepository.start()
                activeBathEntry = entry
                isBathActive = true
                bathSeconds = 0
                timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in
                        guard let self, let entry = self.activeBathEntry else { return }
                        self.bathSeconds = Int(Date().timeIntervalSince(entry.startDate))
                    }
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

    func loadTodayEntries() async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        if let entries = try? await bathRepository.getEntries(from: start, to: end) {
            todayEntries = entries.sorted { $0.startDate < $1.startDate }
        }
    }

    private func formatMinutes(_ mins: Int) -> String {
        if mins < 60 { return "\(mins) \(lm.strings.unitMin)" }
        let h = mins / 60, m = mins % 60
        return lm.strings.sleepDurationFormatted(h: h, m: m)
    }
}
