import Foundation

/// Decides whether locally cached family data must be wiped after a join.
enum FamilySwitchPolicy {
    /// True only when moving between two different, real families. A first-ever
    /// join (no previous family) keeps local solo-mode data so it backfills into
    /// the joined family; rejoining the same family is a no-op.
    static func shouldPurgeLocalData(previousFamilyId: String?, newFamilyId: String) -> Bool {
        guard let previous = previousFamilyId, !previous.isEmpty else { return false }
        return previous != newFamilyId
    }
}
