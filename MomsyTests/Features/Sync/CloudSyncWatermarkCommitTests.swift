// MomsyTests/Features/Sync/CloudSyncWatermarkCommitTests.swift
import Testing
import Foundation
@testable import Momsy

@Suite("CloudSyncDownloader watermark commit")
struct CloudSyncWatermarkCommitTests {

    @Test("failed fetch never commits — even the epoch floor on a first pull")
    func failedFetchCommitsNothing() {
        let floor = CloudSyncDownloader.advancedWatermark(previous: nil, maxObserved: nil)
        #expect(CloudSyncDownloader.watermarkAfterFetch(fetchSucceeded: false, next: floor) == nil)
    }

    @Test("successful fetch commits the advanced watermark")
    func successCommitsNext() {
        let prev = Date(timeIntervalSince1970: 1_000)
        let seen = Date(timeIntervalSince1970: 2_000)
        let next = CloudSyncDownloader.advancedWatermark(previous: prev, maxObserved: seen)
        #expect(CloudSyncDownloader.watermarkAfterFetch(fetchSucceeded: true, next: next) == seen)
    }

    @Test("successful empty delta re-commits the previous watermark, not the floor")
    func emptyDeltaKeepsPrevious() {
        let prev = Date(timeIntervalSince1970: 5_000)
        let next = CloudSyncDownloader.advancedWatermark(previous: prev, maxObserved: nil)
        #expect(CloudSyncDownloader.watermarkAfterFetch(fetchSucceeded: true, next: next) == prev)
    }
}
