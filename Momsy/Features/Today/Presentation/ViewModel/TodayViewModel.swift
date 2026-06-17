import SwiftUI
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var diaperCount: Int = 0
    @Published var logEntries: [LogEntry] = []
    @Published var saveError: String?
    @Published var dailyTip: DailyTip?
    @Published var isTipLoading: Bool = false
    @Published var syncedFeedingLogs: [FeedingLog] = []
    @Published var syncedSleepLogs: [SleepLog] = []
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
        if let mergeObserver { NotificationCenter.default.removeObserver(mergeObserver) }
    }

    private func reloadAfterMerge() async {
        await loadTodayEntries()
        await loadDiaperCount()
        await loadLeap()
        await refreshForecast()
    }

    func refreshForecast() async {
        guard let birth = appState.babyProfile?.birthDate else { nextSleep = nil; return }
        nextSleep = try? await predictNextSleep.execute(birthDate: birth)
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
            BabyAgeContext.leapPhase(for: $0, ageDays: BabyAgeContext.ageDays(birthDate: birth))
        }
    }

    /// Localized name of the current leap, or nil when no leap is active.
    var currentLeapName: String? {
        guard let leap = currentLeap else { return nil }
        return leap.name(for: LocalizationManager.shared.current)
    }

    private func startSyncListeners() {
        syncTasks.append(Task {
            for await logs in syncRepo.feedingLogs {
                self.syncedFeedingLogs = logs
            }
        })
        syncTasks.append(Task {
            for await logs in syncRepo.sleepLogs {
                self.syncedSleepLogs = logs
            }
        })
    }

    func addSyncedFeeding(side: FeedingSide, durationMin: Int, amountMl: Int? = nil) {
        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = FeedingLog(
            id: UUID().uuidString,
            startedAt: Date(),
            endedAt: Date(),
            durationMin: durationMin,
            side: side,
            amountMl: amountMl,
            addedBy: uid,
            addedByName: name
        )
        Task { try? await syncRepo.addFeedingLog(log) }
    }

    private func loadDiaperCount() async {
        diaperCount = (try? await diaperRepo.countToday()) ?? 0
        WidgetDataStore.shared.updateDiaperCount(diaperCount)
    }

    func loadTodayEntries() async {
        let lm = LocalizationManager.shared
        let feedings = (try? await getFeeding.execute(for: Date())) ?? []
        let feedingEntries: [LogEntry] = feedings.map {
            LogEntry(
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

    private func computeDaysSinceLastStool() async -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        for daysBack in 0...10 {
            guard let date = cal.date(byAdding: .day, value: -daysBack, to: today) else { continue }
            let nextDay = cal.date(byAdding: .day, value: 1, to: date) ?? date
            let entries = (try? await stoolRepo.getEntries(from: date, to: nextDay)) ?? []
            if !entries.isEmpty { return daysBack }
        }
        return 10
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
        addEntry(LogEntry(time: entry.date, kind: .drop, label: label))
        Task { try? await diaperRepo.add(entry) }
        pushDiaperToFirestore(entry)
        if hasFetchedThisSession { Task { await updateTip() } }
    }

    private func pushDiaperToFirestore(_ entry: DiaperEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = DiaperLog(id: entry.id.uuidString, loggedAt: entry.date,
                            type: .wet, addedBy: uid, addedByName: name)
        Task { try? await BabySyncService().setLog(DiaperLogDTO(from: log), id: log.id, to: "diaperLogs") }
    }

    func removeDiaper() {
        guard diaperCount > 0 else { return }
        diaperCount -= 1
        WidgetDataStore.shared.updateDiaperCount(diaperCount)
        quickLogRepo.removeLast(kind: .drop)
        if let idx = logEntries.firstIndex(where: { $0.kind == .drop }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                logEntries.remove(at: idx)
            }
        }
        Task {
            if let removedId = (try? await diaperRepo.removeLatest(on: Date())).flatMap({ $0 }) {
                BabySyncService().propagateDelete(id: removedId, in: "diaperLogs")
            }
        }
        if hasFetchedThisSession { Task { await updateTip() } }
    }

    func logWalk() {
        let id = UUID()
        let label = LocalizationManager.shared.strings.walkLogged
        quickLogRepo.append(QuickLogEntry(id: id, time: Date(), kind: .walk, label: label))
        addEntry(LogEntry(time: Date(), kind: .walk, label: label))
        pushQuickEventToFirestore(id: id, kind: .walk, label: label)
    }

    func logBath() {
        let id = UUID()
        let label = LocalizationManager.shared.strings.bathLogged
        quickLogRepo.append(QuickLogEntry(id: id, time: Date(), kind: .bath, label: label))
        addEntry(LogEntry(time: Date(), kind: .bath, label: label))
        pushQuickEventToFirestore(id: id, kind: .bath, label: label)
    }

    func logVitamins() {
        let id = UUID()
        let label = LocalizationManager.shared.strings.vitaminsGiven
        quickLogRepo.append(QuickLogEntry(id: id, time: Date(), kind: .vitamin, label: label))
        addEntry(LogEntry(time: Date(), kind: .vitamin, label: label))
        pushQuickEventToFirestore(id: id, kind: .vitamin, label: label)
    }

    func logStool(date: Date) {
        let id = UUID()
        let lm = LocalizationManager.shared
        let label = lm.strings.stoolLogged
        quickLogRepo.append(QuickLogEntry(id: id, time: date, kind: .stool, label: label))
        addEntry(LogEntry(time: date, kind: .stool, label: label))
        Task { try? await stoolRepo.add(id: id, date: date) }
        pushQuickEventToFirestore(id: id, kind: .stool, label: label, at: date)
    }

    private func pushQuickEventToFirestore(id: UUID, kind: BlobKind, label: String, at date: Date = Date()) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
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
                                addedBy: uid, addedByName: name)
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
        return LogEntry(time: entry.startDate, kind: .sleep, label: label, durationMinutes: entry.durationMinutes)
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
