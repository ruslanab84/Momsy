@testable import Momsy

final class MockAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    var events: [AnalyticsEvent] = []
    func track(_ event: AnalyticsEvent) { events.append(event) }
}
