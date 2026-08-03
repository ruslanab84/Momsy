import Foundation

/// Decides whether "delete account" may tear down *shared* health data or must be
/// scoped to the caller's own membership. Shared data may only be destroyed by the
/// last remaining PARENT — otherwise erasing it is data loss for a co-parent (and,
/// under GDPR, processing another person's data without basis), not right-to-erasure.
///
/// The gate is "last parent" rather than "last member" because only a parent role
/// satisfies `canManageFamilyRoster` in the Firestore rules, and that is what every
/// delete under `families/{id}/babies/**` requires. A departing last parent that left
/// a nanny/grandma behind would strand the child's whole log tree: the survivor can
/// never delete it, and the family doc itself is client-undeletable, so the data would
/// outlive every person entitled to erase it.
///
/// Pure and synchronous so the policy is unit-tested without Firestore.
enum AccountErasureGate {
    enum AuthoredDataAction: Equatable {
        case anonymize
        case delete
    }

    static func authoredDataAction(
        subcollection: String,
        documentData: [String: Any],
        deletingUid: String
    ) -> AuthoredDataAction? {
        guard documentData["addedBy"] as? String == deletingUid else { return nil }
        return BabySyncService.privateWellbeingSubcollections.contains(subcollection)
            ? .delete
            : .anonymize
    }

    static func authorAnonymizationUpdate(
        documentData: [String: Any],
        deletingUid: String
    ) -> [String: Any]? {
        guard documentData["addedBy"] as? String == deletingUid else { return nil }
        return ["addedBy": "", "addedByName": ""]
    }

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

    static func isParentRole(_ roleRaw: String) -> Bool {
        FamilyRole(storedRawValue: roleRaw)?.canManageFamilyMembers == true
    }

    static func mayTearDownSharedData(
        members: [(id: String, roleRaw: String)],
        callerUid: String,
        callerRoleRaw: String
    ) -> Bool {
        guard isParentRole(callerRoleRaw) else { return false }
        // `allSatisfy` on an empty roster returns true: an empty/orphaned family has
        // no co-parent to harm, so tearing it down is safe.
        return members.allSatisfy { $0.id == callerUid || !isParentRole($0.roleRaw) }
    }
}
