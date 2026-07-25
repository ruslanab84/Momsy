import Foundation

enum WeeklyInsightAIConsent {
    enum Status: String {
        case notDetermined
        case granted
        case denied
    }

    static let storageKey = "weeklyInsightAIConsent"

    static func status(defaults: UserDefaults = .standard) -> Status {
        defaults.string(forKey: storageKey).flatMap(Status.init(rawValue:)) ?? .notDetermined
    }
}
