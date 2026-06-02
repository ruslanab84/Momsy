import Foundation

/// Deterministic, on-device aggregation of a single completed week.
/// Always computable locally — present even when the AI call fails.
struct WeeklyStats: Codable, Equatable {
    let weekStart: Date
    let weekEnd: Date          // exclusive (start of the following week)
    let ageMonths: Int
    let ageWeeks: Int
    let currentLeapName: String?

    // Sleep
    let avgSleepMinutesPerDay: Int
    let avgNightSleepMinutes: Int
    let avgDaySleepMinutes: Int
    let avgNapsPerDay: Double
    let sleepTrendVsPrevWeekMinutes: Int   // +/- vs previous week avg/day
    let whoMinSleepMinutes: Int
    let whoAwakeWindowMax: Int

    // Feeding
    let avgFeedingsPerDay: Double
    let totalFeedings: Int
    let newFoodsIntroduced: [String]
    let allergensFlagged: [String]

    // Diapers
    let totalDiapers: Int
}

/// AI-generated narrative sections (the only thing the model returns).
struct WeeklyInsightAI: Codable, Equatable {
    let sleepSummary: String
    let sleepRecommendation: String
    let feedingSummary: String
    let feedingRecommendation: String
    let overallSummary: String
}

/// A complete weekly report = deterministic stats + AI narrative.
struct WeeklyInsight: Codable, Equatable, Identifiable {
    var id: Date { stats.weekStart }
    let stats: WeeklyStats
    let ai: WeeklyInsightAI
    let isAIGenerated: Bool
    let generatedAt: Date

    var weekStart: Date { stats.weekStart }
    var weekEnd: Date { stats.weekEnd }
}
