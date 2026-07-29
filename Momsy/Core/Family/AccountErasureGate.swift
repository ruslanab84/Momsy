import Foundation

/// Decides whether "delete account" may tear down *shared* family data (every
/// child's cloud log tree + the family document) or must be scoped to the caller's
/// own membership. Shared data may only be destroyed when the caller is the last
/// remaining member — otherwise erasing it is data loss for a co-parent (and, under
/// GDPR, processing another person's data without basis), not right-to-erasure.
///
/// Pure and synchronous so the policy is unit-tested without Firestore.
enum AccountErasureGate {
    static func isLegacyPlaceholder(documentId: String, data: [String: Any]) -> Bool {
        guard
            UUID(uuidString: documentId) != nil,
            data["id"] as? String == documentId,
            (data["uid"] as? String).map({ $0 == documentId }) ?? true,
            data["joinedAt"] == nil,
            data["inviteCode"] == nil
        else { return false }
        return data["isMe"] as? Bool != true
    }

    static func partitionMemberDocuments(
        _ documents: [(id: String, data: [String: Any])]
    ) -> (realIds: [String], placeholderIds: [String]) {
        var realIds: [String] = []
        var placeholderIds: [String] = []
        for document in documents {
            if isLegacyPlaceholder(documentId: document.id, data: document.data) {
                placeholderIds.append(document.id)
            } else {
                realIds.append(document.id)
            }
        }
        return (realIds, placeholderIds)
    }

    static func mayTearDownSharedData(memberIds: [String], callerUid: String) -> Bool {
        // `allSatisfy` on an empty roster returns true: an empty/orphaned family has
        // no co-parent to harm, so tearing it down is safe.
        memberIds.allSatisfy { $0 == callerUid }
    }

    static func mayTearDownSharedData(
        memberIds: [String],
        callerUid: String,
        callerRoleRaw: String
    ) -> Bool {
        guard FamilyRole(storedRawValue: callerRoleRaw)?.canManageFamilyMembers == true else {
            return false
        }
        return mayTearDownSharedData(memberIds: memberIds, callerUid: callerUid)
    }
}
