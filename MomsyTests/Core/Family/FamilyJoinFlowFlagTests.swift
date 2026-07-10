import Testing
@testable import Momsy

@MainActor
struct FamilyJoinFlowFlagTests {
    @Test func flagTogglesAroundJoinFlow() {
        let manager = FamilyManager.shared
        manager.beginJoinFlow()
        #expect(manager.joinInFlight)
        manager.endJoinFlow()
        #expect(!manager.joinInFlight)
    }
}
