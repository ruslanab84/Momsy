import SwiftUI
import Combine

@MainActor
final class PumpingViewModel: ObservableObject {
    @Published var isPumpingActive = false
    @Published var pumpingSeconds = 0
    @Published var selectedSide: PumpingSide = .left
    @Published var volumeML: Int = 0
    @Published var todayEntries: [PumpingEntry] = []
    @Published var saveError: String?

    private var activeEntry: PumpingEntry?
    private var timerTask: Task<Void, Never>?
    private var lm: LocalizationManager { .shared }

    private let liveActivity = PumpingLiveActivityManager()
    private let repository: any PumpingRepository
    private let quickLogRepo: QuickLogRepository

    init(repository: any PumpingRepository, quickLogRepo: QuickLogRepository) {
        self.repository = repository
        self.quickLogRepo = quickLogRepo
        Task { await loadTodayEntries() }
    }

    deinit { timerTask?.cancel() }

    var pumpingTimerString: String {
        let m = pumpingSeconds / 60
        let s = pumpingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func start() {
        guard !isPumpingActive else { return }
        Task {
            do {
                let entry = try await repository.start(side: selectedSide)
                activeEntry = entry
                volumeML = 0
                activateTimer(from: entry.date)
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func stop() {
        guard isPumpingActive, let entry = activeEntry else { return }
        timerTask?.cancel()
        timerTask = nil
        isPumpingActive = false
        liveActivity.endActivity()
        let savedML = volumeML
        activeEntry = nil
        Task {
            do {
                let finished = try await repository.stop(entry, volumeML: savedML)
                let dur = finished.durationMinutes
                let label = lm.strings.pumpingLogEntry(dur: dur, ml: savedML)
                quickLogRepo.append(
                    QuickLogEntry(id: finished.id, time: finished.endDate ?? Date(), kind: .pump, label: label)
                )
                pushPumpingToFirestore(entry: finished)
                await loadTodayEntries()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    private func pushPumpingToFirestore(entry: PumpingEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = PumpingLog(
            id: entry.id.uuidString, date: entry.date,
            durationSeconds: entry.durationSeconds, side: entry.side.rawValue,
            volumeML: entry.volumeML, endDate: entry.endDate,
            addedBy: uid, addedByName: name
        )
        Task { try? await BabySyncService().setLog(PumpingLogDTO(from: log), id: log.id, to: "pumpingLogs") }
    }

    func syncTimerWithStartDate() {
        guard isPumpingActive, let entry = activeEntry else { return }
        pumpingSeconds = Int(Date().timeIntervalSince(entry.date))
    }

    func loadTodayEntries() async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        if let entries = try? await repository.getEntries(from: start, to: end) {
            todayEntries = entries
        }
    }

    func logManualEntry(date: Date, durationMinutes: Int, side: PumpingSide, volumeML: Int) {
        Task {
            do {
                let entry = try await repository.logManual(
                    date: date, durationMinutes: durationMinutes,
                    side: side, volumeML: volumeML)
                pushPumpingToFirestore(entry: entry)
                if Calendar.current.isDateInToday(entry.date) {
                    let label = lm.strings.pumpingLogEntry(dur: entry.durationMinutes, ml: volumeML)
                    quickLogRepo.append(
                        QuickLogEntry(id: entry.id, time: entry.endDate ?? entry.date, kind: .pump, label: label)
                    )
                    todayEntries.append(entry)
                    todayEntries.sort { $0.date < $1.date }
                }
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    private func activateTimer(from startDate: Date) {
        isPumpingActive = true
        pumpingSeconds = Int(Date().timeIntervalSince(startDate))
        liveActivity.startActivity(side: selectedSide.rawValue, startDate: startDate,
                                   babyName: WidgetDataStore.shared.babyName)
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled, let entry = self.activeEntry else { return }
                self.pumpingSeconds = Int(Date().timeIntervalSince(entry.date))
            }
        }
    }
}
