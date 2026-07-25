import Testing
import Foundation
@testable import Momsy

@Suite("BabySyncBackfill", .serialized)
struct BabySyncBackfillTests {

    private struct DummyLog: Encodable { let id: String; let amountMl: Int }

    @Test func authorStampingFillsEmptyAuthorFields() {
        let payload: [String: Any] = ["amountMl": 120, "addedBy": "", "addedByName": ""]
        let stamped = SyncAuthorMetadata.stamp(
            payload,
            author: SyncAuthorIdentity(uid: "user-1", displayName: "Parent")
        )

        #expect((stamped["amountMl"] as? Int) == 120)
        #expect((stamped["addedBy"] as? String) == "user-1")
        #expect((stamped["addedByName"] as? String) == "Parent")
    }

    @Test func authorStampingPreservesExistingAuthor() {
        let payload: [String: Any] = ["amountMl": 120, "addedBy": "creator-1", "addedByName": "Mom"]
        let stamped = SyncAuthorMetadata.stamp(
            payload,
            author: SyncAuthorIdentity(uid: "editor-2", displayName: "Dad")
        )

        #expect((stamped["addedBy"] as? String) == "creator-1")
        #expect((stamped["addedByName"] as? String) == "Mom")
    }

    @Test func authorStampingLeavesNonAuthorPayloadAlone() {
        let payload: [String: Any] = ["amountMl": 120]
        let stamped = SyncAuthorMetadata.stamp(
            payload,
            author: SyncAuthorIdentity(uid: "user-1", displayName: "Parent")
        )

        #expect((stamped["amountMl"] as? Int) == 120)
        #expect(!stamped.keys.contains("addedBy"))
        #expect(!stamped.keys.contains("addedByName"))
    }

    @Test func authorIdentityTrimsAndFallsBackToUserName() {
        let identity = SyncAuthorIdentity(uid: " user-1 ", displayName: "   ")

        #expect(identity.uid == "user-1")
        #expect(identity.displayName == "User")
    }

    private func clearPath() {
        UserDefaults.standard.removeObject(forKey: kFamilyIdDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kBabyIdDefaultsKey)
    }

    @Test func setLogEnqueuesWhenPathNotReady() async throws {
        clearPath()
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        let service = BabySyncService(cloudSyncAllowed: { true })
        try await service.setLog(DummyLog(id: "log-1", amountMl: 120),
                                 id: "log-1", to: "feedingLogs")

        let queued = PendingWritesStore.shared.all()
        #expect(queued.count == 1)
        #expect(queued[0].collection == "feedingLogs")
        #expect(queued[0].docId == "log-1")
        #expect((queued[0].payload["amountMl"] as? Int) == 120)
    }

    @Test func setLogStampsKnownBabyIdSoReplayRoutesToTheRightChild() async throws {
        // Isolated store so a parallel suite clearing the process-wide active-baby key
        // can't race this test's known-baby setup (the service reads its path from here).
        let suite = "BabySyncBackfillTests.stamp"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        // Baby is known early in onboarding; only the family path is still pending.
        defaults.set("baby-42", forKey: kBabyIdDefaultsKey)
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        try await BabySyncService(defaults: defaults, cloudSyncAllowed: { true })
            .setLog(DummyLog(id: "log-9", amountMl: 60), id: "log-9", to: "feedingLogs")

        let queued = PendingWritesStore.shared.all()
        #expect(queued.count == 1)
        #expect(queued[0].babyId == "baby-42")   // stamped, so replay can't drift to another child
        #expect(queued[0].familyId == "")
    }

    @Test func addFeedingLogEnqueuesByStableIdWhenPathNotReady() async throws {
        clearPath()
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        let repo = BabySyncRepository(service: BabySyncService(cloudSyncAllowed: { true }))
        let log = FeedingLog(id: "feed-7", startedAt: Date(), endedAt: nil,
                             durationMin: 10, side: .left, amountMl: 80,
                             addedBy: "u", addedByName: "U")
        try await repo.addFeedingLog(log)

        let queued = PendingWritesStore.shared.all()
        #expect(queued.count == 1)
        #expect(queued[0].collection == "feedingLogs")
        #expect(queued[0].docId == "feed-7")   // stable id, not an auto-generated doc id
    }

    @Test func setLogDoesNotQueueWithoutCloudConsent() async throws {
        clearPath()
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        try await BabySyncService(cloudSyncAllowed: { false })
            .setLog(DummyLog(id: "local-only", amountMl: 60),
                    id: "local-only", to: "feedingLogs")

        #expect(PendingWritesStore.shared.all().isEmpty)
    }
}
