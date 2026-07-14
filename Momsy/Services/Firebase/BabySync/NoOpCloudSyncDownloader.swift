import Foundation

final class NoOpCloudSyncDownloader: CloudSyncDownloaderProtocol {
    func downloadAndMergeWhenReady() async { }
    func resyncActiveBaby() async { }
    func resyncAll() async { }
    func forceResyncAll() async { }
    func resyncSleepLive() async { }
}
