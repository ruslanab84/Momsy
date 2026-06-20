// MomsyTests/Features/Sync/PendingWritesStoreTests.swift
import Testing
import Foundation
import FirebaseFirestore
@testable import Momsy

@Suite("PendingWritesStore", .serialized)
struct PendingWritesStoreTests {

    private func freshStore() -> PendingWritesStore {
        let suite = "PendingWritesStoreTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return PendingWritesStore(defaults: defaults)
    }

    @Test func addAndAllRoundTripIncludingTimestamp() {
        let store = freshStore()
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        store.add(collection: "feedingLogs", docId: "abc",
                  payload: ["startedAt": Timestamp(date: date), "amountMl": 90])

        let all = store.all()
        #expect(all.count == 1)
        #expect(all[0].collection == "feedingLogs")
        #expect(all[0].docId == "abc")
        #expect((all[0].payload["startedAt"] as? Date) == date)   // Timestamp normalized to Date
        #expect((all[0].payload["amountMl"] as? Int) == 90)
    }

    @Test func addReplacesSameDocId() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1])
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 2])
        let all = store.all()
        #expect(all.count == 1)
        #expect((all[0].payload["v"] as? Int) == 2)
    }

    @Test func removeDeletesEntry() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1])
        store.add(collection: "sleepLogs", docId: "y", payload: ["v": 2])
        store.remove(docId: "x")
        let all = store.all()
        #expect(all.count == 1)
        #expect(all[0].docId == "y")
    }
}
