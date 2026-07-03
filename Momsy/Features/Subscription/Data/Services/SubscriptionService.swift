import StoreKit

protocol SubscriptionServicing {
    func fetchProducts(ids: [String]) async throws -> [Product]
    func purchase(_ product: Product) async throws -> Product.PurchaseResult
    func restorePurchases() async throws
}

struct StoreKitSubscriptionService: SubscriptionServicing {
    func fetchProducts(ids: [String]) async throws -> [Product] {
        try await Product.products(for: ids)
    }

    func purchase(_ product: Product) async throws -> Product.PurchaseResult {
        try await product.purchase()
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
    }
}
