import Testing
@testable import Momsy
import Foundation

@Suite("StaticWeeklyInsightService")
struct StaticWeeklyInsightServiceTests {

    private func stats(
        avgSleep: Int,
        ageMonths: Int,
        avgFeedings: Double = 6,
        foods: [String] = [],
        allergens: [String] = []
    ) -> WeeklyStats {
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        return WeeklyStats(
            weekStart: start,
            weekEnd: start.addingTimeInterval(7 * 86_400),
            ageMonths: ageMonths,
            ageWeeks: ageMonths * 4,
            currentLeapName: nil,
            currentLeapID: nil,
            leapSignals: [],
            avgSleepMinutesPerDay: avgSleep,
            avgNightSleepMinutes: avgSleep * 2 / 3,
            avgDaySleepMinutes: avgSleep / 3,
            avgNapsPerDay: 3,
            sleepTrendVsPrevWeekMinutes: -25,
            whoMinSleepMinutes: WhoNorms.minSleepMinutes(ageMonths: ageMonths),
            whoAwakeWindowMax: WhoNorms.awakeWindowMax(ageMonths: ageMonths),
            avgFeedingsPerDay: avgFeedings,
            totalFeedings: Int(avgFeedings * 7),
            newFoodsIntroduced: foods,
            allergensFlagged: allergens,
            totalDiapers: 35
        )
    }

    @Test("produces a non-empty narrative in every app language")
    func nonEmpty() async throws {
        let service = StaticWeeklyInsightService()
        for language in Language.allCases {
            let context = WeeklyInsightContext(
                stats: stats(avgSleep: 700, ageMonths: 7),
                language: language
            )
            let ai = try await service.generate(context: context)
            #expect(!ai.sleepSummary.isEmpty)
            #expect(!ai.sleepRecommendation.isEmpty)
            #expect(!ai.feedingSummary.isEmpty)
            #expect(!ai.feedingRecommendation.isEmpty)
            #expect(!ai.overallSummary.isEmpty)
        }
    }

    @Test("English fallback explains actual sleep, full WHO range, and exact deficit")
    func englishSleepComparisonIsDetailed() async throws {
        let service = StaticWeeklyInsightService()
        let context = WeeklyInsightContext(
            stats: stats(avgSleep: 600, ageMonths: 7),
            language: .english
        )

        let ai = try await service.generate(context: context)

        #expect(ai.sleepSummary.contains("10h"))
        #expect(ai.sleepSummary.contains("12h to 16h"))
        #expect(ai.sleepSummary.contains("below the lower end"))
        #expect(ai.sleepSummary.contains("2h per day"))
        #expect(ai.sleepSummary.contains("logged"))
    }

    @Test("Russian fallback explains actual sleep, WHO range, and exact deficit")
    func russianSleepComparisonIsDetailed() async throws {
        let service = StaticWeeklyInsightService()
        let context = WeeklyInsightContext(
            stats: stats(avgSleep: 600, ageMonths: 7),
            language: .russian
        )

        let ai = try await service.generate(context: context)

        #expect(ai.sleepSummary.contains("10 ч"))
        #expect(ai.sleepSummary.contains("12 ч–16 ч"))
        #expect(ai.sleepSummary.contains("ниже нижней границы"))
        #expect(ai.sleepSummary.contains("2 ч"))
        #expect(ai.sleepSummary.contains("запис"))
    }

    @Test("under-six-month fallback does not recommend solids from a low logged count")
    func underSixMonthsIsAgeSafe() async throws {
        let service = StaticWeeklyInsightService()
        let context = WeeklyInsightContext(
            stats: stats(avgSleep: 900, ageMonths: 3, avgFeedings: 3),
            language: .english
        )

        let ai = try await service.generate(context: context)

        #expect(ai.feedingSummary.contains("app's reminder heuristic"))
        #expect(ai.feedingSummary.contains("not a WHO clinical intake target"))
        #expect(ai.feedingRecommendation.contains("Do not introduce solids or water"))
    }

    @Test("warns against re-introducing flagged allergens")
    func allergenWarning() async throws {
        let service = StaticWeeklyInsightService()
        let context = WeeklyInsightContext(
            stats: stats(avgSleep: 700, ageMonths: 8, allergens: ["Egg"]),
            language: .english
        )

        let ai = try await service.generate(context: context)

        #expect(ai.feedingSummary.contains("Egg"))
        #expect(ai.feedingRecommendation.contains("Do not reintroduce"))
    }

