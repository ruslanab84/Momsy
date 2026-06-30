import Foundation
import FirebaseFirestore

extension Notification.Name {
    /// Posted after a cloud → local merge completes so view models can reload.
    static let cloudSyncDidMerge = Notification.Name("cloudSyncDidMerge")
}

final class CloudSyncDownloader: CloudSyncDownloaderProtocol {
    private let service: BabySyncService
    private let feedingRepo: any FeedingRepository
    private let sleepRepo: any SleepRepository
    private let diaperRepo: any DiaperRepository
    private let stoolRepo: any StoolRepository
    private let diaryRepo: any DiaryRepository
    private let walkRepo: any WalkRepository
    private let bathRepo: any BathRepository
    private let pumpingRepo: any PumpingRepository
    private let measurementRepo: any MeasurementRepository
    private let vaccinationRepo: any VaccinationRepository
    private let foodDiaryRepo: any ComplementaryFeedingRepository
    private let quickLogRepo: QuickLogRepository
    private let babyRepo: any BabyRepository
    private let temperatureRepo: any TemperatureRepository
    private let momSleepRepo: any MomSleepRepository
    private let waterIntakeRepo: any WaterIntakeRepository
    private let leapsRepo: any LeapsRepository
    private let doctorVisitRepo: any DoctorVisitRepository
    private let watermarks: SyncWatermarkStore

    private var hasRun = false
    private var isSyncing = false
    private var lastSyncAt: Date?

    init(service: BabySyncService,
         feedingRepo: any FeedingRepository,
         sleepRepo: any SleepRepository,
         diaperRepo: any DiaperRepository,
         stoolRepo: any StoolRepository,
         diaryRepo: any DiaryRepository,
         walkRepo: any WalkRepository,
         bathRepo: any BathRepository,
         pumpingRepo: any PumpingRepository,
         measurementRepo: any MeasurementRepository,
         vaccinationRepo: any VaccinationRepository,
         foodDiaryRepo: any ComplementaryFeedingRepository,
         quickLogRepo: QuickLogRepository,
         babyRepo: any BabyRepository,
         temperatureRepo: any TemperatureRepository,
         momSleepRepo: any MomSleepRepository,
         waterIntakeRepo: any WaterIntakeRepository,
         leapsRepo: any LeapsRepository,
         doctorVisitRepo: any DoctorVisitRepository,
         watermarks: SyncWatermarkStore = SyncWatermarkStore()) {
        self.service = service
        self.feedingRepo = feedingRepo
        self.sleepRepo = sleepRepo
        self.diaperRepo = diaperRepo
        self.stoolRepo = stoolRepo
        self.diaryRepo = diaryRepo
        self.walkRepo = walkRepo
        self.bathRepo = bathRepo
        self.pumpingRepo = pumpingRepo
        self.measurementRepo = measurementRepo
        self.vaccinationRepo = vaccinationRepo
        self.foodDiaryRepo = foodDiaryRepo
        self.quickLogRepo = quickLogRepo
        self.babyRepo = babyRepo
        self.temperatureRepo = temperatureRepo
        self.momSleepRepo = momSleepRepo
        self.waterIntakeRepo = waterIntakeRepo
        self.leapsRepo = leapsRepo
        self.doctorVisitRepo = doctorVisitRepo
        self.watermarks = watermarks
    }

    // MARK: - Entry point

    /// Pure debounce/reentrancy decision, extracted for testability.
    static func shouldSkipResync(isSyncing: Bool,
                                 lastSyncAt: Date?,
                                 now: Date,
                                 minInterval: TimeInterval) -> Bool {
        if isSyncing { return true }
        if let last = lastSyncAt, now.timeIntervalSince(last) < minInterval { return true }
        return false
    }

    /// Per-collection watermark math. Never moves backward; falls back to the epoch floor so an
    /// empty/all-legacy first pull doesn't repeat a full pull forever. Pure → unit-tested.
    static func advancedWatermark(previous: Date?, maxObserved: Date?) -> Date {
        let floor = Date(timeIntervalSince1970: 0)
        let candidate = maxObserved ?? previous ?? floor
        if let previous { return max(previous, candidate) }
        return candidate
    }

