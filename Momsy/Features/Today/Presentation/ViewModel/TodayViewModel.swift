import SwiftUI
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var diaperCount: Int = 0
    @Published var logEntries: [LogEntry] = []
    @Published var saveError: String?

    private let getFeeding: GetFeedingEntriesUseCase
    private let getSleep: GetSleepEntriesUseCase
    private let diaperRepo: any DiaperRepository
    private let quickLogRepo: QuickLogRepository

    init(
        getFeeding: GetFeedingEntriesUseCase,
        getSleep: GetSleepEntriesUseCase,
        diaperRepo: any DiaperRepository,
        quickLogRepo: QuickLogRepository
    ) {
        self.getFeeding = getFeeding
        self.getSleep = getSleep
        self.diaperRepo = diaperRepo
        self.quickLogRepo = quickLogRepo
        Task { await loadDiaperCount() }
    }

    private func loadDiaperCount() async {
        diaperCount = (try? await diaperRepo.countToday()) ?? 0
    }

    func loadTodayEntries() async {
        let feedings = (try? await getFeeding.execute(for: Date())) ?? []
        let feedingEntries: [LogEntry] = feedings.map {
            LogEntry(time: $0.date, kind: .bottle, label: feedingLabel($0))
        }
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: Date())
        let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let sleeps = (try? await getSleep.execute(from: startOfDay, to: endOfDay)) ?? []
        let sleepEntries: [LogEntry] = sleeps.map { sleepLabel($0) }
        let quickEntries: [LogEntry] = quickLogRepo.load().map {
            LogEntry(time: $0.time, kind: $0.kind, label: $0.label)
        }
        let merged = (feedingEntries + sleepEntries + quickEntries).sorted { $0.time > $1.time }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            logEntries = merged
        }
    }

    func logDiaper() {
        let lm = LocalizationManager.shared
        let newCount = diaperCount + 1
        diaperCount = newCount
        let label = lm.strings.diaperLogEntry(count: newCount)
        quickLogRepo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .drop, label: label))
        addEntry(LogEntry(time: Date(), kind: .drop, label: label))
        Task { try? await diaperRepo.add(DiaperEntry()) }
    }

    func removeDiaper() {
        guard diaperCount > 0 else { return }
        diaperCount -= 1
        quickLogRepo.removeLast(kind: .drop)
        if let idx = logEntries.firstIndex(where: { $0.kind == .drop }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                logEntries.remove(at: idx)
            }
        }
        Task { try? await diaperRepo.removeLatest(on: Date()) }
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

    func logSymptom() {
        addEntry(LogEntry(time: Date(), kind: .heart, label: LocalizationManager.shared.strings.symptomRecorded))
    }

    private func sleepLabel(_ entry: SleepEntry) -> LogEntry {
        let lm = LocalizationManager.shared
        let label: String
        if let mins = entry.durationMinutes {
            let h = mins / 60, m = mins % 60
            let dur = lm.strings.sleepDurationFormatted(h: h, m: m)
            label = lm.lang == "en" ? "Sleep · \(dur)" : "Сон · \(dur)"
        } else {
            label = lm.strings.sleepStarted
        }
        return LogEntry(time: entry.startDate, kind: .sleep, label: label)
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
