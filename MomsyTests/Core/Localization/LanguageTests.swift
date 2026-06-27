import Testing
@testable import Momsy

@Suite("Language")
struct LanguageTests {

    @Test("exposes every supported language as a selectable case")
    func allCasesAreComplete() {
        let codes = Set(Language.allCases.map(\.rawValue))
        #expect(codes == ["en", "ru", "de", "es", "fr", "pt", "zh"])
    }

    @Test("Chinese is selectable")
    func chineseIsSelectable() {
        #expect(Language.allCases.contains(.chinese))
        #expect(Language(rawValue: "zh") == .chinese)
    }

    // Guards the language picker, which is data-driven from `allCases`:
    // every case must render with a flag and a display name so none can be
    // silently dropped from the menu.
    @Test("every language has a flag and display name")
    func everyLanguageRenders() {
        for language in Language.allCases {
            #expect(!language.flag.isEmpty)
            #expect(!language.displayName.isEmpty)
        }
    }
}
