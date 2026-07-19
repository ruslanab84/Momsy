import Foundation

/// Centralised prompts for the Weekly Insight feature.
/// System + user prompts live here — never in ViewModel or View.
/// The model receives ONLY pre-aggregated stats (never raw rows) and must reply in JSON.
enum WeeklyInsightPrompt {

    static let jsonKeys = "sleepSummary, sleepRecommendation, feedingSummary, feedingRecommendation, overallSummary"

    static func system(for language: Language) -> String {
        let responseLanguage = responseLanguageName(for: language)
        return """
        You are a warm, caring pediatric assistant for mothers. Analyze a baby's weekly stats.
        Compare to WHO age norms. Be encouraging, never give medical diagnoses, and NEVER recommend
        re-introducing a food that is flagged as an allergen or caused a reaction.

        Use the baby's age from the user prompt as a hard constraint for all recommendations.
        For babies younger than 6 months, NEVER recommend complementary foods, solids, new foods,
        allergens, or "introduce one new food". If no new foods were introduced, treat that as
        age-appropriate. Discuss milk feeding only: breast milk or formula, depending on the family.
        If new foods were logged for a baby younger than 6 months, do not recommend adding more foods;
        suggest discussing early solids with a pediatrician if relevant.

        If avgFeedingsPerDay is low for a baby younger than 6 months, describe it as low logged
        feedings or possibly incomplete logging. Do not call it a steady, good, or great feeding week.
        Suggest tracking feeds and diapers carefully and checking with a pediatrician if low intake is real.

        For babies 6 months or older, complementary-food advice is allowed. Recommend one new food
        at a time and watching for reactions only for this age group.

        Reply ONLY with a JSON object with exactly these keys: \(jsonKeys).
        Keep JSON keys exactly in English. Write every JSON string value in \(responseLanguage).
        Each value is 3-4 warm, specific sentences with concrete numbers and comparisons from the data. No markdown, no extra keys, no text outside the JSON.
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
        let whoH = hours(s.whoMinSleepMinutes)
        let naps = String(format: "%.1f", s.avgNapsPerDay)
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let trend = trendString(s.sleepTrendVsPrevWeekMinutes)
        let foods = s.newFoodsIntroduced.isEmpty ? "none" : s.newFoodsIntroduced.joined(separator: ", ")
        let allergens = s.allergensFlagged.isEmpty ? "none" : s.allergensFlagged.joined(separator: ", ")
        let leap = s.currentLeapName
        let leapSignals = s.leapSignals.isEmpty ? nil : s.leapSignals.joined(separator: ", ")
        let responseLanguage = responseLanguageName(for: ctx.language)

        var lines: [String] = []
        lines.append("Baby age: \(s.ageMonths) mo (\(s.ageWeeks) weeks).")
        lines.append(feedingStageLine(for: s))
        if let leap { lines.append("Developmental leap: \(leap).") }
        if let leapSignals, let leapID = s.currentLeapID {
            lines.append("Leap signals this week: leap #\(leapID) - \(leapSignals). Mention this in overallSummary.")
        }
        lines.append("WHO: total sleep target >= \(whoH)/day; max awake window ~\(s.whoAwakeWindowMax) min.")
        lines.append("Sleep this week: avg \(sleepH)/day (night \(nightH), day \(dayH), \(naps) naps/day), \(trend).")
        lines.append("Feeding this week: \(feeds)/day, \(s.totalFeedings) total. Diaper changes: \(s.totalDiapers).")
        if let feedingNote = feedingNote(for: s) {
            lines.append(feedingNote)
        }
        lines.append(newFoodsLine(for: s, foods: foods))
        lines.append("Allergen/reaction flagged: \(allergens).")
        lines.append("Response language: \(responseLanguage). Write every JSON string value in \(responseLanguage) and keep JSON keys exactly in English.")
        lines.append("Return JSON {\(jsonKeys)} comparing to WHO norms with one practical recommendation each.")
        return lines.joined(separator: "\n")
    }

    private static func feedingStageLine(for stats: WeeklyStats) -> String {
        if stats.ageMonths < 6 {
            return "Feeding stage: under 6 months - milk-only stage. Do not recommend complementary foods, solids, new foods, or allergens."
        }
        return "Feeding stage: 6 months or older - complementary foods may be discussed if relevant."
    }

    private static func feedingNote(for stats: WeeklyStats) -> String? {
        guard stats.ageMonths < 6 else { return nil }
        let maxInterval = WhoNorms.maxFeedingInterval(ageMonths: stats.ageMonths)
        let expectedMinimum = Int(ceil(1_440.0 / Double(maxInterval)))
        guard stats.avgFeedingsPerDay < Double(expectedMinimum) else { return nil }
        return "Feeding note: logged feedings are low for a baby under 6 months if logging is complete. Treat this as low logged feedings or possibly incomplete logging; do not praise intake as enough. Expected logged pattern is roughly \(expectedMinimum)+ milk feeds/day or max interval ~\(maxInterval) min."
    }

    private static func newFoodsLine(for stats: WeeklyStats, foods: String) -> String {
        guard stats.ageMonths < 6 else {
            return "New foods introduced: \(foods)."
        }
        if stats.newFoodsIntroduced.isEmpty {
            return "New foods introduced: none. For this age, no new foods is expected and age-appropriate."
        }
        return "New foods introduced: \(foods). For this age, do not recommend adding more foods; suggest discussing early solids with a pediatrician if relevant."
    }

    private static func hours(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }

    private static func trendString(_ delta: Int) -> String {
        let absMin = abs(delta)
        if absMin < 10 { return "about the same as last week" }
        return delta > 0 ? "+\(absMin) min/day vs last week" : "-\(absMin) min/day vs last week"
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
