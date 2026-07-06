import Foundation

/// Deterministic, on-device aggregation of a single completed week.
/// Always computable locally — present even when the AI call fails.
struct WeeklyStats: Codable, Equatable {
    let weekStart: Date
    let weekEnd: Date          // exclusive (start of the following week)
    let ageMonths: Int
    let ageWeeks: Int
    let currentLeapName: String?
    let currentLeapID: Int?
    let leapSignals: [String]

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

    /// True when the week holds no logged activity at all — no sleep, no
    /// feedings, no solids, no diapers. Such weeks get a static "no data"
    /// note instead of an AI narrative, and no Gemini request is made.
    var hasNoData: Bool {
        avgSleepMinutesPerDay == 0
            && totalFeedings == 0
            && newFoodsIntroduced.isEmpty
            && totalDiapers == 0
            && leapSignals.isEmpty
    }

    /// Returns a copy with the localized developmental-leap label replaced.
    /// Used when re-localizing a stored report into a newly selected language.
    func withLeapName(_ name: String?) -> WeeklyStats {
        WeeklyStats(
            weekStart: weekStart, weekEnd: weekEnd,
            ageMonths: ageMonths, ageWeeks: ageWeeks,
            currentLeapName: name, currentLeapID: currentLeapID,
            leapSignals: leapSignals,
            avgSleepMinutesPerDay: avgSleepMinutesPerDay,
            avgNightSleepMinutes: avgNightSleepMinutes,
            avgDaySleepMinutes: avgDaySleepMinutes,
            avgNapsPerDay: avgNapsPerDay,
            sleepTrendVsPrevWeekMinutes: sleepTrendVsPrevWeekMinutes,
            whoMinSleepMinutes: whoMinSleepMinutes,
            whoAwakeWindowMax: whoAwakeWindowMax,
            avgFeedingsPerDay: avgFeedingsPerDay,
            totalFeedings: totalFeedings,
            newFoodsIntroduced: newFoodsIntroduced,
            allergensFlagged: allergensFlagged,
            totalDiapers: totalDiapers
        )
    }
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
    /// The app language the narrative was generated in. Lets us detect and
    /// regenerate a report after the user switches languages.
    let language: Language

    var weekStart: Date { stats.weekStart }
    var weekEnd: Date { stats.weekEnd }
}
