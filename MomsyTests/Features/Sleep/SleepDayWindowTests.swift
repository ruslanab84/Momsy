import Testing
import Foundation
@testable import Momsy

@Suite
struct SleepDayWindowTests {
    private static let cal: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        }
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        let components = DateComponents(
            calendar: Self.cal,
            timeZone: Self.cal.timeZone,
            year: 2026,
            month: 7,
            day: day,
            hour: hour,
            minute: minute
        )
        guard let date = components.date else {
            preconditionFailure("Invalid test date")
        }
        return date
    }

    private var dayStart: Date { date(4, 0) }
    private var dayEnd: Date { date(5, 0) }

    @Test
    func crossMidnightSleepOverlapsBothDays() {
        let start = date(3, 23)
        let end = date(4, 0, 1)

        #expect(SleepDayWindow.overlaps(start: start, end: end, dayStart: date(3, 0), dayEnd: dayStart))
        #expect(SleepDayWindow.overlaps(start: start, end: end, dayStart: dayStart, dayEnd: dayEnd))
    }

    @Test
    func openEntryFromYesterdayOverlapsToday() {
        #expect(
            SleepDayWindow.overlaps(
                start: date(3, 23),
                end: nil,
                dayStart: dayStart,
                dayEnd: dayEnd,
                now: date(4, 0, 30)
            )
        )
    }

    @Test
    func endedBeforeTodayDoesNotOverlap() {
        #expect(
            !SleepDayWindow.overlaps(
                start: date(3, 20),
                end: date(3, 22),
                dayStart: dayStart,
                dayEnd: dayEnd
            )
        )
    }

    @Test
    func endExactlyAtDayStartDoesNotOverlap() {
        #expect(
            !SleepDayWindow.overlaps(
                start: date(3, 23),
                end: dayStart,
                dayStart: dayStart,
                dayEnd: dayEnd
            )
        )
    }

    @Test
    func clippingSplitsNightSleepCorrectly() {
        let start = date(3, 23)
        let end = date(4, 0, 1)

        #expect(
            SleepDayWindow.clippedMinutes(
                start: start,
                end: end,
                dayStart: date(3, 0),
                dayEnd: dayStart
            ) == 60
        )
        #expect(
            SleepDayWindow.clippedMinutes(
                start: start,
                end: end,
                dayStart: dayStart,
                dayEnd: dayEnd
            ) == 1
        )
    }

    @Test
    func clippingFullyInsideDayEqualsDuration() {
        #expect(
            SleepDayWindow.clippedMinutes(
                start: date(4, 13),
                end: date(4, 14, 30),
                dayStart: dayStart,
                dayEnd: dayEnd
            ) == 90
        )
    }

    @Test
    func clippingOutsideDayIsZero() {
        #expect(
            SleepDayWindow.clippedMinutes(
                start: date(3, 20),
                end: date(3, 22),
                dayStart: dayStart,
                dayEnd: dayEnd
            ) == 0
        )
    }
}

@Suite
struct SleepRepositoryOverlapTests {
    private final class StubRepo: SleepRepository {
        var stored: [SleepEntry] = []
        var lastFrom: Date?

        func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
            lastFrom = from
            return stored.filter { $0.startDate >= from && $0.startDate <= to }
        }

        func add(_ entry: SleepEntry) async throws {}
        func upsert(_ entries: [SleepEntry]) async throws {}
        func update(_ entry: SleepEntry) async throws {}
        func delete(id: UUID) async throws {}
    }

    private static let cal: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        }
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        let components = DateComponents(
            calendar: Self.cal,
            timeZone: Self.cal.timeZone,
            year: 2026,
            month: 7,
            day: day,
            hour: hour,
            minute: minute
        )
        guard let date = components.date else {
            preconditionFailure("Invalid test date")
        }
        return date
    }

    @Test
    @MainActor
    func overlappingFetchIncludesCrossMidnightAndOpenEntries() async throws {
        let repo = StubRepo()
        let crossing = SleepEntry(startDate: date(3, 23), endDate: date(4, 0, 1))
        let open = SleepEntry(startDate: date(3, 22), endDate: nil)
        let old = SleepEntry(startDate: date(3, 18), endDate: date(3, 19))
        let today = SleepEntry(startDate: date(4, 13), endDate: date(4, 14))
        repo.stored = [crossing, open, old, today]

        let result = try await repo.getEntries(overlapping: date(4, 0), until: date(5, 0))
        let ids = Set(result.map { $0.id })

        #expect(ids.contains(crossing.id))
        #expect(ids.contains(open.id))
        #expect(ids.contains(today.id))
        #expect(!ids.contains(old.id))
        #expect(repo.lastFrom == date(3, 0))
    }
}
