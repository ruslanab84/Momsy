@testable import Momsy
import Foundation

final class MockAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    var events: [AnalyticsEvent] = []
    func track(_ event: AnalyticsEvent) { events.append(event) }
}
