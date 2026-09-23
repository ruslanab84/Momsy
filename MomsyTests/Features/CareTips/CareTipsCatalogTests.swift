import Testing
@testable import Momsy
import Foundation

@Suite("CareTipsCatalog")
struct CareTipsCatalogTests {

    @Test("catalog is not empty and every category is represented")
    func categoriesPopulated() {
        #expect(!CareTipsCatalog.all.isEmpty)
        for category in CareTipCategory.allCases {
            #expect(!CareTipsCatalog.tips(in: category).isEmpty, "\(category.rawValue) has no tips")
        }
    }

    @Test("ids are unique and inside the category namespace")
    func idsAreUniqueAndNamespaced() {
        let ids = CareTipsCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)

        let ranges: [CareTipCategory: Range<Int>] = [
            .feeding: 1000..<1100,
            .sleep: 1100..<1200,
            .hygiene: 1200..<1300,
            .comfort: 1300..<1400,
            .development: 1400..<1500,
            .safety: 1500..<1600,
            .parent: 1600..<1700
        ]
        for tip in CareTipsCatalog.all {
            #expect(ranges[tip.category]?.contains(tip.id) == true, "id \(tip.id) outside its namespace")
        }
    }

    @Test("every tip has complete content in English")
    func contentIsComplete() {
        for tip in CareTipsCatalog.all {
            #expect(!tip.title(.english).isEmpty)
            #expect(!tip.summary(.english).isEmpty)
            #expect(!tip.whyItMatters(.english).isEmpty)
            #expect(tip.whatToDo(.english).count >= 3, "tip \(tip.id) has too few steps")
            #expect(!tip.commonMistakes(.english).isEmpty)
            #expect(!tip.whenToCallDoctor(.english).isEmpty, "tip \(tip.id) has no red flags")
            #expect(!tip.icon.isEmpty)
        }
    }

    @Test("every tip is translated into all seven languages")
    func allLanguagesPresent() {
        for tip in CareTipsCatalog.all {
            for lang in Language.allCases {
                #expect(tip.title.isTranslated(into: lang),
                        "tip \(tip.id): title missing \(lang.rawValue)")
                #expect(tip.summary.isTranslated(into: lang),
                        "tip \(tip.id): summary missing \(lang.rawValue)")
                #expect(tip.whyItMatters.isTranslated(into: lang),
                        "tip \(tip.id): whyItMatters missing \(lang.rawValue)")
                #expect(tip.whatToDo.isTranslated(into: lang),
                        "tip \(tip.id): whatToDo missing \(lang.rawValue)")
                #expect(tip.commonMistakes.isTranslated(into: lang),
                        "tip \(tip.id): commonMistakes missing \(lang.rawValue)")
                #expect(tip.whenToCallDoctor.isTranslated(into: lang),
                        "tip \(tip.id): whenToCallDoctor missing \(lang.rawValue)")
            }
        }
    }

    @Test("list fields have the same item count in every language")
    func listCountsMatchAcrossLanguages() {
        for tip in CareTipsCatalog.all {
            let fields: [(String, LocalizedList)] = [
                ("whatToDo", tip.whatToDo),
                ("commonMistakes", tip.commonMistakes),
                ("whenToCallDoctor", tip.whenToCallDoctor)
            ]
            for (name, list) in fields {
                let expected = list(.english).count
                for lang in Language.allCases {
                    #expect(list(lang).count == expected,
                            "tip \(tip.id): \(name) has \(list(lang).count) items in \(lang.rawValue), expected \(expected)")
                }
            }
        }
    }

    @Test("age windows are valid")
    func ageWindowsValid() {
        for tip in CareTipsCatalog.all {
            #expect(tip.ageFromMonths >= 0)
            #expect(tip.ageToMonths >= tip.ageFromMonths)
            #expect(tip.ageToMonths <= 24)
        }
    }

    @Test("untranslated languages fall back to English")
    func fallsBackToEnglish() {
        guard let tip = CareTipsCatalog.all.first else { return }
        for lang in Language.allCases {
            #expect(!tip.title(lang).isEmpty, "\(lang.rawValue) resolved to an empty title")
            #expect(!tip.whatToDo(lang).isEmpty)
        }
    }

    @Test("age filter selects only tips covering that age")
    func ageFilter() {
        let newbornTips = CareTipsCatalog.all.filter { $0.matches(ageMonths: 0) }
        #expect(!newbornTips.isEmpty)
        #expect(newbornTips.allSatisfy { $0.ageFromMonths == 0 })

        let solidsTip = CareTipsCatalog.tip(id: 1007)
        #expect(solidsTip?.matches(ageMonths: 0) == false)
        #expect(solidsTip?.matches(ageMonths: 6) == true)
    }

    @Test("search matches title and summary case-insensitively")
    func search() {
        let tip = CareTipsCatalog.tip(id: 1001)
        #expect(tip?.matches(query: "UPRIGHT", lang: .english) == true)
        #expect(tip?.matches(query: "", lang: .english) == true)
        #expect(tip?.matches(query: "zzzzz", lang: .english) == false)
    }

    // MARK: - Citations (A3)

    private func copy(_ tip: CareTip, id: Int, sources: [MedicalSourceID]) -> CareTip {
        CareTip(
            id: id, category: tip.category, icon: tip.icon,
            ageFrom: tip.ageFromMonths, ageTo: tip.ageToMonths,
            title: tip.title, summary: tip.summary, whatToDo: tip.whatToDo,
            whyItMatters: tip.whyItMatters, commonMistakes: tip.commonMistakes,
            whenToCallDoctor: tip.whenToCallDoctor, sources: sources
        )
    }

    @Test("release filter drops unsourced tips")
    func releaseFilterDropsUnsourced() throws {
        let base = try #require(CareTipsCatalog.tip(id: 1001))
        let sourced = copy(base, id: 1, sources: [.whoInfantYoungChildFeeding])
        let unsourced = copy(base, id: 2, sources: [])
        #expect(CareTipsCatalog.publishable([sourced, unsourced]).map(\.id) == [1])
    }

    @Test("every tip that ships in Release is publishable")
    func releaseCatalogIsPublishable() {
        let release = CareTipsCatalog.publishable(CareTipsCatalog.all)
        #expect(!release.isEmpty)
        #expect(release.allSatisfy { CitationPolicy.isPublishable($0.sources) })
    }

    @Test("sources are ordered by publisher priority and resolve in the catalog")
    func sourcesOrderedByPriority() {
        for tip in CareTipsCatalog.all {
            let priorities = tip.sources.compactMap { MedicalSourceCatalog.source($0)?.publisher.priority }
            #expect(priorities.count == tip.sources.count, "tip \(tip.id) cites an unknown source")
            #expect(priorities == priorities.sorted(), "tip \(tip.id) sources not WHO-first")
        }
    }
}
