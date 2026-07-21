import Testing
@testable import Momsy

struct FamilySuppressedRestoreTests {
    @Test func inviteMembershipIsAdoptedNotDeleted() {
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: true, memberHasInviteCode: true
        ) == .adoptInviteMembership)
    }

    @Test func preDeletionMembershipIsDiscarded() {
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: true, memberHasInviteCode: false
        ) == .discardStaleMembership)
    }

    @Test func missingMemberDocStartsFresh() {
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: false, memberHasInviteCode: true
        ) == .startFresh)
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: false, memberHasInviteCode: false
        ) == .startFresh)
    }
}
