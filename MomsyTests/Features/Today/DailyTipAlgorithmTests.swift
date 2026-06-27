import Testing
import Foundation
@testable import Momsy

@Suite("DailyTipAlgorithm")
struct DailyTipAlgorithmTests {

    @Test("DailyTip has default category .defaultTip")
    func dailyTip_defaultCategory() {
        let tip = DailyTip(text: "hello", contextHash: "h")
        #expect(tip.category == .defaultTip)
    }

    // MARK: - WhoNorms

    @Test("maxFeedingInterval for 0m is 180")
    func whoNorms_feedingInterval_newborn() {
        #expect(WhoNorms.maxFeedingInterval(ageMonths: 0) == 180)
    }

    @Test("maxFeedingInterval for 6m is 270")
    func whoNorms_feedingInterval_6m() {
        #expect(WhoNorms.maxFeedingInterval(ageMonths: 6) == 270)
    }

    @Test("minSleepMinutes for 0m is 840")
    func whoNorms_minSleep_newborn() {
        #expect(WhoNorms.minSleepMinutes(ageMonths: 0) == 840)
    }

    @Test("maxDaysWithoutStool for 1m is 3")
    func whoNorms_stool_1m() {
        #expect(WhoNorms.maxDaysWithoutStool(ageMonths: 1) == 3)
    }

    @Test("awakeWindowMax for 4m is 110")
    func whoNorms_awakeWindow_4m() {
        #expect(WhoNorms.awakeWindowMax(ageMonths: 4) == 110)
    }

    // MARK: - Alert Rules

    @Test("Alert A fires when minutesSinceLastFeed exceeds maxInterval")
    func alertA_longFeedGap() {
        let ctx = makeContext(ageMonths: 2, minutesSinceLastFeed: 220, hour: 14)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
    }

