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
    private var timerCancellable: AnyCancellable?
    private var lm: LocalizationManager { .shared }

    private let repository: any PumpingRepository
    private let quickLogRepo: QuickLogRepository

    init(repository: any PumpingRepository, quickLogRepo: QuickLogRepository) {
        self.repository = repository
        self.quickLogRepo = quickLogRepo
        Task { await loadTodayEntries() }
    }

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
        timerCancellable?.cancel()
        timerCancellable = nil
        isPumpingActive = false
        let savedML = volumeML
        activeEntry = nil
        Task {
            do {
                let finished = try await repository.stop(entry, volumeML: savedML)
                let dur = finished.durationMinutes
                let label = lm.strings.pumpingLogEntry(dur: dur, ml: savedML)
                quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .pump, label: label))
                await loadTodayEntries()
            } catch {
                saveError = error.localizedDescription
            }
        }
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

    private func activateTimer(from startDate: Date) {
        isPumpingActive = true
        pumpingSeconds = Int(Date().timeIntervalSince(startDate))
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let entry = self.activeEntry else { return }
                self.pumpingSeconds = Int(Date().timeIntervalSince(entry.date))
            }
    }
}
