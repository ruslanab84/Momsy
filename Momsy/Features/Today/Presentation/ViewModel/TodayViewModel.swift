import SwiftUI
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var diaperCount: Int = 0
    @Published var logEntries: [LogEntry] = []
    @Published var saveError: String?
    @Published var dailyTip: DailyTip?
    @Published var isTipLoading: Bool = false
    @Published private(set) var currentLeap: DevelopmentLeap?
    @Published private(set) var leapPhase: BabyAgeContext.LeapPhase?
    @Published private(set) var nextSleep: SleepPrediction?

    private let getFeeding: GetFeedingEntriesUseCase
    private let getSleep: GetSleepEntriesUseCase
    private let getLeaps: GetLeapsUseCase
    private let diaperRepo: any DiaperRepository
    private let stoolRepo: any StoolRepository
    private let quickLogRepo: QuickLogRepository
    private let tipRepository: DailyTipRepository
    private let appState: AppState
    private let syncRepo: any BabySyncRepositoryProtocol
    private let predictNextSleep: PredictNextSleepUseCase
    private var syncTasks: [Task<Void, Never>] = []
    private var hasFetchedThisSession = false
    private var mergeObserver: NSObjectProtocol?
    private var reloadTask: Task<Void, Never>?
    private var tipRefreshTask: Task<Void, Never>?
    private var reloadGeneration = 0
    private var isReloading = false
    private var syncedFeedingLogs: [FeedingLog] = []
    private var syncedSleepLogs: [SleepLog] = []

    init(
        getFeeding: GetFeedingEntriesUseCase,
        getSleep: GetSleepEntriesUseCase,
        getLeaps: GetLeapsUseCase,
        diaperRepo: any DiaperRepository,
        stoolRepo: any StoolRepository,
        quickLogRepo: QuickLogRepository,
        tipRepository: DailyTipRepository,
        appState: AppState,
        syncRepo: any BabySyncRepositoryProtocol,
        predictNextSleep: PredictNextSleepUseCase
    ) {
        self.getFeeding = getFeeding
        self.getSleep = getSleep
        self.getLeaps = getLeaps
        self.diaperRepo = diaperRepo
        self.stoolRepo = stoolRepo
        self.quickLogRepo = quickLogRepo
        self.tipRepository = tipRepository
        self.appState = appState
        self.syncRepo = syncRepo
        self.predictNextSleep = predictNextSleep
        startSyncListeners()
        Task { await loadDiaperCount() }
        Task { await loadLeap() }
        mergeObserver = NotificationCenter.default.addObserver(
            forName: .cloudSyncDidMerge, object: nil, queue: .main
        ) { [weak self] _ in
            Task { await self?.reloadAfterMerge() }
        }
    }

    deinit {
        syncTasks.forEach { $0.cancel() }
        tipRefreshTask?.cancel()
        if let mergeObserver { NotificationCenter.default.removeObserver(mergeObserver) }
    }

    /// A multi-step cloud resync posts `.cloudSyncDidMerge` several times in quick
    /// succession. Cancel-and-replace collapses that burst into a single reload so
    /// we never run overlapping reads against the shared `ModelContext` (concurrent
    /// reads vs. the downloader's writes are what made the counts/forecast flicker).
    func reloadAfterMerge() async {
        reloadTask?.cancel()
        reloadGeneration &+= 1
        let generation = reloadGeneration
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performReload()
        }
        reloadTask = task
        isReloading = true
        await task.value
        // Only the newest reload clears the gate; a superseded (cancelled) one
        // returning here must not flip `isReloading` off while its successor runs.
        if generation == reloadGeneration { isReloading = false }
    }

    private func performReload() async {
        await loadTodayEntries()
        if Task.isCancelled { return }
        await loadDiaperCount()
        if Task.isCancelled { return }
        await loadLeap()
        if Task.isCancelled { return }
        await refreshForecast()
        if Task.isCancelled { return }
        // Switching the active child reloads the data above; the daily tip is
        // derived from it, so recompute it too or it stays stuck on the prior baby.
        await updateTip()
    }

    func refreshForecast() async {
        guard let birth = appState.babyProfile?.birthDate else { nextSleep = nil; return }
        do {
            // A successful `nil` is legitimate (e.g. the next onset falls at night,
            // so the card should hide) and must be honored. Only a thrown error —
            // a transient read during a concurrent merge — keeps the last value.
            nextSleep = try await predictNextSleep.execute(birthDate: birth)
        } catch {
            return
        }
    }

    // MARK: - Developmental leap

    /// Derives the baby's current developmental leap by age, mirroring
    /// `LeapsViewModel.loadLeaps()` so the Today screen and Leaps tab agree.
    /// `currentLeap` is nil for newborns / the calm gap between leaps, which
    /// hides the badge and card.
    func loadLeap() async {
        let progress = (try? await getLeaps.execute()) ?? []
        let doneIDs = Set(progress.filter(\.isDone).map(\.id))
        let birth = appState.babyProfile?.birthDate
        let ageWeeks = BabyAgeContext.ageWeeks(birthDate: birth)
        let leap = BabyAgeContext.currentLeap(ageWeeks: ageWeeks, completedIDs: doneIDs)
        currentLeap = leap
        leapPhase = leap.map {
            BabyAgeContext.leapPhase(for: $0, birthDate: birth)
        }
    }

    /// Localized name of the current leap, or nil when no leap is active.
    var currentLeapName: String? {
        guard let leap = currentLeap else { return nil }
        return leap.name(for: LocalizationManager.shared.current)
    }

    private func startSyncListeners() {
        syncTasks.append(Task { [weak self] in
            guard let feedingLogs = self?.syncRepo.feedingLogs else { return }
            for await logs in feedingLogs {
                self?.syncedFeedingLogs = logs
            }
        })
        syncTasks.append(Task { [weak self] in
            guard let sleepLogs = self?.syncRepo.sleepLogs else { return }
            for await logs in sleepLogs {
                self?.syncedSleepLogs = logs
            }
        })
    }

    func addSyncedFeeding(side: FeedingSide, durationMin: Int, amountMl: Int? = nil) {
        let log = FeedingLog(
            id: UUID().uuidString,
            startedAt: Date(),
            endedAt: Date(),
            durationMin: durationMin,
            side: side,
            amountMl: amountMl,
            addedBy: "",
            addedByName: ""
        )
        Task { try? await syncRepo.addFeedingLog(log) }
    }

    private func loadDiaperCount() async {
        // A legitimate 0 (no diapers today) comes back as a successful Int; only a
        // thrown read — the context busy mid-merge — falls through and keeps the
        // last value, instead of flashing the count to 0.
        guard let count = try? await diaperRepo.countToday() else { return }
        diaperCount = count
        WidgetDataStore.shared.updateDiaperCount(count)
    }

    func loadTodayEntries() async {
        let lm = LocalizationManager.shared
        // Keep the last list on a thrown read (context busy mid-merge); a genuinely
        // empty day still comes back as a successful `[]` and clears the list.
        guard let feedings = try? await getFeeding.execute(for: Date()) else { return }
        let feedingEntries: [LogEntry] = feedings.map {
            LogEntry(
                id: "feeding:\($0.id.uuidString)",
                time: $0.date,
                kind: .bottle,
                label: feedingLabel($0),
                durationMinutes: $0.durationMinutes,
                feedSide: $0.side.displayName(lang: lm.lang).lowercased(),
                isBottleFeed: $0.side == .bottle
            )
        }
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: Date())
        let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        guard let sleeps = try? await getSleep.executeOverlapping(from: startOfDay, to: endOfDay) else { return }
        let sleepEntries: [LogEntry] = sleeps.map { sleepLabel($0) }
        let quickEntries: [LogEntry] = quickLogRepo.load().map {
            LogEntry(id: "quick:\($0.id.uuidString)", time: $0.time, kind: $0.kind, label: $0.label)
        }
        let merged = (feedingEntries + sleepEntries + quickEntries).sorted { $0.time > $1.time }
        logEntries = merged
    }

    // MARK: - Daily Tip

    func fetchDailyTipIfNeeded() async {
        guard !hasFetchedThisSession else { return }
        hasFetchedThisSession = true
        await loadDiaperCount()
        if logEntries.isEmpty { await loadTodayEntries() }
        await updateTip()
    }

    func refreshTip() async {
        hasFetchedThisSession = false
        await fetchDailyTipIfNeeded()
    }

    private func updateTip() async {
        isTipLoading = true
        let days = await computeDaysSinceLastStool()
        let ctx = DailyContextBuilder.build(
            from: logEntries,
            diaperCount: diaperCount,
            daysSinceLastStool: days,
            appState: appState
        )
        dailyTip = DailyTipAlgorithm.evaluate(context: ctx)
        isTipLoading = false
    }

    /// Days since the last logged stool, or `nil` when none has ever been logged
    /// within the search window — the algorithm treats `nil` as "no data" and
    /// won't raise a constipation alert on a fresh install.
    private func computeDaysSinceLastStool() async -> Int? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard
            let searchStart = cal.date(byAdding: .day, value: -10, to: today),
            let tomorrow = cal.date(byAdding: .day, value: 1, to: today)
        else { return nil }
        let now = Date()
        let entries = ((try? await stoolRepo.getEntries(from: searchStart, to: tomorrow)) ?? [])
            .filter { $0 <= now }
        guard let latest = entries.max() else { return nil }
        let latestDay = cal.startOfDay(for: latest)
        return max(0, cal.dateComponents([.day], from: latestDay, to: today).day ?? 0)
    }

    // MARK: - Quick log actions

    func logDiaper() {
        let lm = LocalizationManager.shared
        let newCount = diaperCount + 1
        diaperCount = newCount
        WidgetDataStore.shared.updateDiaperCount(newCount)
        let label = lm.strings.diaperLogEntry(count: newCount)
        let entry = DiaperEntry()
        quickLogRepo.append(QuickLogEntry(id: entry.id, time: entry.date, kind: .drop, label: label))
        addEntry(LogEntry(id: "quick:\(entry.id.uuidString)", time: entry.date, kind: .drop, label: label))
        Task { try? await diaperRepo.add(entry) }
        pushDiaperToFirestore(entry)
        scheduleTipRefresh()
    }

    private func pushDiaperToFirestore(_ entry: DiaperEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = DiaperLog(id: entry.id.uuidString, loggedAt: entry.date,
                            type: .wet, addedBy: "", addedByName: "")
        Task { try? await BabySyncService().setLog(DiaperLogDTO(from: log), id: log.id, to: "diaperLogs") }
    }

    func removeDiaper() {
        guard diaperCount > 0 else { return }
        diaperCount -= 1
        WidgetDataStore.shared.updateDiaperCount(diaperCount)
        quickLogRepo.removeLast(kind: .drop)
        if let idx = logEntries.firstIndex(where: { $0.kind == .drop }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                _ = logEntries.remove(at: idx)
            }
        }
        Task {
            if let removedId = (try? await diaperRepo.removeLatest(on: Date())).flatMap({ $0 }) {
                BabySyncService().propagateDelete(id: removedId, in: "diaperLogs")
            }
        }
        scheduleTipRefresh()
    }

    func logWalk() {
        let id = UUID()
        let date = Date()
        let label = LocalizationManager.shared.strings.walkLogged
        quickLogRepo.append(QuickLogEntry(id: id, time: date, kind: .walk, label: label))
        addEntry(LogEntry(id: "quick:\(id.uuidString)", time: date, kind: .walk, label: label))
        pushQuickEventToFirestore(id: id, kind: .walk, label: label, at: date)
    }

    func logBath() {
        let id = UUID()
        let date = Date()
        let label = LocalizationManager.shared.strings.bathLogged
        quickLogRepo.append(QuickLogEntry(id: id, time: date, kind: .bath, label: label))
        addEntry(LogEntry(id: "quick:\(id.uuidString)", time: date, kind: .bath, label: label))
        pushQuickEventToFirestore(id: id, kind: .bath, label: label, at: date)
    }

    func logVitamins() {
        let id = UUID()
        let date = Date()
        let label = LocalizationManager.shared.strings.vitaminsGiven
        quickLogRepo.append(QuickLogEntry(id: id, time: date, kind: .vitamin, label: label))
        addEntry(LogEntry(id: "quick:\(id.uuidString)", time: date, kind: .vitamin, label: label))
        pushQuickEventToFirestore(id: id, kind: .vitamin, label: label, at: date)
    }

    func logStool(date: Date) {
        let id = UUID()
        let lm = LocalizationManager.shared
        let label = lm.strings.stoolLogged
        quickLogRepo.append(QuickLogEntry(id: id, time: date, kind: .stool, label: label))
        addEntry(LogEntry(id: "quick:\(id.uuidString)", time: date, kind: .stool, label: label))
        Task { try? await stoolRepo.add(id: id, date: date) }
        pushQuickEventToFirestore(id: id, kind: .stool, label: label, at: date)
    }

    private func pushQuickEventToFirestore(id: UUID, kind: BlobKind, label: String, at date: Date = Date()) {
        guard FamilyManager.shared.familyId != nil else { return }
        // Only quick events with a dedicated collection are synced. Anything else
        // is intentionally not written (the old `quickLogs` catch-all is removed).
        let collection: String
        switch kind {
        case .walk:    collection = "walkLogs"
        case .bath:    collection = "bathLogs"
        case .vitamin: collection = "vitaminLogs"
        case .stool:   collection = "stoolLogs"
        default:       return
        }
        let log = QuickEventLog(id: id.uuidString, kind: kind.rawValue,
                                loggedAt: date, label: label,
                                addedBy: "", addedByName: "")
        Task { try? await BabySyncService().setLog(QuickEventLogDTO(from: log), id: log.id, to: collection) }
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
            label = lm.strings.sleepLogEntry(dur: dur)
        } else {
            label = lm.strings.sleepStarted
        }
        return LogEntry(
            id: "sleep:\(entry.id.uuidString)",
            time: entry.startDate,
            kind: .sleep,
            label: label,
            durationMinutes: entry.durationMinutes
        )
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

    private func scheduleTipRefresh() {
        guard hasFetchedThisSession else { return }
        tipRefreshTask?.cancel()
        tipRefreshTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 600_000_000)
            guard let self, !Task.isCancelled else { return }
            await self.updateTip()
        }
    }
}
