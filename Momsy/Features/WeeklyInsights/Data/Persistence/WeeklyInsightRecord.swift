import SwiftData
import Foundation

/// Local-only SwiftData record for a generated weekly report.
/// NOT synced to Firestore — stays on device (privacy + user requirement).
@Model
final class WeeklyInsightRecord {
    var babyId: UUID = ActiveBaby.unassigned
    var weekStart: Date = Date()
    var weekEnd: Date = Date()
    var generatedAt: Date = Date()
    var isAIGenerated: Bool = false
    /// Language the narrative was generated in (BCP-47 short code). Defaults to
    /// "en" for records written before this field existed (lightweight migration).
    var language: String = "en"

    // Stats
    var ageMonths: Int = 0
    var ageWeeks: Int = 0
    var currentLeapName: String?
    var currentLeapID: Int?
    var leapSignals: [String] = []
    var avgSleepMinutesPerDay: Int = 0
    var avgNightSleepMinutes: Int = 0
    var avgDaySleepMinutes: Int = 0
    var avgNapsPerDay: Double = 0
    var sleepTrendVsPrevWeekMinutes: Int = 0
    var whoMinSleepMinutes: Int = 0
    var whoAwakeWindowMax: Int = 0
    var avgFeedingsPerDay: Double = 0
    var totalFeedings: Int = 0
    var newFoodsIntroduced: [String] = []
    var allergensFlagged: [String] = []
    var totalDiapers: Int = 0

    // AI narrative
    var sleepSummary: String = ""
    var sleepRecommendation: String = ""
    var feedingSummary: String = ""
    var feedingRecommendation: String = ""
    var overallSummary: String = ""

    init(_ insight: WeeklyInsight, babyId: UUID) {
        let s = insight.stats
        self.babyId = babyId
        weekStart = s.weekStart
        weekEnd = s.weekEnd
        generatedAt = insight.generatedAt
        isAIGenerated = insight.isAIGenerated
        language = insight.language.rawValue
        ageMonths = s.ageMonths
        ageWeeks = s.ageWeeks
        currentLeapName = s.currentLeapName
        currentLeapID = s.currentLeapID
        leapSignals = s.leapSignals
        avgSleepMinutesPerDay = s.avgSleepMinutesPerDay
        avgNightSleepMinutes = s.avgNightSleepMinutes
        avgDaySleepMinutes = s.avgDaySleepMinutes
        avgNapsPerDay = s.avgNapsPerDay
        sleepTrendVsPrevWeekMinutes = s.sleepTrendVsPrevWeekMinutes
        whoMinSleepMinutes = s.whoMinSleepMinutes
        whoAwakeWindowMax = s.whoAwakeWindowMax
        avgFeedingsPerDay = s.avgFeedingsPerDay
        totalFeedings = s.totalFeedings
        newFoodsIntroduced = s.newFoodsIntroduced
        allergensFlagged = s.allergensFlagged
        totalDiapers = s.totalDiapers
        sleepSummary = insight.ai.sleepSummary
        sleepRecommendation = insight.ai.sleepRecommendation
        feedingSummary = insight.ai.feedingSummary
        feedingRecommendation = insight.ai.feedingRecommendation
        overallSummary = insight.ai.overallSummary
    }

    func toDomain() -> WeeklyInsight {
        let stats = WeeklyStats(
            weekStart: weekStart,
            weekEnd: weekEnd,
            ageMonths: ageMonths,
            ageWeeks: ageWeeks,
            currentLeapName: currentLeapName,
            currentLeapID: currentLeapID,
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
        let ai = WeeklyInsightAI(
            sleepSummary: sleepSummary,
            sleepRecommendation: sleepRecommendation,
            feedingSummary: feedingSummary,
            feedingRecommendation: feedingRecommendation,
            overallSummary: overallSummary
        )
        return WeeklyInsight(stats: stats, ai: ai, isAIGenerated: isAIGenerated, generatedAt: generatedAt,
                             language: Language(rawValue: language) ?? .english)
    }
}
