// MomsyTests/Features/Sync/WatermarkAdvanceTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("WatermarkAdvance")
struct WatermarkAdvanceTests {
    private let epoch = Date(timeIntervalSince1970: 0)
    private let t1 = Date(timeIntervalSince1970: 1_700_000_000)
    private let t2 = Date(timeIntervalSince1970: 1_700_000_500)

    @Test func firstPullWithDataSeedsToMax() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: nil, maxObserved: t1) == t1)
    }

    @Test func firstPullEmptyFallsToEpochFloor() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: nil, maxObserved: nil) == epoch)
    }

    @Test func incrementalAdvancesForward() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: t1, maxObserved: t2) == t2)
    }

    @Test func neverMovesBackward() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: t2, maxObserved: t1) == t2)
    }

    @Test func emptyDeltaKeepsPrevious() {
        #expect(CloudSyncDownloader.advancedWatermark(previous: t1, maxObserved: nil) == t1)
    }
}
