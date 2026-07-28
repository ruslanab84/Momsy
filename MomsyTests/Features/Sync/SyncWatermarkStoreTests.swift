// MomsyTests/Features/Sync/SyncWatermarkStoreTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("SyncWatermarkStore", .serialized)
struct SyncWatermarkStoreTests {

    private func freshStore(now: Date = Date(timeIntervalSince1970: 1_800_000_000))
        -> (store: SyncWatermarkStore, defaults: UserDefaults) {
        let suite = "SyncWatermarkStoreTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return (SyncWatermarkStore(defaults: defaults, now: { now }), defaults)
    }

    @Test func firstRegularReadBootstrapsAtNowInsteadOfRequestingFullHistory() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let store = freshStore(now: now).store

        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == now)
    }

    @Test func firstSleepReadUsesOnlyTheActiveSessionLookback() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let store = freshStore(now: now).store
        let expected = now.addingTimeInterval(-CloudSyncBootstrapPolicy.activeSleepLookback)

        #expect(store.watermark(family: "f", baby: "b", collection: "sleepLogs") == expected)
    }

    @Test func setAndReadRoundTrip() {
        let store = freshStore().store
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == d)
    }

    @Test func scopedPerCollectionFamilyBaby() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let store = freshStore(now: now).store
        let saved = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: saved)

        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == saved)
        #expect(store.watermark(family: "f", baby: "b", collection: "sleepLogs")
                == now.addingTimeInterval(-CloudSyncBootstrapPolicy.activeSleepLookback))
        #expect(store.watermark(family: "f", baby: "x", collection: "feedingLogs") == now)
        #expect(store.watermark(family: "g", baby: "b", collection: "feedingLogs") == now)
    }

    @Test func emptyScopeIsNoOp() {
        let store = freshStore().store
        store.set(family: "", baby: "b", collection: "feedingLogs", to: Date())
        #expect(store.watermark(family: "", baby: "b", collection: "feedingLogs") == nil)
    }

    @Test func resetRecreatesABoundedCheckpoint() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let store = freshStore(now: now).store
        let d = Date(timeIntervalSince1970: 1_700_000_000)
        store.set(family: "f", baby: "b", collection: "feedingLogs", to: d)
        store.reset(family: "f", baby: "b")

        #expect(store.watermark(family: "f", baby: "b", collection: "feedingLogs") == now)
    }

    @Test func preProductionBootstrapDisablesLegacyRemoteJobs() {
        let result = freshStore()

        #expect(result.defaults.bool(forKey: "babysync_perbaby_migration_v1_done"))
        #expect(result.defaults.bool(forKey: "firestore_quicklogs_cleanup_v1_done"))
        #expect(result.defaults.bool(forKey: "babysync_deletions_watermark_reset_v1_done"))
    }
}
