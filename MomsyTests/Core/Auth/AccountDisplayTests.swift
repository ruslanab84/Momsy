import Testing
@testable import Momsy

struct AccountDisplayTests {
    @Test func displayNameWins() {
        #expect(AccountDisplay.memberName(displayName: "Anna", email: "x@privaterelay.appleid.com") == "Anna")
    }

    @Test func relayEmailNeverLeaks() {
        #expect(AccountDisplay.memberName(displayName: nil, email: "jm2kg4hb96@privaterelay.appleid.com") == "User")
        #expect(AccountDisplay.memberName(displayName: "  ", email: "AB@PrivateRelay.AppleID.com") == "User")
    }

    @Test func regularEmailAllowedAsFallback() {
        #expect(AccountDisplay.memberName(displayName: nil, email: "anna@example.com") == "anna@example.com")
    }

    @Test func emptyEverythingFallsBack() {
        #expect(AccountDisplay.memberName(displayName: nil, email: nil) == "User")
        #expect(AccountDisplay.memberName(displayName: "", email: "") == "User")
    }

    @Test func relayDetection() {
        #expect(AccountDisplay.isPrivateRelay("a@privaterelay.appleid.com"))
        #expect(!AccountDisplay.isPrivateRelay("a@appleid.com"))
        #expect(!AccountDisplay.isPrivateRelay("privaterelay.appleid.com@gmail.com"))
    }
}
