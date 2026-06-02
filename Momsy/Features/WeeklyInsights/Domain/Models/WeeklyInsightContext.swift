import Foundation

/// Input to the AI service: pre-aggregated stats + target language.
struct WeeklyInsightContext {
    let stats: WeeklyStats
    let language: Language

    var weekStart: Date { stats.weekStart }
    var weekEnd: Date { stats.weekEnd }

    var contextHash: String {
        let week = Int(stats.weekStart.timeIntervalSince1970)
        let feeds = Int(stats.avgFeedingsPerDay * 10)
        let foods = stats.newFoodsIntroduced.count
        return "\(language.rawValue)-\(week)-\(stats.avgSleepMinutesPerDay)-\(feeds)-\(foods)-\(stats.totalDiapers)"
    }
}
