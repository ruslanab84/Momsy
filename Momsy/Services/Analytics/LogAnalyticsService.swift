import Foundation

// Default analytics implementation — prints to console in DEBUG builds.
// Swap for FirebaseAnalyticsService once Firebase Analytics SDK is added:
//   Analytics.logEvent(event.name, parameters: event.parameters as [String: NSObject])
final class LogAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    func track(_ event: AnalyticsEvent) {
#if DEBUG
        print("[Analytics] \(event.name) \(event.parameters.isEmpty ? "" : "\(event.parameters)")")
#endif
    }
}
