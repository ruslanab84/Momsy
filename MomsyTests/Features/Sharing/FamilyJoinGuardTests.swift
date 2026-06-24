import Testing
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
}
