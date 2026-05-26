import Foundation
@testable import Momsy

final class MockDailyTipService: DailyTipService, @unchecked Sendable {
    var stubbedText = "Test AI tip"
    var shouldThrow = false
    var callCount = 0

    func fetch(context: DailyContext) async throws -> String {
        callCount += 1
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedText
    }
}
