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

    private var hasRun = false

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
         doctorVisitRepo: any DoctorVisitRepository) {
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
    }

    // MARK: - Entry point

    @MainActor
    func downloadAndMergeWhenReady() async {
        guard !hasRun else { return }
        if FamilyManager.shared.familyId == nil {
            await waitForFamilyReady(timeout: 8)
        }
        guard FamilyManager.shared.familyId != nil else { return }
        hasRun = true
        // Resolve the per-baby path before any read/write: migrate the old family-keyed
        // tree (deriving the canonical babyId), then discover it from the roster for a
        // device that joined an already-migrated family with no local baby yet.
        await service.migrateFromFamilyPathIfNeeded()
        await service.discoverAndPersistBabyId()
        await syncBabyProfile()
        await downloadAndMerge()
        await purgeLegacyQuickLogsOnce()
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
                WidgetDataStore.shared.setBabyInfo(name: remote.name, birthDate: remote.birthDate)
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
    private func downloadAndMerge() async {
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
        let tombstonedIds = Set((try? await service.fetchTombstones())?.compactMap(UUID.init) ?? [])
        let deletedIds = tombstonedIds.union(PendingDeletionsStore.shared.ids())

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
        let quickToday = (await walkDTOs + bathDTOs + vitaminDTOs + stoolDTOs)
            .compactMap(Self.todayQuickLog)

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
        quickToday.forEach { quickLogRepo.appendUnique($0) }

        // Propagate deletes made on other devices: remove any local row whose id was
        // explicitly tombstoned. Only ever deletes ids we have a tombstone for.
        if !deletedIds.isEmpty {
            try? await diaperRepo.applyDeletions(deletedIds)
            try? await vaccinationRepo.applyDeletions(deletedIds)
            try? await foodDiaryRepo.applyDeletions(deletedIds)
        }

        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
    }

    private func fetch<T: Decodable>(_ collection: String, dateField: String) async -> [T] {
        (try? await service.fetchAll(from: collection, dateField: dateField)) ?? []
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
        // Quick-event logs only carry a single timestamp; end time isn't synced.
        return WalkEntry(id: uuid, startDate: dto.domain.loggedAt, endDate: nil)
    }

    private static func bathEntry(_ dto: QuickEventLogDTO) -> BathEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        return BathEntry(id: uuid, startDate: dto.domain.loggedAt, endDate: nil)
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
}
