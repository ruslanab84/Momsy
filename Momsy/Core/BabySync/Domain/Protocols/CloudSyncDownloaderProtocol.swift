import Foundation

/// Downloads cloud (Firestore) logs and merges them into local SwiftData on launch,
/// so Today So Far and Diary reflect data created on other devices / family members
/// / before a reinstall.
protocol CloudSyncDownloaderProtocol {
    /// Waits (briefly) for the family to be ready, then runs the merge once per session.
    func downloadAndMergeWhenReady() async
    /// Re-pulls the now-active child's logs after switching the active baby.
    func resyncActiveBaby() async
    /// Re-pulls every child in the roster on foreground. Debounced; only after launch.
    func resyncAll() async
    /// Re-pulls every child after joining a family. Bypasses the time-debounce.
    func forceResyncAll() async
    /// Targeted merge of the active baby's `sleepLogs` delta for the live sleep
    /// trigger. NOT time-debounced: the snapshot fires once per co-parent server
    /// write with no retry, so a debounce-skipped event would be lost until the
    /// next foreground sync. One incremental (watermark-scoped) query per event.
    func resyncSleepLive() async
}
