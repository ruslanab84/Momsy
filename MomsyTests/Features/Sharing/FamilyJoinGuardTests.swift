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
}

@Suite("StoredFamilyMember Firestore mapping")
struct StoredFamilyMemberFirestoreMappingTests {
    @Test("legacy member doc without id or role still maps into roster")
    func legacyMemberDocMaps() throws {
        let member = try #require(StoredFamilyMember(
            firestoreData: ["name": "Alex"],
            docId: "firebase-uid-1",
            currentUid: "firebase-uid-1"
        ))

        #expect(member.name == "Alex")
        #expect(member.roleRaw == FamilyRole.dad.rawValue)
        #expect(member.uid == "firebase-uid-1")
        #expect(member.isMe)
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
}
