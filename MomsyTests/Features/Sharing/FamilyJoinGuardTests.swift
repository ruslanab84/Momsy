import Testing
import Foundation
@testable import Momsy

@Suite("FamilyJoinGuard")
struct FamilyJoinGuardTests {
    @Test("no current family → no confirmation")
    func noFamily() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: nil, targetFamilyId: "F2", currentFamilyHasData: true, force: false))
    }
    @Test("re-joining the same family → no confirmation")
    func sameFamily() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F1", currentFamilyHasData: true, force: false))
    }
    @Test("different family with existing data, not forced → confirmation")
    func differentWithData() {
        #expect(FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F2", currentFamilyHasData: true, force: false))
    }
    @Test("forced bypasses the guard")
    func forced() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F2", currentFamilyHasData: true, force: true))
    }
    @Test("different family but no existing data → no confirmation")
    func differentNoData() {
        #expect(!FamilyJoinGuard.requiresConfirmation(currentFamilyId: "F1", targetFamilyId: "F2", currentFamilyHasData: false, force: false))
    }

    @Test("family cache is stale when owner uid differs")
    func staleFamilyCacheWhenOwnerUidDiffers() {
        #expect(!FamilyManager.cacheIsStale(cachedOwnerUid: nil, currentUid: "provider"))
        #expect(!FamilyManager.cacheIsStale(cachedOwnerUid: "provider", currentUid: "provider"))
        #expect(FamilyManager.cacheIsStale(cachedOwnerUid: "anonymous", currentUid: "provider"))
    }

    @Test("legacy roles preserve the pre-role full-access contract")
    func legacyRoleRepairPolicy() {
        #expect(FamilyManager.legacyRepairRole(isFamilyCreator: true) == .mom)
        #expect(FamilyManager.legacyRepairRole(isFamilyCreator: false) == .dad)
    }
}

@Suite("StoredFamilyMember Firestore mapping")
struct StoredFamilyMemberFirestoreMappingTests {
    @Test("member doc without id uses stable id when role is valid")
    func memberDocWithoutIdMaps() throws {
        let member = try #require(StoredFamilyMember(
            firestoreData: ["name": "Alex", "roleRaw": FamilyRole.dad.rawValue],
            docId: "firebase-uid-1",
            currentUid: "firebase-uid-1"
        ))

        #expect(member.name == "Alex")
        #expect(member.roleRaw == FamilyRole.dad.rawValue)
        #expect(member.uid == "firebase-uid-1")
        #expect(member.isMe)
    }

    @Test("missing or invalid role fails closed")
    func invalidRoleDoesNotMap() {
        #expect(StoredFamilyMember(
            firestoreData: ["name": "Alex"],
            docId: "firebase-uid-1"
        ) == nil)
        #expect(StoredFamilyMember(
            firestoreData: ["name": "Alex", "roleRaw": "owner"],
            docId: "firebase-uid-1"
        ) == nil)
    }

    @Test("current uid overrides persisted isMe flag")
    func currentUidControlsIsMe() throws {
        let member = try #require(StoredFamilyMember(
            firestoreData: [
                "id": UUID().uuidString,
                "name": "Parent",
                "roleRaw": FamilyRole.mom.rawValue,
                "uid": "other-uid",
                "isMe": true
            ],
            docId: "other-uid",
            currentUid: "current-uid"
        ))

        #expect(!member.isMe)
    }

    @Test("legacy Add to team placeholder does not map as a real member")
    func legacyPlaceholderDoesNotMap() {
        let documentId = "9517DE8C-7EE9-4D88-962B-8D609F48CB48"

        #expect(StoredFamilyMember(
            firestoreData: [
                "id": documentId,
                "name": "Invited parent",
                "roleRaw": FamilyRole.dad.rawValue,
                "isMe": false
            ],
            docId: documentId
        ) == nil)
    }
}

@Suite("Family role avatars")
struct FamilyRoleAvatarTests {
    @Test("every family role uses its matching person avatar")
    func roleAvatarMapping() {
        #expect(FamilyRole.mom.defaultBlob == .mom)
        #expect(FamilyRole.dad.defaultBlob == .dad)
        #expect(FamilyRole.nanny.defaultBlob == .nanny)
        #expect(FamilyRole.grandma.defaultBlob == .grandma)

        var member = FamilyMember(name: "Alex", role: .mom, isMe: true)
        member.role = .grandma
        #expect(member.blob == .grandma)
    }
}

@Suite("FamilyAccessPolicy")
struct FamilyAccessPolicyTests {
    @Test("roles have the exact Firestore capability matrix")
    func roleMatrix() {
        let all = Set(FamilyAccessCapability.allCases)

        #expect(allowed(for: .mom) == all)
        #expect(allowed(for: .dad) == all)
        #expect(allowed(for: .nanny) == [.viewBabyStatus, .writeRoutineTracking])
        #expect(allowed(for: .grandma) == [.viewBabyStatus])
    }

    @Test("missing role fails closed")
    func missingRole() {
        #expect(allowed(for: nil).isEmpty)
    }

    @Test("only parents can create a family")
    func familyCreation() {
        #expect(FamilyRole.mom.canCreateFamily)
        #expect(FamilyRole.dad.canCreateFamily)
        #expect(!FamilyRole.nanny.canCreateFamily)
        #expect(!FamilyRole.grandma.canCreateFamily)
    }

    private func allowed(for role: FamilyRole?) -> Set<FamilyAccessCapability> {
        Set(FamilyAccessCapability.allCases.filter {
            FamilyAccessPolicy.allows($0, for: role)
        })
    }
}
