import Testing
@testable import Momsy

struct AppLegalLinksTests {
    @Test func reviewURLIsPresentAndWellFormed() {
        let url = AppLegalLinks.appStoreReviewURL
        #expect(url != nil)
        let s = url?.absoluteString ?? ""
        #expect(s.hasPrefix("https://apps.apple.com/app/id"))
        #expect(s.hasSuffix("action=write-review"))
        #expect(!AppLegalLinks.appStoreID.isEmpty)
        let isNumericID = AppLegalLinks.appStoreID.allSatisfy { $0.isNumber }
        #expect(isNumericID)
    }

    @Test func manageSubscriptionsURLPointsAtAppStoreSubscriptions() {
        let url = AppLegalLinks.manageSubscriptionsURL
        #expect(url != nil)
        #expect(url?.absoluteString == "https://apps.apple.com/account/subscriptions")
    }
}