    @MainActor
    func downloadAndMergeWhenReady() async {
        guard !hasRun else { return }
        if FamilyManager.shared.familyId == nil {
            await waitForFamilyReady(timeout: 8)
        }
        guard FamilyManager.shared.familyId != nil else { return }
        hasRun = true
        isSyncing = true
        defer { isSyncing = false; lastSyncAt = Date() }
        // Migrate the old family-keyed tree first (derives the canonical babyId for a
        // pre-per-baby family), flush any writes queued before the path was ready, then
        // sync every child in the roster.
        await service.migrateFromFamilyPathIfNeeded()
        await service.replayPendingWrites()
        await downloadAllBabies()
        await purgeLegacyQuickLogsOnce()
    }

    /// Pulls profile + logs for every child in the family roster. Each child is synced
    /// under a task-local `ActiveBaby.syncTargetOverride` so the Firestore path and the
    /// babyId stamped onto merged records target that child — WITHOUT moving the user's
    /// persisted selection. This way a concurrent user write (a different task tree) is
    /// never misattributed to whichever child the loop is mid-processing. The persisted
    /// pointer is only established here when the user has no selection yet.
    @MainActor
    private func downloadAllBabies() async {
        let desiredActive = ActiveBaby.currentId

        var ids = await service.discoverAllBabyIds()
        // Include a locally-known active child even if the roster read missed/lacks it
        // (e.g. created locally and not yet uploaded — syncBabyProfile backfills it).
        if let active = desiredActive, !ids.contains(active.uuidString) {
            ids.append(active.uuidString)
        }
        guard !ids.isEmpty else {
            // No roster yet: preserve prior single-baby behaviour.
            await syncBabyProfile()
            await downloadAndMerge()
            return
        }

        // The active child is synced last so its data lands on the in-memory "today"
        // strip. With no prior selection, the first roster entry becomes active —
        // persist it once (the only legitimate mutation of the global pointer here).
        let activeStr = desiredActive?.uuidString ?? ids.first!
        if desiredActive == nil, let firstActive = UUID(uuidString: activeStr) {
            ActiveBaby.currentId = firstActive
        }
        let ordered = ids.filter { $0 != activeStr } + [activeStr]

        for idStr in ordered {
            guard let id = UUID(uuidString: idStr) else { continue }
            // Only the active child contributes to the in-memory "today" quick-log strip.
            await ActiveBaby.$syncTargetOverride.withValue(id) {
                await syncBabyProfile()
                await downloadAndMerge(recordQuickLogs: idStr == activeStr)
            }
        }
    }

    /// Re-pull the now-active child's logs after a profile switch. Skips the one-time
    /// path migration/discovery — those already ran on first launch. The repositories
    /// read the active babyId at query time, so the merge targets the new child.
    @MainActor
    func resyncActiveBaby() async {
        guard FamilyManager.shared.familyId != nil else { return }
        await syncBabyProfile()
        await downloadAndMerge()
    }

    /// Foreground refresh. Re-pulls every child in the roster, skipping the one-time
    /// launch work (migration, legacy purge). Only runs after the launch download has
    /// happened (`hasRun`), so the initial activation never double-syncs with the
    /// `.task` download. Debounced so a quick background→foreground bounce is a no-op.
    @MainActor
    func resyncAll() async {
        guard hasRun else { return }
        // Foreground re-pull is a cheap delta now (incremental sync), but a quick
        // background→foreground bounce still needn't re-hit Firestore: debounce wide.
        if Self.shouldSkipResync(isSyncing: isSyncing, lastSyncAt: lastSyncAt,
                                 now: Date(), minInterval: 300) { return }
        guard FamilyManager.shared.familyId != nil else { return }
        isSyncing = true
        defer { isSyncing = false; lastSyncAt = Date() }
        await service.replayPendingWrites()
        await downloadAllBabies()
    }

