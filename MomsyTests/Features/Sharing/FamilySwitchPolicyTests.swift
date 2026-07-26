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
        let strong = "MOMSY-A2B3-C4D5-E6F7"

        #expect(FirestoreInviteService.canReuseCachedInvite(
            cachedCode: strong, cachedFamilyId: "A", currentFamilyId: "A", expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: strong, cachedFamilyId: "A", currentFamilyId: "B", expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: strong, cachedFamilyId: "A", currentFamilyId: "A", expiry: now, now: now
        ))
    }

    @Test("a cached legacy-format code is never reused")
    func legacyCachedCodeForcesRegeneration() {
        let now = Date(timeIntervalSince1970: 1_000)
        let future = now.addingTimeInterval(60)

        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: "MOMSY-ABC234", cachedFamilyId: "A", currentFamilyId: "A",
            expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: nil, cachedFamilyId: "A", currentFamilyId: "A",
            expiry: future, now: now
        ))
    }
}
