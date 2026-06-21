import Foundation

/// The single source of truth for "which child is currently active".
///
/// The active baby id is persisted as a UUID string under `kBabyIdDefaultsKey`
/// (the same key `BabySyncService` reads to resolve cloud paths), so switching the
/// active child automatically retargets cloud sync. Local repositories read
/// `ActiveBaby.currentId` at query time to scope SwiftData fetches to one child,
/// mirroring the lazy UserDefaults-read pattern used elsewhere for actor-free access.
enum ActiveBaby {
    /// Sentinel babyId for records created before multi-child support existed, or
    /// before any child is selected. `BabyLogBackfill` rewrites these to child #1.
    static let unassigned = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    /// Maximum number of children per family.
    static let maxChildren = 5

    /// Task-scoped target for a background roster sync. Bound (via `withValue`) only
    /// for the span of one child's sync inside `CloudSyncDownloader.downloadAllBabies`,
    /// so the sync can retarget the cloud path and local scope per child WITHOUT moving
    /// the user's persisted selection. A concurrent user write runs in a separate task
    /// tree, never inherits this binding, and so always reads the real active child —
    /// closing the window where a foreground resync could misattribute a new log.
    @TaskLocal static var syncTargetOverride: UUID?

    static var currentId: UUID? {
        get {
            if let override = syncTargetOverride { return override }
            return UserDefaults.standard.string(forKey: kBabyIdDefaultsKey).flatMap(UUID.init)
        }
        set {
            if let id = newValue {
                UserDefaults.standard.set(id.uuidString, forKey: kBabyIdDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: kBabyIdDefaultsKey)
            }
        }
    }

    /// The babyId to scope a local fetch/insert by: the active child, or the
    /// `unassigned` sentinel when no child is selected yet.
    static var scope: UUID { currentId ?? unassigned }
}
