// MomsyTests/Features/Sync/PendingWritesStoreTests.swift
import Testing
import Foundation
import CryptoKit
import FirebaseFirestore
@testable import Momsy

@Suite("PendingWritesStore", .serialized)
struct PendingWritesStoreTests {

    private func freshStore() -> (PendingWritesStore, UserDefaults) {
        let suite = "PendingWritesStoreTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let secureDefaults = SecurePreferences(
            defaults: defaults,
            encryptionKey: SymmetricKey(size: .bits256)
        )
        return (PendingWritesStore(defaults: defaults, secureDefaults: secureDefaults), defaults)
    }

    @Test func addAndAllRoundTripIncludingTimestamp() {
        let (store, defaults) = freshStore()
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
        #expect(defaults.object(forKey: "pending_writes_v1") == nil)
        #expect(defaults.data(forKey: SecurePreferences.encryptedKey(for: "pending_writes_v1")) != nil)
    }

    @Test func productionKeychainPathPersistsAcrossStoreRecreation() throws {
        let suite = "PendingWritesStoreTests.productionKeychain"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = PendingWritesStore(defaults: defaults)
        store.add(collection: "feedingLogs", docId: "durable",
                  payload: ["amountMl": 90], familyId: "family", babyId: "baby")

        #expect(defaults.object(forKey: "pending_writes_v1") == nil)
        #expect(defaults.data(forKey: SecurePreferences.encryptedKey(for: "pending_writes_v1")) != nil)

        let relaunchedStore = PendingWritesStore(defaults: defaults)
        let entry = try #require(relaunchedStore.all().first)
        #expect(entry.docId == "durable")
        #expect((entry.payload["amountMl"] as? Int) == 90)
    }

    @Test func addReplacesSameDocId() {
        let (store, _) = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "f", babyId: "b")
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 2], familyId: "f", babyId: "b")
        let all = store.all()
        #expect(all.count == 1)
        #expect((all[0].payload["v"] as? Int) == 2)
    }

    @Test func concurrentAddsKeepEveryEntry() async {
        let (store, _) = freshStore()
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
        let (store, _) = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "f", babyId: "b")
        store.add(collection: "sleepLogs", docId: "y", payload: ["v": 2], familyId: "f", babyId: "b")
        store.remove(docId: "x")
        let all = store.all()
        #expect(all.count == 1)
        #expect(all[0].docId == "y")
    }

    @Test func removeAllForBabyKeepsOtherChildrenQueued() {
        let (store, _) = freshStore()
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
        let (store, _) = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "f", babyId: "b")
        store.add(collection: "feedingLogs", docId: "y", payload: ["v": 2], familyId: "f", babyId: "b")
        store.clear()
        #expect(store.all().isEmpty)
    }

    @Test func legacyEntryWithoutStampDefaultsToEmptyPath() {
        let (store, _) = freshStore()
        store.add(collection: "sleepLogs", docId: "x", payload: ["v": 1], familyId: "", babyId: "")
        let all = store.all()
        #expect(all[0].familyId == "")
        #expect(all[0].babyId == "")
    }

    @Test func migratesLegacyPlaintextOnlyAfterEncryptedWrite() {
        let suite = "PendingWritesStoreTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set([[
            "collection": "sleepLogs",
            "docId": "legacy",
            "payload": ["temperature": 37.2],
            "familyId": "family",
            "babyId": "baby"
        ]], forKey: "pending_writes_v1")
        let secureDefaults = SecurePreferences(
            defaults: defaults,
            encryptionKey: SymmetricKey(size: .bits256)
        )
        let store = PendingWritesStore(defaults: defaults, secureDefaults: secureDefaults)

        #expect(store.all().map(\.docId) == ["legacy"])
        #expect(defaults.object(forKey: "pending_writes_v1") == nil)
        #expect(defaults.data(forKey: SecurePreferences.encryptedKey(for: "pending_writes_v1")) != nil)
    }
}
