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

    /// The EPDS copyright holder permits free reproduction only while the authors,
    /// the title and the source stay attached to the questionnaire, so the citation
    /// losing any of the three is a licence breach, not a copy tweak.
    @Test func epdsCitationCarriesAuthorsTitleAndSource() {
        let citation = AppLegalLinks.epdsCitation
        for author in ["Cox", "Holden", "Sagovsky"] {
            #expect(citation.contains(author))
        }
        #expect(citation.contains("Edinburgh Postnatal Depression Scale"))
        #expect(citation.contains("British Journal of Psychiatry"))
        #expect(citation.contains("1987"))
        #expect(citation.contains("Royal College of Psychiatrists"))
    }

    @Test func whoSourceURLsPointAtWHO() {
        for url in [AppLegalLinks.whoGrowthStandardsURL, AppLegalLinks.whoImmunizationScheduleURL] {
            #expect(url != nil)
            #expect(url?.host() == "www.who.int")
        }
    }

    @Test func manageSubscriptionsURLPointsAtAppStoreSubscriptions() {
        let url = AppLegalLinks.manageSubscriptionsURL
        #expect(url != nil)
        #expect(url?.absoluteString == "https://apps.apple.com/account/subscriptions")
    }
}