    @Test("Alert A does not fire when feed was recent")
    func alertA_recentFeed_noAlert() {
        let ctx = makeContext(ageMonths: 2, minutesSinceLastFeed: 60, hour: 14)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    @Test("Alert B fires when diaperCount < 4 in evening for age <= 6")
    func alertB_fewDiapers() {
        let ctx = makeContext(ageMonths: 3, diaperCount: 2, hour: 19)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
    }

    @Test("Alert B does not fire for older baby")
    func alertB_olderBaby_noAlert() {
        let ctx = makeContext(ageMonths: 9, diaperCount: 2, hour: 19)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    @Test("Alert B does not fire when no diapers logged yet (fresh install)")
    func alertB_zeroDiapers_noFalseAlert() {
        let ctx = makeContext(ageMonths: 3, diaperCount: 0, hour: 20)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    @Test("Alert C fires when daysSinceLastStool >= alertDays")
    func alertC_noStool() {
        let ctx = makeContext(ageMonths: 4, daysSinceLastStool: 4, hour: 12)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
    }

    @Test("Alert C does not fire when no stool has ever been logged (fresh install)")
    func alertC_noStoolData_noFalseAlert() {
        let ctx = makeContext(ageMonths: 4, daysSinceLastStool: nil, hour: 12)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    @Test("Alert D fires when totalSleepMinutes is critically low in evening")
    func alertD_sleepDeficit() {
        let ctx = makeContext(ageMonths: 4, totalSleepMinutes: 580, hour: 20)
        let result = AlertRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .alert)
    }

    @Test("Alert D does not fire when no sleep logged yet (fresh install)")
    func alertD_zeroSleep_noFalseAlert() {
        let ctx = makeContext(
            ageMonths: 4,
            diaperCount: 7,
            totalSleepMinutes: 0,
            sleepCount: 0,
            hour: 20
        )
        let result = AlertRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    // MARK: - Situational Rules

    @Test("SITU C fires when awake too long")
    func situC_longAwake() {
        let ctx = makeContext(ageMonths: 3, minutesSinceLastSleepEnd: 120, hour: 10)
        let result = SituationalRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .situational)
    }

    @Test("SITU D fires in evening without bath for baby >= 1m")
    func situD_noBath() {
        let ctx = makeContext(ageMonths: 4, bathCount: 0, hour: 19)
        let result = SituationalRules.evaluate(context: ctx)
        #expect(result != nil)
        #expect(result?.category == .situational)
    }

    @Test("SITU D does not fire in morning")
    func situD_noBath_morning_noAlert() {
        let ctx = makeContext(ageMonths: 4, bathCount: 0, hour: 9)
        let result = SituationalRules.evaluate(context: ctx)
        #expect(result == nil)
    }

    // MARK: - DailyTipAlgorithm

    @Test("evaluate never returns empty text")
    func evaluate_alwaysHasText() {
        let ctx = makeContext(ageMonths: 3)
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(!tip.text.isEmpty)
    }

    @Test("spec example: 4m baby at 18:30 → evening bath tip")
    func evaluate_specExample_bathTip() {
        let ctx = makeContext(
            ageMonths: 4,
            minutesSinceLastFeed: 150,
            diaperCount: 7,
            totalSleepMinutes: 700,
            minutesSinceLastSleepEnd: 95,
            walkCount: 1,
            bathCount: 0,
            daysSinceLastStool: 1,
            hour: 18
        )
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(tip.category == .situational)
        #expect(tip.text.contains("купан") || tip.text.contains("bath") || tip.text.contains("Bad"))
    }

    @Test("evaluate returns .alert when feed interval exceeded")
    func evaluate_alertCategory_whenFeedLate() {
        let ctx = makeContext(ageMonths: 1, minutesSinceLastFeed: 200, hour: 15)
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(tip.category == .alert)
    }

    @Test("fresh install in evening with no logged data is never an alarming zero tip")
    func evaluate_freshInstall_evening_noZeroAlert() {
        let ctx = makeContext(
            ageMonths: 2,
            minutesSinceLastFeed: nil,
            diaperCount: 0,
            totalSleepMinutes: 0,
            sleepCount: 0,
            feedingCount: 0,
            minutesSinceLastSleepEnd: nil,
            walkCount: 0,
            bathCount: 0,
            daysSinceLastStool: 0,
            hour: 20
        )
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(tip.category != .alert)
        #expect(!tip.text.contains("0 ч"))
        #expect(!tip.text.contains("0 подгузник"))
    }

    @Test("evaluate returns .care when no conditions fire")
    func evaluate_careCategory_whenIdle() {
        let ctx = makeContext(
            ageMonths: 4,
            minutesSinceLastFeed: 90,
            diaperCount: 7,
            totalSleepMinutes: 700,
            minutesSinceLastSleepEnd: 60,
            walkCount: 1,
            bathCount: 1,
            daysSinceLastStool: 0,
            hour: 12
        )
        let tip = DailyTipAlgorithm.evaluate(context: ctx)
        #expect(tip.category == .care)
    }

    // MARK: - Helper

    private func makeContext(
        ageMonths: Int = 3,
        minutesSinceLastFeed: Int? = nil,
        diaperCount: Int = 7,
        totalSleepMinutes: Int = 750,
        sleepCount: Int = 3,
        feedingCount: Int = 6,
        minutesSinceLastSleepEnd: Int? = nil,
        walkCount: Int = 1,
        bathCount: Int = 0,
        daysSinceLastStool: Int? = 0,
        hour: Int = 10,
        language: Language = .russian
    ) -> DailyContext {
        DailyContext(
            babyName: "Лёва",
            ageMonths: ageMonths,
            ageDays: 15,
            currentLeapName: nil,
            feedingCount: feedingCount,
            totalFeedingMinutes: 90,
            minutesSinceLastFeed: minutesSinceLastFeed,
            lastFeedSide: nil,
            sleepCount: sleepCount,
            totalSleepMinutes: totalSleepMinutes,
            diaperCount: diaperCount,
            timeOfDay: .morning,
            language: language,
            hour: hour,
            minutesSinceLastSleepEnd: minutesSinceLastSleepEnd,
            walkCount: walkCount,
            bathCount: bathCount,
            daysSinceLastStool: daysSinceLastStool,
            dayOfYear: 148,
            lastFeedDurationMinutes: 15,
            recentFeedSides: []
        )
    }
}