    @Test("mentions leap signals without claiming causation")
    func mentionsLeapSignals() async throws {
        let service = StaticWeeklyInsightService()
        let base = stats(avgSleep: 700, ageMonths: 4)
        let withLeap = WeeklyStats(
            weekStart: base.weekStart,
            weekEnd: base.weekEnd,
            ageMonths: base.ageMonths,
            ageWeeks: base.ageWeeks,
            currentLeapName: "World of Events",
            currentLeapID: 4,
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

        let ai = try await service.generate(
            context: WeeklyInsightContext(stats: withLeap, language: .english)
        )

        #expect(ai.overallSummary.contains("leap #4"))
        #expect(ai.overallSummary.contains("new skills"))
        #expect(ai.overallSummary.contains("without proving"))
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

    @Test("uses explicit response language and structured section depth")
    func usesResponseLanguageAndStructuredDepth() {
        let context = WeeklyInsightContext(
            stats: stats(ageMonths: 3, ageWeeks: 13),
            language: .russian
        )

        let system = WeeklyInsightPrompt.system(for: context.language)
        let user = WeeklyInsightPrompt.user(ctx: context)

        #expect(system.contains("Every value must be an ARRAY"))
        #expect(system.contains("written in Russian"))
        #expect(system.contains("sleepSummary: 4-6 sentences"))
        #expect(user.contains("BABY: age 3 months (13 weeks)."))
        #expect(user.contains("OUTPUT LANGUAGE: Russian"))
        #expect(!user.contains("Возраст малыша"))
    }

    @Test("uses the full WHO sleep range and deterministic deficit")
    func usesFullSleepRangeAndDeficit() {
        let context = WeeklyInsightContext(
            stats: stats(ageMonths: 7, avgSleep: 600, avgFeedings: 6),
            language: .english
        )

        let user = WeeklyInsightPrompt.user(ctx: context)

        #expect(user.contains("WHO range 12h-16h"))
        #expect(user.contains("below the WHO range by 2h per day (120 minutes/day)"))
        #expect(user.contains("Use this exact classification"))
    }

    @Test("keeps the two-year-old WHO range at 11 to 14 hours")
    func twoYearOldSleepRange() {
        #expect(WhoNorms.sleepRangeMinutes(ageMonths: 24) == 660...840)
        #expect(WhoNorms.sleepRangeMinutes(ageMonths: 36) == 600...780)
    }

    @Test("separates WHO guidance from the app feed heuristic under six months")
    func underSixMonthFeedingGuidance() {
        let context = WeeklyInsightContext(
            stats: stats(ageMonths: 3, ageWeeks: 13),
            language: .english
        )

        let system = WeeklyInsightPrompt.system(for: context.language)
        let user = WeeklyInsightPrompt.user(ctx: context)

        #expect(system.contains("never recommend complementary foods"))
        #expect(user.contains("WHO breastfeeding guidance recommends exclusive breastfeeding"))
        #expect(user.contains("app logging heuristic of about 6+ feeds/day"))
        #expect(user.contains("not a WHO clinical intake target"))
        #expect(user.contains("NEW FOOD DIARY: none, which is age-appropriate before 6 months"))
    }

    @Test("includes WHO meal guidance without making a false meal-frequency classification")
    func complementaryFoodContextFromSixMonths() {
        let context = WeeklyInsightContext(
            stats: stats(
                ageMonths: 6,
                ageWeeks: 26,
                avgFeedings: 5.0,
                totalFeedings: 35,
                foods: ["Carrot"]
            ),
            language: .english
        )

        let user = WeeklyInsightPrompt.user(ctx: context)

        #expect(user.contains("WHO complementary-food reference is 2-3 meals/day"))
        #expect(user.contains("meal-frequency status cannot be determined"))
        #expect(user.contains("NEW FOOD DIARY: Carrot"))
        #expect(!user.contains("low for a baby under 6 months"))
    }
}

@Suite("GeminiWeeklyInsightService decoding")
struct GeminiWeeklyInsightServiceDecodingTests {

    @Test("joins schema-controlled sentence arrays into readable paragraphs")
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

        #expect(decoded?.sleepSummary == "Sleep one.\n\nSleep two.\n\nSleep three.\n\nSleep four.")
        #expect(decoded?.feedingRecommendation.contains("Feed action three."))
        #expect(decoded?.overallSummary.contains("Overall three."))
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
