import Testing
@testable import Momsy

@Suite("AccountErasureGate")
struct AccountErasureGateTests {
    @Test("anonymizes only the deleting account's author metadata")
    func authorAnonymization() {
        let ownUpdate = AccountErasureGate.authorAnonymizationUpdate(
            documentData: ["addedBy": "me", "addedByName": "Mom", "amount": 120],
            deletingUid: "me"
        )

        #expect(ownUpdate?["addedBy"] as? String == "")
        #expect(ownUpdate?["addedByName"] as? String == "")
        #expect(ownUpdate?.count == 2)
        #expect(AccountErasureGate.authorAnonymizationUpdate(
            documentData: ["addedBy": "partner", "addedByName": "Dad"],
            deletingUid: "me"
        ) == nil)
    }

    @Test("deletes private wellbeing but anonymizes shared authored logs")
    func privateWellbeingDeletionPolicy() {
        let own = ["addedBy": "me", "addedByName": "Mom"]

        #expect(AccountErasureGate.authoredDataAction(
            subcollection: "momSleepLogs",
            documentData: own,
            deletingUid: "me"
        ) == .delete)
        #expect(AccountErasureGate.authoredDataAction(
            subcollection: "waterIntakeLogs",
            documentData: own,
            deletingUid: "me"
        ) == .delete)
        #expect(AccountErasureGate.authoredDataAction(
            subcollection: "sleepLogs",
            documentData: own,
            deletingUid: "me"
        ) == .anonymize)
        #expect(AccountErasureGate.authoredDataAction(
            subcollection: "momSleepLogs",
            documentData: ["addedBy": "partner"],
            deletingUid: "me"
        ) == nil)
    }

    @Test("sole member may tear down shared data")
    func soleMember() {
        #expect(AccountErasureGate.mayTearDownSharedData(
            members: [(id: "me", roleRaw: FamilyRole.mom.rawValue)],
            callerUid: "me",
            callerRoleRaw: FamilyRole.mom.rawValue
        ))
    }
    @Test("member with a co-parent may NOT tear down shared data")
    func withCoParent() {
        #expect(!AccountErasureGate.mayTearDownSharedData(
            members: [
                (id: "me", roleRaw: FamilyRole.mom.rawValue),
                (id: "partner", roleRaw: FamilyRole.dad.rawValue)
            ],
            callerUid: "me",
            callerRoleRaw: FamilyRole.mom.rawValue
        ))
    }

    @Test("empty roster treated as sole — nobody else to harm")
    func emptyRoster() {
        #expect(AccountErasureGate.mayTearDownSharedData(
            members: [],
            callerUid: "me",
            callerRoleRaw: FamilyRole.mom.rawValue
        ))
    }
    @Test("roster of only other parents may NOT tear down")
    func othersOnly() {
        #expect(!AccountErasureGate.mayTearDownSharedData(
            members: [
                (id: "a", roleRaw: FamilyRole.mom.rawValue),
                (id: "b", roleRaw: FamilyRole.dad.rawValue)
            ],
            callerUid: "me",
            callerRoleRaw: FamilyRole.mom.rawValue
        ))
    }
    @Test("caller plus other parents may NOT tear down")
    func callerPlusOthers() {
        #expect(!AccountErasureGate.mayTearDownSharedData(
            members: [
                (id: "me", roleRaw: FamilyRole.mom.rawValue),
                (id: "a", roleRaw: FamilyRole.dad.rawValue),
                (id: "b", roleRaw: FamilyRole.mom.rawValue)
            ],
            callerUid: "me",
            callerRoleRaw: FamilyRole.mom.rawValue
        ))
    }

    @Test("last parent MAY tear down even with restricted members left behind")
    func lastParentWithRestrictedSurvivors() {
        // A nanny/grandma survivor can never delete the baby tree (rules demand a
        // parent role) and the family doc is client-undeletable, so leaving the data
        // behind would strand it permanently.
        #expect(AccountErasureGate.mayTearDownSharedData(
            members: [
                (id: "me", roleRaw: FamilyRole.mom.rawValue),
                (id: "nanny", roleRaw: FamilyRole.nanny.rawValue),
                (id: "grandma", roleRaw: FamilyRole.grandma.rawValue)
            ],
            callerUid: "me",
            callerRoleRaw: FamilyRole.mom.rawValue
        ))
    }

    @Test("an unrecognized member role is never treated as a surviving parent")
    func unknownSurvivorRole() {
        #expect(AccountErasureGate.mayTearDownSharedData(
            members: [
                (id: "me", roleRaw: FamilyRole.dad.rawValue),
                (id: "legacy", roleRaw: "")
            ],
            callerUid: "me",
            callerRoleRaw: FamilyRole.dad.rawValue
        ))
    }

    @Test("recognizes only the legacy Add to team placeholder shape")
    func legacyPlaceholderClassification() {
        let documentId = "9517DE8C-7EE9-4D88-962B-8D609F48CB48"
        let placeholder: [String: Any] = [
            "id": documentId,
            "name": "Invited parent",
            "roleRaw": FamilyRole.dad.rawValue,
            "isMe": false
        ]

        #expect(AccountErasureGate.isLegacyPlaceholder(
            documentId: documentId,
            data: placeholder
        ))
        #expect(AccountErasureGate.isLegacyPlaceholder(
            documentId: documentId,
            data: placeholder.merging(["uid": documentId]) { _, new in new }
        ))
        #expect(!AccountErasureGate.isLegacyPlaceholder(
            documentId: documentId,
            data: placeholder.merging(["joinedAt": true]) { _, new in new }
        ))
        #expect(!AccountErasureGate.isLegacyPlaceholder(
            documentId: "real-auth-uid",
            data: ["name": "Parent", "roleRaw": FamilyRole.mom.rawValue]
        ))

        let soleMember = AccountErasureGate.partitionMemberDocuments([
            (id: "me", data: ["uid": "me"]),
            (id: documentId, data: placeholder)
        ])
        #expect(soleMember.realIds == ["me"])
        #expect(soleMember.placeholderIds == [documentId])

        let sharedFamily = AccountErasureGate.partitionMemberDocuments([
            (id: "me", data: ["uid": "me"]),
            (id: "partner", data: ["uid": "partner"])
        ])
        #expect(sharedFamily.realIds == ["me", "partner"])
        #expect(sharedFamily.placeholderIds.isEmpty)
    }

    @Test("sole parent may tear down shared data")
    func soleParent() {
        #expect(AccountErasureGate.mayTearDownSharedData(
            members: [(id: "me", roleRaw: FamilyRole.dad.rawValue)],
            callerUid: "me",
            callerRoleRaw: FamilyRole.dad.rawValue
        ))
    }

    @Test("sole restricted member may only remove their membership")
    func soleRestrictedMember() {
        #expect(!AccountErasureGate.mayTearDownSharedData(
            members: [(id: "me", roleRaw: FamilyRole.nanny.rawValue)],
            callerUid: "me",
            callerRoleRaw: FamilyRole.nanny.rawValue
        ))
        #expect(!AccountErasureGate.mayTearDownSharedData(
            members: [(id: "me", roleRaw: FamilyRole.grandma.rawValue)],
            callerUid: "me",
            callerRoleRaw: FamilyRole.grandma.rawValue
        ))
    }

    @Test("last parent may tear down shared data even with a nanny left in the roster")
    func lastParentWithNannyMayTearDown() {
        #expect(AccountErasureGate.mayTearDownSharedData(
            members: [(id: "p1", roleRaw: "Мама"), (id: "n1", roleRaw: "Няня")],
            callerUid: "p1", callerRoleRaw: "Мама"))
    }

    @Test("a co-parent in the roster blocks tearing down shared data")
    func coParentBlocksTearDown() {
        #expect(AccountErasureGate.mayTearDownSharedData(
            members: [(id: "p1", roleRaw: "Мама"), (id: "p2", roleRaw: "Папа")],
            callerUid: "p1", callerRoleRaw: "Мама") == false)
    }
}
