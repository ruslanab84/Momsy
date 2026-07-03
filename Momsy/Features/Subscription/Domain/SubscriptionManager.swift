import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var isPremium = false
    @Published private(set) var isLoading = false
    @Published private(set) var monthlyPrice = ""
    @Published private(set) var subscriptionName = ""
    @Published private var product: Product?

    var canPurchase: Bool {
        product != nil
    }

    private let service: any SubscriptionServicing
    private var listenerTask: Task<Void, Never>?
    private var productLoadTask: Task<Product, Error>?

    init(service: any SubscriptionServicing) {
        self.service = service
        listenerTask = Task {
            _ = await loadProducts()
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

        let product = try await loadProductIfNeeded()
        let result = try await service.purchase(product)
        switch result {
        case .success(let verification):
            let tx = try verified(verification)
            let grantsPremium = tx.productID == ProductID.monthly && tx.revocationDate == nil
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

    @discardableResult
    private func loadProducts() async -> Product? {
        try? await loadProductIfNeeded()
    }

    private func loadProductIfNeeded() async throws -> Product {
        if let product { return product }
        if let productLoadTask {
            let loadedProduct = try await productLoadTask.value
            cache(loadedProduct)
            return loadedProduct
        }

        let service = service
        let task = Task<Product, Error> {
            let products = try await service.fetchProducts(ids: ProductID.all)
            guard let product = products.first(where: { $0.id == ProductID.monthly }) else {
                throw SubscriptionError.productUnavailable
            }
            return product
        }
        productLoadTask = task
        defer { productLoadTask = nil }

        let loadedProduct = try await task.value
        cache(loadedProduct)
        return loadedProduct
    }

    private func cache(_ loadedProduct: Product) {
        product = loadedProduct
        monthlyPrice = loadedProduct.displayPrice
        subscriptionName = loadedProduct.displayName
    }

    private func updateStatus() async {
        var hasSub = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productID == ProductID.monthly,
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
