import Foundation
import Testing
@testable import Momsy

struct UnitSystemTimeFormatTests {
    @Test("The same log date uses each viewer's local unit system")
    func formatsTimeForCurrentViewer() throws {
        let timeZone = try #require(TimeZone(secondsFromGMT: 0))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let date = try #require(calendar.date(
            from: DateComponents(year: 2026, month: 7, day: 25, hour: 13, minute: 5)
        ))
        let locale = Locale(identifier: "en_US_POSIX")

        #expect(date.formatted(UnitSystem.metric.timeFormatStyle(
            locale: locale,
            calendar: calendar,
            timeZone: timeZone
        )) == "13:05")
        #expect(date.formatted(UnitSystem.imperial.timeFormatStyle(
            locale: locale,
            calendar: calendar,
            timeZone: timeZone
        )) == "1:05\u{202F}PM")
    }
}
