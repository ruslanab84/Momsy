import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    static let productID = "com.ruslanabdulov.momsy.premium.monthly"

    @Published private(set) var isPremium = false
    @Published private(set) var isLoading = false
    @Published private(set) var product: Product?

    private var listenerTask: Task<Void, Never>?

    init() {
        listenerTask = Task {
            await loadProducts()
            await updateStatus()
            for await result in Transaction.updates {
                guard case .verified(let tx) = result else { continue }
                await tx.finish()
                await updateStatus()
            }
        }
    }

    deinit {
        listenerTask?.cancel()
    }

    func purchase() async throws {
        guard let product else { return }
        isLoading = true
        defer { isLoading = false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let tx = try verified(verification)
            await tx.finish()
            isPremium = true
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        try? await AppStore.sync()
        await updateStatus()
    }

    private func loadProducts() async {
        guard let p = try? await Product.products(for: [Self.productID]).first else { return }
        product = p
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
}
