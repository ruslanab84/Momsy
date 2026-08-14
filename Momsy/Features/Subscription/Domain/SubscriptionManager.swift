import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var isPremium = false
    @Published private(set) var accessState: PremiumAccessState = .resolving
    @Published private(set) var isLoading = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var trialEligible = false
    @Published var selectedProductID = ProductID.annual

    var canPurchase: Bool { selectedProduct != nil }

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
    private let syncQueue: SubscriptionSyncQueue
    private var listenerTask: Task<Void, Never>?
    private var bootstrapTask: Task<Void, Never>?
    private var productLoadTask: Task<[Product], Error>?
    private var familyIDObserver: AnyCancellable?
    private var familyResolutionTask: Task<Void, Never>?
    private var personalPremium = false
    private var familyPremium = false
    private var isResolvingPersonal = true
    private var isResolvingFamily = true
    private var observedFamilyID: String?
    private var hasObservedFamily = false

    init(
        service: any SubscriptionServicing,
        familyPremiumService: any FamilyPremiumServicing,
        syncStore: PendingSubscriptionSyncStore = PendingSubscriptionSyncStore()
    ) {
        self.service = service
        self.familyPremiumService = familyPremiumService
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
            _ = try? await loadProductsIfNeeded()
            await refreshAccess()
            syncQueue.scheduleFlush()
        }
    }

    deinit {
        listenerTask?.cancel()
        bootstrapTask?.cancel()
        familyResolutionTask?.cancel()
        familyIDObserver?.cancel()
    }

    func purchase() async throws -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        defer { isLoading = false }

        let loaded = try await loadProductsIfNeeded()
        guard let product = loaded.first(where: { $0.id == selectedProductID }) else {
            throw SubscriptionError.productUnavailable
        }
        let result = try await service.purchase(product)
        switch result {
        case .success(let verification):
            let tx = try verified(verification)
            let grantsPremium = Self.grantsPremium(productID: tx.productID)
                && tx.revocationDate == nil
            if grantsPremium {
                personalPremium = true
                updateAccessState()
            }
            await persistAndFinishIfNeeded(
                transaction: tx,
                signedTransaction: verification.jwsRepresentation
            )
            await refreshAccess()
            return grantsPremium
        case .pending, .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        try? await service.restorePurchases()
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
            familyResolutionTask?.cancel()
            familyPremiumService.stopObserving()
            syncQueue.clear()
            familyPremium = false
            isResolvingFamily = false
            updateAccessState()
        }
    }

    func eraseLocalSubscriptionState() {
        familyResolutionTask?.cancel()
        familyPremiumService.stopObserving()
        syncQueue.clear()
        familyPremium = false
        isResolvingFamily = false
        updateAccessState()
    }

    /// Any product in the app's catalog grants premium.
    nonisolated static func grantsPremium(productID: String) -> Bool {
        ProductID.all.contains(productID)
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
            await adopt(loaded)
            return loaded
        }

        let service = service
        let task = Task<[Product], Error> {
            let fetched = try await service.fetchProducts(ids: ProductID.all)
            guard !fetched.isEmpty else { throw SubscriptionError.productUnavailable }
            return fetched
        }
        productLoadTask = task
        defer { productLoadTask = nil }

        let loaded = try await task.value
        await adopt(loaded)
        return loaded
    }

    private func adopt(_ loaded: [Product]) async {
        products = loaded
        if let subscription = loaded.first?.subscription {
            trialEligible = await subscription.isEligibleForIntroOffer
        }
    }

    private func updatePersonalStatus(synchronizeFamilyEntitlement: Bool) async {
        var hasSub = false
        var pending: PendingSubscriptionSync?
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               Self.grantsPremium(productID: tx.productID),
               tx.revocationDate == nil {
                hasSub = true
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
        familyResolutionTask?.cancel()
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
            self.familyResolutionTask?.cancel()
            self.familyPremium = isPremium
            self.isResolvingFamily = false
            self.updateAccessState()
        }
        familyResolutionTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard let self,
                  !Task.isCancelled,
                  self.observedFamilyID == familyID,
                  self.isResolvingFamily
            else { return }
            self.familyPremium = false
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
        guard let context = familyPremiumService.currentContext else { return nil }
        return PendingSubscriptionSync(
            uid: context.uid,
            familyID: context.familyID,
            originalTransactionID: String(transaction.originalID),
            signedTransaction: signedTransaction
        )
    }
}

enum SubscriptionError: Error {
    case failedVerification
    case productUnavailable
}
