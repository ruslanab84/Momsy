import Testing
@testable import Momsy
import Foundation

@Suite("SleepForecastEngine")
@MainActor
struct SleepForecastEngineTests {

    private let cal = Calendar.current
    private let engine = DeterministicSleepForecastEngine()

    // MARK: - Fixtures

    /// Midnight anchor for a fixed, DST-stable day.
    private func makeToday() throws -> Date {
        var c = DateComponents()
        c.year = 2025; c.month = 6; c.day = 10; c.hour = 0; c.minute = 0
        return try #require(cal.date(from: c))
    }

    private func at(_ day: Date, _ hour: Int, _ minute: Int) throws -> Date {
        try #require(cal.date(bySettingHour: hour, minute: minute, second: 0, of: day))
    }

    private func birth(_ today: Date, daysOld: Int) throws -> Date {
        try #require(cal.date(byAdding: .day, value: -daysOld, to: today))
    }

    private func entry(_ start: Date, _ end: Date?) -> SleepEntry {
        SleepEntry(startDate: start, endDate: end)
    }

    /// `n` days, each with two daytime naps (08:00–09:15, 11:15–12:30).
    /// Yields exactly one valid 120-min daytime wake window per day; cross-day
    /// pairs are excluded because their endpoints fall on different calendar days.
    private func evenDays(_ n: Int, today: Date) throws -> [SleepEntry] {
        var result: [SleepEntry] = []
        for d in 0..<n {
            let day = try #require(cal.date(byAdding: .day, value: -d, to: today))
            result.append(entry(try at(day, 8, 0), try at(day, 9, 15)))
            result.append(entry(try at(day, 11, 15), try at(day, 12, 30)))
        }
        return result
    }

    // MARK: - 1. Even ~2h windows, ≥8 samples → nap, high

