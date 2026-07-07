import FirebaseAppCheck
import FirebaseCore

final class MomsyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
        // App Attest requires a physical device; simulator/dev builds use the debug provider.
        return AppCheckDebugProvider(app: app)
        #else
        return AppAttestProvider(app: app)
        #endif
    }
}
