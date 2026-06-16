import Foundation

/// What a cloud → local merge should do with a single incoming record, decided
/// purely from timestamps so the logic is testable in isolation.
enum MergeDecision: Equatable {
    case insert   // not present locally → add it
    case update   // present locally and the incoming copy is newer → overwrite
    case skip     // present locally and not newer → leave the local copy
}

/// Last-write-wins reconciliation for cross-device sync.
///
/// `updatedAt` is stamped on every local mutation and carried through Firestore,
/// so the device that made a change sees an equal timestamp on the round-trip and
/// the merge is a no-op for it. A missing timestamp (legacy row or legacy cloud
/// doc, both predating this field) is treated as `.distantPast`, so the comparison
/// is non-destructive on ties: only a strictly newer cloud write overwrites local.
enum SyncMerge {
    static func decide(localExists: Bool,
                       localUpdatedAt: Date?,
                       incomingUpdatedAt: Date?) -> MergeDecision {
        guard localExists else { return .insert }
        let local = localUpdatedAt ?? .distantPast
        let incoming = incomingUpdatedAt ?? .distantPast
        return incoming > local ? .update : .skip
    }
}
