import SwiftUI
import Combine

@MainActor
final class SleepViewModel: ObservableObject {
    @Published var isSleepActive = false
    @Published var sleepSeconds = 0
    @Published var todayEntries: [SleepEntry] = []
    @Published var selectedQuality: SleepQuality = .normal
    @Published var saveError: String?
    @Published var selectedChartPeriod = 0
    @Published var sleepDays: [SleepDayPoint] = []
    @Published private(set) var nextSleep: SleepPrediction?

    private var activeSleepEntry: SleepEntry?
    private var activeSleepBabyId: UUID?
    private var pendingStartEntryId: UUID?
    private var pendingStartTask: Task<SleepEntry, Error>?
    private var timerTask: Task<Void, Never>?
    private var activeBabyCancellable: AnyCancellable?
    private var reloadTask: Task<Void, Never>?
    private var lm: LocalizationManager { .shared }

    private let liveActivity = SleepLiveActivityManager()
    /// Longest plausible single sleep; anything beyond this is treated as a corrupt
    /// recovered end and the orphan is discarded instead of closed.
    private static let maxPlausibleSleep: TimeInterval = 24 * 3600

    private let startSleepUC: StartSleepUseCase
    private let stopSleepUC: StopSleepUseCase
    private let getSleepUC: GetSleepEntriesUseCase
    private let addManualSleepUC: AddManualSleepUseCase
    private let reconcileStaleSleepUC: ReconcileStaleSleepUseCase
    private let predictNextSleepUC: PredictNextSleepUseCase
    private let appState: AppState

