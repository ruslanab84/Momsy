import SwiftUI
import Combine

@MainActor
final class WalkViewModel: ObservableObject {
    @Published var isWalkActive = false
    @Published var walkSeconds = 0
    @Published var todayEntries: [WalkEntry] = []
    @Published var saveError: String?

    private var activeWalkEntry: WalkEntry?
    private var timerCancellable: AnyCancellable?
    private var lm: LocalizationManager { .shared }

    private let walkRepository: any WalkRepository
    private let quickLogRepo: QuickLogRepository

    init(walkRepository: any WalkRepository, quickLogRepo: QuickLogRepository) {
        self.walkRepository = walkRepository
        self.quickLogRepo = quickLogRepo
        Task { await loadTodayEntries() }
    }

    var walkTimerString: String {
        let h = walkSeconds / 3600
        let m = (walkSeconds % 3600) / 60
        let s = walkSeconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    var lastWalkDurationString: String {
        guard let last = todayEntries.last(where: { $0.endDate != nil }),
              let mins = last.durationMinutes else { return "—" }
        return formatMinutes(mins)
    }

    var lastWalkSubtitle: String {
        guard let last = todayEntries.last(where: { $0.endDate != nil }),
              let end = last.endDate else { return lm.strings.noWalkYet }
        let mins = max(0, Int(-end.timeIntervalSinceNow / 60))
        if mins == 0 { return lm.strings.justNow }
        if mins < 60 { return lm.strings.minsAgo(mins) }
        return lm.strings.hrAgo(mins / 60)
    }

    var totalWalksToday: String {
        let total = todayEntries.compactMap(\.durationMinutes).reduce(0, +)
        if total == 0 { return "0 \(lm.strings.unitMin)" }
        return formatMinutes(total)
    }

    func start() {
        Task {
            do {
                let entry = try await walkRepository.start()
                activeWalkEntry = entry
                isWalkActive = true
                walkSeconds = 0
                timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in
                        guard let self, let entry = self.activeWalkEntry else { return }
                        self.walkSeconds = Int(Date().timeIntervalSince(entry.startDate))
                    }
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func stop() {
        guard isWalkActive, let entry = activeWalkEntry else { return }
        timerCancellable?.cancel()
        timerCancellable = nil
        isWalkActive = false
        activeWalkEntry = nil
        Task {
            do {
                let finished = try await walkRepository.stop(entry)
                let dur = finished.durationMinutes ?? 1
                let label = lm.strings.walkLogEntry(dur: dur)
                quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .walk, label: label))
                await loadTodayEntries()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func syncTimerWithStartDate() {
        guard isWalkActive, let entry = activeWalkEntry else { return }
        walkSeconds = Int(Date().timeIntervalSince(entry.startDate))
    }

    func loadTodayEntries() async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        if let entries = try? await walkRepository.getEntries(from: start, to: end) {
            todayEntries = entries.sorted { $0.startDate < $1.startDate }
        }
    }

    private func formatMinutes(_ mins: Int) -> String {
        if mins < 60 { return "\(mins) \(lm.strings.unitMin)" }
        let h = mins / 60, m = mins % 60
        return lm.strings.sleepDurationFormatted(h: h, m: m)
    }
}
