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

    @Test("an expired entitlement is final even when read from cache")
    func expiredEntitlementIsFinalFromCache() {
        let now = Date()
        let expired = ["premiumEntitlement": validEntitlement(expiresAt: now.addingTimeInterval(-1))]

        #expect(FamilyPremiumService.resolvedAccess(expired, isFromCache: true, now: now) == false)
    }

    @Test("an active family entitlement lapses when expiresAt passes without a new snapshot")
    @MainActor
    func activeEntitlementLapsesAtExpiry() async {
        let clock = TestClock()
        let document = FakeFamilyDocument()
        let service = FamilyPremiumService(
            documentListener: document,
            now: { clock.now },
            sleep: { clock.advance(by: $0) }
        )
        let recorder = AccessRecorder()
        service.observe(familyId: "family-a") { recorder.values.append($0) }

        document.send(["premiumEntitlement": validEntitlement(expiresAt: clock.now.addingTimeInterval(2))], fromCache: false)
        await waitUntil { recorder.values.last == false }

        #expect(recorder.values == [true, false])
        service.stopObserving()
    }

    @Test("reevaluate reports an expired entitlement even after a server-sourced grant")
    @MainActor
    func reevaluateDropsExpiredServerGrant() {
        let clock = TestClock()
        let document = FakeFamilyDocument()
        let service = FamilyPremiumService(
            documentListener: document,
            now: { clock.now },
            sleep: { _ in try await Task.sleep(for: .seconds(3600)) }
        )
        let recorder = AccessRecorder()
        service.observe(familyId: "family-a") { recorder.values.append($0) }
        document.send(["premiumEntitlement": validEntitlement(expiresAt: clock.now.addingTimeInterval(60))], fromCache: false)

        clock.advance(by: .seconds(61))
        service.reevaluate()

        #expect(recorder.values == [true, false])
        service.stopObserving()
    }

    @Test("an offline cache-only miss resolves to no family premium after the grace period")
    @MainActor
    func cacheOnlyMissResolvesAfterGrace() async {
        let clock = TestClock()
        let document = FakeFamilyDocument()
        let service = FamilyPremiumService(
            documentListener: document,
            now: { clock.now },
            sleep: { clock.advance(by: $0) }
        )
        let recorder = AccessRecorder()
        service.observe(familyId: "family-a") { recorder.values.append($0) }

        document.send(nil, fromCache: true)
        await waitUntil { !recorder.values.isEmpty }

        #expect(recorder.values == [false])
        service.stopObserving()
    }

    @Test("a server grant arriving within the grace period is the only answer")
    @MainActor
    func serverGrantWithinGraceWins() async {
        let clock = TestClock()
        let document = FakeFamilyDocument()
        let service = FamilyPremiumService(
            documentListener: document,
            now: { clock.now },
            sleep: { _ in try await Task.sleep(for: .seconds(3600)) }
        )
        let recorder = AccessRecorder()
        service.observe(familyId: "family-a") { recorder.values.append($0) }

        document.send(nil, fromCache: true)
        document.send(["premiumEntitlement": validEntitlement(expiresAt: clock.now.addingTimeInterval(60))], fromCache: false)
        await Task.yield()

        #expect(recorder.values == [true])
        service.stopObserving()
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

    private func waitUntil(_ condition: @MainActor () -> Bool) async {
        for _ in 0..<1000 where !condition() {
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    /// A clock whose `sleep` jumps straight to the deadline instead of waiting.
    private final class TestClock: @unchecked Sendable {
        private let lock = NSLock()
        private var current = Date(timeIntervalSince1970: 1_800_000_000)

        var now: Date { lock.withLock { current } }

        func advance(by duration: Duration) {
            let seconds = Double(duration.components.seconds)
                + Double(duration.components.attoseconds) / 1e18
            lock.withLock { current = current.addingTimeInterval(seconds) }
        }
    }

    @MainActor
    private final class AccessRecorder {
        var values: [Bool] = []
    }

    @MainActor
    private final class FakeFamilyDocument: FamilyDocumentListening {
        private var onEvent: (@MainActor (Result<FamilyDocumentSnapshot, Error>) -> Void)?

        func listen(
            familyId: String,
            onEvent: @escaping @MainActor (Result<FamilyDocumentSnapshot, Error>) -> Void
        ) -> (() -> Void)? {
            self.onEvent = onEvent
            return { [weak self] in self?.onEvent = nil }
        }

        func send(_ data: [String: Any]?, fromCache: Bool) {
            onEvent?(.success(FamilyDocumentSnapshot(data: data, isFromCache: fromCache)))
        }
    }
}
