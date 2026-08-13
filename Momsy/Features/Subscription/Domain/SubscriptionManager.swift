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
    private let familyPremiumService: FamilyPremiumService
    private var listenerTask: Task<Void, Never>?
    private var productLoadTask: Task<[Product], Error>?
    private var familyJoinObserver: NSObjectProtocol?
    private var familyRevocationObserver: NSObjectProtocol?
    private var personalPremium = false
    private var familyPremium = false
    private var isResolvingPersonal = true
    private var isResolvingFamily = true
    private var observedFamilyID: String?
    private var hasObservedFamily = false

    init(service: any SubscriptionServicing, familyPremiumService: FamilyPremiumService) {
        self.service = service
        self.familyPremiumService = familyPremiumService
        observeFamilyChanges()
        listenerTask = Task {
            _ = try? await loadProductsIfNeeded()
            await refreshAccess()
            for await result in Transaction.updates {
                guard case .verified(let tx) = result else { continue }
                await updatePersonalStatus(synchronizeFamilyEntitlement: false)
                guard Self.grantsPremium(productID: tx.productID) else {
                    await tx.finish()
                    continue
                }
                do {
                    try await familyPremiumService.synchronize(transactionJWS: result.jwsRepresentation)
                    await tx.finish()
                } catch {
                    continue
                }
            }
        }
    }

    deinit {
        listenerTask?.cancel()
        if let familyJoinObserver { NotificationCenter.default.removeObserver(familyJoinObserver) }
        if let familyRevocationObserver { NotificationCenter.default.removeObserver(familyRevocationObserver) }
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
                try await familyPremiumService.synchronize(transactionJWS: verification.jwsRepresentation)
            }
            await tx.finish()
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
        // ponytail: expiry is rechecked on foreground; add App Store Server Notifications
        // when entitlement changes must reach an already-open co-parent app immediately.
        observeCurrentFamily(forceRefresh: true)
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
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               Self.grantsPremium(productID: tx.productID),
               tx.revocationDate == nil {
                hasSub = true
                if synchronizeFamilyEntitlement {
                    try? await familyPremiumService.synchronize(transactionJWS: result.jwsRepresentation)
                }
            }
        }
        personalPremium = hasSub
        isResolvingPersonal = false
        updateAccessState()
    }

    private func observeFamilyChanges() {
        familyJoinObserver = NotificationCenter.default.addObserver(
            forName: .familyDidJoin, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.observeCurrentFamily() }
        }
        familyRevocationObserver = NotificationCenter.default.addObserver(
            forName: .familyMembershipRevoked, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.observeCurrentFamily() }
        }
    }

    private func observeCurrentFamily(forceRefresh: Bool = false) {
        let familyID = FamilyManager.shared.familyId
        guard forceRefresh || !hasObservedFamily || observedFamilyID != familyID else { return }
        hasObservedFamily = true
        observedFamilyID = familyID
        isResolvingFamily = true
        updateAccessState()
        familyPremiumService.observe(familyId: familyID) { [weak self] isPremium in
            guard let self else { return }
            self.familyPremium = isPremium
            self.isResolvingFamily = false
            self.updateAccessState()
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
}

enum SubscriptionError: Error {
    case failedVerification
    case productUnavailable
}
