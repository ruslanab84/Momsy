import Foundation
import Testing
@testable import Momsy

@MainActor
private final class SpyCloudSyncDownloader: CloudSyncDownloaderProtocol {
    private(set) var sleepLiveResyncs = 0
    func downloadAndMergeWhenReady() async {}
    func resyncActiveBaby() async {}
    func resyncAll() async {}
    func forceResyncAll() async {}
    func resyncSleepLive() async { sleepLiveResyncs += 1 }
}

@MainActor
struct SleepLiveSyncServiceTests {

    @Test func startDoesNotIssueAnUnconditionalDeltaQuery() async throws {
        let spy = SpyCloudSyncDownloader()
        let service = SleepLiveSyncService(
            downloader: spy,
            streamFactory: { AsyncStream { $0.finish() } }
        )

        service.start()
        try await Task.sleep(for: .milliseconds(50))
        service.stop()

        #expect(spy.sleepLiveResyncs == 0)
    }

    @Test func liveDocumentSignalRunsOneTargetedSleepMerge() async throws {
        let spy = SpyCloudSyncDownloader()
        let service = SleepLiveSyncService(
            downloader: spy,
            streamFactory: {
                AsyncStream { continuation in
                    continuation.yield(())
                    continuation.finish()
                }
            }
        )

        service.start()
        for _ in 0..<100 where spy.sleepLiveResyncs == 0 {
            try await Task.sleep(for: .milliseconds(10))
        }
        service.stop()

        #expect(spy.sleepLiveResyncs == 1)
    }
}
