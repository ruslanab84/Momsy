import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    static let productID = "com.ruslanabdulov.momsy.premium.monthly"

    @Published private(set) var isPremium = false
    @Published private(set) var isLoading = false
    @Published private(set) var product: Product?

    private var listenerTask: Task<Void, Never>?
    private var productLoadTask: Task<Product, Error>?

    init() {
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
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let tx = try verified(verification)
            let grantsPremium = tx.productID == Self.productID && tx.revocationDate == nil
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
        try? await AppStore.sync()
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
            product = loadedProduct
            return loadedProduct
        }

        let task = Task<Product, Error> {
            let products = try await Product.products(for: [Self.productID])
            guard let product = products.first else {
                throw SubscriptionError.productUnavailable
            }
            return product
        }
        productLoadTask = task
        defer { productLoadTask = nil }

        let loadedProduct = try await task.value
        product = loadedProduct
        return loadedProduct
    }

    private func updateStatus() async {
        var hasSub = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productID == Self.productID,
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
