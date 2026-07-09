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
                  payload: ["startedAt": Timestamp(date: date), "amountMl": 90],
                  familyId: "fam-1", babyId: "baby-1")

        let all = store.all()
        #expect(all.count == 1)
        #expect(all[0].collection == "feedingLogs")
        #expect(all[0].docId == "abc")
        #expect(all[0].familyId == "fam-1")
        #expect(all[0].babyId == "baby-1")
        #expect((all[0].payload["startedAt"] as? Date) == date)   // Timestamp normalized to Date
        #expect((all[0].payload["amountMl"] as? Int) == 90)
    }

    @Test func addReplacesSameDocId() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "f", babyId: "b")
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 2], familyId: "f", babyId: "b")
        let all = store.all()
        #expect(all.count == 1)
        #expect((all[0].payload["v"] as? Int) == 2)
    }

    @Test func concurrentAddsKeepEveryEntry() async {
        let store = freshStore()
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    store.add(collection: "feedingLogs", docId: "doc-\(i)",
                              payload: ["i": i], familyId: "fam", babyId: "baby")
                }
            }
        }

        #expect(store.all().count == 100)
    }

    @Test func removeDeletesEntry() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "f", babyId: "b")
        store.add(collection: "sleepLogs", docId: "y", payload: ["v": 2], familyId: "f", babyId: "b")
        store.remove(docId: "x")
        let all = store.all()
        #expect(all.count == 1)
        #expect(all[0].docId == "y")
    }

    @Test func removeAllForBabyKeepsOtherChildrenQueued() {
        let store = freshStore()
        let deletedBaby = UUID()
        let remainingBaby = UUID()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1],
                  familyId: "f", babyId: deletedBaby.uuidString)
        store.add(collection: "feedingLogs", docId: "y", payload: ["v": 2],
                  familyId: "f", babyId: remainingBaby.uuidString)
        store.add(collection: "diaperLogs", docId: "z", payload: ["v": 3],
                  familyId: "f", babyId: "")

        store.removeAll(forBaby: deletedBaby)

        let all = store.all()
        #expect(all.map(\.docId).sorted() == ["y", "z"])
        #expect(all.allSatisfy { $0.babyId != deletedBaby.uuidString })
    }

    @Test func clearRemovesAllEntries() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "f", babyId: "b")
        store.add(collection: "feedingLogs", docId: "y", payload: ["v": 2], familyId: "f", babyId: "b")
        store.clear()
        #expect(store.all().isEmpty)
    }

    @Test func legacyEntryWithoutStampDefaultsToEmptyPath() {
        let store = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "", babyId: "")
        let all = store.all()
        #expect(all[0].familyId == "")
        #expect(all[0].babyId == "")
    }
}
