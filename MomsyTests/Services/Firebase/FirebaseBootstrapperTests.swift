import Foundation
import Testing
@testable import Momsy

@Suite("FirebaseBootstrapper")
struct FirebaseBootstrapperTests {

    @Test("missing GoogleService-Info.plist returns nil")
    func missingConfigurationReturnsNil() throws {
        let bundle = try Self.makeBundle()

        #expect(FirebaseBootstrapper.googleServiceInfoPath(in: bundle) == nil)
    }

    @Test("existing GoogleService-Info.plist path is found")
    func existingConfigurationPathIsFound() throws {
        let bundle = try Self.makeBundle(files: ["GoogleService-Info.plist": "<plist version=\"1.0\"><dict/></plist>"])

        #expect(FirebaseBootstrapper.googleServiceInfoPath(in: bundle) != nil)
    }

    @Test("App Check uses debug only in the simulator")
    func appCheckProviderModeMatchesRuntime() {
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isSimulator: true,
            isAppAttestSupported: false
        ) == .debug)
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isSimulator: false,
            isAppAttestSupported: true
        ) == .appAttest)
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isSimulator: false,
            isAppAttestSupported: false
        ) == .deviceCheck)
    }

    private static func makeBundle(files: [String: String] = [:]) throws -> Bundle {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("bundle")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let info = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleIdentifier</key>
            <string>com.momsy.tests.\(UUID().uuidString)</string>
            <key>CFBundlePackageType</key>
            <string>BNDL</string>
        </dict>
        </plist>
        """
        try info.write(to: directory.appendingPathComponent("Info.plist"), atomically: true, encoding: .utf8)

        for (name, contents) in files {
            try contents.write(to: directory.appendingPathComponent(name), atomically: true, encoding: .utf8)
        }

        return try #require(Bundle(url: directory))
    }
}
