import Foundation
import Testing
@testable import Momsy

@Suite("FamilySwitchPolicy")
struct FamilySwitchPolicyTests {

    @Test("first-ever join keeps local solo-mode data")
    func firstJoin() {
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: nil, newFamilyId: "B") == false)
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: "", newFamilyId: "B") == false)
    }

    @Test("rejoining the same family is a no-op")
    func sameFamily() {
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: "A", newFamilyId: "A") == false)
    }

    @Test("switching between two real families purges")
    func realSwitch() {
        #expect(FamilySwitchPolicy.shouldPurgeLocalData(previousFamilyId: "A", newFamilyId: "B") == true)
    }
}

@Suite("Invite cache scope")
struct InviteCacheScopeTests {

    @Test("cached invite is reusable only for its family while unexpired")
    func familyAndExpiryMustMatch() {
        let now = Date(timeIntervalSince1970: 1_000)
        let future = now.addingTimeInterval(60)

        #expect(FirestoreInviteService.canReuseCachedInvite(
            cachedFamilyId: "A", currentFamilyId: "A", expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedFamilyId: "A", currentFamilyId: "B", expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedFamilyId: "A", currentFamilyId: "A", expiry: now, now: now
        ))
    }
}
