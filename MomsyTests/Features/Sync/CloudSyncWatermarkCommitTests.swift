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

    @Test("a full page continues pagination")
    func fullPageContinuesPagination() {
        #expect(BabySyncService.shouldContinuePaginating(pageCount: 500, pageSize: 500))
        #expect(!BabySyncService.shouldContinuePaginating(pageCount: 499, pageSize: 500))
    }

    @Test("private wellbeing mapping preserves the owner")
    func wellbeingMappingPreservesOwner() throws {
        let sleepId = UUID()
        var sleepDTO = SleepLogDTO(from: SleepLog(
            id: sleepId.uuidString,
            startedAt: Date(),
            endedAt: Date().addingTimeInterval(3_600),
            durationMin: 60,
            quality: .good,
            addedBy: "mom-uid",
            addedByName: "Mom"
        ))
        sleepDTO.id = sleepId.uuidString

        let waterId = UUID()
        var waterDTO = WaterIntakeLogDTO(from: WaterIntakeLog(
            id: waterId.uuidString,
            date: Date(),
            amountMl: 250,
            addedBy: "mom-uid",
            addedByName: "Mom"
        ))
        waterDTO.id = waterId.uuidString

        let sleep = try #require(CloudSyncDownloader.momSleepEntry(sleepDTO))
        let water = try #require(CloudSyncDownloader.waterIntakeEntry(waterDTO))
        #expect(sleep.startedBy == "mom-uid")
        #expect(sleep.startedByName == "Mom")
        #expect(water.ownerUID == "mom-uid")
        #expect(water.ownerName == "Mom")
    }
}
