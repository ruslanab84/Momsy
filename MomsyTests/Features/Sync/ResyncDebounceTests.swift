import Testing
import Foundation
@testable import Momsy

@Suite("ResyncDebounce")
struct ResyncDebounceTests {

    @Test func skipsWhileSyncing() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: now.addingTimeInterval(-5), lastSyncAt: nil,
            now: now, minInterval: 8, lease: 120) == true)
    }

    @Test func skipsWithinWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: nil, lastSyncAt: now.addingTimeInterval(-3),
            now: now, minInterval: 8, lease: 120) == true)
    }

    @Test func runsAfterWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: nil, lastSyncAt: now.addingTimeInterval(-20),
            now: now, minInterval: 8, lease: 120) == false)
    }

    @Test func runsWhenNeverSynced() {
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: nil, lastSyncAt: nil,
            now: Date(), minInterval: 8, lease: 120) == false)
    }

    @Test("a sync older than the lease no longer blocks a new attempt")
    func wedgedSyncReleasesLease() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: now.addingTimeInterval(-121), lastSyncAt: nil,
            now: now, minInterval: 8, lease: 120) == false)
    }

    @Test("lease boundary is exclusive at expiry")
    func leaseBoundary() {
        let now = Date()
        #expect(CloudSyncDownloader.isSyncInFlight(
            syncStartedAt: now.addingTimeInterval(-119), now: now, lease: 120) == true)
        #expect(CloudSyncDownloader.isSyncInFlight(
            syncStartedAt: now.addingTimeInterval(-120), now: now, lease: 120) == false)
    }

    @Test("no sync started means nothing is in flight")
    func nothingInFlight() {
        #expect(CloudSyncDownloader.isSyncInFlight(
            syncStartedAt: nil, now: Date(), lease: 120) == false)
    }
}
