import Testing
import Foundation
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

    @Test("source does not reintroduce English/Russian localization fallbacks")
    func sourceDoesNotUseBinaryLanguageFallbacks() throws {
        let root = try projectRoot()
        let sourceDirectories = ["Momsy", "MomsyWatch", "MomsyWidget"]
        let disallowedPatterns = [
            #"\b(?:lang|loc\.lang|lm\.lang)\s*==\s*"(?:en|ru)""#,
            #"lang\s*==\s*"en"\s*\?"#,
            #"loc\.lang\s*==\s*"en"\s*\?"#,
            #"lm\.lang\s*==\s*"en"\s*\?"#,
            #"case\s+\.english\s*,\s*\.spanish"#,
            #"case\s+\.english\s*,\s*\.spanish\s*,\s*\.portuguese"#,
            #"Locale\(identifier:\s*[^)]*"en_US"[^)]*"ru_RU"[^)]*\)"#,
        ]

        var violations: [String] = []
        for directory in sourceDirectories {
            let directoryURL = root.appendingPathComponent(directory)
            guard let files = FileManager.default.enumerator(
                at: directoryURL,
                includingPropertiesForKeys: nil
            ) else { continue }

            for case let fileURL as URL in files where fileURL.pathExtension == "swift" {
                let contents = try String(contentsOf: fileURL, encoding: .utf8)
                for (index, line) in contents.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                    let text = String(line)
                    if disallowedPatterns.contains(where: { text.range(of: $0, options: .regularExpression) != nil }) {
                        let relativePath = fileURL.path.replacingOccurrences(of: root.path + "/", with: "")
                        violations.append("\(relativePath):\(index + 1): \(text.trimmingCharacters(in: .whitespaces))")
                    }
                }
            }
        }

        #expect(violations.isEmpty, "Remove binary English/Russian localization fallbacks:\n\(violations.joined(separator: "\n"))")
    }

    private func projectRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.path != "/" {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("Momsy.xcodeproj").path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        throw NSError(domain: "LanguageTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not locate project root"])
    }
}
