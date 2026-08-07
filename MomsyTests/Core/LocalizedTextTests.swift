import Testing
@testable import Momsy

@Suite("LocalizedText")
struct LocalizedTextTests {

    @Test("string literal authoring resolves to English for every language")
    func literalFallback() {
        let text: LocalizedText = "Hold your baby upright"
        for lang in Language.allCases {
            #expect(text(lang) == "Hold your baby upright")
        }
        #expect(text.isTranslated(into: .english))
        #expect(!text.isTranslated(into: .russian))
    }

    @Test("authored translation wins over the English fallback")
    func translationWins() {
        let text = LocalizedText(en: "Sleep", ru: "Сон")
        #expect(text(.russian) == "Сон")
        #expect(text(.german) == "Sleep")
        #expect(text.isTranslated(into: .russian))
    }

    @Test("array literal authoring resolves to English")
    func listFallback() {
        let list: LocalizedList = ["one", "two"]
        #expect(list(.french) == ["one", "two"])
        #expect(LocalizedList(en: ["one"], ru: ["один"])(.russian) == ["один"])
    }
}
