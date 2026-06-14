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

    /// Where the baby is within the current leap.
    enum LeapPhase: Equatable {
        /// Inside the fussy stretch. `day` is 1-indexed from the leap's onset.
        case stormy(day: Int, total: Int)
        /// Hard part has passed; the baby is consolidating new skills.
        case settled
    }

    /// Phase of `leap` for a baby aged `days`. The leap surfaces `leapLookaheadWeeks`
    /// before its nominal week, so the stormy window is the first `leap.hardDays` days
    /// from that onset; afterwards the baby is settled.
    static func leapPhase(for leap: DevelopmentLeap, ageDays days: Int) -> LeapPhase {
        let onsetDay = max(0, (leap.week - leapLookaheadWeeks) * 7)
        let dayInLeap = days - onsetDay + 1
        if dayInLeap >= 1 && dayInLeap <= leap.hardDays {
            return .stormy(day: dayInLeap, total: leap.hardDays)
        }
        return .settled
    }

    static let leapLookaheadWeeks = 1

    /// The leap the baby is currently going through, by age.
    /// Latest leap whose onset week is within `leapLookaheadWeeks` of the baby's age,
    /// excluding any leap already marked complete. nil before the first leap / between leaps.
    static func currentLeap(ageWeeks weeks: Int, completedIDs: Set<Int> = []) -> DevelopmentLeap? {
        DevelopmentLeap.catalog.last(where: {
            $0.week <= weeks + leapLookaheadWeeks && !completedIDs.contains($0.id)
        })
    }

    /// Name of the current developmental leap for the given age, localized.
    static func currentLeapName(ageWeeks weeks: Int, lang: String) -> String? {
        guard let leap = currentLeap(ageWeeks: weeks) else { return nil }
        return lang == "en" ? leap.nameEn : leap.name
    }
}
