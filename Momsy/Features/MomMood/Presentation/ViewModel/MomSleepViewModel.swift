import SwiftUI
import Combine

@MainActor
final class MomSleepViewModel: ObservableObject {
    @Published var isSleepActive = false
    @Published var sleepSeconds = 0
    @Published var todayEntries: [SleepEntry] = []
    @Published var selectedQuality: SleepQuality = .normal
    @Published var saveError: String?
    @Published var selectedChartPeriod = 0
    @Published var sleepDays: [SleepDayPoint] = []

    let normMin: Double = 7
    let normMax: Double = 9

    private var activeSleepEntry: SleepEntry?
    private var timerCancellable: AnyCancellable?
    private var chartPeriodCancellable: AnyCancellable?
    private var lm: LocalizationManager { .shared }

    private let startUC: StartMomSleepUseCase
    private let stopUC: StopMomSleepUseCase
    private let getUC: GetMomSleepEntriesUseCase
    private let addManualUC: AddManualMomSleepUseCase

    init(start: StartMomSleepUseCase, stop: StopMomSleepUseCase,
         get: GetMomSleepEntriesUseCase, addManual: AddManualMomSleepUseCase) {
        self.startUC     = start
        self.stopUC      = stop
        self.getUC       = get
        self.addManualUC = addManual
        Task {
            await loadTodayEntries()
            if let open = todayEntries.first(where: { $0.endDate == nil }) {
                activateTimer(entry: open)
            }
            await loadChartData()
        }
        chartPeriodCancellable = $selectedChartPeriod
            .dropFirst()
            .sink { [weak self] _ in Task { [weak self] in await self?.loadChartData() } }
    }

    // MARK: - Chart

    func loadChartData() async {
        let cal = Calendar.current
        let dayCount = selectedChartPeriod == 0 ? 7 : 30
        let today = cal.startOfDay(for: Date())
        guard let periodStart = cal.date(byAdding: .day, value: -(dayCount - 1), to: today) else { return }
        let entries = (try? await getUC.execute(from: periodStart, to: Date())) ?? []
        let completed = entries.filter { $0.endDate != nil }
        sleepDays = (0..<dayCount).compactMap { offset in
            guard let day = cal.date(byAdding: .day, value: offset, to: periodStart) else { return nil }
            let mins = completed
                .filter { cal.isDate($0.startDate, inSameDayAs: day) }
                .compactMap(\.durationMinutes)
                .reduce(0, +)
            return SleepDayPoint(id: day, totalMinutes: mins)
        }
    }

    // MARK: - Computed Display

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
        return lm.strings.durationFormatted(mins)
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
        return lm.strings.durationFormatted(total)
    }

    // MARK: - Timer Actions

    func start() {
        Task {
            do {
                let entry = try await startUC.execute()
                activateTimer(entry: entry)
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func syncTimerWithStartDate() {
        guard isSleepActive, let entry = activeSleepEntry else { return }
        sleepSeconds = Int(Date().timeIntervalSince(entry.startDate))
    }

    private func activateTimer(entry: SleepEntry) {
        activeSleepEntry = entry
        isSleepActive = true
        sleepSeconds = Int(Date().timeIntervalSince(entry.startDate))
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let entry = self.activeSleepEntry else { return }
                self.sleepSeconds = Int(Date().timeIntervalSince(entry.startDate))
            }
    }

    func stop() {
        guard isSleepActive, var entry = activeSleepEntry else { return }
        timerCancellable?.cancel()
        timerCancellable = nil
        entry.quality = selectedQuality
        var completed = entry
        completed.endDate = Date()
        if let idx = todayEntries.firstIndex(where: { $0.id == completed.id }) {
            todayEntries[idx] = completed
        } else {
            todayEntries.append(completed)
        }
        isSleepActive = false
        activeSleepEntry = nil
        Task {
            do {
                let saved = try await stopUC.execute(entry)
                if let idx = todayEntries.firstIndex(where: { $0.id == saved.id }) {
                    todayEntries[idx] = saved
                }
                pushMomSleepToFirestore(saved)
            } catch {
                todayEntries.removeAll { $0.id == completed.id }
                saveError = error.localizedDescription
            }
        }
    }

    func logManualEntry(startDate: Date, endDate: Date, quality: SleepQuality, note: String) {
        Task {
            do {
                let saved = try await addManualUC.execute(
                    startDate: startDate, endDate: endDate, quality: quality, note: note)
                if Calendar.current.isDateInToday(saved.startDate) {
                    todayEntries.append(saved)
                    todayEntries.sort { $0.startDate < $1.startDate }
                }
                pushMomSleepToFirestore(saved)
                await loadChartData()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    /// Mom's sleep syncs to its own `momSleepLogs` subcollection (reusing the SleepLog
    /// shape) so it round-trips across devices without colliding with the baby's sleep.
    private func pushMomSleepToFirestore(_ entry: SleepEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = SleepLog(
            id: entry.id.uuidString, startedAt: entry.startDate,
            endedAt: entry.endDate, durationMin: entry.durationMinutes,
            quality: entry.quality, addedBy: "", addedByName: ""
        )
        Task { try? await BabySyncService().setLog(SleepLogDTO(from: log), id: log.id, to: "momSleepLogs") }
    }

    func loadTodayEntries() async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        if let entries = try? await getUC.execute(from: start, to: end) {
            todayEntries = entries.sorted { $0.startDate < $1.startDate }
        }
    }
}
