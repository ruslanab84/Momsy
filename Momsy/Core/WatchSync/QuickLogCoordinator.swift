import Foundation

/// Service-level entry point for the three Watch quick actions. Routes through the
/// same use cases, `WidgetDataStore`, Live Activity managers and Firestore push that
/// the in-app ViewModels use, so a Watch-initiated action behaves exactly like one
/// performed on the phone (timer state, lock-screen Live Activity, cloud sync).
@MainActor
final class QuickLogCoordinator {
    private let logFeeding: LogFeedingUseCase
    private let startSleepUC: StartSleepUseCase
    private let stopSleepUC: StopSleepUseCase
    private let getSleepUC: GetSleepEntriesUseCase
    private let diaperRepo: any DiaperRepository
    private let appState: AppState
    private let analytics: any AnalyticsServiceProtocol
    private let pushNotifications: any PushNotificationServiceProtocol

    private let feedingLA = FeedingLiveActivityManager()
    private let sleepLA = SleepLiveActivityManager()

    init(
        logFeeding: LogFeedingUseCase,
        startSleep: StartSleepUseCase,
        stopSleep: StopSleepUseCase,
        getSleep: GetSleepEntriesUseCase,
        diaperRepo: any DiaperRepository,
        appState: AppState,
        analytics: any AnalyticsServiceProtocol,
        pushNotifications: any PushNotificationServiceProtocol
    ) {
        self.logFeeding = logFeeding
        self.startSleepUC = startSleep
        self.stopSleepUC = stopSleep
        self.getSleepUC = getSleep
        self.diaperRepo = diaperRepo
        self.appState = appState
        self.analytics = analytics
        self.pushNotifications = pushNotifications
    }

    // MARK: - Feeding (mirrors FeedingViewModel)

    func startFeeding(sideToken: String) {
        let side = FeedingSide(token: sideToken)
        let start = Date()
        WidgetDataStore.shared.setFeedingRunning(effectiveStartDate: start, side: side.rawValue)
        analytics.track(.feedingStarted(side: side.rawValue))
        feedingLA.startActivity(side: side.token, startDate: start, babyName: WidgetDataStore.shared.babyName)
    }

    func pauseFeeding() {
        guard case .running(let start, let sideRaw) = WidgetDataStore.shared.feedingState else { return }
        let elapsed = max(0, Int(Date().timeIntervalSince(start)))
        WidgetDataStore.shared.setFeedingPaused(elapsedSeconds: elapsed, side: sideRaw)
        feedingLA.pauseActivity(pausedSeconds: elapsed)
    }

    func resumeFeeding() {
        guard case .paused(let elapsed, let sideRaw) = WidgetDataStore.shared.feedingState else { return }
        let effectiveStart = Date().addingTimeInterval(-TimeInterval(elapsed))
        WidgetDataStore.shared.setFeedingRunning(effectiveStartDate: effectiveStart, side: sideRaw)
        feedingLA.resumeActivity(effectiveStartDate: effectiveStart)
    }

    func stopFeeding() {
        let seconds: Int
        let sideRaw: String
        switch WidgetDataStore.shared.feedingState {
        case .running(let start, let s):
            seconds = max(0, Int(Date().timeIntervalSince(start)))
            sideRaw = s
        case .paused(let elapsed, let s):
            seconds = elapsed
            sideRaw = s
        case .idle:
            return  // nothing active — idempotent no-op
        }
        let side = FeedingSide(rawValue: sideRaw) ?? .left
        WidgetDataStore.shared.clearFeeding(lastFeedingDate: Date())
        feedingLA.endActivity()
        analytics.track(.feedingStopped(durationMinutes: max(1, seconds / 60), side: side.rawValue))
        pushNotifications.scheduleFeedingReminder(afterMinutes: 3 * 60)
        Task {
            if let saved = try? await logFeeding.execute(durationSeconds: seconds, side: side) {
                pushFeedingToFirestore(saved)
            }
        }
    }

    // MARK: - Sleep (mirrors SleepViewModel)

