import Foundation
import Testing
@testable import Momsy

@MainActor
private final class SpyCloudSyncDownloader: CloudSyncDownloaderProtocol {
    private let onSleepLiveResync: @MainActor () -> Void
    private(set) var sleepLiveResyncs = 0

    init(onSleepLiveResync: @MainActor @escaping () -> Void = {}) {
        self.onSleepLiveResync = onSleepLiveResync
    }

    func downloadAndMergeWhenReady() async {}
    func resyncActiveBaby() async {}
    func resyncAll() async {}
    func forceResyncAll() async {}
    func resyncSleepLive() async {
        sleepLiveResyncs += 1
        onSleepLiveResync()
    }
}

@MainActor
struct SleepLiveSyncServiceTests {

    /// A sleep started by a co-parent while this device was backgrounded is invisible
    /// to the realtime listener (it only sees writes newer than attach time) and to
    /// the foreground `resyncAll` (debounced 5 min). `start()` must therefore run one
    /// catch-up delta merge so the open session appears immediately on foreground.
    @Test func startRunsCatchUpDeltaMerge() async throws {
        let spy = SpyCloudSyncDownloader()
        let service = SleepLiveSyncService(downloader: spy)
        service.start()
        for _ in 0..<100 where spy.sleepLiveResyncs == 0 {
            try await Task.sleep(for: .milliseconds(10))
        }
        service.stop()
        #expect(spy.sleepLiveResyncs == 1)
    }

    @Test("attaches the listener before catch-up can suspend")
    func listenerAttachesBeforeCatchUp() async throws {
        var events: [String] = []
        let spy = SpyCloudSyncDownloader { events.append("catch-up") }
        let service = SleepLiveSyncService(
            downloader: spy,
            stream: { _ in
                events.append("listener")
                return AsyncStream { _ in }
            }
        )

        service.start()
        for _ in 0..<100 where spy.sleepLiveResyncs == 0 {
            try await Task.sleep(for: .milliseconds(10))
        }
        service.stop()

        #expect(events == ["listener", "catch-up"])
    }
}
