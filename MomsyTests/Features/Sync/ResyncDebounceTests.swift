import Testing
import Foundation
@testable import Momsy

@Suite("ResyncDebounce")
struct ResyncDebounceTests {

    @Test func skipsWhileSyncing() {
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: true, lastSyncAt: nil, now: Date(), minInterval: 8) == true)
    }

    @Test func skipsWithinWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: false, lastSyncAt: now.addingTimeInterval(-3), now: now, minInterval: 8) == true)
    }

    @Test func runsAfterWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: false, lastSyncAt: now.addingTimeInterval(-20), now: now, minInterval: 8) == false)
    }

    @Test func runsWhenNeverSynced() {
        #expect(CloudSyncDownloader.shouldSkipResync(
            isSyncing: false, lastSyncAt: nil, now: Date(), minInterval: 8) == false)
    }
}
