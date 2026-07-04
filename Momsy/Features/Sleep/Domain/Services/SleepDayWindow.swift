import Foundation

enum SleepDayWindow {
    static func overlaps(start: Date, end: Date?, dayStart: Date, dayEnd: Date, now: Date = Date()) -> Bool {
        let effectiveEnd = end ?? max(now, start)
        return start < dayEnd && effectiveEnd > dayStart
    }

    static func clippedMinutes(start: Date, end: Date, dayStart: Date, dayEnd: Date) -> Int {
        let clippedStart = max(start, dayStart)
        let clippedEnd = min(end, dayEnd)
        guard clippedEnd > clippedStart else { return 0 }
        return Int(clippedEnd.timeIntervalSince(clippedStart) / 60)
    }
}
