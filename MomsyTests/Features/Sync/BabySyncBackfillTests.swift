import Testing
import Foundation
@testable import Momsy

@Suite("BabySyncBackfill", .serialized)
struct BabySyncBackfillTests {

    private struct DummyLog: Encodable { let id: String; let amountMl: Int }

    private func clearPath() {
        UserDefaults.standard.removeObject(forKey: kFamilyIdDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kBabyIdDefaultsKey)
    }

    @Test func setLogEnqueuesWhenPathNotReady() async throws {
        clearPath()
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        let service = BabySyncService()
        try await service.setLog(DummyLog(id: "log-1", amountMl: 120),
                                 id: "log-1", to: "feedingLogs")

        let queued = PendingWritesStore.shared.all()
        #expect(queued.count == 1)
        #expect(queued[0].collection == "feedingLogs")
        #expect(queued[0].docId == "log-1")
        #expect((queued[0].payload["amountMl"] as? Int) == 120)
    }

    @Test func addFeedingLogEnqueuesByStableIdWhenPathNotReady() async throws {
        clearPath()
        PendingWritesStore.shared.clear()
        defer { PendingWritesStore.shared.clear() }

        let repo = BabySyncRepository(service: BabySyncService())
        let log = FeedingLog(id: "feed-7", startedAt: Date(), endedAt: nil,
                             durationMin: 10, side: .left, amountMl: 80,
                             addedBy: "u", addedByName: "U")
        try await repo.addFeedingLog(log)

        let queued = PendingWritesStore.shared.all()
        #expect(queued.count == 1)
        #expect(queued[0].collection == "feedingLogs")
        #expect(queued[0].docId == "feed-7")   // stable id, not an auto-generated doc id
    }
}
