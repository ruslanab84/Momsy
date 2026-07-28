import Foundation

/// Centralised prompts for the Weekly Insight feature.
/// System + user prompts live here — never in ViewModel or View.
/// The model receives ONLY pre-aggregated stats (never raw rows) and must reply in JSON.
enum WeeklyInsightPrompt {

    static let jsonKeys = "sleepSummary, sleepRecommendation, feedingSummary, feedingRecommendation, overallSummary"

    static func system(for language: Language) -> String {
        let responseLanguage = responseLanguageName(for: language)
        return """
        You are a warm, careful pediatric information assistant for parents. Explain a baby's
        pre-aggregated weekly tracking data in plain language. You are not diagnosing illness.

        EVIDENCE AND ACCURACY RULES
        - Treat the age-specific WHO sleep RANGE supplied in the user prompt as the source of truth.
        - Always state the logged sleep average, the full WHO range, and the exact comparison:
          below the range, within the range, above the range, or insufficient logging data.
        - Distinguish logged events from the baby's true behaviour. Low values can reflect incomplete logging.
        - WHO recommends breastfeeding on demand, day and night, and does not define one universal numeric
          milk-feed count. Never present the app's logging heuristic as a WHO clinical target.
        - Complementary-food diary entries are not necessarily complete meals. Do not claim that WHO meal
          frequency was met or missed unless the prompt explicitly says the data supports that conclusion.
        - Never describe an obviously low logged value as steady, good, healthy, or enough.
        - Do not infer hydration or intake adequacy from total diaper count alone.
        - Never give a medical diagnosis. Use calm wording and recommend contacting a pediatrician when a
          genuinely low pattern appears complete, a reaction is flagged, or the parent is concerned.
        - NEVER recommend re-introducing a food that is flagged as an allergen or caused a reaction.

        AGE RULES
        - Use the baby's age from the user prompt as a hard constraint.
        - For babies younger than 6 months, never recommend complementary foods, solids, new foods,
          allergens, water, or "introduce one new food". Discuss breast milk or formula according to
          the family's logged feeding type.
        - For babies 6 months or older, complementary-food guidance is allowed when relevant. Recommend
          age-appropriate variety and responsive feeding, without forcing the child to eat.

        REQUIRED OUTPUT DEPTH
        Return exactly these five JSON keys: \(jsonKeys).
        Every value must be an ARRAY of complete sentences written in \(responseLanguage).
        - sleepSummary: 4-6 sentences. Include actual sleep, WHO range, status/difference, night/day split,
          naps, previous-week trend, and a logging-quality caveat when needed.
        - sleepRecommendation: 3-5 sentences. Give specific, practical next steps tied to the status.
        - feedingSummary: 4-6 sentences. Include logged feeds/day and weekly total, age-appropriate WHO
          guidance, the honest comparison/data limitation, complementary foods, reactions, and diapers.
        - feedingRecommendation: 3-5 sentences. Give age-safe actions and clear reaction/allergen guidance.
        - overallSummary: 3-5 sentences. Summarize the week, mention developmental-leap signals when supplied,
          identify the main thing to watch, and end with supportive but data-consistent wording.

        Each array item must contain exactly one complete sentence. Do not use markdown, headings, bullet
        symbols, extra keys, or text outside the JSON. Do not repeat the same sentence across sections.
        """
    }

    static func user(ctx: WeeklyInsightContext) -> String {
        build(ctx: ctx)
    }

    // MARK: - Builder

    private static func build(ctx: WeeklyInsightContext) -> String {
        let s = ctx.stats
        let sleepH = hours(s.avgSleepMinutesPerDay)
        let nightH = hours(s.avgNightSleepMinutes)
        let dayH = hours(s.avgDaySleepMinutes)
        let sleepRange = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let whoMinH = hours(sleepRange.lowerBound)
        let whoMaxH = hours(sleepRange.upperBound)
        let naps = decimal(s.avgNapsPerDay)
        let feeds = decimal(s.avgFeedingsPerDay)
        let trend = trendString(s.sleepTrendVsPrevWeekMinutes)
        let foods = s.newFoodsIntroduced.isEmpty ? "none" : s.newFoodsIntroduced.joined(separator: ", ")
        let allergens = s.allergensFlagged.isEmpty ? "none" : s.allergensFlagged.joined(separator: ", ")
        let leap = s.currentLeapName
        let leapSignals = s.leapSignals.isEmpty ? nil : s.leapSignals.joined(separator: ", ")
        let responseLanguage = responseLanguageName(for: ctx.language)

        var lines: [String] = []
        lines.append("BABY: age \(s.ageMonths) months (\(s.ageWeeks) weeks).")
        if let leap { lines.append("DEVELOPMENTAL LEAP: \(leap).") }
        if let leapSignals, let leapID = s.currentLeapID {
            lines.append("LEAP SIGNALS: leap #\(leapID) - \(leapSignals). Mention these in overallSummary without claiming causation.")
        }

        lines.append("SLEEP REFERENCE: WHO range \(whoMinH)-\(whoMaxH) total sleep per 24 hours, including naps.")
        lines.append("SLEEP LOGS: average \(sleepH)/day; night \(nightH)/day; daytime \(dayH)/day; \(naps) naps/day; \(trend).")
        lines.append("SLEEP CLASSIFICATION: \(sleepComparison(for: s, range: sleepRange)). Use this exact classification and difference.")
        lines.append("ROUTINE GUIDE: app awake-window estimate about \(s.whoAwakeWindowMax) minutes. This is an app planning estimate, not a WHO sleep-duration standard.")

        lines.append(feedingStageLine(for: s))
        lines.append("MILK FEED LOGS: \(feeds)/day average, \(s.totalFeedings) total this week. These are logged events, not measured milk volume or proof of intake adequacy.")
        lines.append(feedingComparisonLine(for: s))
        lines.append(newFoodsLine(for: s, foods: foods))
        lines.append("ALLERGEN OR REACTION FLAGS: \(allergens).")
        lines.append("DIAPER LOGS: \(s.totalDiapers) total this week. The aggregate has no wet/dirty breakdown, so do not infer hydration from this number alone.")

        lines.append("OUTPUT LANGUAGE: \(responseLanguage). Write every sentence in \(responseLanguage); keep the five JSON keys in English.")
        lines.append("FINAL CHECK: every section must satisfy its required sentence count and include concrete numbers rather than generic reassurance.")
        return lines.joined(separator: "\n")
    }

