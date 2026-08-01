import DeviceCheck
import FirebaseAppCheck
import FirebaseCore

final class MomsyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    enum ProviderMode {
        case debug
        case appAttest
        case deviceCheck
    }

    static func providerMode(
        isSimulator: Bool,
        isAppAttestSupported: Bool
    ) -> ProviderMode {
        if isSimulator { return .debug }
        return isAppAttestSupported ? .appAttest : .deviceCheck
    }

    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if targetEnvironment(simulator)
        let mode = Self.providerMode(isSimulator: true, isAppAttestSupported: false)
        #else
        let mode = Self.providerMode(
            isSimulator: false,
            isAppAttestSupported: DCAppAttestService.shared.isSupported
        )
        #endif

        switch mode {
        case .debug:
            return AppCheckDebugProvider(app: app)
        case .appAttest:
            return AppAttestProvider(app: app)
        case .deviceCheck:
            return DeviceCheckProvider(app: app)
        }
    }
}
