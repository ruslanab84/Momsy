import Testing
import Foundation
@testable import Momsy

/// The app's translations live in Swift (`L10n.swift`), which iOS cannot see.
/// Unless the bundle *declares* the languages, `Bundle.main.preferredLocalizations`
/// stays `["en"]` and every sheet iOS draws for us — Sign in with Apple,
/// permission alerts, the StoreKit purchase confirmation — renders in English on
/// a Russian or German device, and App Store Connect refuses the localized
/// listings. These tests guard the declarations that fix that.
@Suite("Bundle localization")
struct BundleLocalizationTests {

    private var supportedCodes: Set<String> { Set(Language.allCases.map(\.rawValue)) }

    @Test("the app bundle declares every supported language")
    func appBundleDeclaresEveryLanguage() throws {
        let declared = try declaredLocalizations(inPlistAt: "Momsy/Info.plist")
        #expect(supportedCodes.isSubset(of: declared),
                "Missing from Momsy/Info.plist CFBundleLocalizations: \(supportedCodes.subtracting(declared).sorted())")
    }

    @Test("the widget extension declares every supported language")
    func widgetBundleDeclaresEveryLanguage() throws {
        let declared = try declaredLocalizations(inPlistAt: "MomsyWidget/Info.plist")
        #expect(supportedCodes.isSubset(of: declared),
                "Missing from MomsyWidget/Info.plist CFBundleLocalizations: \(supportedCodes.subtracting(declared).sorted())")
    }

    @Test("the Xcode project knows every supported region")
    func projectKnowsEveryRegion() throws {
        let project = try String(
            contentsOf: projectRoot().appendingPathComponent("Momsy.xcodeproj/project.pbxproj"),
            encoding: .utf8
        )
        guard let range = project.range(of: #"knownRegions = \([^)]*\)"#, options: .regularExpression) else {
            Issue.record("knownRegions not found in project.pbxproj")
            return
        }
        let regions = Set(
            project[range]
                .replacingOccurrences(of: "\"", with: "")
                .split(whereSeparator: { " \n\t(),=".contains($0) })
                .map(String.init)
        )
        #expect(supportedCodes.isSubset(of: regions),
                "Missing from knownRegions: \(supportedCodes.subtracting(regions).sorted())")
    }

    // The declarations above are only worth anything if they survive into the
    // built product — this is the value that was `["en"]` before.
    @Test("the built bundle resolves every supported language at runtime")
    func builtBundleExposesEveryLanguage() {
        let localizations = Set(Bundle.main.localizations)
        #expect(supportedCodes.isSubset(of: localizations),
                "Momsy.app is missing localizations: \(supportedCodes.subtracting(localizations).sorted())")
    }

    @Test("regional identifiers map onto the language we ship")
    func regionalIdentifiersMapOntoShippedLanguages() {
        #expect(Language.matching("pt-BR") == .portuguese)
        #expect(Language.matching("zh-Hans-CN") == .chinese)
        #expect(Language.matching("zh-Hant") == .chinese)
        #expect(Language.matching("de_DE") == .german)
        #expect(Language.matching("en") == .english)
        #expect(Language.matching("ja") == nil)
    }

    @Test("the system-resolved language is always one we ship")
    func systemPreferredIsSupported() {
        #expect(Language.allCases.contains(Language.systemPreferred))
    }

    private func declaredLocalizations(inPlistAt relativePath: String) throws -> Set<String> {
        let data = try Data(contentsOf: projectRoot().appendingPathComponent(relativePath))
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        let localizations = (plist as? [String: Any])?["CFBundleLocalizations"] as? [String] ?? []
        return Set(localizations)
    }

    private func projectRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.path != "/" {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("Momsy.xcodeproj").path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        throw NSError(domain: "BundleLocalizationTests", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Could not locate project root"])
    }
}
