import Foundation
import Testing
@testable import Momsy

struct MedicalSourceCatalogTests {
    @Test func everyIDResolvesExactlyOnce() {
        for id in MedicalSourceID.allCases {
            #expect(MedicalSourceCatalog.all.filter { $0.id == id }.count == 1, "\(id)")
            #expect(MedicalSourceCatalog.source(id)?.id == id)
        }
        #expect(MedicalSourceCatalog.all.count == MedicalSourceID.allCases.count)
    }

    @Test func urlsAreHTTPSOnThePublisherHost() {
        for source in MedicalSourceCatalog.all {
            if let url = source.url {
                #expect(url.scheme == "https", "\(source.id)")
                #expect(url.host() != nil && url.host() == source.publisher.allowedHost, "\(source.id)")
            } else {
                #expect(source.publisher == .peerReviewed, "\(source.id) has no URL")
            }
        }
    }

    @Test func peerReviewedSourcesCarryACitation() {
        for source in MedicalSourceCatalog.all where source.publisher == .peerReviewed {
            #expect(!(source.citation ?? "").isEmpty, "\(source.id)")
        }
    }

    @Test func publishabilityRequiresAtLeastOneValidSource() {
        #expect(!CitationPolicy.isPublishable([]))
        #expect(CitationPolicy.isPublishable([.whoGrowthStandards]))
        #expect(CitationPolicy.isPublishable([.whoGrowthStandards, .nhsColic, .epdsCox1987]))
    }

    @Test func sourcesScreenListsEveryCatalogSourceWhoFirst() {
        let groups = MedicalSourcesScreen.groups
        #expect(groups.flatMap { $0 }.count == MedicalSourceCatalog.all.count)
        #expect(groups.first?.allSatisfy { MedicalSourceCatalog.source($0)?.publisher == .who } == true)
    }
}
