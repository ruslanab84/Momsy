import Foundation

/// Resolves the race where both parents start within the sync window: the earliest
/// open session (tie-broken by id) is canonical; each device discards only its OWN
/// later near-duplicates, so no device ever deletes the co-parent's data.
enum DuplicateOpenSessionPolicy {
    static func canonical(_ open: [SleepEntry]) -> SleepEntry? {
        open.min { ($0.startDate, $0.id.uuidString) < ($1.startDate, $1.id.uuidString) }
    }

    static func ownDiscards(
        _ open: [SleepEntry], canonical: SleepEntry,
        currentUid: String?, window: TimeInterval
    ) -> [SleepEntry] {
        open.filter {
            $0.id != canonical.id
            && !SleepSessionOwnership.isRemoteOwned(startedBy: $0.startedBy, currentUid: currentUid)
            && $0.startDate.timeIntervalSince(canonical.startDate) < window
        }
    }
}
