import Testing
@testable import Momsy

@MainActor
struct LeapsSourcesTests {
    @Test func leapsSourcesArePublishable() {
        #expect(!LeapsView.sourceIDs.isEmpty)
        for id in LeapsView.sourceIDs {
            #expect(CitationPolicy.isPublishable([id]), "\(id) is not publishable")
        }
    }

    @Test func everyLeapHasTipAndDescriptionInAllLanguages() {
        for leap in DevelopmentLeap.catalog {
            for lang in Language.allCases {
                #expect(!(leap.tips[lang] ?? "").isEmpty, "leap \(leap.id) tip missing \(lang)")
                #expect(!(leap.descriptions[lang] ?? "").isEmpty, "leap \(leap.id) description missing \(lang)")
            }
        }
    }
}
