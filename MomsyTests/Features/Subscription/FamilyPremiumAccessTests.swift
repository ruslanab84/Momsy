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

    @Test("an authentication change clears the persisted paywall decision")
    func authenticationChangeClearsPaywallCache() throws {
        let suiteName = "FamilyPremiumAccessTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(true, forKey: "paywallShown")

        PaywallPresentationState.resetForAuthenticationChange(defaults: defaults)

        #expect(defaults.object(forKey: "paywallShown") == nil)
    }

    @Test("only an authentication change invalidates the paywall decision")
    func paywallDecisionSurvivesAccessStateRepublish() throws {
        let suiteName = "FamilyPremiumAccessTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(true, forKey: "paywallShown")

        // A `.requiresPurchase` state on its own must never clear the user's dismissal:
        // that reset ran on every scene activation and swapped the root view mid-flow.
        #expect(defaults.bool(forKey: "paywallShown"))

        PaywallPresentationState.resetForAuthenticationChange(defaults: defaults)

        #expect(defaults.object(forKey: "paywallShown") == nil)
    }

    @Test("a pending invite makes the paywall CTA join instead of purchasing")
    @MainActor
    func pendingInviteUsesFamilyJoin() async throws {
        let suiteName = "FamilyPremiumAccessTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = PendingFamilyInviteStore(defaults: defaults)
        store.save("momsy://join?code=MOMSY-ABCD12")
        var joinedCodes: [String] = []
        var purchaseCount = 0
        let handler = PaywallActionHandler(
            pendingInviteStore: store,
            subscribe: {
                purchaseCount += 1
                return true
            },
            joinFamily: { joinedCodes.append($0) }
        )

        let completed = await handler.perform()

        #expect(completed)
        #expect(joinedCodes == ["MOMSY-ABCD12"])
        #expect(purchaseCount == 0)
        #expect(store.load() == nil)
        #expect(!handler.isLoading)
        #expect(handler.error == nil)
    }

    @Test("a failed family join remains retryable")
    @MainActor
    func failedFamilyJoinResetsLoadingAndKeepsInvite() async throws {
        let suiteName = "FamilyPremiumAccessTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = PendingFamilyInviteStore(defaults: defaults)
        store.save("MOMSY-ABCD12")
        let handler = PaywallActionHandler(
            pendingInviteStore: store,
            subscribe: { true },
            joinFamily: { _ in throw TestJoinError() }
        )

        let completed = await handler.perform()

        #expect(!completed)
        #expect(!handler.isLoading)
        #expect(handler.error is TestJoinError)
        #expect(store.load() == "MOMSY-ABCD12")
    }

    private func validEntitlement(expiresAt: Date) -> [String: Any] {
        [
            "active": true,
            "originalTransactionId": "1000000123456789",
            "productId": ProductID.monthly,
            "expiresAt": Timestamp(date: expiresAt),
        ]
    }

    private struct TestJoinError: Error {}
}