    @Test("personalized nap forecast at high confidence")
    func evenWindowsHighConfidence() throws {
        let today = try makeToday()
        let now = try at(today, 14, 0)
        let entries = try evenDays(9, today: today)
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: entries, now: now))
        #expect(pred.kind == .nap)
        #expect(pred.confidence == .high)
        #expect(pred.basis == .personalized(samples: 9))
        let anchor = try at(today, 12, 30)
        let deltaMin = pred.predictedOnset.timeIntervalSince(anchor) / 60
        #expect(deltaMin >= 100 && deltaMin <= 140)
    }

    // MARK: - 2. Outlier gap filtered out

    @Test("a single 6h gap is filtered and does not move the window")
    func outlierFiltered() throws {
        let today = try makeToday()
        let now = try at(today, 14, 0)
        var entries = try evenDays(5, today: today)
        // Broken day with a 6h daytime gap (missed log) — must be discarded.
        let brokenDay = try #require(cal.date(byAdding: .day, value: -6, to: today))
        entries.append(entry(try at(brokenDay, 7, 0), try at(brokenDay, 8, 0)))
        entries.append(entry(try at(brokenDay, 14, 0), try at(brokenDay, 14, 30)))

        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: entries, now: now))
        let anchor = try at(today, 12, 30)
        let deltaMin = pred.predictedOnset.timeIntervalSince(anchor) / 60
        #expect(deltaMin < 160) // stays near the ~120-min typical, not pulled toward 360
    }

    // MARK: - 3. Confidence thresholds 3 / 5 / 8

    @Test("sample count maps to low / medium / high confidence")
    func confidenceThresholds() throws {
        let today = try makeToday()
        let now = try at(today, 14, 0)
        let b = try birth(today, daysOld: 150)
        #expect(engine.predict(birthDate: b, entries: try evenDays(3, today: today), now: now)?.confidence == .low)
        #expect(engine.predict(birthDate: b, entries: try evenDays(5, today: today), now: now)?.confidence == .medium)
        #expect(engine.predict(birthDate: b, entries: try evenDays(8, today: today), now: now)?.confidence == .high)
    }

    // MARK: - 4. Sleeping now → anchor = start + typicalNapMinutes

    @Test("an ongoing sleep anchors onset to expected wake-up")
    func sleepingNowAnchor() throws {
        let today = try makeToday()
        let start = try at(today, 13, 0)
        let entries = [entry(start, nil)]
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: entries, now: try at(today, 13, 30)))
        // typicalNapMinutes 75 + age-only window 127 (months4to6).
        let expected = start.addingTimeInterval(TimeInterval((75 + 127) * 60))
        #expect(abs(pred.predictedOnset.timeIntervalSince(expected)) < 90)
        #expect(pred.basis == .ageOnly)
    }

    // MARK: - 5. No logs → age-only, low confidence, built from morning

    @Test("no logs falls back to age-only morning forecast")
    func noLogsAgeOnly() throws {
        let today = try makeToday()
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: [], now: try at(today, 10, 0)))
        #expect(pred.basis == .ageOnly)
        #expect(pred.confidence == .low)
        #expect(pred.napsRemaining == 4)
        #expect(cal.component(.hour, from: pred.predictedOnset) == 8) // 06:00 + 127 min
    }

    // MARK: - 6. Daytime naps exhausted → bedtime

    @Test("no naps remaining yields a bedtime forecast")
    func napsExhaustedBedtime() throws {
        let today = try makeToday()
        let entries = [
            entry(try at(today, 8, 0), try at(today, 9, 30)),
            entry(try at(today, 13, 0), try at(today, 14, 30))
        ]
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 300),
                                               entries: entries, now: try at(today, 16, 0)))
        #expect(pred.kind == .bedtime)
        #expect(pred.napsRemaining == 0)
    }

    // MARK: - 7. Onset in deep night → nil

    @Test("a deep-night onset produces no forecast")
    func deepNightReturnsNil() throws {
        let today = try makeToday()
        let entries = [entry(try at(today, 14, 0), try at(today, 18, 0))]
        let pred = engine.predict(birthDate: try birth(today, daysOld: 400),
                                  entries: entries, now: try at(today, 18, 30))
        #expect(pred == nil)
    }

    // MARK: - 8. No birthDate (age < 0) → nil

    @Test("a future birth date returns nil")
    func futureBirthDateReturnsNil() throws {
        let today = try makeToday()
        let future = try #require(cal.date(byAdding: .day, value: 10, to: today))
        #expect(engine.predict(birthDate: future, entries: [], now: today) == nil)
    }

    // MARK: - 9. Elapsed window → overdue, with awake duration

    @Test("an elapsed window flags overdue and reports minutes awake")
    func elapsedWindowIsOverdue() throws {
        let today = try makeToday()
        // Woke at 07:00; ideal onset lands ~08:15, but it is now 11:00.
        let entries = [entry(try at(today, 6, 0), try at(today, 7, 0))]
        let now = try at(today, 11, 0)
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 60),
                                               entries: entries, now: now))
        #expect(pred.isOverdue)
        #expect(pred.minutesAwake == 240)                     // 07:00 → 11:00
        #expect(pred.predictedOnset < now)                    // onset stays the (past) ideal
    }

    // MARK: - 10. Window still ahead → not overdue

    @Test("an upcoming window is not overdue")
    func upcomingWindowIsNotOverdue() throws {
        let today = try makeToday()
        let entries = [entry(try at(today, 12, 0), try at(today, 13, 0))]
        let now = try at(today, 13, 10)
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 60),
                                               entries: entries, now: now))
        #expect(pred.predictedOnset > now)
        #expect(!pred.isOverdue)
    }

    // MARK: - 11. Sleeping now → never overdue, awake is nil

    @Test("an ongoing sleep is never overdue")
    func sleepingNowIsNotOverdue() throws {
        let today = try makeToday()
        let entries = [entry(try at(today, 13, 0), nil)]
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 60),
                                               entries: entries, now: try at(today, 13, 30)))
        #expect(!pred.isOverdue)
        #expect(pred.minutesAwake == nil)
    }
}
