import Foundation

/// Decides whether "delete account" may tear down *shared* family data (every
/// child's cloud log tree + the family document) or must be scoped to the caller's
/// own membership. Shared data may only be destroyed when the caller is the last
/// remaining member — otherwise erasing it is data loss for a co-parent (and, under
/// GDPR, processing another person's data without basis), not right-to-erasure.
///
/// Pure and synchronous so the policy is unit-tested without Firestore.
enum AccountErasureGate {
    static func mayTearDownSharedData(memberIds: [String], callerUid: String) -> Bool {
        // `allSatisfy` on an empty roster returns true: an empty/orphaned family has
        // no co-parent to harm, so tearing it down is safe.
        memberIds.allSatisfy { $0 == callerUid }
    }
}
