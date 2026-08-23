import Combine
import CryptoKit
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var isPremium = false
    @Published private(set) var accessState: PremiumAccessState = .resolving
    @Published private(set) var isLoading = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var productLoadFailed = false
    @Published private(set) var trialEligible = false
    @Published var selectedProductID = ProductID.annual

    var selectedProduct: Product? { products.first { $0.id == selectedProductID } }
    var monthlyProduct: Product? { products.first { $0.id == ProductID.monthly } }
    var annualProduct: Product? { products.first { $0.id == ProductID.annual } }

    var savingsPercent: Int? {
        guard let monthly = monthlyProduct?.price,
              let annual = annualProduct?.price else { return nil }
        return Self.savingsPercent(monthlyPrice: monthly, annualPrice: annual)
    }

    private let service: any SubscriptionServicing
    private let familyPremiumService: any FamilyPremiumServicing
    private let productLoadTimeout: Duration
    private let syncQueue: SubscriptionSyncQueue
    private var listenerTask: Task<Void, Never>?
    private var bootstrapTask: Task<Void, Never>?
    private var productLoadTask: Task<[Product], Error>?
    private var familyIDObserver: AnyCancellable?
    private var personalPremium = false
    private var familyPremium = false
    private var isResolvingPersonal = true
    private var isResolvingFamily = true
    private var observedFamilyID: String?
    private var hasObservedFamily = false

    init(
        service: any SubscriptionServicing,
        familyPremiumService: any FamilyPremiumServicing,
        syncStore: PendingSubscriptionSyncStore = PendingSubscriptionSyncStore(),
        productLoadTimeout: Duration = .seconds(15)
    ) {
        self.service = service
        self.familyPremiumService = familyPremiumService
        self.productLoadTimeout = productLoadTimeout
        syncQueue = SubscriptionSyncQueue(
            store: syncStore,
            currentContext: { familyPremiumService.currentContext },
            synchronize: { try await familyPremiumService.synchronize($0) }
        )
        observeFamilyChanges()
        listenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self, !Task.isCancelled else { return }
                await self.processUpdatedTransaction(result)
            }
        }
        bootstrapTask = Task { [weak self] in
            guard let self else { return }
            await loadProducts()
            await refreshAccess()
            syncQueue.scheduleFlush()
        }
    }

    deinit {
        listenerTask?.cancel()
        bootstrapTask?.cancel()
        familyIDObserver?.cancel()
    }

    /// Retryable entry point for the paywall. The catalog fetch runs exactly once per
    /// process otherwise — a launch-time failure would leave every later paywall with no
    /// prices at all. Tracks its own flag rather than `isLoading`, which gates `purchase()`.
    func loadProducts() async {
        guard products.isEmpty, !isLoadingProducts else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            _ = try await loadProductsIfNeeded()
            productLoadFailed = false
        } catch {
            productLoadFailed = true
        }
    }

    func purchase() async throws -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        defer { isLoading = false }

        let loaded = try await loadProductsIfNeeded()
        guard let product = loaded.first(where: { $0.id == selectedProductID }) else {
            throw SubscriptionError.productUnavailable
        }
        let accountToken = familyPremiumService.currentUID.map {
            Self.appAccountToken(for: $0)
        }
        let result = try await service.purchase(product, appAccountToken: accountToken)
        try Self.throwIfPending(result)
        switch result {
        case .success(let verification):
            let tx = try verified(verification)
            await refreshAccess()
            grantIfEntitled(tx)
            await persistAndFinishIfNeeded(
                transaction: tx,
                signedTransaction: verification.jwsRepresentation
            )
            // The App Store accepted the purchase but it stays bound to a different Momsy
            // account, so it grants nothing here. Never fail silently: a dead Subscribe
            // button is the worst outcome of the binding rule above. Checks the personal
            // entitlement, not `isPremium` — an existing family grant would otherwise mask
            // a purchase that bought this account nothing.
            guard personalPremium else { throw SubscriptionError.ownedByAnotherAccount }
            return true
        case .pending, .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        try await service.restorePurchases()
        await refreshAccess()
    }

    func refreshAccess() async {
        await updatePersonalStatus(synchronizeFamilyEntitlement: true)
        syncQueue.scheduleFlush()
    }

    func cloudSyncConsentDidChange(enabled: Bool) {
        if enabled {
            observeCurrentFamily(FamilyManager.shared.familyId, force: true)
            Task { [weak self] in
                await self?.updatePersonalStatus(synchronizeFamilyEntitlement: true)
            }
        } else {
            familyPremiumService.stopObserving()
            syncQueue.clear()
            familyPremium = false
            isResolvingFamily = false
            updateAccessState()
        }
    }

    func eraseLocalSubscriptionState() {
        familyPremiumService.stopObserving()
        syncQueue.clear()
        personalPremium = false
        familyPremium = false
        isResolvingPersonal = false
        isResolvingFamily = false
        updateAccessState()
    }

    func authSessionDidChange(isAuthenticated: Bool) async {
        familyPremiumService.stopObserving()
        personalPremium = false
        familyPremium = false
        observedFamilyID = nil
        hasObservedFamily = false
        isResolvingPersonal = isAuthenticated
        isResolvingFamily = isAuthenticated
            && FirebaseBootstrapper.isConfigured
            && CloudSyncConsent.isGranted()
        updateAccessState()

        guard isAuthenticated else { return }
        await updatePersonalStatus(synchronizeFamilyEntitlement: true)
        syncQueue.scheduleFlush()
    }

    /// Any product in the app's catalog grants premium.
    nonisolated static func grantsPremium(productID: String) -> Bool {
        ProductID.all.contains(productID)
    }

    nonisolated static func shouldSynchronizeFamilyEntitlement(
        environment: AppStore.Environment
    ) -> Bool {
        environment != .xcode
    }

    nonisolated static func appAccountToken(for uid: String) -> UUID {
        var bytes = Array(
            SHA256.hash(data: Data("RuslanAbd.Momsy:\(uid)".utf8)).prefix(16)
        )
        bytes[6] = (bytes[6] & 0x0f) | 0x50
        bytes[8] = (bytes[8] & 0x3f) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }

    /// Ownership is decided by what the PURCHASE is bound to, never by who happens to be
    /// signed in. Deciding by the session granted a deleted account's still-active Apple
    /// subscription to the signed-out device that follows the erasure, and denied legacy
    /// unbound purchases to their rightful owner. Mirrors `matchesAppAccountToken` in
    /// `functions/subscription-entitlement.js`.
    nonisolated static func shouldGrantPersonalEntitlement(
        transactionAccountToken: UUID?,
        currentUID: String?
    ) -> Bool {
        // Bought without a Momsy account (local-only build, or cloud sync declined), so it
        // belongs to the device rather than to any one account.
        guard let transactionAccountToken else { return true }
        // Bound to an account no longer present on this device — its owner must sign in.
        guard let currentUID else { return false }
        return transactionAccountToken == appAccountToken(for: currentUID)
    }

    /// A nil `expirationDate` means a non-consumable / lifetime purchase, which never lapses.
    nonisolated static func isUnexpired(expirationDate: Date?, now: Date = Date()) -> Bool {
        guard let expirationDate else { return true }
        return expirationDate > now
    }

    nonisolated static func throwIfPending(_ result: Product.PurchaseResult) throws {
        if case .pending = result { throw SubscriptionError.pendingApproval }
    }

    nonisolated static func resolvedProductID(
        selectedProductID: String,
        availableProductIDs: [String]
    ) -> String? {
        if availableProductIDs.contains(selectedProductID) { return selectedProductID }
        return ProductID.all.first(where: availableProductIDs.contains)
    }

    /// Percentage saved on annual vs paying monthly for a year. Nil when annual
    /// isn't cheaper or inputs are invalid.
    nonisolated static func savingsPercent(monthlyPrice: Decimal, annualPrice: Decimal) -> Int? {
        guard monthlyPrice > 0, annualPrice > 0 else { return nil }
        let yearAtMonthly = monthlyPrice * 12
        guard annualPrice < yearAtMonthly else { return nil }
        let fraction = (yearAtMonthly - annualPrice) / yearAtMonthly
        // ponytail: NSDecimalNumber.intValue silently returns 0 on this Decimal's
        // 38-digit mantissa; doubleValue routes around the overflow.
        let percent = Int(NSDecimalNumber(decimal: fraction * 100).doubleValue)
        return percent > 0 ? percent : nil
    }

    @discardableResult
    private func loadProductsIfNeeded() async throws -> [Product] {
        if !products.isEmpty { return products }
        if let productLoadTask {
            let loaded = try await productLoadTask.value
            adopt(loaded)
            return loaded
        }

        let service = service
        let timeout = productLoadTimeout
        let task = Task<[Product], Error> {
            let results = AsyncThrowingStream<[Product], Error> { continuation in
                let fetchTask = Task { @MainActor in
                    do {
                        let fetched = try await service.fetchProducts(ids: ProductID.all)
                        guard !fetched.isEmpty else {
                            continuation.finish(throwing: SubscriptionError.productUnavailable)
                            return
                        }
                        continuation.yield(fetched)
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                let timeoutTask = Task {
                    do {
                        try await Task.sleep(for: timeout)
                        continuation.finish(throwing: SubscriptionError.productUnavailable)
                    } catch {}
                }
                continuation.onTermination = { @Sendable _ in
                    fetchTask.cancel()
                    timeoutTask.cancel()
                }
            }
            var iterator = results.makeAsyncIterator()
            guard let fetched = try await iterator.next() else {
                throw SubscriptionError.productUnavailable
            }
            return fetched
        }
        productLoadTask = task
        defer { productLoadTask = nil }

        let loaded = try await task.value
        adopt(loaded)
        return loaded
    }

    private func adopt(_ loaded: [Product]) {
        products = loaded
        if let productID = Self.resolvedProductID(
            selectedProductID: selectedProductID,
            availableProductIDs: loaded.map(\.id)
        ) {
            selectedProductID = productID
        }
        guard let subscription = loaded.first?.subscription else { return }
        Task { [weak self] in
            self?.trialEligible = await subscription.isEligibleForIntroOffer
        }
    }

    /// A verified, live transaction seen on this device grants access. Only ever adds, so a
    /// `Transaction.currentEntitlements` scan that has not caught up with a just-completed
    /// purchase can no longer erase it. Both call sites run this AFTER `updatePersonalStatus`,
    /// so it must re-check every not-entitled state itself — StoreKit signals revocation via
    /// `revocationDate` but lapse/expiry only via `expirationDate`, and reading just the
    /// former would let a replayed stale transaction resurrect an expired subscription.
    private func grantIfEntitled(_ transaction: Transaction) {
        guard !personalPremium,
              Self.grantsPremium(productID: transaction.productID),
              transaction.revocationDate == nil,
              Self.isUnexpired(expirationDate: transaction.expirationDate),
              Self.shouldGrantPersonalEntitlement(
                transactionAccountToken: transaction.appAccountToken,
                currentUID: familyPremiumService.currentUID
              )
        else { return }
        personalPremium = true
        updateAccessState()
    }

    private func updatePersonalStatus(synchronizeFamilyEntitlement: Bool) async {
        var hasSub = false
        var pending: PendingSubscriptionSync?
        let currentUID = familyPremiumService.currentUID
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               Self.grantsPremium(productID: tx.productID),
               tx.revocationDate == nil {
                if Self.shouldGrantPersonalEntitlement(
                    transactionAccountToken: tx.appAccountToken,
                    currentUID: currentUID
                ) {
                    hasSub = true
                }
                if synchronizeFamilyEntitlement,
                   let candidate = pendingSync(
                    transaction: tx,
                    signedTransaction: result.jwsRepresentation
                   ) {
                    pending = candidate
                }
            }
        }
        personalPremium = hasSub
        isResolvingPersonal = false
        updateAccessState()
        if let pending {
            syncQueue.enqueue(pending)
            syncQueue.scheduleFlush()
        }
    }

    private func observeFamilyChanges() {
        familyIDObserver = FamilyManager.shared.$familyId
            .removeDuplicates()
            .sink { [weak self] familyID in
                Task { @MainActor in self?.observeCurrentFamily(familyID) }
            }
    }

    private func observeCurrentFamily(_ familyID: String?, force: Bool = false) {
        guard force || !hasObservedFamily || observedFamilyID != familyID else { return }
        let previousFamilyID = observedFamilyID
        hasObservedFamily = true
        observedFamilyID = familyID
        familyPremiumService.stopObserving()
        familyPremium = false

        if previousFamilyID != nil && familyID == nil {
            syncQueue.clear()
        } else {
            syncQueue.discardPendingIfScopeChanged(to: familyPremiumService.currentContext)
        }

        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let familyID
        else {
            isResolvingFamily = false
            updateAccessState()
            return
        }

        isResolvingFamily = true
        updateAccessState()
        familyPremiumService.observe(familyId: familyID) { [weak self] isPremium in
            guard let self, self.observedFamilyID == familyID else { return }
            self.familyPremium = isPremium
            self.isResolvingFamily = false
            self.updateAccessState()
        }
        Task { [weak self] in
            await self?.updatePersonalStatus(synchronizeFamilyEntitlement: true)
        }
    }

    private func updateAccessState() {
        accessState = PremiumAccessPolicy.state(
            personalPremium: personalPremium,
            familyPremium: familyPremium,
            isResolving: isResolvingPersonal || isResolvingFamily
        )
        isPremium = accessState == .premium
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw SubscriptionError.failedVerification
        case .verified(let v): return v
        }
    }

    private func processUpdatedTransaction(
        _ result: VerificationResult<Transaction>
    ) async {
        guard case .verified(let transaction) = result else { return }
        await updatePersonalStatus(synchronizeFamilyEntitlement: false)
        grantIfEntitled(transaction)
        await persistAndFinishIfNeeded(
            transaction: transaction,
            signedTransaction: result.jwsRepresentation
        )
    }

    private func persistAndFinishIfNeeded(
        transaction: Transaction,
        signedTransaction: String
    ) async {
        guard Self.grantsPremium(productID: transaction.productID),
              let pending = pendingSync(
                transaction: transaction,
                signedTransaction: signedTransaction
              )
        else {
            await transaction.finish()
            return
        }
        await syncQueue.persistAndFinish(pending) {
            await transaction.finish()
        }
        syncQueue.scheduleFlush()
    }

    private func pendingSync(
        transaction: Transaction,
        signedTransaction: String
    ) -> PendingSubscriptionSync? {
        guard Self.shouldSynchronizeFamilyEntitlement(environment: transaction.environment),
              let context = familyPremiumService.currentContext
        else { return nil }
        return PendingSubscriptionSync(
            uid: context.uid,
            familyID: context.familyID,
            originalTransactionID: String(transaction.originalID),
            signedTransaction: signedTransaction
        )
    }
}

enum SubscriptionError: Error, Equatable {
    case failedVerification
    case pendingApproval
    case productUnavailable
    case ownedByAnotherAccount
}
