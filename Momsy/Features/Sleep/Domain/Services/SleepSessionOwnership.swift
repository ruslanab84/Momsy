import Foundation

/// Ownership and lifecycle policy for open sleep sessions shared across devices.
/// Pure so it is unit-tested directly (see StaleSessionReconciler / FamilyJoinGuard).
enum SleepSessionOwnership {
    static func isRemoteOwned(startedBy: String?, currentUid: String?) -> Bool {
        guard let startedBy, !startedBy.isEmpty else { return false }
        guard let currentUid, !currentUid.isEmpty else { return true }
        return startedBy != currentUid
    }

    /// A co-parent's open session is mirrored while plausible; an implausibly old one
    /// is left alone — only the owning device has the signals to reconcile it.
    static func shouldMirrorRemoteOpen(start: Date, now: Date, maxDuration: TimeInterval) -> Bool {
        now.timeIntervalSince(start) < maxDuration
    }
}
