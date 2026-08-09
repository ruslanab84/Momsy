import Testing
import SwiftData
@testable import Momsy
import Foundation
import CryptoKit

/// Phase-1 multi-child foundation: roster + cap, active-baby log scoping, and the
/// legacy backfill. Serialized because `ActiveBaby` is backed by shared UserDefaults.
@Suite("MultiChildFoundation", .serialized)
@MainActor
struct MultiChildFoundationTests {

    private func freshActive() { ActiveBaby.currentId = nil }

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: SleepRecord.self, FeedingRecord.self, BabyRecord.self, WeeklyInsightRecord.self,
            configurations: config
        )
        return ModelContext(container)
    }

    private func weeklyInsight(weekStart: Date, summary: String) -> WeeklyInsight {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        let stats = WeeklyStats(
            weekStart: weekStart, weekEnd: weekEnd,
            ageMonths: 2, ageWeeks: 9, currentLeapName: nil,
            currentLeapID: nil, leapSignals: [],
            avgSleepMinutesPerDay: 0, avgNightSleepMinutes: 0, avgDaySleepMinutes: 0,
            avgNapsPerDay: 0, sleepTrendVsPrevWeekMinutes: 0,
            whoMinSleepMinutes: 840, whoAwakeWindowMax: 90,
            avgFeedingsPerDay: 0, totalFeedings: 0,
            newFoodsIntroduced: [], allergensFlagged: [], totalDiapers: 0
        )
        let ai = WeeklyInsightAI(
            sleepSummary: "", sleepRecommendation: "",
            feedingSummary: "", feedingRecommendation: "", overallSummary: summary
        )
        return WeeklyInsight(
            stats: stats, ai: ai, isAIGenerated: true,
            generatedAt: weekEnd, language: .english
        )
    }

    // MARK: Roster + cap

    @Test func rosterUpsertSortsAndCapsAtFive() async throws {
        freshActive()
        let repo = MockBabyRepository()
        let base = Date(timeIntervalSince1970: 1_000_000)
        // Insert 5 children with increasing birthDates (out of order).
        var ids: [UUID] = []
        for i in [2, 0, 4, 1, 3] {
            let p = BabyProfile(name: "C\(i)", birthDate: base.addingTimeInterval(Double(i) * 86_400))
            ids.append(p.id)
            try await repo.saveProfile(p)
        }
        let all = try await repo.getAllProfiles()
        #expect(all.count == 5)
        #expect(all.map(\.name) == ["C0", "C1", "C2", "C3", "C4"]) // oldest first

        // 6th is rejected.
        await #expect(throws: BabyError.self) {
            try await repo.saveProfile(BabyProfile(name: "C5"))
        }
        freshActive()
    }

    /// Onboarding the first child must make it the active child even when a stale
    /// active-baby pointer is persisted (e.g. left by a removed child or a prior
    /// account). Otherwise the child is appended to the roster but never mirrored to
    /// `babyProfile`, stranding the app with no active profile — the regression that
    /// made `SleepViewModel.sleepNorm` fall back to its no-profile defaults.
    @Test func updateAdoptsFirstChildWhenPersistedPointerIsStale() async throws {
        freshActive()
        ActiveBaby.currentId = UUID()   // points at a child that isn't in the roster
        let appState = makeAppState()
        let child = BabyProfile(name: "Solo", birthDate: Date())

        appState.update(child)

        #expect(appState.babyProfile?.id == child.id)
        #expect(appState.activeBabyId == child.id)
        freshActive()
    }

    @Test func deleteRemovesChild() async throws {
        freshActive()
        let repo = MockBabyRepository()
        let a = BabyProfile(name: "A"); let b = BabyProfile(name: "B")
        try await repo.saveProfile(a)
        try await repo.saveProfile(b)
        try await repo.deleteProfile(id: a.id)
        let all = try await repo.getAllProfiles()
        #expect(all.map(\.name) == ["B"])
        freshActive()
    }

    // MARK: Active-baby log scoping

    @Test func getEntriesReturnsOnlyActiveChildLogs() async throws {
        freshActive()
        let ctx = try makeContext()
        let repo = SwiftDataSleepRepository(context: ctx)
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let window = (from: day.addingTimeInterval(-3600), to: day.addingTimeInterval(7200))
        let babyA = UUID(), babyB = UUID()

        ActiveBaby.currentId = babyA
        try await repo.add(SleepEntry(startDate: day, endDate: day.addingTimeInterval(3600)))
        try await repo.add(SleepEntry(startDate: day, endDate: day.addingTimeInterval(3600)))

        ActiveBaby.currentId = babyB
        try await repo.add(SleepEntry(startDate: day, endDate: day.addingTimeInterval(3600)))

        // Active = B → only B's single entry.
        let bEntries = try await repo.getEntries(from: window.from, to: window.to)
        #expect(bEntries.count == 1)

        // Switch active to A → only A's two entries.
        ActiveBaby.currentId = babyA
        let aEntries = try await repo.getEntries(from: window.from, to: window.to)
        #expect(aEntries.count == 2)
        freshActive()
    }

    @Test func weeklyInsightsAreScopedToActiveChildAndDeletedWithIt() async throws {
        freshActive()
        defer { freshActive() }
        let context = try makeContext()
        let repository = SwiftDataWeeklyInsightRepository(context: context)
        let weekStart = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))
        let babyA = UUID(), babyB = UUID()

        ActiveBaby.currentId = babyA
        try await repository.save(weeklyInsight(weekStart: weekStart, summary: "A"))

        ActiveBaby.currentId = babyB
        #expect(try await repository.all().isEmpty)
        #expect(try await repository.latest() == nil)
        #expect(try await repository.report(forWeekStarting: weekStart) == nil)
        try await repository.save(weeklyInsight(weekStart: weekStart, summary: "B"))

        let stored = try context.fetch(FetchDescriptor<WeeklyInsightRecord>())
        #expect(stored.count == 2)
        #expect(Set(stored.map(\.babyId)) == [babyA, babyB])

        ActiveBaby.currentId = babyA
        #expect(try await repository.all().map(\.ai.overallSummary) == ["A"])
        BabyLogBackfill.deleteLogs(forBaby: babyA, context: context)
        try context.save()
        #expect(try await repository.all().isEmpty)

        ActiveBaby.currentId = babyB
        #expect(try await repository.all().map(\.ai.overallSummary) == ["B"])
    }

    @Test func wellbeingRepositoriesAreScopedToCurrentUser() async throws {
        freshActive()
        ActiveBaby.currentId = UUID()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: MomSleepRecord.self, WaterIntakeRecord.self,
            configurations: config
        )
        let context = ModelContext(container)
        let momSleep = SwiftDataMomSleepRepository(context: context, currentUID: { "mom" })
        let dadSleep = SwiftDataMomSleepRepository(context: context, currentUID: { "dad" })
        let momWater = SwiftDataWaterIntakeRepository(context: context, currentUID: { "mom" })
        let dadWater = SwiftDataWaterIntakeRepository(context: context, currentUID: { "dad" })
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let window = (from: date.addingTimeInterval(-1), to: date.addingTimeInterval(1))

        try await momSleep.upsert([
            SleepEntry(startDate: date, endDate: date, startedBy: "mom"),
            SleepEntry(startDate: date, endDate: date, startedBy: "dad"),
        ])
        try await momWater.upsert([
            WaterIntakeEntry(id: UUID(), date: date, amountMl: 200, ownerUID: "mom"),
            WaterIntakeEntry(id: UUID(), date: date, amountMl: 300, ownerUID: "dad"),
        ])
        context.insert(MomSleepRecord(SleepEntry(startDate: date, endDate: date)))
        context.insert(WaterIntakeRecord(WaterIntakeEntry(id: UUID(), date: date, amountMl: 400)))
        try context.save()

        #expect(try await momSleep.getEntries(from: window.from, to: window.to).map(\.startedBy) == ["mom"])
        #expect(try await dadSleep.getEntries(from: window.from, to: window.to).map(\.startedBy) == ["dad"])
        #expect(try await momWater.getEntries(from: window.from, to: window.to).map(\.ownerUID) == ["mom"])
        #expect(try await dadWater.getEntries(from: window.from, to: window.to).map(\.ownerUID) == ["dad"])
        freshActive()
    }

    @Test func localWellbeingSurvivesFirstCloudSyncOptIn() async throws {
        freshActive()
        ActiveBaby.currentId = UUID()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: MomSleepRecord.self, WaterIntakeRecord.self,
            configurations: config
        )
        let context = ModelContext(container)
        var uid: String?
        let sleep = SwiftDataMomSleepRepository(context: context, currentUID: { uid })
        let water = SwiftDataWaterIntakeRepository(context: context, currentUID: { uid })
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let window = (from: date.addingTimeInterval(-1), to: date.addingTimeInterval(1))

        try await sleep.add(SleepEntry(startDate: date, endDate: date))
        try await water.add(WaterIntakeEntry(id: UUID(), date: date, amountMl: 250))
        uid = "mom"

        #expect(try await sleep.getEntries(from: window.from, to: window.to).map(\.startedBy) == ["mom"])
        #expect(try await water.getEntries(from: window.from, to: window.to).map(\.ownerUID) == ["mom"])
        freshActive()
    }

    // MARK: Quick-log strip scoping

    /// The "Today so far" quick-log strip (diaper/walk/bath/vitamin/stool) must be
    /// scoped per active child. Switching the active baby must not leak the previous
    /// child's quick events into the new child's strip.
    @Test func quickLogStripIsScopedToActiveChild() {
        freshActive()
        let suite = "MultiChildFoundationTests.quickLog"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let secureDefaults = SecurePreferences(
            defaults: defaults,
            encryptionKey: SymmetricKey(size: .bits256)
        )
        let repo = QuickLogRepository(defaults: secureDefaults)
        let babyA = UUID(), babyB = UUID()
        defer {
            defaults.removePersistentDomain(forName: suite)
            freshActive()
        }

        ActiveBaby.currentId = babyA
        repo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .drop, label: "A diaper"))

        // Switch to B → strip is empty for the freshly-selected child.
        ActiveBaby.currentId = babyB
        #expect(repo.load().isEmpty)

        repo.append(QuickLogEntry(id: UUID(), time: Date(), kind: .walk, label: "B walk"))
        #expect(repo.load().map(\.label) == ["B walk"])

        // Switch back to A → only A's own entry, never B's.
        ActiveBaby.currentId = babyA
        #expect(repo.load().map(\.label) == ["A diaper"])
        #expect(defaults.object(forKey: "quick_log_today_entries_\(babyA.uuidString)") == nil)
        #expect(defaults.data(forKey: SecurePreferences.encryptedKey(
            for: "quick_log_today_entries_\(babyA.uuidString)"
        )) != nil)
    }

    // MARK: Backfill

    @Test func backfillStampsLegacyLogsToFirstChild() async throws {
        freshActive()
        UserDefaults.standard.removeObject(forKey: "babyLogBackfill_v2_done")
        defer {
            UserDefaults.standard.removeObject(forKey: "babyLogBackfill_v2_done")
            freshActive()
        }
        let ctx = try makeContext()

        // A baby exists, but logs were created before multi-child (unassigned).
        let child = BabyProfile(name: "First", birthDate: Date(timeIntervalSince1970: 1_000))
        ctx.insert(BabyRecord(child))
        let legacy = SleepRecord(SleepEntry(startDate: Date()))
        legacy.babyId = ActiveBaby.unassigned   // simulate pre-migration row
        ctx.insert(legacy)
        ctx.insert(WeeklyInsightRecord(
            weeklyInsight(weekStart: Date(timeIntervalSince1970: 1_700_000_000), summary: "legacy"),
            babyId: ActiveBaby.unassigned
        ))
        try ctx.save()

        BabyLogBackfill.run(context: ctx)

        let all = try ctx.fetch(FetchDescriptor<SleepRecord>())
        #expect(all.allSatisfy { $0.babyId == child.id })
        #expect(try ctx.fetch(FetchDescriptor<WeeklyInsightRecord>()).isEmpty)
        #expect(ActiveBaby.currentId == child.id)
    }
}
