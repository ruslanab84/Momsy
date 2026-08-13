import Testing
@testable import Momsy

@Suite("Family Premium access")
struct FamilyPremiumAccessTests {
    @Test("a joined parent receives the active family entitlement")
    func joinedParentReceivesFamilyPremium() {
        #expect(
            PremiumAccessPolicy.state(
                personalPremium: false,
                familyPremium: true,
                isResolving: false
            ) == .premium
        )
    }

    @Test("the paywall waits until family access has resolved")
    func paywallDoesNotFlashBeforeResolution() {
        #expect(
            PremiumAccessPolicy.state(
                personalPremium: false,
                familyPremium: false,
                isResolving: true
            ) == .resolving
        )
    }

    @Test("a parent without either entitlement remains eligible for the paywall")
    func noEntitlementRequiresPaywall() {
        #expect(
            PremiumAccessPolicy.state(
                personalPremium: false,
                familyPremium: false,
                isResolving: false
            ) == .requiresPurchase
        )
    }
}
