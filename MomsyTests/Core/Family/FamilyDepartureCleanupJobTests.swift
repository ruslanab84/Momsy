import Testing
@testable import Momsy

struct FamilyDepartureCleanupJobTests {
    @Test("account deletion uses the trusted cleanup kind")
    func accountDeletionKind() {
        #expect(FamilyDepartureCleanupJob.accountDeletionKind == "accountDeletion")
    }

    @Test("cleanup job IDs are stable and unambiguous")
    func stableDocumentID() {
        let first = FamilyDepartureCleanupJob.documentID(familyID: "family_a", uid: "member")

        #expect(first.count == 64)
        #expect(first == "cd2135f3be29a59b70783a1aa034128f3b99f00959ddf133c2c8b794a13bf1f3")
        #expect(first == FamilyDepartureCleanupJob.documentID(familyID: "family_a", uid: "member"))
        #expect(first != FamilyDepartureCleanupJob.documentID(familyID: "family", uid: "a_member"))
    }

    @Test("stored auth UID wins, with safe fallbacks for legacy documents")
    func resolvesUID() {
        #expect(FamilyDepartureCleanupJob.resolvedUID(
            storedUID: "auth-uid",
            fallbackUID: "fallback",
            documentID: "legacy-doc"
        ) == "auth-uid")
        #expect(FamilyDepartureCleanupJob.resolvedUID(
            storedUID: "invalid/uid",
            fallbackUID: nil,
            documentID: "legacy-doc"
        ) == "legacy-doc")
    }
}
