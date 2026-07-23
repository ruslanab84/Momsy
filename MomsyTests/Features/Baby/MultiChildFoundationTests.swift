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
            for: SleepRecord.self, FeedingRecord.self, BabyRecord.self,
            configurations: config
        )
        return ModelContext(container)
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
        UserDefaults.standard.removeObject(forKey: "babyLogBackfill_v1_done")
        let ctx = try makeContext()

        // A baby exists, but logs were created before multi-child (unassigned).
        let child = BabyProfile(name: "First", birthDate: Date(timeIntervalSince1970: 1_000))
        ctx.insert(BabyRecord(child))
        let legacy = SleepRecord(SleepEntry(startDate: Date()))
        legacy.babyId = ActiveBaby.unassigned   // simulate pre-migration row
        ctx.insert(legacy)
        try ctx.save()

        BabyLogBackfill.run(context: ctx)

        let all = try ctx.fetch(FetchDescriptor<SleepRecord>())
        #expect(all.allSatisfy { $0.babyId == child.id })
        #expect(ActiveBaby.currentId == child.id)

        UserDefaults.standard.removeObject(forKey: "babyLogBackfill_v1_done")
        freshActive()
    }
}
