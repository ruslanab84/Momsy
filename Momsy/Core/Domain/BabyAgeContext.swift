import Foundation

/// Shared baby age + developmental-leap derivation used by AI context builders.
/// Mirrors the logic in `DailyContextBuilder` so weekly insights stay consistent
/// with the daily tip feature.
enum BabyAgeContext {

    static func ageMonths(birthDate: Date?, now: Date = Date()) -> Int {
        guard let birth = birthDate else { return 0 }
        let comps = Calendar.current.dateComponents([.month], from: birth, to: now)
        return max(0, comps.month ?? 0)
    }

    static func ageWeeks(birthDate: Date?, now: Date = Date()) -> Int {
        guard let birth = birthDate else { return 0 }
        let comps = Calendar.current.dateComponents([.weekOfYear], from: birth, to: now)
        return max(0, comps.weekOfYear ?? 0)
    }

    static func ageDays(birthDate: Date?, now: Date = Date()) -> Int {
        guard let birth = birthDate else { return 0 }
        let comps = Calendar.current.dateComponents([.day], from: birth, to: now)
        return max(0, comps.day ?? 0)
    }

    /// Where the baby is within a leap's calendar window.
    enum LeapPhase: Equatable {
        case upcoming(startDate: Date?, daysUntilStart: Int?)
        case hardDays(
            day: Int,
            total: Int,
            peakDate: Date?,
            daysUntilPeak: Int?,
            endDate: Date?,
            daysRemaining: Int
        )
        case consolidation
        case completed
    }

    /// Phase of `leap` for a baby aged `days`.
    static func leapPhase(for leap: DevelopmentLeap, ageDays days: Int) -> LeapPhase {
        let onsetDay = max(0, (leap.week - leapLookaheadWeeks) * 7)
        let dayInLeap = days - onsetDay + 1
        if dayInLeap < 1 {
            return .upcoming(startDate: nil, daysUntilStart: abs(dayInLeap) + 1)
        }
        if dayInLeap <= leap.hardDays {
            let peakDay = peakDay(totalHardDays: leap.hardDays)
            return .hardDays(
                day: dayInLeap,
                total: leap.hardDays,
                peakDate: nil,
                daysUntilPeak: max(0, peakDay - dayInLeap),
                endDate: nil,
                daysRemaining: max(1, leap.hardDays - dayInLeap + 1)
            )
        }
        return .consolidation
    }

    static func leapPhase(
        for leap: DevelopmentLeap,
        birthDate: Date?,
        now: Date = Date(),
        isCompleted: Bool = false,
        calendar: Calendar = .current
    ) -> LeapPhase {
        if isCompleted { return .completed }

        guard let birthDate else {
            return .upcoming(startDate: nil, daysUntilStart: nil)
        }

        let today = calendar.startOfDay(for: now)
        let startDate = leapStartDate(for: leap, birthDate: birthDate, calendar: calendar)
        let startDay = calendar.startOfDay(for: startDate)

        if today < startDay {
            return .upcoming(
                startDate: startDay,
                daysUntilStart: daysBetween(today, startDay, calendar: calendar)
            )
        }

        let dayInLeap = daysBetween(startDay, today, calendar: calendar) + 1
        if dayInLeap <= leap.hardDays {
            let peakDay = peakDay(totalHardDays: leap.hardDays)
            let peakDate = addDays(peakDay - 1, to: startDay, calendar: calendar)
            let endDate = addDays(leap.hardDays - 1, to: startDay, calendar: calendar)
            return .hardDays(
                day: dayInLeap,
                total: leap.hardDays,
                peakDate: peakDate,
                daysUntilPeak: max(0, peakDay - dayInLeap),
                endDate: endDate,
                daysRemaining: max(1, leap.hardDays - dayInLeap + 1)
            )
        }

        return .consolidation
    }

    static let leapLookaheadWeeks = DevelopmentLeapSchedule.lookaheadWeeks

    /// The leap the baby is currently going through, by age.
    /// Latest leap whose onset week is within `leapLookaheadWeeks` of the baby's age.
    /// If that latest eligible leap was manually completed, there is no current leap
    /// until the next scheduled one starts.
    static func currentLeap(ageWeeks weeks: Int, completedIDs: Set<Int> = []) -> DevelopmentLeap? {
        guard let leap = DevelopmentLeap.catalog.last(where: { $0.week <= weeks + leapLookaheadWeeks }) else {
            return nil
        }
        return completedIDs.contains(leap.id) ? nil : leap
    }

    /// Name of the current developmental leap for the given age, localized.
    static func currentLeapName(ageWeeks weeks: Int, lang: String) -> String? {
        guard let leap = currentLeap(ageWeeks: weeks) else { return nil }
        return leap.name(for: Language(rawValue: lang) ?? .english)
    }

    static func leapStartDate(
        for leap: DevelopmentLeap,
        birthDate: Date,
        calendar: Calendar = .current
    ) -> Date {
        let startWeek = max(0, leap.week - leapLookaheadWeeks)
        return calendar.date(byAdding: .weekOfYear, value: startWeek, to: birthDate) ?? birthDate
    }

    static func peakDay(totalHardDays: Int) -> Int {
        max(1, min(totalHardDays, Int((Double(totalHardDays) * 0.45).rounded(.up))))
    }

    private static func daysBetween(_ start: Date, _ end: Date, calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    private static func addDays(_ days: Int, to date: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }
}
