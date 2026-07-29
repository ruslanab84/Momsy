import FirebaseAppCheck
import FirebaseCore

final class MomsyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    enum ProviderMode {
        case debug
        case appAttest
    }

    static func providerMode(isSimulator: Bool) -> ProviderMode {
        isSimulator ? .debug : .appAttest
    }

    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if targetEnvironment(simulator)
        let mode = Self.providerMode(isSimulator: true)
        #else
        let mode = Self.providerMode(isSimulator: false)
        #endif

        switch mode {
        case .debug:
            return AppCheckDebugProvider(app: app)
        case .appAttest:
            return AppAttestProvider(app: app)
        }
    }
}