    func startSleep() {
        let babyId = currentBabyId
        Task {
            guard let entry = try? await withBabyScope(babyId, operation: {
                try await startSleepUC.execute()
            }) else { return }
            WidgetDataStore.shared.setSleepActive(startDate: entry.startDate, babyId: babyId)
            sleepLA.startActivity(
                startDate: entry.startDate,
                babyName: appState.babyProfile?.name ?? WidgetDataStore.shared.babyName
            )
        }
    }

    func stopSleep(qualityRaw: String) {
        let quality = SleepQuality(rawValue: qualityRaw) ?? .normal
        let babyId = currentBabyId
        Task {
            let cal = Calendar.current
            let dayStart = cal.startOfDay(for: Date())
            let from = cal.date(byAdding: .day, value: -1, to: dayStart) ?? dayStart
            let to = cal.date(byAdding: .day, value: 1, to: dayStart) ?? Date()
            let entries = (try? await withBabyScope(babyId, operation: {
                try await getSleepUC.execute(from: from, to: to)
            })) ?? []
            guard var open = entries.first(where: { $0.endDate == nil }) else {
                WidgetDataStore.shared.clearSleep(lastDurationSeconds: 0, babyId: babyId)
                sleepLA.endActivity()
                return
            }
            open.quality = quality
            let secs = max(0, Int(Date().timeIntervalSince(open.startDate)))
            WidgetDataStore.shared.setLastSleepEnd(Date(), babyId: babyId)
            WidgetDataStore.shared.clearSleep(lastDurationSeconds: secs, babyId: babyId)
            sleepLA.endActivity()
            if let saved = try? await stopSleepUC.execute(open) {
                pushSleepToFirestore(saved, babyId: babyId)
            }
        }
    }

    // MARK: - Diaper (mirrors TodayViewModel)

    func logDiaper() {
        let entry = DiaperEntry()
        pushDiaperToFirestore(entry)
        Task {
            try? await diaperRepo.add(entry)
            let count = (try? await diaperRepo.countToday()) ?? (WidgetDataStore.shared.diaperCount + 1)
            WidgetDataStore.shared.updateDiaperCount(count)
        }
    }

    // MARK: - Firestore push (identical to the in-app ViewModels)

    private func pushFeedingToFirestore(_ entry: FeedingEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = FeedingLog(
            id:          entry.id.uuidString,
            startedAt:   entry.date,
            endedAt:     nil,
            durationMin: entry.durationMinutes,
            side:        entry.side,
            amountMl:    entry.milliliters,
            addedBy:     "",
            addedByName: ""
        )
        Task { try? await BabySyncService().setLog(FeedingLogDTO(from: log), id: log.id, to: "feedingLogs") }
    }

    private func pushSleepToFirestore(_ entry: SleepEntry, babyId: UUID?) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = SleepLog(
            id:          entry.id.uuidString,
            startedAt:   entry.startDate,
            endedAt:     entry.endDate,
            durationMin: entry.durationMinutes,
            quality:     entry.quality,
            addedBy:     "",
            addedByName: ""
        )
        Task {
            try? await withBabyScope(babyId) {
                try await BabySyncService().setLog(SleepLogDTO(from: log), id: log.id, to: "sleepLogs")
            }
        }
    }

    private func pushDiaperToFirestore(_ entry: DiaperEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = DiaperLog(
            id:          entry.id.uuidString,
            loggedAt:    entry.date,
            type:        .wet,
            addedBy:     "",
            addedByName: ""
        )
        Task { try? await BabySyncService().setLog(DiaperLogDTO(from: log), id: log.id, to: "diaperLogs") }
    }

    private var currentBabyId: UUID? {
        appState.babyProfile?.id ?? appState.activeBabyId ?? ActiveBaby.currentId
    }

    private func withBabyScope<T>(_ babyId: UUID?, operation: () async throws -> T) async throws -> T {
        guard let babyId else { return try await operation() }
        return try await ActiveBaby.$syncTargetOverride.withValue(babyId) {
            try await operation()
        }
    }
}

private extension FeedingSide {
    /// Maps the stable Watch/Live-Activity token back to a side.
    init(token: String) {
        switch token {
        case "right":  self = .right
        case "bottle": self = .bottle
        default:       self = .left
        }
    }
}
