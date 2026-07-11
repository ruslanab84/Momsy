import Foundation
import FirebaseAppCheck
import FirebaseCore
import FirebaseFirestore
import os

enum FirebaseBootstrapper {
    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "Firebase")
    private static let configurationName = "GoogleService-Info"
    private static let configurationExtension = "plist"

    static var isConfigured: Bool {
        FirebaseApp.app() != nil
    }

    @discardableResult
    static func configureIfAvailable(bundle: Bundle = .main) -> Bool {
        guard FirebaseApp.app() == nil else { return true }

        guard let path = googleServiceInfoPath(in: bundle) else {
            log.warning("Skipping Firebase configuration: GoogleService-Info.plist is missing from the app bundle.")
            return false
        }

        guard let options = FirebaseOptions(contentsOfFile: path) else {
            log.error("Skipping Firebase configuration: GoogleService-Info.plist could not be loaded.")
            return false
        }

        AppCheck.setAppCheckProviderFactory(MomsyAppCheckProviderFactory())
        FirebaseApp.configure(options: options)
        configureFirestoreCache()
        return true
    }

    static func googleServiceInfoPath(in bundle: Bundle) -> String? {
        bundle.path(forResource: configurationName, ofType: configurationExtension)
    }

    private static func configureFirestoreCache() {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
    }
}