    private static func sleepComparison(for stats: WeeklyStats, range: ClosedRange<Int>) -> String {
        let actual = stats.avgSleepMinutesPerDay
        guard actual > 0 else {
            return "insufficient sleep data because no sleep duration was logged; do not call 0 minutes the baby's true sleep."
        }
        if actual < range.lowerBound {
            let delta = range.lowerBound - actual
            return "below the WHO range by \(hours(delta)) per day (\(delta) minutes/day)."
        }
        if actual > range.upperBound {
            let delta = actual - range.upperBound
            return "above the WHO range by \(hours(delta)) per day (\(delta) minutes/day); mention possible overlap or incomplete stop logging before interpreting it clinically."
        }
        let aboveMin = actual - range.lowerBound
        let belowMax = range.upperBound - actual
        return "within the WHO range, \(hours(aboveMin)) above the lower bound and \(hours(belowMax)) below the upper bound."
    }

    private static func feedingStageLine(for stats: WeeklyStats) -> String {
        if stats.ageMonths < 6 {
            return "FEEDING STAGE: under 6 months. WHO breastfeeding guidance recommends exclusive breastfeeding for the first 6 months and feeding on demand, day and night. Momsy may contain breast or formula logs, so do not invent a fixed WHO feed count."
        }
        if let meals = WhoNorms.complementaryMealsPerDay(ageMonths: stats.ageMonths) {
            var line = "FEEDING STAGE: \(stats.ageMonths) months. WHO complementary-food reference is \(meals.lowerBound)-\(meals.upperBound) meals/day while milk feeding continues."
            if let snacks = WhoNorms.complementarySnacksPerDay(ageMonths: stats.ageMonths) {
                line += " WHO also allows \(snacks.lowerBound)-\(snacks.upperBound) nutritious snacks as needed."
            }
            return line
        }
        return "FEEDING STAGE: milk feeding plus an age-appropriate varied family diet; the supplied weekly data does not contain a complete meal-frequency count."
    }

    private static func feedingComparisonLine(for stats: WeeklyStats) -> String {
        if stats.ageMonths < 6 {
            let maxInterval = WhoNorms.maxFeedingInterval(ageMonths: stats.ageMonths)
            let expectedMinimum = Int(ceil(1_440.0 / Double(maxInterval)))
            let actual = stats.avgFeedingsPerDay
            if actual == 0 {
                return "MILK-FEED COMPARISON: no feeds were logged. The app cannot distinguish missing logs from no feeding; ask the parent to verify tracking."
            }
            if actual < Double(expectedMinimum) {
                let deficit = Double(expectedMinimum) - actual
                return "MILK-FEED COMPARISON: \(decimal(actual))/day is \(decimal(deficit)) below the app logging heuristic of about \(expectedMinimum)+ feeds/day (maximum interval about \(maxInterval) minutes). This heuristic is not a WHO clinical intake target; describe the pattern as low logged frequency or incomplete logging."
            }
            return "MILK-FEED COMPARISON: \(decimal(actual))/day is at or above the app logging heuristic of about \(expectedMinimum)+ feeds/day (maximum interval about \(maxInterval) minutes). WHO still recommends responsive feeding rather than targeting a fixed count."
        }

        if let meals = WhoNorms.complementaryMealsPerDay(ageMonths: stats.ageMonths) {
            return "COMPLEMENTARY-FEEDING COMPARISON: WHO suggests \(meals.lowerBound)-\(meals.upperBound) complementary meals/day for this age, but Momsy currently supplies new-food diary entries rather than a complete meal count. State that meal-frequency status cannot be determined from these data; do not label it low or normal."
        }
        return "FEEDING COMPARISON: there is no complete meal-count dataset in this report, so describe only the logged pattern and avoid a low/normal clinical classification."
    }

    private static func newFoodsLine(for stats: WeeklyStats, foods: String) -> String {
        guard stats.ageMonths < 6 else {
            return "NEW FOOD DIARY: \(foods). These entries show introductions, not every complementary meal."
        }
        if stats.newFoodsIntroduced.isEmpty {
            return "NEW FOOD DIARY: none, which is age-appropriate before 6 months."
        }
        return "NEW FOOD DIARY: \(foods) were logged before 6 months. Do not recommend more foods; suggest discussing early solids with a pediatrician."
    }

    private static func hours(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }

    private static func decimal(_ value: Double) -> String {
        String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private static func trendString(_ delta: Int) -> String {
        let absMin = abs(delta)
        if absMin < 10 { return "about the same as last week" }
        return delta > 0 ? "+\(absMin) minutes/day versus last week" : "-\(absMin) minutes/day versus last week"
    }

    private static func responseLanguageName(for language: Language) -> String {
        switch language {
        case .english: return "English"
        case .russian: return "Russian"
        case .german: return "German"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese"
        }
    }
}
