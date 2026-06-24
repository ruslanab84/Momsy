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
}