    init(startSleep: StartSleepUseCase, stopSleep: StopSleepUseCase,
         getSleep: GetSleepEntriesUseCase, addManualSleep: AddManualSleepUseCase,
         reconcileStaleSleep: ReconcileStaleSleepUseCase, appState: AppState,
         predictNextSleep: PredictNextSleepUseCase) {
        self.startSleepUC = startSleep
        self.stopSleepUC = stopSleep
        self.getSleepUC = getSleep
        self.addManualSleepUC = addManualSleep
        self.reconcileStaleSleepUC = reconcileStaleSleep
        self.predictNextSleepUC = predictNextSleep
        self.appState = appState
        activeBabyCancellable = appState.$babyProfile
            .map { $0?.id }
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.scheduleReloadForActiveBaby(reconcileStaleOpenSession: false, clearVisibleState: true)
                }
            }
        scheduleReloadForActiveBaby(reconcileStaleOpenSession: true, clearVisibleState: false)
    }

    deinit {
        timerTask?.cancel()
        pendingStartTask?.cancel()
        reloadTask?.cancel()
        activeBabyCancellable?.cancel()
    }

    func refreshForecast() async {
        await refreshForecast(expectedBabyId: currentBabyId)
    }

    var sleepNorm: (min: Double, max: Double) {
        guard let birth = appState.babyProfile?.birthDate else { return (12, 14) }
        let months = Calendar.current.dateComponents([.month], from: birth, to: Date()).month ?? 0
        switch months {
        case 0..<3:  return (14, 17)
        case 3..<6:  return (12, 15)
        case 6..<12: return (12, 14)
        case 12..<24: return (11, 14)
        default:     return (10, 13)
        }
    }

    func loadChartData() async {
        await loadChartData(expectedBabyId: currentBabyId)
    }

    private func loadChartData(expectedBabyId: UUID?) async {
        let cal = Calendar.current
        let dayCount = selectedChartPeriod == 0 ? 7 : 30
        let today = cal.startOfDay(for: Date())
        guard let periodStart = cal.date(byAdding: .day, value: -(dayCount - 1), to: today) else { return }
        let entries = (try? await withBabyScope(expectedBabyId) {
            try await getSleepUC.executeOverlapping(from: periodStart, to: Date())
        }) ?? []
        guard isCurrentBaby(expectedBabyId) else { return }
        let completed = entries.filter { $0.endDate != nil }
        sleepDays = (0..<dayCount).compactMap { offset in
            guard let day = cal.date(byAdding: .day, value: offset, to: periodStart),
                  let next = cal.date(byAdding: .day, value: 1, to: day) else { return nil }
            let mins = completed.reduce(0) { total, entry in
                guard let end = entry.endDate else { return total }
                return total + SleepDayWindow.clippedMinutes(
                    start: entry.startDate,
                    end: end,
                    dayStart: day,
                    dayEnd: next
                )
            }
            return SleepDayPoint(id: day, totalMinutes: mins)
        }
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
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: Date())
        let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart.addingTimeInterval(24 * 3600)
        let total = todayEntries.reduce(0) { total, entry in
            guard let end = entry.endDate else { return total }
            return total + SleepDayWindow.clippedMinutes(
                start: entry.startDate,
                end: end,
                dayStart: dayStart,
                dayEnd: dayEnd
            )
        }
        return lm.strings.durationFormatted(total)
    }

    func start() {
        guard !isSleepActive else { return }
        let babyId = currentBabyId
        let entry = SleepEntry(startDate: Date())
        reloadTask?.cancel()
        saveError = nil
        activateTimer(entry: entry, babyId: babyId)

        let startTask = Task { @MainActor in
            try await withBabyScope(babyId) {
                try await startSleepUC.execute(entry)
            }
        }
        pendingStartEntryId = entry.id
        pendingStartTask = startTask

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let saved = try await startTask.value
                finishStartPersistence(saved, optimisticEntryId: entry.id, babyId: babyId)
            } catch {
                handleStartPersistenceFailure(error, optimisticEntryId: entry.id, babyId: babyId)
            }
        }
    }

    func syncTimerWithStartDate() {
        guard isSleepActive, let entry = activeSleepEntry else { return }
        sleepSeconds = Int(Date().timeIntervalSince(entry.startDate))
    }

    private func activateTimer(entry: SleepEntry, babyId: UUID?) {
        activeSleepEntry = entry
        activeSleepBabyId = babyId
        isSleepActive = true
        sleepSeconds = Int(Date().timeIntervalSince(entry.startDate))
        WidgetDataStore.shared.setSleepActive(startDate: entry.startDate, babyId: babyId)
        liveActivity.startActivity(startDate: entry.startDate, babyName: appState.babyProfile?.name ?? "")
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled, let entry = self.activeSleepEntry else { return }
                self.sleepSeconds = Int(Date().timeIntervalSince(entry.startDate))
            }
        }
    }

    func stop() {
        guard isSleepActive, var entry = activeSleepEntry else { return }
        let babyId = activeSleepBabyId ?? currentBabyId
        reloadTask?.cancel()
        let startTask = pendingStartEntryId == entry.id ? pendingStartTask : nil
        if pendingStartEntryId == entry.id {
            pendingStartEntryId = nil
            pendingStartTask = nil
        }
        timerTask?.cancel()
        timerTask = nil
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
        activeSleepBabyId = nil
        liveActivity.endActivity()
        WidgetDataStore.shared.setLastSleepEnd(Date(), babyId: babyId)
        WidgetDataStore.shared.clearSleep(lastDurationSeconds: sleepSeconds, babyId: babyId)
        Task {
            do {
                _ = try await startTask?.value
                let saved = try await stopSleepUC.execute(entry)
                if let idx = todayEntries.firstIndex(where: { $0.id == saved.id }) {
                    todayEntries[idx] = saved
                }
                pushSleepToFirestore(saved, babyId: babyId)
                await refreshForecast()
            } catch {
                todayEntries.removeAll { $0.id == completed.id }
                saveError = error.localizedDescription
            }
        }
    }

    private func finishStartPersistence(_ saved: SleepEntry, optimisticEntryId: UUID, babyId: UUID?) {
        let shouldRestoreVisibleTimer = pendingStartEntryId == optimisticEntryId && activeSleepEntry == nil
        if pendingStartEntryId == optimisticEntryId {
            pendingStartEntryId = nil
            pendingStartTask = nil
        }
        guard isCurrentBaby(babyId) else { return }
        if activeSleepEntry?.id == optimisticEntryId {
            activeSleepEntry = saved
            activeSleepBabyId = babyId
            sleepSeconds = Int(Date().timeIntervalSince(saved.startDate))
            WidgetDataStore.shared.setSleepActive(startDate: saved.startDate, babyId: babyId)
        } else if shouldRestoreVisibleTimer {
            activateTimer(entry: saved, babyId: babyId)
        }
    }

    private func handleStartPersistenceFailure(_ error: Error, optimisticEntryId: UUID, babyId: UUID?) {
        if pendingStartEntryId == optimisticEntryId {
            pendingStartEntryId = nil
            pendingStartTask = nil
        }
        guard activeSleepEntry?.id == optimisticEntryId else { return }
        timerTask?.cancel()
        timerTask = nil
        activeSleepEntry = nil
        activeSleepBabyId = nil
        isSleepActive = false
        sleepSeconds = 0
        selectedQuality = .normal
        liveActivity.endActivity()
        WidgetDataStore.shared.clearSleep(lastDurationSeconds: 0, babyId: babyId)
        if isCurrentBaby(babyId) {
            saveError = error.localizedDescription
        }
    }

    private func pushSleepToFirestore(_ entry: SleepEntry, babyId: UUID?) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = SleepLog(
            id:          entry.id.uuidString,
            startedAt:   entry.startDate,
            endedAt:     entry.endDate,
            durationMin: entry.durationMinutes,
            quality:     entry.quality,
            addedBy:     uid,
            addedByName: name,
            updatedAt:   entry.updatedAt ?? Date()
        )
        Task {
            try? await withBabyScope(babyId) {
                try await BabySyncService().setLog(SleepLogDTO(from: log), id: log.id, to: "sleepLogs")
            }
        }
    }

    func logManualEntry(startDate: Date, endDate: Date, quality: SleepQuality, note: String) {
        let babyId = currentBabyId
        Task {
            do {
                let saved = try await withBabyScope(babyId) {
                    try await addManualSleepUC.execute(
                        startDate: startDate, endDate: endDate, quality: quality, note: note
                    )
                }
                pushSleepToFirestore(saved, babyId: babyId)
                guard isCurrentBaby(babyId) else { return }
                let cal = Calendar.current
                let dayStart = cal.startOfDay(for: Date())
                let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart.addingTimeInterval(24 * 3600)
                if SleepDayWindow.overlaps(
                    start: saved.startDate,
                    end: saved.endDate,
                    dayStart: dayStart,
                    dayEnd: dayEnd
                ) {
                    todayEntries.append(saved)
                    todayEntries.sort { $0.startDate < $1.startDate }
                }
                await loadChartData()
                await refreshForecast()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func loadTodayEntries() async {
        await loadTodayEntries(expectedBabyId: currentBabyId)
    }

    private func loadTodayEntries(expectedBabyId: UUID?) async {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        if let entries = try? await withBabyScope(expectedBabyId, operation: {
            try await getSleepUC.executeOverlapping(from: start, to: end)
        }) {
            guard isCurrentBaby(expectedBabyId), !Task.isCancelled else { return }
            todayEntries = entries.sorted { $0.startDate < $1.startDate }
        }
    }

    /// Closes an orphaned open sleep at the end time the widget recorded when `stop()`
    /// ran, or discards it when that end is unknown / implausible.
    private func reconcileStaleSleep(_ entry: SleepEntry, babyId: UUID?) async {
        let resolution = StaleSessionReconciler.resolve(
            start: entry.startDate,
            recoveredEnd: WidgetDataStore.shared.lastSleepEndDate(for: babyId),
            maxDuration: Self.maxPlausibleSleep
        )
        switch resolution {
        case .close(let end): try? await reconcileStaleSleepUC.execute(entry, end: end)
        case .discard:        try? await reconcileStaleSleepUC.execute(entry, end: nil)
        }
    }

    private var currentBabyId: UUID? {
        appState.babyProfile?.id ?? appState.activeBabyId ?? ActiveBaby.currentId
    }

    private func isCurrentBaby(_ babyId: UUID?) -> Bool {
        currentBabyId == babyId
    }

    private func scheduleReloadForActiveBaby(reconcileStaleOpenSession: Bool, clearVisibleState: Bool) {
        let babyId = currentBabyId
        reloadTask?.cancel()
        detachVisibleTimer()
        if clearVisibleState {
            todayEntries = []
            sleepDays = []
            nextSleep = nil
        }
        reloadTask = Task { @MainActor [weak self] in
            await self?.reloadActiveBabyState(
                expectedBabyId: babyId,
                reconcileStaleOpenSession: reconcileStaleOpenSession
            )
        }
    }

    private func detachVisibleTimer() {
        timerTask?.cancel()
        timerTask = nil
        activeSleepEntry = nil
        activeSleepBabyId = nil
        isSleepActive = false
        sleepSeconds = 0
        selectedQuality = .normal
    }

    private func reloadActiveBabyState(expectedBabyId: UUID?, reconcileStaleOpenSession: Bool) async {
        await loadTodayEntries(expectedBabyId: expectedBabyId)
        guard isCurrentBaby(expectedBabyId), !Task.isCancelled else { return }
        if let open = todayEntries.first(where: { $0.endDate == nil }) {
            await restoreOpenSession(
                open,
                babyId: expectedBabyId,
                reconcileStaleOpenSession: reconcileStaleOpenSession
            )
        }
        guard isCurrentBaby(expectedBabyId), !Task.isCancelled else { return }
        await loadChartData(expectedBabyId: expectedBabyId)
        await refreshForecast(expectedBabyId: expectedBabyId)
    }

    private func restoreOpenSession(_ entry: SleepEntry, babyId: UUID?, reconcileStaleOpenSession: Bool) async {
        if !reconcileStaleOpenSession {
            activateTimer(entry: entry, babyId: babyId)
            return
        }
        if case .active = WidgetDataStore.shared.sleepState(for: babyId) {
            liveActivity.reattachIfNeeded()
            activateTimer(entry: entry, babyId: babyId)
        } else {
            await reconcileStaleSleep(entry, babyId: babyId)
            await loadTodayEntries(expectedBabyId: babyId)
        }
    }

    private func refreshForecast(expectedBabyId: UUID?) async {
        guard isCurrentBaby(expectedBabyId), let birth = appState.babyProfile?.birthDate else {
            nextSleep = nil
            return
        }
        let prediction = try? await withBabyScope(expectedBabyId) {
            try await predictNextSleepUC.execute(birthDate: birth)
        }
        guard isCurrentBaby(expectedBabyId) else { return }
        nextSleep = prediction
    }

    private func withBabyScope<T>(_ babyId: UUID?, operation: () async throws -> T) async throws -> T {
        guard let babyId else { return try await operation() }
        return try await ActiveBaby.$syncTargetOverride.withValue(babyId) {
            try await operation()
        }
    }

}
