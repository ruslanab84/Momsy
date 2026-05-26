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
        let state = AppState(getBabyProfile: GetBabyProfileUseCase(repository: repo))
        state.babyProfile = profile
        return state
    }

    private func feedingEntry(minutesAgo: Int = 60, durationMin: Int = 15, side: String = "левая") -> LogEntry {
        LogEntry(
            time: Date().addingTimeInterval(-TimeInterval(minutesAgo * 60)),
            kind: .bottle,
            label: "Кормление · \(durationMin) мин · \(side)"
        )
    }

    private func sleepEntry(minutesAgo: Int = 120, durationH: Int = 1, durationM: Int = 30) -> LogEntry {
        LogEntry(
            time: Date().addingTimeInterval(-TimeInterval(minutesAgo * 60)),
            kind: .sleep,
            label: "Сон · \(durationH) ч \(durationM) м"
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
}
