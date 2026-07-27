import Testing
import Foundation
@testable import Momsy

@Suite("TombstoneWatermark")
struct TombstoneWatermarkTests {
    private let epoch = Date(timeIntervalSince1970: 0)
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("a normal batch advances to its newest tombstone")
    func advancesToMax() {
        let observed = [now.addingTimeInterval(-300), now.addingTimeInterval(-60)]
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: now.addingTimeInterval(-600), observed: observed,
            now: now, tolerance: 300) == now.addingTimeInterval(-60))
    }

    @Test("a tombstone stamped far in the future cannot poison the watermark")
    func clampsFutureOutlier() {
        let sane = now.addingTimeInterval(-60)
        let poisoned = now.addingTimeInterval(3_600)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: nil, observed: [sane, poisoned],
            now: now, tolerance: 300) == sane)
    }

    @Test("a batch of only future outliers keeps the previous watermark")
    func allOutliersKeepPrevious() {
        let previous = now.addingTimeInterval(-600)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: previous, observed: [now.addingTimeInterval(7_200)],
            now: now, tolerance: 300) == previous)
    }

    @Test("a timestamp inside the tolerance window is accepted")
    func toleranceAcceptsSmallSkew() {
        let slightlyAhead = now.addingTimeInterval(120)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: nil, observed: [slightlyAhead],
            now: now, tolerance: 300) == slightlyAhead)
    }

    @Test("the watermark never moves backward")
    func neverMovesBackward() {
        let previous = now.addingTimeInterval(-60)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: previous, observed: [now.addingTimeInterval(-600)],
            now: now, tolerance: 300) == previous)
    }

    @Test("an empty batch keeps the previous watermark")
    func emptyKeepsPrevious() {
        let previous = now.addingTimeInterval(-60)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: previous, observed: [], now: now, tolerance: 300) == previous)
    }

    @Test("an empty first pull falls back to the epoch floor")
    func emptyFirstPullFallsToEpoch() {
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: nil, observed: [], now: now, tolerance: 300) == epoch)
    }
}
