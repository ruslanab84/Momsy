import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var isPremium = false
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
    private var listenerTask: Task<Void, Never>?
    private var productLoadTask: Task<[Product], Error>?

    init(service: any SubscriptionServicing) {
        self.service = service
        listenerTask = Task {
            _ = try? await loadProductsIfNeeded()
            await updateStatus()
            for await result in Transaction.updates {
                guard case .verified(let tx) = result else { continue }
                await updateStatus()
                await tx.finish()
            }
        }
    }

    deinit {
        listenerTask?.cancel()
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
                isPremium = true
            }
            await tx.finish()
            await updateStatus()
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
        await updateStatus()
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

    private func updateStatus() async {
        var hasSub = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               Self.grantsPremium(productID: tx.productID),
               tx.revocationDate == nil {
                hasSub = true
            }
        }
        isPremium = hasSub
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
