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
            avgSleepMinutesPerDay: 274,
            avgNightSleepMinutes: 220,
            avgDaySleepMinutes: 54,
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

    @Test("uses English instructions with explicit response language")
    func usesEnglishInstructionsWithResponseLanguage() {
        let ctx = WeeklyInsightContext(stats: stats(ageMonths: 3, ageWeeks: 13), language: .russian)

        let system = WeeklyInsightPrompt.system(for: ctx.language)
        let user = WeeklyInsightPrompt.user(ctx: ctx)

        #expect(system.contains("Write every JSON string value in Russian"))
        #expect(user.contains("Baby age: 3 mo (13 weeks)."))
        #expect(user.contains("Response language: Russian"))
        #expect(!user.contains("Возраст малыша"))
    }

    @Test("blocks complementary food advice for babies under six months")
    func blocksComplementaryFoodAdviceUnderSixMonths() {
        let ctx = WeeklyInsightContext(stats: stats(ageMonths: 3, ageWeeks: 13), language: .english)

        let system = WeeklyInsightPrompt.system(for: ctx.language)
        let user = WeeklyInsightPrompt.user(ctx: ctx)

        #expect(system.contains("NEVER recommend complementary foods"))
        #expect(user.contains("Feeding stage: under 6 months - milk-only stage"))
        #expect(user.contains("New foods introduced: none. For this age, no new foods is expected"))
        #expect(user.contains("Expected logged pattern is roughly 6+ milk feeds/day"))
    }

    @Test("allows complementary food context from six months")
    func allowsComplementaryFoodContextFromSixMonths() {
        let ctx = WeeklyInsightContext(
            stats: stats(ageMonths: 6, ageWeeks: 26, avgFeedings: 5.0, totalFeedings: 35, foods: ["Carrot"]),
            language: .english
        )

        let user = WeeklyInsightPrompt.user(ctx: ctx)

        #expect(user.contains("Feeding stage: 6 months or older - complementary foods may be discussed"))
        #expect(user.contains("New foods introduced: Carrot."))
        #expect(!user.contains("low for a baby under 6 months"))
    }

}
