import Foundation

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
    private let quickLogRepo: QuickLogRepository

    private var hasRun = false

    init(service: BabySyncService,
         feedingRepo: any FeedingRepository,
         sleepRepo: any SleepRepository,
         diaperRepo: any DiaperRepository,
         stoolRepo: any StoolRepository,
         diaryRepo: any DiaryRepository,
         quickLogRepo: QuickLogRepository) {
        self.service = service
        self.feedingRepo = feedingRepo
        self.sleepRepo = sleepRepo
        self.diaperRepo = diaperRepo
        self.stoolRepo = stoolRepo
        self.diaryRepo = diaryRepo
        self.quickLogRepo = quickLogRepo
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
        await downloadAndMerge()
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
        async let feedingDTOs: [FeedingLogDTO]   = fetch("feedingLogs", dateField: "startedAt")
        async let sleepDTOs:   [SleepLogDTO]      = fetch("sleepLogs",   dateField: "startedAt")
        async let diaperDTOs:  [DiaperLogDTO]     = fetch("diaperLogs",  dateField: "loggedAt")
        async let stoolDTOs:   [QuickEventLogDTO] = fetch("stoolLogs",   dateField: "loggedAt")
        async let walkDTOs:    [QuickEventLogDTO] = fetch("walkLogs",    dateField: "loggedAt")
        async let bathDTOs:    [QuickEventLogDTO] = fetch("bathLogs",    dateField: "loggedAt")
        async let vitaminDTOs: [QuickEventLogDTO] = fetch("vitaminLogs", dateField: "loggedAt")
        async let diaryDTOs:   [DiaryLogDTO]      = fetch("diaryLogs",   dateField: "date")

        let feedings = await feedingDTOs.compactMap(Self.feedingEntry)
        let sleeps   = await sleepDTOs.compactMap(Self.sleepEntry)
        let diapers  = await diaperDTOs.compactMap(Self.diaperEntry)
        let stools   = await stoolDTOs.compactMap(Self.stoolEntry)
        let diaries  = await diaryDTOs.compactMap(Self.diaryItem)
        let quickToday = (await walkDTOs + bathDTOs + vitaminDTOs + stoolDTOs)
            .compactMap(Self.todayQuickLog)

        // Merge into SwiftData on the main actor (shared context is main-actor owned).
        try? await feedingRepo.upsert(feedings)
        try? await sleepRepo.upsert(sleeps)
        try? await diaperRepo.upsert(diapers)
        try? await stoolRepo.upsert(stools)
        try? await diaryRepo.upsert(diaries)
        quickToday.forEach { quickLogRepo.appendUnique($0) }

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
                            side: log.side, milliliters: log.amountMl)
    }

    private static func sleepEntry(_ dto: SleepLogDTO) -> SleepEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        return SleepEntry(id: uuid, startDate: log.startedAt, endDate: log.endedAt,
                          note: "", quality: log.quality)
    }

    private static func diaperEntry(_ dto: DiaperLogDTO) -> DiaperEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        return DiaperEntry(id: uuid, date: dto.domain.loggedAt)
    }

    private static func stoolEntry(_ dto: QuickEventLogDTO) -> StoolEntry? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        return StoolEntry(id: uuid, date: dto.domain.loggedAt)
    }

    private static func diaryItem(_ dto: DiaryLogDTO) -> StoredDiaryItem? {
        guard let idStr = dto.id, let uuid = UUID(uuidString: idStr) else { return nil }
        let log = dto.domain
        let kind = StoredDiaryItemKind(rawValue: log.kind) ?? .note
        return StoredDiaryItem(id: uuid, date: log.date, kind: kind, text: log.text,
                               isMilestone: kind == .milestone, iconName: log.iconName)
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
