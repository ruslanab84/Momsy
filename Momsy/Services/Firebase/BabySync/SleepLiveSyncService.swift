import Foundation

/// Foreground-only realtime trigger for co-parent sleep updates. Listens to the active
/// baby's `sleepLogs` for server writes newer than attach time and runs the watermark
/// downloader, which merges and posts `.cloudSyncDidMerge` for the UI. Costs ~0 reads
/// at attach (the query starts empty) and one snapshot per co-parent write.
@MainActor
final class SleepLiveSyncService {
    private let downloader: any CloudSyncDownloaderProtocol
    private var streamTask: Task<Void, Never>?

    init(downloader: any CloudSyncDownloaderProtocol) { self.downloader = downloader }

    func start() {
        stop()
        streamTask = Task { [weak self] in
            let stream = BabySyncService().streamLogUpdates(from: "sleepLogs", since: Date())
            for await _ in stream {
                guard !Task.isCancelled, let self else { return }
                try? await Task.sleep(for: .milliseconds(300))
                await self.downloader.resyncAll()
            }
        }
    }

    func stop() {
        streamTask?.cancel()
        streamTask = nil
    }

    func restart() { start() }
}
