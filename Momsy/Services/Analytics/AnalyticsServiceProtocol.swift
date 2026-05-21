import Foundation

protocol AnalyticsServiceProtocol: Sendable {
    func track(_ event: AnalyticsEvent)
}