    /// Post-join refresh. Unlike `resyncAll`, this bypasses the time-debounce — a join
    /// right after launch must pull the newly-joined family even though the launch
    /// download just set `lastSyncAt`. It still waits out any in-flight sync (bounded)
    /// so two `downloadAllBabies` never interleave their `ActiveBaby` mutations.
    @MainActor
    func forceResyncAll() async {
        guard FamilyManager.shared.familyId != nil else { return }
        let deadline = Date().addingTimeInterval(8)
        while isSyncing && Date() < deadline {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
        isSyncing = true
        defer { isSyncing = false; lastSyncAt = Date() }
        await service.replayPendingWrites()
        await downloadAllBabies()
    }

    /// Two-way reconcile of the baby profile against the `babies/{familyId}` parent doc.
    /// - Backfill: a baby created locally (e.g. before this fix, or before the family was
    ///   ready) is uploaded so the previously-empty parent document gets populated.
    /// - Adopt: a second device with no local baby pulls the profile down from Firestore.
    @MainActor
    private func syncBabyProfile() async {
        let remote = (try? await service.fetchBabyProfile())?.domain
        let local  = try? await babyRepo.getProfile()

        if let remote {
            // Cloud is authoritative when a profile exists there. Adopt it locally if it
            // differs (covers a fresh second device and any edits made elsewhere). Edits
            // are pushed to the cloud immediately, so the cloud copy is current.
            if remote != local {
                try? await babyRepo.saveProfile(remote)
                let activeId = UserDefaults.standard.string(forKey: kBabyIdDefaultsKey).flatMap(UUID.init)
                if activeId == nil || activeId == remote.id {
                    WidgetDataStore.shared.setBabyInfo(id: remote.id, name: remote.name, birthDate: remote.birthDate)
                }
                NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
            }
        } else if let local {
            // No cloud profile yet → backfill the locally-created baby into the
            // previously-empty `babies/{familyId}` parent document.
            try? await service.setBabyProfile(local)
        }
    }

    /// One-time removal of the retired `quickLogs` collection. It is no longer
    /// written or read; this clears stale docs left by older app versions.
    private func purgeLegacyQuickLogsOnce() async {
        let flag = "firestore_quicklogs_cleanup_v1_done"
        guard !UserDefaults.standard.bool(forKey: flag) else { return }
        do {
            try await service.deleteAll(in: "quickLogs")
            UserDefaults.standard.set(true, forKey: flag)
        } catch {
            // Leave the flag unset so cleanup retries on a future launch.
        }
    }

    @MainActor
    private func waitForFamilyReady(timeout seconds: Double) async {
        let deadline = Date().addingTimeInterval(seconds)
        while FamilyManager.shared.familyId == nil && Date() < deadline {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        }
    }

    // MARK: - Merge

    @MainActor
    private func downloadAndMerge(recordQuickLogs: Bool = true) async {
        // Fetch all collections concurrently (network runs off the main actor).
        async let feedingDTOs: [FeedingLogDTO]     = fetch("feedingLogs",     dateField: "startedAt")
        async let sleepDTOs:   [SleepLogDTO]        = fetch("sleepLogs",       dateField: "startedAt")
        async let diaperDTOs:  [DiaperLogDTO]       = fetch("diaperLogs",      dateField: "loggedAt")
        async let stoolDTOs:   [QuickEventLogDTO]   = fetch("stoolLogs",       dateField: "loggedAt")
        async let walkDTOs:    [QuickEventLogDTO]   = fetch("walkLogs",        dateField: "loggedAt")
        async let bathDTOs:    [QuickEventLogDTO]   = fetch("bathLogs",        dateField: "loggedAt")
        async let vitaminDTOs: [QuickEventLogDTO]   = fetch("vitaminLogs",     dateField: "loggedAt")
        async let pumpingDTOs: [PumpingLogDTO]      = fetch("pumpingLogs",     dateField: "date")
        async let diaryDTOs:   [DiaryLogDTO]        = fetch("diaryLogs",       dateField: "date")
        async let measureDTOs: [MeasurementLogDTO]  = fetch("measurementLogs", dateField: "date")
        async let vaccineDTOs: [VaccinationLogDTO]  = fetch("vaccinationLogs", dateField: "doneDate")
        async let foodDTOs:    [FoodDiaryLogDTO]    = fetch("foodDiaryLogs",   dateField: "date")
        async let tempDTOs:    [TemperatureLogDTO]  = fetch("temperatureLogs", dateField: "date")
        async let momSleepDTOs:[SleepLogDTO]        = fetch("momSleepLogs",    dateField: "startedAt")
        async let waterDTOs:   [WaterIntakeLogDTO]  = fetch("waterIntakeLogs", dateField: "date")
        async let leapDTOs:    [LeapLogDTO]         = fetch("leapLogs",        dateField: "completedDate")
        async let visitDTOs:   [DoctorVisitLogDTO]  = fetch("doctorVisitLogs", dateField: "date")

        // Reconcile deletes before merging: retry our own unsent deletes, then gather
        // every tombstoned id so the merge neither resurrects nor re-inserts a deleted
        // entry. Pending-local ids are unioned in so an in-flight delete is honoured
        // even before its tombstone round-trips.
        await service.retryPendingDeletions()

        // Reconcile deletes incrementally: only pull tombstones newer than last seen. A tombstone
        // older than the watermark was already applied on a previous sync, and `applyDeletions`
        // is idempotent (deleting an already-absent row is a no-op).
        let tombScope = service.currentScope()
        let tombWatermark = watermarks.watermark(family: tombScope.familyId, baby: tombScope.babyId,
                                                 collection: "deletions")
        let tombstones = (try? await service.fetchTombstones(since: tombWatermark)) ?? []
        let tombstonedIds = Set(tombstones.compactMap { UUID(uuidString: $0.id) })
        let deletedIds = tombstonedIds.union(PendingDeletionsStore.shared.ids())

        let maxTomb = tombstones.map(\.deletedAt).max()
        let nextTomb = Self.advancedWatermark(previous: tombWatermark, maxObserved: maxTomb)
        watermarks.set(family: tombScope.familyId, baby: tombScope.babyId,
                       collection: "deletions", to: nextTomb)

        let feedings = await feedingDTOs.compactMap(Self.feedingEntry)
        let sleeps   = await sleepDTOs.compactMap(Self.sleepEntry)
        let diapers  = await diaperDTOs.compactMap(Self.diaperEntry)
        let stools   = await stoolDTOs.compactMap(Self.stoolEntry)
        let diaries  = await diaryDTOs.compactMap(Self.diaryItem)
        let walks    = await walkDTOs.compactMap(Self.walkEntry)
        let baths    = await bathDTOs.compactMap(Self.bathEntry)
        let pumpings = await pumpingDTOs.compactMap(Self.pumpingEntry)
        let measures = await measureDTOs.compactMap(Self.measurementEntry)
        let vaccines = await vaccineDTOs.compactMap(Self.vaccinationEntry)
        let foods    = await foodDTOs.compactMap(Self.foodEntry)
        let temps    = await tempDTOs.compactMap(Self.temperatureEntry)
        let momSleeps = await momSleepDTOs.compactMap(Self.momSleepEntry)
        let waters   = await waterDTOs.compactMap(Self.waterIntakeEntry)
        let leaps    = await leapDTOs.compactMap(Self.leapProgress)
        let visits   = await visitDTOs.compactMap(Self.doctorVisit)
        let quickEventDTOs =
            (await walkDTOs) + (await bathDTOs) + (await vitaminDTOs) + (await stoolDTOs)
        let quickToday = quickEventDTOs.compactMap(Self.todayQuickLog)
            + (await diaperDTOs).compactMap(Self.todayDiaperQuickLog)
            + (await pumpingDTOs).compactMap(Self.todayPumpingQuickLog)

        // Merge into SwiftData on the main actor (shared context is main-actor owned).
        try? await feedingRepo.upsert(feedings)
        try? await sleepRepo.upsert(sleeps)
        try? await diaperRepo.upsert(diapers.filter { !deletedIds.contains($0.id) })
        try? await stoolRepo.upsert(stools)
        try? await diaryRepo.upsert(diaries)
        try? await walkRepo.upsert(walks)
        try? await bathRepo.upsert(baths)
        try? await pumpingRepo.upsert(pumpings)
        try? await measurementRepo.upsert(measures)
        try? await vaccinationRepo.upsert(vaccines.filter { !deletedIds.contains($0.id) })
        try? await foodDiaryRepo.upsert(foods.filter { !deletedIds.contains($0.id) })
        try? await temperatureRepo.upsert(temps)
        try? await momSleepRepo.upsert(momSleeps)
        try? await waterIntakeRepo.upsert(waters)
        try? await leapsRepo.upsert(leaps)
        try? await doctorVisitRepo.upsert(visits)
        if recordQuickLogs { quickToday.forEach { quickLogRepo.appendUnique($0) } }

        // Propagate deletes made on other devices: remove any local row whose id was
        // explicitly tombstoned. Only ever deletes ids we have a tombstone for.
        if !deletedIds.isEmpty {
            try? await diaperRepo.applyDeletions(deletedIds)
            try? await vaccinationRepo.applyDeletions(deletedIds)
            try? await foodDiaryRepo.applyDeletions(deletedIds)
            quickLogRepo.remove(ids: deletedIds)
        }

        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
    }

    /// Incremental fetch: full pull on first sync of a collection (captures legacy `nil`-`updatedAt`
    /// docs that a `>=` range query would exclude), delta thereafter. Advances the
    /// per-`(family, baby, collection)` watermark by the max server `updatedAt` merged.
    private func fetch<T: Decodable & CloudSyncTimestamped>(_ collection: String,
                                                            dateField: String) async -> [T] {
        let scope = service.currentScope()
        let previous = watermarks.watermark(family: scope.familyId, baby: scope.babyId,
                                            collection: collection)

        let dtos: [T]
        if let previous {
            dtos = (try? await service.fetchChanged(from: collection, since: previous)) ?? []
        } else {
            dtos = (try? await service.fetchAll(from: collection, dateField: dateField)) ?? []
        }

        let maxObserved = dtos.compactMap { $0.updatedAt?.dateValue() }.max()
        let next = Self.advancedWatermark(previous: previous, maxObserved: maxObserved)
        watermarks.set(family: scope.familyId, baby: scope.babyId, collection: collection, to: next)
        return dtos
    }

    // MARK: - DTO → local mapping (skip docs whose id isn't a UUID, e.g. legacy random ids)

    private static func feedingEntry(_ dto: FeedingLogDTO) -> FeedingEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return FeedingEntry(id: uuid, date: log.startedAt,
                            durationSeconds: log.durationMin * 60,
                            side: log.side, milliliters: log.amountMl,
                            updatedAt: dto.updatedAt?.dateValue())
    }

