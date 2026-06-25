// MomsyTests/Features/Sync/SyncWatermarkStoreTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("SyncWatermarkStore", .serialized)
struct SyncWatermarkStoreTests {

    private func freshStore() -> SyncWatermarkStore {
        let suite = "SyncWatermarkStoreTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return SyncWatermarkStore(defaults: defaults)
    }

    @Test func nilUntilSet() {
        let store = freshStore()
        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == nil)
    }

    @Test func setAndReadRoundTrip() {
        let store = freshStore()
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == d)
    }

    @Test func scopedPerCollectionFamilyBaby() {
        let store = freshStore()
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        #expect(store.watermark(family: "f", baby: "b", collection: "sleepLogs") == nil)
        #expect(store.watermark(family: "f", baby: "x", collection: "feedingLogs") == nil)
        #expect(store.watermark(family: "g", baby: "b", collection: "feedingLogs") == nil)
    }

    @Test func emptyScopeIsNoOp() {
        let store = freshStore()
        store.set(family: "", baby: "b", collection: "feedingLogs", to: Date())
        #expect(store.watermark(family: "", baby: "b", collection: "feedingLogs") == nil)
    }

    @Test func resetClearsBucket() {
        let store = freshStore()
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        store.reset(family: "f", baby: "b")
        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == nil)
    }
}
