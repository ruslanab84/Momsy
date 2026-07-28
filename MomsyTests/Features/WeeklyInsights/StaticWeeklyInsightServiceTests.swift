import Testing
@testable import Momsy
import Foundation

@Suite("StaticWeeklyInsightService")
struct StaticWeeklyInsightServiceTests {

    private func stats(avgSleep: Int, ageMonths: Int, foods: [String] = [], allergens: [String] = []) -> WeeklyStats {
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        return WeeklyStats(
            weekStart: start, weekEnd: start.addingTimeInterval(7 * 86400),
            ageMonths: ageMonths, ageWeeks: ageMonths * 4, currentLeapName: nil,
            currentLeapID: nil, leapSignals: [],
            avgSleepMinutesPerDay: avgSleep, avgNightSleepMinutes: avgSleep * 2 / 3,
            avgDaySleepMinutes: avgSleep / 3, avgNapsPerDay: 3,
            sleepTrendVsPrevWeekMinutes: 0,
            whoMinSleepMinutes: WhoNorms.minSleepMinutes(ageMonths: ageMonths),
            whoAwakeWindowMax: WhoNorms.awakeWindowMax(ageMonths: ageMonths),
            avgFeedingsPerDay: 6, totalFeedings: 42,
            newFoodsIntroduced: foods, allergensFlagged: allergens, totalDiapers: 35
        )
    }

    @Test("produces non-empty narrative in each language")
    func nonEmpty() async throws {
        let service = StaticWeeklyInsightService()
        for lang in [Language.english, .russian, .german, .spanish] {
            let ctx = WeeklyInsightContext(stats: stats(avgSleep: 700, ageMonths: 7), language: lang)
            let ai = try await service.generate(context: ctx)
            #expect(!ai.sleepSummary.isEmpty)
            #expect(!ai.feedingSummary.isEmpty)
            #expect(!ai.overallSummary.isEmpty)
        }
    }

    @Test("recommends more rest when below WHO norm")
    func belowNorm() async throws {
        let service = StaticWeeklyInsightService()
        let below = WeeklyInsightContext(stats: stats(avgSleep: 300, ageMonths: 7), language: .english)
        let above = WeeklyInsightContext(stats: stats(avgSleep: 900, ageMonths: 7), language: .english)
        let belowAI = try await service.generate(context: below)
        let aboveAI = try await service.generate(context: above)
        #expect(belowAI.sleepRecommendation != aboveAI.sleepRecommendation)
    }

    @Test("warns against re-introducing flagged allergens")
    func allergenWarning() async throws {
        let service = StaticWeeklyInsightService()
        let ctx = WeeklyInsightContext(stats: stats(avgSleep: 700, ageMonths: 8, allergens: ["Egg"]), language: .english)
        let ai = try await service.generate(context: ctx)
        #expect(ai.feedingRecommendation.contains("Egg"))
    }

    @Test("mentions leap signals in the offline summary")
    func mentionsLeapSignals() async throws {
        let service = StaticWeeklyInsightService()
        var base = stats(avgSleep: 700, ageMonths: 4)
        base = WeeklyStats(
            weekStart: base.weekStart, weekEnd: base.weekEnd,
            ageMonths: base.ageMonths, ageWeeks: base.ageWeeks,
            currentLeapName: "World of Events", currentLeapID: 4,
            leapSignals: ["sleep", "feedings", "new skills"],
            avgSleepMinutesPerDay: base.avgSleepMinutesPerDay,
            avgNightSleepMinutes: base.avgNightSleepMinutes,
            avgDaySleepMinutes: base.avgDaySleepMinutes,
            avgNapsPerDay: base.avgNapsPerDay,
            sleepTrendVsPrevWeekMinutes: base.sleepTrendVsPrevWeekMinutes,
            whoMinSleepMinutes: base.whoMinSleepMinutes,
            whoAwakeWindowMax: base.whoAwakeWindowMax,
            avgFeedingsPerDay: base.avgFeedingsPerDay,
            totalFeedings: base.totalFeedings,
            newFoodsIntroduced: base.newFoodsIntroduced,
            allergensFlagged: base.allergensFlagged,
            totalDiapers: base.totalDiapers
        )

        let ai = try await service.generate(context: WeeklyInsightContext(stats: base, language: .english))

        #expect(ai.overallSummary.contains("leap #4"))
        #expect(ai.overallSummary.contains("new skills"))
    }
}

@Suite("WeeklyInsightPrompt")
struct WeeklyInsightPromptTests {

    private func stats(
        ageMonths: Int,
        ageWeeks: Int? = nil,
        avgSleep: Int = 274,
        avgFeedings: Double = 3.1,
        totalFeedings: Int = 22,
        foods: [String] = []
    ) -> WeeklyStats {
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        return WeeklyStats(
            weekStart: start,
            weekEnd: start.addingTimeInterval(7 * 86_400),
            ageMonths: ageMonths,
            ageWeeks: ageWeeks ?? ageMonths * 4,
            currentLeapName: nil,
            currentLeapID: nil,
            leapSignals: [],
            avgSleepMinutesPerDay: avgSleep,
            avgNightSleepMinutes: avgSleep * 2 / 3,
            avgDaySleepMinutes: avgSleep / 3,
            avgNapsPerDay: 3.0,
            sleepTrendVsPrevWeekMinutes: 0,
            whoMinSleepMinutes: WhoNorms.minSleepMinutes(ageMonths: ageMonths),
            whoAwakeWindowMax: WhoNorms.awakeWindowMax(ageMonths: ageMonths),
            avgFeedingsPerDay: avgFeedings,
            totalFeedings: totalFeedings,
            newFoodsIntroduced: foods,
            allergensFlagged: [],
            totalDiapers: 20
        )
    }

