@testable import Momsy
import Foundation

final class MockWeeklyInsightRepository: WeeklyInsightRepository {
    var stored: [WeeklyInsight] = []
    var saveCount = 0

    func all() async throws -> [WeeklyInsight] {
        stored.sorted { $0.weekStart > $1.weekStart }
    }

    func latest() async throws -> WeeklyInsight? {
        try await all().first
    }

    func report(forWeekStarting weekStart: Date) async throws -> WeeklyInsight? {
        stored.first { Calendar.current.isDate($0.weekStart, inSameDayAs: weekStart) }
    }

    func save(_ insight: WeeklyInsight) async throws {
        saveCount += 1
        stored.removeAll { Calendar.current.isDate($0.weekStart, inSameDayAs: insight.weekStart) }
        stored.append(insight)
    }
}

final class MockWeeklyInsightService: WeeklyInsightService, @unchecked Sendable {
    var shouldThrow = false
    var callCount = 0
    var canned = WeeklyInsightAI(
        sleepSummary: "AI sleep summary",
        sleepRecommendation: "AI sleep rec",
        feedingSummary: "AI feeding summary",
        feedingRecommendation: "AI feeding rec",
        overallSummary: "AI overall"
    )

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        callCount += 1
        if shouldThrow { throw TestError.mock }
        return canned
    }
}
