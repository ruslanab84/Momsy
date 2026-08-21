import StoreKit

protocol SubscriptionServicing {
    func fetchProducts(ids: [String]) async throws -> [Product]
    func purchase(_ product: Product, appAccountToken: UUID?) async throws -> Product.PurchaseResult
    func restorePurchases() async throws
}

struct StoreKitSubscriptionService: SubscriptionServicing {
    func fetchProducts(ids: [String]) async throws -> [Product] {
        try await Product.products(for: ids)
    }

    func purchase(_ product: Product, appAccountToken: UUID?) async throws -> Product.PurchaseResult {
        guard let appAccountToken else { return try await product.purchase() }
        return try await product.purchase(options: [.appAccountToken(appAccountToken)])
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
    }
}