    private static func sleepEntry(_ dto: SleepLogDTO) -> SleepEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return SleepEntry(id: uuid, startDate: log.startedAt, endDate: log.endedAt,
                          note: "", quality: log.quality, updatedAt: log.updatedAt)
    }

    private static func diaperEntry(_ dto: DiaperLogDTO) -> DiaperEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        return DiaperEntry(id: uuid, date: dto.domain.loggedAt, updatedAt: dto.updatedAt?.dateValue())
    }

    private static func stoolEntry(_ dto: QuickEventLogDTO) -> StoolEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        return StoolEntry(id: uuid, date: dto.domain.loggedAt)
    }

    private static func walkEntry(_ dto: QuickEventLogDTO) -> WalkEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        let start = log.startDate ?? log.loggedAt
        return WalkEntry(id: uuid, startDate: start, endDate: log.endDate ?? log.loggedAt)
    }

    private static func bathEntry(_ dto: QuickEventLogDTO) -> BathEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        let start = log.startDate ?? log.loggedAt
        return BathEntry(id: uuid, startDate: start, endDate: log.endDate ?? log.loggedAt)
    }

    private static func pumpingEntry(_ dto: PumpingLogDTO) -> PumpingEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return PumpingEntry(id: uuid, date: log.date, durationSeconds: log.durationSeconds,
                            side: PumpingSide(rawValue: log.side) ?? .both,
                            volumeML: log.volumeML, endDate: log.endDate ?? log.date,
                            updatedAt: dto.updatedAt?.dateValue())
    }

    private static func measurementEntry(_ dto: MeasurementLogDTO) -> MeasurementEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM"
        fmt.locale = Locale.current
        return MeasurementEntry(id: uuid, date: log.date, dateLabel: fmt.string(from: log.date),
                                weight: log.weight, height: log.height, headCirc: log.headCirc,
                                delta: "", visitLabel: nil, updatedAt: dto.updatedAt?.dateValue())
    }

    private static func vaccinationEntry(_ dto: VaccinationLogDTO) -> VaccinationEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        // Custom vaccines use a negative catalogId; catalog ones are 1–20.
        let customName = log.catalogId < 0 ? log.vaccineName : nil
        return VaccinationEntry(id: uuid, catalogId: log.catalogId, doneDate: log.doneDate,
                                notes: log.notes, customName: customName,
                                updatedAt: dto.updatedAt?.dateValue())
    }

    private static func foodEntry(_ dto: FoodDiaryLogDTO) -> ComplementaryFoodEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return ComplementaryFoodEntry(
            id: uuid, date: log.date, foodName: log.foodName,
            category: FoodCategory(rawValue: log.category) ?? .other,
            reaction: FoodReaction(rawValue: log.reaction) ?? .none,
            isAllergen: log.isAllergen, notes: log.notes, photoPath: log.photoPath,
            updatedAt: dto.updatedAt?.dateValue()
        )
    }

    private static func temperatureEntry(_ dto: TemperatureLogDTO) -> TemperatureEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        let dateFmt = DateFormatter(); dateFmt.dateStyle = .short
        let timeFmt = DateFormatter(); timeFmt.timeStyle = .short
        return TemperatureEntry(id: uuid, date: log.date,
                                dateLabel: dateFmt.string(from: log.date),
                                timeLabel: timeFmt.string(from: log.date),
                                value: log.value, note: log.note,
                                updatedAt: dto.updatedAt?.dateValue())
    }

    private static func momSleepEntry(_ dto: SleepLogDTO) -> SleepEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return SleepEntry(id: uuid, startDate: log.startedAt, endDate: log.endedAt,
                          note: "", quality: log.quality, updatedAt: log.updatedAt)
    }

    private static func waterIntakeEntry(_ dto: WaterIntakeLogDTO) -> WaterIntakeEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return WaterIntakeEntry(id: uuid, date: log.date, amountMl: log.amountMl,
                                updatedAt: dto.updatedAt?.dateValue())
    }

    // Leaps are keyed by an Int leapId (not a UUID), so no UUID guard here.
    private static func leapProgress(_ dto: LeapLogDTO) -> LeapProgress? {
        let log = dto.domain
        return LeapProgress(id: log.leapId, isDone: log.isDone, completedDate: log.completedDate)
    }

    private static func doctorVisit(_ dto: DoctorVisitLogDTO) -> DoctorVisit? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        return DoctorVisit(id: uuid, date: dto.domain.date)
    }

    private static func diaryItem(_ dto: DiaryLogDTO) -> StoredDiaryItem? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        let kind = StoredDiaryItemKind(rawValue: log.kind) ?? .note
        return StoredDiaryItem(id: uuid, date: log.date, kind: kind, text: log.text,
                               isMilestone: kind == .milestone, iconName: log.iconName,
                               updatedAt: dto.updatedAt?.dateValue())
    }

    /// QuickLogRepository is UserDefaults + today-only, so we only merge today's quick events.
    private static func todayQuickLog(_ dto: QuickEventLogDTO) -> QuickLogEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        guard Calendar.current.isDateInToday(log.loggedAt) else { return nil }
        let kind = BlobKind(rawValue: log.kind) ?? .star
        return QuickLogEntry(id: uuid, time: log.loggedAt, kind: kind, label: log.label)
    }

    private static func todayDiaperQuickLog(_ dto: DiaperLogDTO) -> QuickLogEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        guard Calendar.current.isDateInToday(log.loggedAt) else { return nil }
        let strings = LocalizationManager.shared.strings
        return QuickLogEntry(
            id: uuid,
            time: log.loggedAt,
            kind: .drop,
            label: "\(strings.diaper) · \(strings.diaperWet)"
        )
    }

    private static func todayPumpingQuickLog(_ dto: PumpingLogDTO) -> QuickLogEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        let time = log.endDate ?? log.date
        guard Calendar.current.isDateInToday(time) else { return nil }
        let minutes = max(1, log.durationSeconds / 60)
        return QuickLogEntry(
            id: uuid,
            time: time,
            kind: .pump,
            label: LocalizationManager.shared.strings.pumpingLogEntry(dur: minutes, ml: log.volumeML)
        )
    }
}
