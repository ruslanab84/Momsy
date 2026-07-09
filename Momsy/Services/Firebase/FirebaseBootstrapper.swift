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

        pinDebugAppCheckTokenIfNeeded()
        AppCheck.setAppCheckProviderFactory(MomsyAppCheckProviderFactory())
        FirebaseApp.configure(options: options)
        configureFirestoreCache()
        return true
    }

    static func googleServiceInfoPath(in bundle: Bundle) -> String? {
        bundle.path(forResource: configurationName, ofType: configurationExtension)
    }

    /// Pins a fixed App Check debug token in DEBUG builds. `AppCheckDebugProvider`
    /// reads this token from `UserDefaults`; without it the provider mints a fresh
    /// random token per install that Firebase rejects (403 "App attestation failed")
    /// until it is manually registered in the console. A stable, pre-registered value
    /// makes simulator and device debug runs work regardless of how the app is
    /// launched — Xcode ▶️ Run, a tap on the icon, or a relaunch — none of which need
    /// the scheme env var. The value matches the token registered under
    /// App Check → Apps → Momsy (iOS) → Manage debug tokens. Never compiled into
    /// Release, where App Attest is used instead.
    ///
    /// Both keys are written on purpose: firebase-ios-sdk ≤ 10 used
    /// `FIRAAppCheckDebugToken`, while 11+/`AppCheckCore` (the version pinned here)
    /// reads `GACAppCheckDebugToken`. The SDK ignores the key it doesn't recognise,
    /// so writing both is safe and survives an SDK up/downgrade.
    private static func pinDebugAppCheckTokenIfNeeded() {
        #if DEBUG
        let token = "674D7A53-D799-4089-8A37-A027E8C5194A"
        UserDefaults.standard.set(token, forKey: "GACAppCheckDebugToken")
        UserDefaults.standard.set(token, forKey: "FIRAAppCheckDebugToken")
        #endif
    }

    private static func configureFirestoreCache() {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
    }
}
