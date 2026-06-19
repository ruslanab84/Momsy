import Testing
import Foundation
@testable import Momsy

@Suite("DailyContextBuilder")
@MainActor
struct DailyContextBuilderTests {

    private func makeTestAppState(monthsOld: Int = 3) -> AppState {
        let profile = BabyProfile(
            id: UUID(),
            name: "Лёва",
            birthDate: Calendar.current.date(byAdding: .month, value: -monthsOld, to: Date()) ?? Date(),
            gender: "boy"
        )
        let repo = MockBabyRepository(initialProfile: profile)
        let state = AppState(getBabyProfile: GetBabyProfileUseCase(repository: repo),
                             getAllBabies: GetAllBabiesUseCase(repository: repo))
        state.babyProfile = profile
        return state
    }

    private func feedingEntry(minutesAgo: Int = 60, durationMin: Int = 15, side: String = "левая") -> LogEntry {
        LogEntry(
            time: Date().addingTimeInterval(-TimeInterval(minutesAgo * 60)),
            kind: .bottle,
            label: "Кормление · \(durationMin) мин · \(side)",
            durationMinutes: durationMin,
            feedSide: side
        )
    }

    private func sleepEntry(minutesAgo: Int = 120, durationH: Int = 1, durationM: Int = 30) -> LogEntry {
        LogEntry(
            time: Date().addingTimeInterval(-TimeInterval(minutesAgo * 60)),
            kind: .sleep,
            label: "Сон · \(durationH) ч \(durationM) м",
            durationMinutes: durationH * 60 + durationM
        )
    }

    @Test("counts feeding entries correctly")
    func build_countsFeedingsCorrectly() {
        let entries = [feedingEntry(), feedingEntry(minutesAgo: 180), feedingEntry(minutesAgo: 360)]
        let ctx = DailyContextBuilder.build(from: entries, diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.feedingCount == 3)
    }

    @Test("sums feeding minutes from labels")
    func build_sumsFeedingMinutes() {
        let entries = [feedingEntry(durationMin: 15), feedingEntry(durationMin: 20)]
        let ctx = DailyContextBuilder.build(from: entries, diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.totalFeedingMinutes == 35)
    }

    @Test("computes minutesSinceLastFeed from most recent bottle entry")
    func build_computesMinutesSinceLastFeed() {
        let entries = [feedingEntry(minutesAgo: 45)]
        let ctx = DailyContextBuilder.build(from: entries, diaperCount: 0, appState: makeTestAppState())
        // Allow ±2 min tolerance for test timing
        #expect(abs((ctx.minutesSinceLastFeed ?? 0) - 45) <= 2)
    }

    @Test("extracts last feed side from label")
    func build_extractsLastFeedSide() {
        let entries = [feedingEntry(side: "правая")]
        let ctx = DailyContextBuilder.build(from: entries, diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.lastFeedSide == "правая")
    }

    @Test("counts sleep entries correctly")
    func build_countsSleepEntries() {
        let entries = [sleepEntry(), sleepEntry(minutesAgo: 240)]
        let ctx = DailyContextBuilder.build(from: entries, diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.sleepCount == 2)
    }

    @Test("sums sleep minutes from Russian labels")
    func build_sumsSleepMinutesRU() {
        let entries = [sleepEntry(durationH: 1, durationM: 30), sleepEntry(durationH: 0, durationM: 45)]
        let ctx = DailyContextBuilder.build(from: entries, diaperCount: 0, appState: makeTestAppState())
        // 90 + 45 = 135
        #expect(ctx.totalSleepMinutes == 135)
    }

    @Test("contextHash changes when diaperCount changes")
    func contextHash_changesWhenDiaperAdded() {
        let appState = makeAppState()
        let ctx0 = DailyContextBuilder.build(from: [], diaperCount: 0, appState: appState)
        let ctx1 = DailyContextBuilder.build(from: [], diaperCount: 1, appState: appState)
        #expect(ctx0.contextHash != ctx1.contextHash)
    }

    @Test("returns zero counts for empty entries")
    func build_emptyEntries() {
        let ctx = DailyContextBuilder.build(from: [], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.feedingCount == 0)
        #expect(ctx.sleepCount == 0)
        #expect(ctx.minutesSinceLastFeed == nil)
    }

    @Test("build sets walkCount from .walk entries")
    func build_countsWalkEntries() {
        let walk = LogEntry(time: Date(), kind: .walk, label: "Walk logged")
        let ctx = DailyContextBuilder.build(from: [walk], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.walkCount == 1)
    }

    @Test("build sets bathCount from .bath entries")
    func build_countsBathEntries() {
        let bath1 = LogEntry(time: Date(), kind: .bath, label: "Bath logged")
        let bath2 = LogEntry(time: Date().addingTimeInterval(-3600), kind: .bath, label: "Bath logged")
        let ctx = DailyContextBuilder.build(from: [bath1, bath2], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.bathCount == 2)
    }

    @Test("build sets dayOfYear to non-zero")
    func build_setsDayOfYear() {
        let ctx = DailyContextBuilder.build(from: [], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.dayOfYear > 0)
    }

    @Test("build passes daysSinceLastStool parameter")
    func build_setsDaysSinceLastStool() {
        let ctx = DailyContextBuilder.build(from: [], diaperCount: 0, daysSinceLastStool: 3, appState: makeTestAppState())
        #expect(ctx.daysSinceLastStool == 3)
    }

    @Test("build sets lastFeedDurationMinutes from most recent bottle label")
    func build_setsLastFeedDuration() {
        let entry = feedingEntry(minutesAgo: 10, durationMin: 18, side: "левая")
        let ctx = DailyContextBuilder.build(from: [entry], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.lastFeedDurationMinutes == 18)
    }

    @Test("build populates recentFeedSides from labels")
    func build_setsRecentFeedSides() {
        let e1 = feedingEntry(minutesAgo: 5, durationMin: 15, side: "левая")
        let e2 = feedingEntry(minutesAgo: 120, durationMin: 15, side: "правая")
        let ctx = DailyContextBuilder.build(from: [e1, e2], diaperCount: 0, appState: makeTestAppState())
        #expect(ctx.recentFeedSides.count == 2)
        #expect(ctx.recentFeedSides[0] == "левая")
    }
}
