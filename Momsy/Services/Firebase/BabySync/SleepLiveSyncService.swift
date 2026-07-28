import Foundation

/// Foreground-only realtime trigger for co-parent sleep updates. It listens to the active
/// baby's single `liveSleep` state on the baby document, never to the `sleepLogs` history
/// collection. Each remote Start/Stop runs the existing targeted delta merge so SwiftData
/// remains the source of truth for the UI.
@MainActor
final class SleepLiveSyncService {
    private let downloader: any CloudSyncDownloaderProtocol
    private let streamFactory: () -> AsyncStream<Void>
    private var streamTask: Task<Void, Never>?

    init(
        downloader: any CloudSyncDownloaderProtocol,
        streamFactory: @escaping () -> AsyncStream<Void> = {
            BabySyncService().streamSleepLiveUpdates()
        }
    ) {
        self.downloader = downloader
        self.streamFactory = streamFactory
    }

    func start() {
        stop()
        streamTask = Task { [weak self] in
            guard let self else { return }
            // The document listener's initial snapshot is the catch-up signal. Unlike the
            // old implementation, start() does not issue an unconditional Firestore query.
            let stream = streamFactory()
            for await _ in stream {
                guard !Task.isCancelled else { return }
                // Coalesce a rapid metadata/state pair or two near-simultaneous writes.
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled else { return }
                await downloader.resyncSleepLive()
            }
        }
    }

    func stop() {
        streamTask?.cancel()
        streamTask = nil
    }

    func restart() { start() }
}
