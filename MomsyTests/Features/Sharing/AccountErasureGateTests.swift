import Testing
@testable import Momsy

@Suite("AccountErasureGate")
struct AccountErasureGateTests {
    @Test("sole member may tear down shared data")
    func soleMember() {
        #expect(AccountErasureGate.mayTearDownSharedData(memberIds: ["me"], callerUid: "me"))
    }
    @Test("member with a co-parent may NOT tear down shared data")
    func withCoParent() {
        #expect(!AccountErasureGate.mayTearDownSharedData(memberIds: ["me", "partner"], callerUid: "me"))
    }

    @Test("empty roster treated as sole — nobody else to harm")
    func emptyRoster() {
        #expect(AccountErasureGate.mayTearDownSharedData(memberIds: [], callerUid: "me"))
    }
    @Test("roster of only other members may NOT tear down")
    func othersOnly() {
        #expect(!AccountErasureGate.mayTearDownSharedData(memberIds: ["a", "b"], callerUid: "me"))
    }
    @Test("caller plus others may NOT tear down")
    func callerPlusOthers() {
        #expect(!AccountErasureGate.mayTearDownSharedData(memberIds: ["me", "a", "b"], callerUid: "me"))
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
        #expect(AccountErasureGate.mayTearDownSharedData(
            memberIds: soleMember.realIds,
            callerUid: "me"
        ))

        let sharedFamily = AccountErasureGate.partitionMemberDocuments([
            (id: "me", data: ["uid": "me"]),
            (id: "partner", data: ["uid": "partner"])
        ])
        #expect(!AccountErasureGate.mayTearDownSharedData(
            memberIds: sharedFamily.realIds,
            callerUid: "me"
        ))
    }

    @Test("sole parent may tear down shared data")
    func soleParent() {
        #expect(AccountErasureGate.mayTearDownSharedData(
            memberIds: ["me"],
            callerUid: "me",
            callerRoleRaw: FamilyRole.dad.rawValue
        ))
    }

    @Test("sole restricted member may only remove their membership")
    func soleRestrictedMember() {
        #expect(!AccountErasureGate.mayTearDownSharedData(
            memberIds: ["me"],
            callerUid: "me",
            callerRoleRaw: FamilyRole.nanny.rawValue
        ))
        #expect(!AccountErasureGate.mayTearDownSharedData(
            memberIds: ["me"],
            callerUid: "me",
            callerRoleRaw: FamilyRole.grandma.rawValue
        ))
    }
}
