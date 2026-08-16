import FirebaseFirestore
import Foundation
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

    @Test("verified access wins while the other entitlement source resolves")
    func verifiedAccessWinsDuringResolution() {
        #expect(
            PremiumAccessPolicy.state(
                personalPremium: true,
                familyPremium: false,
                isResolving: true
            ) == .premium
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

    @Test("family entitlement accepts missing or Firestore-null revocation")
    func familyEntitlementAcceptsOnlyValidNonRevokedShapes() {
        let now = Date()
        var entitlement = validEntitlement(expiresAt: now.addingTimeInterval(60))
        #expect(FamilyPremiumService.isActive(["premiumEntitlement": entitlement], now: now))

        entitlement["revokedAt"] = NSNull()
        #expect(FamilyPremiumService.isActive(["premiumEntitlement": entitlement], now: now))

        entitlement["revokedAt"] = "malformed"
        #expect(!FamilyPremiumService.isActive(["premiumEntitlement": entitlement], now: now))
    }

    @Test("family entitlement fails closed for missing active flag and expiry")
    func familyEntitlementRequiresActiveUnexpiredSchema() {
        let now = Date()
        var entitlement = validEntitlement(expiresAt: now.addingTimeInterval(60))
        entitlement.removeValue(forKey: "active")
        #expect(!FamilyPremiumService.isActive(["premiumEntitlement": entitlement], now: now))

        entitlement = validEntitlement(expiresAt: now.addingTimeInterval(-1))
        #expect(!FamilyPremiumService.isActive(["premiumEntitlement": entitlement], now: now))
    }

    @Test("a cache miss does not prove that the family lacks Premium")
    func familyAccessWaitsForServerTruth() {
        let now = Date()
        let active = [
            "premiumEntitlement": validEntitlement(expiresAt: now.addingTimeInterval(60))
        ]

        #expect(FamilyPremiumService.resolvedAccess(nil, isFromCache: true, now: now) == nil)
        #expect(FamilyPremiumService.resolvedAccess(nil, isFromCache: false, now: now) == false)
        #expect(FamilyPremiumService.resolvedAccess(active, isFromCache: true, now: now) == true)
    }

    private func validEntitlement(expiresAt: Date) -> [String: Any] {
        [
            "active": true,
            "originalTransactionId": "1000000123456789",
            "productId": ProductID.monthly,
            "expiresAt": Timestamp(date: expiresAt),
        ]
    }
}
