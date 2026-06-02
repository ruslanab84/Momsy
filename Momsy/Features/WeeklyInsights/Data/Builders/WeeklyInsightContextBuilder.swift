import Foundation

/// Aggregates one completed week of logs into deterministic `WeeklyStats`.
/// Pulls from the same repositories used elsewhere; never sends raw rows to the AI.
enum WeeklyInsightContextBuilder {

    /// Night sleep = sessions that start at or after 19:00 or before 07:00.
    private static func isNight(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 19 || hour < 7
    }

    static func buildStats(
        weekStart: Date,
        weekEnd: Date,
        birthDate: Date?,
        language: Language,
        sleepRepo: any SleepRepository,
        feedingRepo: any FeedingRepository,
        foodRepo: any ComplementaryFeedingRepository,
        diaperRepo: any DiaperRepository
    ) async -> WeeklyStats {

        let ageMonths = BabyAgeContext.ageMonths(birthDate: birthDate, now: weekEnd)
        let ageWeeks = BabyAgeContext.ageWeeks(birthDate: birthDate, now: weekEnd)
        let leap = BabyAgeContext.currentLeapName(ageWeeks: ageWeeks, lang: language.rawValue)

        // Sleep — this week + previous week (for trend).
        let prevStart = Calendar.current.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
        let weekSleep = (try? await sleepRepo.getEntries(from: weekStart, to: weekEnd)) ?? []
        let prevSleep = (try? await sleepRepo.getEntries(from: prevStart, to: weekStart)) ?? []

        let totalSleep = weekSleep.compactMap(\.durationMinutes).reduce(0, +)
        let nightSleep = weekSleep.filter { isNight($0.startDate) }.compactMap(\.durationMinutes).reduce(0, +)
        let daySleep = totalSleep - nightSleep
        let napCount = weekSleep.filter { !isNight($0.startDate) }.count
        let prevTotal = prevSleep.compactMap(\.durationMinutes).reduce(0, +)

        let avgSleepPerDay = totalSleep / 7
        let avgNightPerDay = nightSleep / 7
        let avgDayPerDay = daySleep / 7
        let avgNaps = Double(napCount) / 7.0
        let trend = avgSleepPerDay - (prevTotal / 7)

        // Feeding.
        let weekFeeds = (try? await feedingRepo.getEntries(from: weekStart, to: weekEnd)) ?? []
        let avgFeedsPerDay = Double(weekFeeds.count) / 7.0

        // Complementary foods introduced this week + allergen/reaction flags.
        let allFoods = (try? await foodRepo.getAll()) ?? []
        let weekFoods = allFoods.filter { $0.date >= weekStart && $0.date < weekEnd }
        let newFoods = orderedUnique(weekFoods.map(\.foodName))
        let flagged = orderedUnique(weekFoods.filter { $0.isAllergen || $0.reaction != .none }.map(\.foodName))

        // Diapers.
        let weekDiapers = (try? await diaperRepo.getEntries(from: weekStart, to: weekEnd)) ?? []

        return WeeklyStats(
            weekStart: weekStart,
            weekEnd: weekEnd,
            ageMonths: ageMonths,
            ageWeeks: ageWeeks,
            currentLeapName: leap,
            avgSleepMinutesPerDay: avgSleepPerDay,
            avgNightSleepMinutes: avgNightPerDay,
            avgDaySleepMinutes: avgDayPerDay,
            avgNapsPerDay: avgNaps,
            sleepTrendVsPrevWeekMinutes: trend,
            whoMinSleepMinutes: WhoNorms.minSleepMinutes(ageMonths: ageMonths),
            whoAwakeWindowMax: WhoNorms.awakeWindowMax(ageMonths: ageMonths),
            avgFeedingsPerDay: avgFeedsPerDay,
            totalFeedings: weekFeeds.count,
            newFoodsIntroduced: newFoods,
            allergensFlagged: flagged,
            totalDiapers: weekDiapers.count
        )
    }

    private static func orderedUnique(_ items: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for item in items where !item.isEmpty && seen.insert(item).inserted {
            result.append(item)
        }
        return result
    }
}
