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

    /// Name of the current developmental leap for the given age, localized.
    /// First not-yet-passed leap within a 4-week look-ahead, else the last passed leap.
    static func currentLeapName(ageWeeks weeks: Int, lang: String) -> String? {
        let catalog = DevelopmentLeap.catalog
        let leap = catalog.first(where: { !$0.isDone && $0.week <= weeks + 4 })
            ?? catalog.last(where: { $0.week <= weeks })
        guard let leap else { return nil }
        return lang == "en" ? leap.nameEn : leap.name
    }
}
