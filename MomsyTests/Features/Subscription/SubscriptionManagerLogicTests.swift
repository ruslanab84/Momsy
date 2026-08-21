import Foundation
import StoreKit
import Testing
@testable import Momsy

@MainActor
struct SubscriptionManagerLogicTests {
    @Test func signOutClearsInMemoryPremiumAccess() async {
        let manager = SubscriptionManager(
            service: StalledSubscriptionService(),
            familyPremiumService: NoFamilyPremiumService(),
            syncStore: PendingSubscriptionSyncStore(defaults: makeDefaults())
        )

        await manager.authSessionDidChange(isAuthenticated: false)

        #expect(!manager.isPremium)
        #expect(manager.accessState == .requiresPurchase)
    }

    @Test func stalledProductLoadingLeavesPaywallRetryable() async {
        let service = StalledSubscriptionService()
        let manager = SubscriptionManager(
            service: service,
            familyPremiumService: NoFamilyPremiumService(),
            syncStore: PendingSubscriptionSyncStore(defaults: makeDefaults()),
            productLoadTimeout: .milliseconds(20)
        )
        let clock = ContinuousClock()

        for _ in 0..<2 {
            let start = clock.now
            await #expect(throws: SubscriptionError.productUnavailable) {
                try await manager.purchase()
            }
            #expect(start.duration(to: clock.now) < .milliseconds(500))
            #expect(!manager.isLoading)
            await Task.yield()
        }

