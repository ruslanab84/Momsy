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

    /// One collection's fetch result with its watermark commit deferred until the
    /// merge lands. `commitTo == nil` when the fetch itself failed — the previous
    /// watermark must stay untouched so the next sync retries the same window.
    struct PendingFetch<T> {
        let dtos: [T]
        let familyId: String
        let babyId: String
        let collection: String
        let commitTo: Date?
    }

    /// Pure: the watermark to persist after a merge, or nil to leave it as-is.
    /// A failed fetch never commits — in particular a failed FIRST pull must not
    /// write the epoch floor, or the one-time full pull (which captures legacy
    /// nil-`updatedAt` docs) would be skipped forever.
    static func watermarkAfterFetch(fetchSucceeded: Bool, next: Date) -> Date? {
        fetchSucceeded ? next : nil
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
        async let feedingFetch:  PendingFetch<FeedingLogDTO>     = fetch("feedingLogs",     dateField: "startedAt")
        async let sleepFetch:    PendingFetch<SleepLogDTO>       = fetch("sleepLogs",       dateField: "startedAt")
        async let diaperFetchA:  PendingFetch<DiaperLogDTO>      = fetch("diaperLogs",      dateField: "loggedAt")
        async let stoolFetchA:   PendingFetch<QuickEventLogDTO>  = fetch("stoolLogs",       dateField: "loggedAt")
        async let walkFetchA:    PendingFetch<QuickEventLogDTO>  = fetch("walkLogs",        dateField: "loggedAt")
        async let bathFetchA:    PendingFetch<QuickEventLogDTO>  = fetch("bathLogs",        dateField: "loggedAt")
        async let vitaminFetchA: PendingFetch<QuickEventLogDTO>  = fetch("vitaminLogs",     dateField: "loggedAt")
        async let pumpingFetchA: PendingFetch<PumpingLogDTO>     = fetch("pumpingLogs",     dateField: "date")
        async let diaryFetch:    PendingFetch<DiaryLogDTO>       = fetch("diaryLogs",       dateField: "date")
        async let measureFetch:  PendingFetch<MeasurementLogDTO> = fetch("measurementLogs", dateField: "date")
        async let vaccineFetch:  PendingFetch<VaccinationLogDTO> = fetch("vaccinationLogs", dateField: "doneDate")
        async let foodFetch:     PendingFetch<FoodDiaryLogDTO>   = fetch("foodDiaryLogs",   dateField: "date")
        async let tempFetch:     PendingFetch<TemperatureLogDTO> = fetch("temperatureLogs", dateField: "date")
        async let momSleepFetch: PendingFetch<SleepLogDTO>       = fetch("momSleepLogs",    dateField: "startedAt")
        async let waterFetch:    PendingFetch<WaterIntakeLogDTO> = fetch("waterIntakeLogs", dateField: "date")
        async let leapFetch:     PendingFetch<LeapLogDTO>        = fetch("leapLogs",        dateField: "completedDate")
        async let visitFetch:    PendingFetch<DoctorVisitLogDTO> = fetch("doctorVisitLogs", dateField: "date")

        // Reconcile deletes before merging: retry our own unsent deletes, then gather
        // every tombstoned id so the merge neither resurrects nor re-inserts a deleted
        // entry. Pending-local ids are unioned in so an in-flight delete is honoured
        // even before its tombstone round-trips.
        await service.retryPendingDeletions()

        // Incremental tombstone pull. The `deletions` watermark is committed only after
        // `applyDeletions` below succeeds — a failed apply must re-pull the same
        // tombstones, or the deleted entry resurrects on this device forever.
        let tombScope = service.currentScope()
        let tombWatermark = watermarks.watermark(family: tombScope.familyId, baby: tombScope.babyId,
                                                 collection: "deletions")
        let tombstones = try? await service.fetchTombstones(since: tombWatermark)
        let tombstonedIds = Set((tombstones ?? []).compactMap { UUID(uuidString: $0.id) })
        let deletedIds = tombstonedIds.union(PendingDeletionsStore.shared.ids())

        // Raw fetch results needed twice (entry merge + quick-log strip).
        let stoolFetch   = await stoolFetchA
        let walkFetch    = await walkFetchA
        let bathFetch    = await bathFetchA
        let vitaminFetch = await vitaminFetchA
        let diaperFetch  = await diaperFetchA
        let pumpingFetch = await pumpingFetchA

        // Merge into SwiftData on the main actor (shared context is main-actor owned).
        // Each collection commits its own watermark iff its upsert did not throw.
        await merge(await feedingFetch,  map: Self.feedingEntry)     { try await self.feedingRepo.upsert($0) }
        await merge(await sleepFetch,    map: Self.sleepEntry)       { try await self.sleepRepo.upsert($0) }
        await merge(diaperFetch,         map: Self.diaperEntry)      { entries in
            try await self.diaperRepo.upsert(entries.filter { !deletedIds.contains($0.id) })
        }
        await merge(stoolFetch,          map: Self.stoolEntry)       { try await self.stoolRepo.upsert($0) }
        await merge(await diaryFetch,    map: Self.diaryItem)        { try await self.diaryRepo.upsert($0) }
        await merge(walkFetch,           map: Self.walkEntry)        { try await self.walkRepo.upsert($0) }
        await merge(bathFetch,           map: Self.bathEntry)        { try await self.bathRepo.upsert($0) }
        await merge(pumpingFetch,        map: Self.pumpingEntry)     { try await self.pumpingRepo.upsert($0) }
        await merge(await measureFetch,  map: Self.measurementEntry) { try await self.measurementRepo.upsert($0) }
        await merge(await vaccineFetch,  map: Self.vaccinationEntry) { entries in
            try await self.vaccinationRepo.upsert(entries.filter { !deletedIds.contains($0.id) })
        }
        await merge(await foodFetch,     map: Self.foodEntry)        { entries in
            try await self.foodDiaryRepo.upsert(entries.filter { !deletedIds.contains($0.id) })
        }
        await merge(await tempFetch,     map: Self.temperatureEntry) { try await self.temperatureRepo.upsert($0) }
        await merge(await momSleepFetch, map: Self.momSleepEntry)    { try await self.momSleepRepo.upsert($0) }
        await merge(await waterFetch,    map: Self.waterIntakeEntry) { try await self.waterIntakeRepo.upsert($0) }
        await merge(await leapFetch,     map: Self.leapProgress)     { try await self.leapsRepo.upsert($0) }
        await merge(await visitFetch,    map: Self.doctorVisit)      { try await self.doctorVisitRepo.upsert($0) }

        // Quick-log "today" strip. `appendUnique` cannot throw; vitamins have no
        // entry repo, so their watermark commits here.
        if recordQuickLogs {
            let quickEventDTOs = walkFetch.dtos + bathFetch.dtos + vitaminFetch.dtos + stoolFetch.dtos
            let quickToday = quickEventDTOs.compactMap(Self.todayQuickLog)
                + diaperFetch.dtos.compactMap(Self.todayDiaperQuickLog)
                + pumpingFetch.dtos.compactMap(Self.todayPumpingQuickLog)
            quickToday.forEach { quickLogRepo.appendUnique($0) }
        }
        commit(vitaminFetch)

        // Propagate deletes made on other devices: remove any local row whose id was
        // explicitly tombstoned. Only ever deletes ids we have a tombstone for.
        var deletionsApplied = true
        if !deletedIds.isEmpty {
            do {
                try await diaperRepo.applyDeletions(deletedIds)
                try await vaccinationRepo.applyDeletions(deletedIds)
                try await foodDiaryRepo.applyDeletions(deletedIds)
                quickLogRepo.remove(ids: deletedIds)
            } catch {
                deletionsApplied = false
            }
        }
        if deletionsApplied, let tombstones {
            let maxTomb = tombstones.map(\.deletedAt).max()
            let nextTomb = Self.advancedWatermark(previous: tombWatermark, maxObserved: maxTomb)
            watermarks.set(family: tombScope.familyId, baby: tombScope.babyId,
                           collection: "deletions", to: nextTomb)
        }

        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
    }

    /// Incremental fetch: full pull on first sync of a collection (captures legacy `nil`-`updatedAt`
    /// docs that a `>=` range query would exclude), delta thereafter. The per-`(family, baby,
    /// collection)` watermark is NOT advanced here — the caller commits it via `merge`/`commit`
    /// only after the local upsert succeeds, so a failed save re-pulls the same window.
    private func fetch<T: Decodable & CloudSyncTimestamped>(_ collection: String,
                                                            dateField: String) async -> PendingFetch<T> {
        let scope = service.currentScope()
        let previous = watermarks.watermark(family: scope.familyId, baby: scope.babyId,
                                            collection: collection)
        var dtos: [T] = []
        var fetchSucceeded = false
        do {
            if let previous {
                dtos = try await service.fetchChanged(from: collection, since: previous)
            } else {
                dtos = try await service.fetchAll(from: collection, dateField: dateField)
            }
            fetchSucceeded = true
        } catch {
            // Transient failure: keep the previous watermark; retried next sync.
        }
        let maxObserved = dtos.compactMap { $0.updatedAt?.dateValue() }.max()
        let next = Self.advancedWatermark(previous: previous, maxObserved: maxObserved)
        return PendingFetch(dtos: dtos, familyId: scope.familyId, babyId: scope.babyId,
                            collection: collection,
                            commitTo: Self.watermarkAfterFetch(fetchSucceeded: fetchSucceeded,
                                                               next: next))
    }

    /// Merges one collection and, only on success, advances its watermark. A throwing
    /// upsert leaves the watermark untouched so the same delta is re-pulled next sync.
    @MainActor
    private func merge<DTO, Entry>(_ fetched: PendingFetch<DTO>,
                                   map: (DTO) -> Entry?,
                                   upsert: ([Entry]) async throws -> Void) async {
        let entries = fetched.dtos.compactMap(map)
        do {
            try await upsert(entries)
            commit(fetched)
        } catch {
            // Watermark not advanced; this window is retried on the next sync.
        }
    }

    @MainActor
    private func commit<DTO>(_ fetched: PendingFetch<DTO>) {
        guard let date = fetched.commitTo else { return }
        watermarks.set(family: fetched.familyId, baby: fetched.babyId,
                       collection: fetched.collection, to: date)
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
