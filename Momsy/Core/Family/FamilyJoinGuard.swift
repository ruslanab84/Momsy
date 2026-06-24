import Foundation

/// Joining a *different* family while the caller still has their own family data would
/// orphan that data (a separate cloud tree that does not migrate). This policy decides
/// when explicit user confirmation is required first. Pure so it is unit-tested directly.
enum FamilyJoinGuard {
    static func requiresConfirmation(
        currentFamilyId: String?,
        targetFamilyId: String,
        currentFamilyHasData: Bool,
        force: Bool
    ) -> Bool {
        guard !force else { return false }
        guard let currentFamilyId, currentFamilyId != targetFamilyId else { return false }
        return currentFamilyHasData
    }
}