        #expect(service.fetchCount >= 2)
    }

    @Test func pendingPurchaseReportsApprovalState() {
        #expect {
            try SubscriptionManager.throwIfPending(.pending)
        } throws: { error in
            error as? SubscriptionError == .pendingApproval
        }
    }

    @Test func monthlyGrantsPremium() {
        #expect(SubscriptionManager.grantsPremium(productID: ProductID.monthly))
    }

    @Test func annualGrantsPremium() {
        #expect(SubscriptionManager.grantsPremium(productID: ProductID.annual))
    }

    @Test func unknownProductDoesNotGrantPremium() {
        #expect(!SubscriptionManager.grantsPremium(productID: "com.other.product"))
    }

    @Test func xcodeTransactionsStayLocal() {
        #expect(!SubscriptionManager.shouldSynchronizeFamilyEntitlement(environment: .xcode))
        #expect(SubscriptionManager.shouldSynchronizeFamilyEntitlement(environment: .sandbox))
        #expect(SubscriptionManager.shouldSynchronizeFamilyEntitlement(environment: .production))
    }

    @Test func appAccountTokenIsStableAndAccountScoped() {
        let token = SubscriptionManager.appAccountToken(for: "uid-a")

        #expect(token.uuidString.lowercased() == "65cf791d-d515-559f-9e18-4d4491df6c9d")
        #expect(token != SubscriptionManager.appAccountToken(for: "uid-b"))
    }

    @Test func authenticatedPersonalEntitlementRequiresMatchingAccountToken() {
        let token = SubscriptionManager.appAccountToken(for: "uid-a")

        #expect(SubscriptionManager.shouldGrantPersonalEntitlement(
            transactionAccountToken: token,
            currentUID: "uid-a"
        ))
        #expect(!SubscriptionManager.shouldGrantPersonalEntitlement(
            transactionAccountToken: token,
            currentUID: "uid-b"
        ))
    }

    /// The deleted account's Apple subscription stays active, and the device is signed out
    /// once the erasure completes. Granting it there let a re-onboarded user skip the paywall.
    @Test func aDeletedAccountsBoundEntitlementDoesNotSurviveSignOut() {
        #expect(!SubscriptionManager.shouldGrantPersonalEntitlement(
            transactionAccountToken: SubscriptionManager.appAccountToken(for: "deleted-uid"),
            currentUID: nil
        ))
    }

    /// A purchase made without a Momsy account belongs to the device, matching the backend's
    /// `matchesAppAccountToken`. Denying it locked out local-only and cloud-sync-declined buyers.
    @Test func unboundPurchasesGrantPremiumRegardlessOfSession() {
        #expect(SubscriptionManager.shouldGrantPersonalEntitlement(
            transactionAccountToken: nil,
            currentUID: "uid-a"
        ))
        #expect(SubscriptionManager.shouldGrantPersonalEntitlement(
            transactionAccountToken: nil,
            currentUID: nil
        ))
    }

    @Test func savingsPercentTypicalCase() {
        // 4.99 * 12 = 59.88; annual 39.99 → ~33%
        let percent = SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 39.99)
        #expect(percent == 33)
    }

    @Test func savingsNilWhenAnnualNotCheaper() {
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 59.88) == nil)
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 70.00) == nil)
    }

    @Test func savingsNilForInvalidInputs() {
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 0, annualPrice: 39.99) == nil)
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 0) == nil)
    }

    @Test func pendingSyncIsScopedAndDeduplicated() {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        let first = pending(signedTransaction: "first")
        let latest = pending(signedTransaction: "latest")

        store.save(first)
        store.save(latest)

        #expect(store.load() == latest)
        #expect(latest.matches(SubscriptionSyncContext(uid: "uid-a", familyID: "family-a")))
        #expect(!latest.matches(SubscriptionSyncContext(uid: "uid-b", familyID: "family-a")))
        #expect(!latest.matches(SubscriptionSyncContext(uid: "uid-a", familyID: "family-b")))
    }

    @Test func transactionFinishesBeforeAFailingNetworkFlush() async {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        let context = SubscriptionSyncContext(uid: "uid-a", familyID: "family-a")
        var events: [String] = []
        let queue = SubscriptionSyncQueue(
            store: store,
            currentContext: { context },
            synchronize: { _ in
                events.append("sync")
                throw TestSyncError()
            },
            retryDelays: []
        )

        await queue.persistAndFinish(pending(signedTransaction: "signed")) {
            events.append("finish")
        }
        await queue.flush()

        #expect(events == ["finish", "sync"])
        #expect(store.load()?.signedTransaction == "signed")
    }

    @Test func terminalSyncFailureDropsThePendingJob() async {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        let context = SubscriptionSyncContext(uid: "uid-a", familyID: "family-a")
        store.save(pending(signedTransaction: "signed"))
        let queue = SubscriptionSyncQueue(
            store: store,
            currentContext: { context },
            synchronize: { _ in
                throw FamilyPremiumSyncError(
                    code: "owned_by_another_account",
                    isRetryable: false
                )
            },
            retryDelays: []
        )

        await queue.flush()

        #expect(store.load() == nil)
    }

    @Test func accountOrFamilySwitchDropsTheOldScopedJob() async {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        store.save(pending(signedTransaction: "signed"))
        let queue = SubscriptionSyncQueue(
            store: store,
            currentContext: {
                SubscriptionSyncContext(uid: "uid-b", familyID: "family-b")
            },
            synchronize: { _ in Issue.record("A stale job must not reach the network") },
            retryDelays: []
        )

        await queue.flush()

        #expect(store.load() == nil)
    }

    @Test func successfulSyncIsRecordedOnlyAfterTheNetworkSucceeds() async {
        let defaults = makeDefaults()
        let store = PendingSubscriptionSyncStore(defaults: defaults)
        let context = SubscriptionSyncContext(uid: "uid-a", familyID: "family-a")
        let job = pending(signedTransaction: "signed")
        let queue = SubscriptionSyncQueue(
            store: store,
            currentContext: { context },
            synchronize: { _ in },
            retryDelays: []
        )
        queue.enqueue(job)

        #expect(!store.wasSuccessfullySynchronized(job))
        await queue.flush()
        #expect(store.wasSuccessfullySynchronized(job))
        #expect(store.load() == nil)

        queue.enqueue(job)
        #expect(store.load() == nil)
    }

    @Test func backendFailureClassificationPreservesTransientFamilyStates() {
        #expect(FamilyPremiumService.isRetryable(
            statusCode: 409,
            code: "no_family",
            serverValue: nil
        ))
        #expect(!FamilyPremiumService.isRetryable(
            statusCode: 409,
            code: "owned_by_another_account",
            serverValue: nil
        ))
        #expect(FamilyPremiumService.isRetryable(
            statusCode: 503,
            code: "verification_unavailable",
            serverValue: nil
        ))
        #expect(!FamilyPremiumService.isRetryable(
            statusCode: 503,
            code: "verification_unavailable",
            serverValue: false
        ))
    }

    private func pending(signedTransaction: String) -> PendingSubscriptionSync {
        PendingSubscriptionSync(
            uid: "uid-a",
            familyID: "family-a",
            originalTransactionID: "1000000123456789",
            signedTransaction: signedTransaction
        )
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "SubscriptionManagerLogicTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            preconditionFailure("Could not create isolated UserDefaults")
        }
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private struct TestSyncError: Error {}

    private final class StalledSubscriptionService: SubscriptionServicing {
        private(set) var fetchCount = 0

        func fetchProducts(ids: [String]) async throws -> [Product] {
            fetchCount += 1
            let clock = ContinuousClock()
            let deadline = clock.now.advanced(by: .seconds(1))
            while clock.now < deadline { await Task.yield() }
            return []
        }

        func purchase(
            _ product: Product,
            appAccountToken: UUID?
        ) async throws -> Product.PurchaseResult {
            Issue.record("Purchase must not start without a loaded product")
            throw SubscriptionError.productUnavailable
        }

        func restorePurchases() async throws {}
    }

    private final class NoFamilyPremiumService: FamilyPremiumServicing {
        var currentUID: String? { nil }
        var currentContext: SubscriptionSyncContext? { nil }

        func observe(familyId: String?, onChange: @escaping @MainActor (Bool) -> Void) {
            onChange(false)
        }

        func stopObserving() {}

        func synchronize(_ pending: PendingSubscriptionSync) async throws {}
    }
}
