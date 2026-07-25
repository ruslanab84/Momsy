import Foundation

nonisolated enum CloudSyncConsent {
    enum Status: String {
        case notDetermined
        case granted
        case denied
    }

    static let storageKey = "cloudSyncConsent"

    static func status(defaults: UserDefaults = .standard) -> Status {
        defaults.string(forKey: storageKey).flatMap(Status.init(rawValue:)) ?? .notDetermined
    }

    static func isGranted(defaults: UserDefaults = .standard) -> Bool {
        status(defaults: defaults) == .granted
    }

    static func set(_ status: Status, defaults: UserDefaults = .standard) {
        defaults.set(status.rawValue, forKey: storageKey)
    }
}
