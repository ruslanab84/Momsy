import Foundation

/// Generates the narrative sections of a weekly report from pre-aggregated stats.
protocol WeeklyInsightService {
    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI
}
