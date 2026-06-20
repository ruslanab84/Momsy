import Foundation

/// Downloads cloud (Firestore) logs and merges them into local SwiftData on launch,
/// so Today So Far and Diary reflect data created on other devices / family members
/// / before a reinstall.
protocol CloudSyncDownloaderProtocol {
    /// Waits (briefly) for the family to be ready, then runs the merge once per session.
    func downloadAndMergeWhenReady() async
    /// Re-pulls the now-active child's logs after switching the active baby.
    func resyncActiveBaby() async
    /// Re-pulls every child in the roster (foreground / post-join). Debounced.
    func resyncAll() async
}
