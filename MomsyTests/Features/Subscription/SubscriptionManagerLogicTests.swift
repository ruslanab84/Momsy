import Testing
@testable import Momsy

struct SubscriptionManagerLogicTests {
    @Test func monthlyGrantsPremium() {
        #expect(SubscriptionManager.grantsPremium(productID: ProductID.monthly))
    }

    @Test func annualGrantsPremium() {
        #expect(SubscriptionManager.grantsPremium(productID: ProductID.annual))
    }

    @Test func unknownProductDoesNotGrantPremium() {
        #expect(!SubscriptionManager.grantsPremium(productID: "com.other.product"))
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
}