    @Test("uses English instructions with explicit response language and structured depth")
    func usesEnglishInstructionsWithResponseLanguage() {
        let ctx = WeeklyInsightContext(stats: stats(ageMonths: 3, ageWeeks: 13), language: .russian)

        let system = WeeklyInsightPrompt.system(for: ctx.language)
        let user = WeeklyInsightPrompt.user(ctx: ctx)

        #expect(system.contains("Every value must be an ARRAY"))
        #expect(system.contains("written in Russian"))
        #expect(system.contains("sleepSummary: 4-6 sentences"))
        #expect(user.contains("BABY: age 3 months (13 weeks)."))
        #expect(user.contains("OUTPUT LANGUAGE: Russian"))
        #expect(!user.contains("Возраст малыша"))
    }

    @Test("uses the full WHO sleep range and deterministic deficit")
    func usesFullSleepRangeAndDeficit() {
        let ctx = WeeklyInsightContext(
            stats: stats(ageMonths: 7, avgSleep: 600, avgFeedings: 6),
            language: .english
        )

        let user = WeeklyInsightPrompt.user(ctx: ctx)

        #expect(user.contains("WHO range 12h-16h"))
        #expect(user.contains("below the WHO range by 2h per day (120 minutes/day)"))
        #expect(user.contains("Use this exact classification"))
    }

    @Test("blocks complementary food advice and separates WHO from app feed heuristic under six months")
    func blocksComplementaryFoodAdviceUnderSixMonths() {
        let ctx = WeeklyInsightContext(stats: stats(ageMonths: 3, ageWeeks: 13), language: .english)

        let system = WeeklyInsightPrompt.system(for: ctx.language)
        let user = WeeklyInsightPrompt.user(ctx: ctx)

        #expect(system.contains("never recommend complementary foods"))
        #expect(user.contains("WHO guidance is exclusive milk feeding"))
        #expect(user.contains("app logging heuristic of about 6+ feeds/day"))
        #expect(user.contains("not a WHO clinical intake target"))
        #expect(user.contains("NEW FOOD DIARY: none, which is age-appropriate before 6 months"))
    }

    @Test("includes WHO complementary meal guidance but refuses a false meal-frequency classification")
    func complementaryFoodContextFromSixMonths() {
        let ctx = WeeklyInsightContext(
            stats: stats(ageMonths: 6, ageWeeks: 26, avgFeedings: 5.0, totalFeedings: 35, foods: ["Carrot"]),
            language: .english
        )

        let user = WeeklyInsightPrompt.user(ctx: ctx)

        #expect(user.contains("WHO complementary-food reference is 2-3 meals/day"))
        #expect(user.contains("meal-frequency status cannot be determined"))
        #expect(user.contains("NEW FOOD DIARY: Carrot"))
        #expect(!user.contains("low for a baby under 6 months"))
    }
}

@Suite("WhoNorms weekly report ranges")
struct WhoNormsWeeklyReportTests {

    @Test("uses the complete WHO sleep range without changing legacy Today thresholds")
    func separatesWeeklyRangeFromTodayThreshold() {
        #expect(WhoNorms.sleepRangeMinutes(ageMonths: 2) == 840...1_020)
        #expect(WhoNorms.minSleepMinutes(ageMonths: 2) == 810)
        #expect(WhoNorms.sleepRangeMinutes(ageMonths: 7) == 720...960)
    }

    @Test("uses WHO complementary meal frequency only where defined")
    func complementaryMealRanges() {
        #expect(WhoNorms.complementaryMealsPerDay(ageMonths: 5) == nil)
        #expect(WhoNorms.complementaryMealsPerDay(ageMonths: 7) == 2...3)
        #expect(WhoNorms.complementaryMealsPerDay(ageMonths: 12) == 3...4)
    }
}

@Suite("GeminiWeeklyInsightService decoding")
struct GeminiWeeklyInsightServiceDecodingTests {

    @Test("joins schema-controlled sentence arrays into UI strings")
    func joinsStructuredArrays() {
        let raw = """
        {
          "sleepSummary": ["Sleep one.", "Sleep two.", "Sleep three.", "Sleep four."],
          "sleepRecommendation": ["Sleep action one.", "Sleep action two.", "Sleep action three."],
          "feedingSummary": ["Feed one.", "Feed two.", "Feed three.", "Feed four."],
          "feedingRecommendation": ["Feed action one.", "Feed action two.", "Feed action three."],
          "overallSummary": ["Overall one.", "Overall two.", "Overall three."]
        }
        """

        let decoded = GeminiWeeklyInsightService.decode(raw)

        #expect(decoded?.sleepSummary == "Sleep one. Sleep two. Sleep three. Sleep four.")
        #expect(decoded?.feedingRecommendation.contains("Feed action three.") == true)
        #expect(decoded?.overallSummary.contains("Overall three.") == true)
    }

    @Test("rejects schema arrays that are too shallow")
    func rejectsShallowStructuredArrays() {
        let raw = """
        {
          "sleepSummary": ["Too short."],
          "sleepRecommendation": ["Too short."],
          "feedingSummary": ["Too short."],
          "feedingRecommendation": ["Too short."],
          "overallSummary": ["Too short."]
        }
        """

        #expect(GeminiWeeklyInsightService.decode(raw) == nil)
    }
}
