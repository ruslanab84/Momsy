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
        diaperRepo: any DiaperRepository,
        leapCheckInRepo: (any LeapCheckInRepository)? = nil,
        diaryRepo: (any DiaryRepository)? = nil
    ) async -> WeeklyStats {

        let ageMonths = BabyAgeContext.ageMonths(birthDate: birthDate, now: weekEnd)
        let ageWeeks = BabyAgeContext.ageWeeks(birthDate: birthDate, now: weekEnd)
        let currentLeap = BabyAgeContext.currentLeap(ageWeeks: ageWeeks)
        let leap = currentLeap?.name(for: language)

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
        let prevFeeds = (try? await feedingRepo.getEntries(from: prevStart, to: weekStart)) ?? []
        let avgFeedsPerDay = Double(weekFeeds.count) / 7.0

        // Complementary foods introduced this week + allergen/reaction flags.
        let weekFoods = (try? await foodRepo.getEntries(from: weekStart, to: weekEnd)) ?? []
        let newFoods = orderedUnique(weekFoods.map(\.foodName))
        let flagged = orderedUnique(weekFoods.filter { $0.isAllergen || $0.reaction != .none }.map(\.foodName))

        // Diapers.
        let weekDiapers = (try? await diaperRepo.getEntries(from: weekStart, to: weekEnd)) ?? []
        let leapSignals = await buildLeapSignals(
            currentLeap: currentLeap,
            weekStart: weekStart,
            weekEnd: weekEnd,
            weekSleep: weekSleep,
            prevSleep: prevSleep,
            weekFeeds: weekFeeds,
            prevFeeds: prevFeeds,
            language: language,
            leapCheckInRepo: leapCheckInRepo,
            diaryRepo: diaryRepo
        )

        return WeeklyStats(
            weekStart: weekStart,
            weekEnd: weekEnd,
            ageMonths: ageMonths,
            ageWeeks: ageWeeks,
            currentLeapName: leap,
            currentLeapID: currentLeap?.id,
            leapSignals: leapSignals,
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

    private enum LeapSignal {
        case sleep
        case feedings
        case newSkills
        case fussiness
    }

    private static func buildLeapSignals(
        currentLeap: DevelopmentLeap?,
        weekStart: Date,
        weekEnd: Date,
        weekSleep: [SleepEntry],
        prevSleep: [SleepEntry],
        weekFeeds: [FeedingEntry],
        prevFeeds: [FeedingEntry],
        language: Language,
        leapCheckInRepo: (any LeapCheckInRepository)?,
        diaryRepo: (any DiaryRepository)?
    ) async -> [String] {
        guard let currentLeap else { return [] }

        let checkIns = ((try? await leapCheckInRepo?.getCheckIns(leapID: currentLeap.id)) ?? [])
            .filter { $0.date >= weekStart && $0.date < weekEnd }
        let symptoms = Set(checkIns.flatMap(\.symptoms))
        let diaryMilestones = ((try? await diaryRepo?.getEntries(from: weekStart, to: weekEnd)) ?? [])
            .filter { $0.kind == .milestone && !$0.text.isEmpty }

        var signals: [LeapSignal] = []
        if symptoms.contains(.sleepWorse) || sleepDropped(weekSleep: weekSleep, prevSleep: prevSleep) {
            signals.append(.sleep)
        }
        if symptoms.contains(.appetiteShift) || feedingShifted(weekFeeds: weekFeeds, prevFeeds: prevFeeds) {
            signals.append(.feedings)
        }
        if symptoms.contains(.newSkills) || !diaryMilestones.isEmpty {
            signals.append(.newSkills)
        }
        if symptoms.contains(.fussiness) || symptoms.contains(.wantsHeld) {
            signals.append(.fussiness)
        }

        return orderedUnique(signals.map { title(for: $0, language: language) })
    }

    private static func sleepDropped(weekSleep: [SleepEntry], prevSleep: [SleepEntry]) -> Bool {
        let current = weekSleep.compactMap(\.durationMinutes).reduce(0, +)
        let previous = prevSleep.compactMap(\.durationMinutes).reduce(0, +)
        guard previous > 0 else { return false }
        return (previous / 7) - (current / 7) >= 30
    }

    private static func feedingShifted(weekFeeds: [FeedingEntry], prevFeeds: [FeedingEntry]) -> Bool {
        guard !prevFeeds.isEmpty else { return false }
        let delta = abs(weekFeeds.count - prevFeeds.count)
        return delta >= 7 || Double(delta) / Double(prevFeeds.count) >= 0.25
    }

    private static func title(for signal: LeapSignal, language: Language) -> String {
        switch signal {
        case .sleep:
            return localized("sleep", "сон", "Schlaf", "sueño", "sommeil", "sono", "睡眠", language)
        case .feedings:
            return localized("feedings", "кормления", "Mahlzeiten", "tomas", "tétées", "mamadas", "喂养", language)
        case .newSkills:
            return localized("new skills", "новые навыки", "neue Fähigkeiten", "nuevas habilidades", "nouvelles compétences", "novas competências", "新技能", language)
        case .fussiness:
            return localized("fussiness", "капризность", "Quengeln", "irritabilidad", "agitation", "irritação", "烦躁", language)
        }
    }

    private static func localized(
        _ en: String,
        _ ru: String,
        _ de: String,
        _ es: String,
        _ fr: String,
        _ pt: String,
        _ zh: String,
        _ language: Language
    ) -> String {
        switch language {
        case .english: return en
        case .russian: return ru
        case .german: return de
        case .spanish: return es
        case .french: return fr
        case .portuguese: return pt
        case .chinese: return zh
        }
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
