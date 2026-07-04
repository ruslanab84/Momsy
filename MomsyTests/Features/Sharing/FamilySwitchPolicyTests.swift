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
