import Foundation

enum WhoNorms {

    /// App-level reminder heuristic for the longest interval between logged milk feeds.
    /// WHO recommends feeding on demand and does not define a universal numeric feed count.
    static func maxFeedingInterval(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...1:  return 180
        case 2:      return 210
        case 3...4:  return 240
        case 5...6:  return 270
        case 7...12: return 300
        default:     return 360
        }
    }

    /// WHO 24-hour sleep-duration range, including naps.
    /// 0–3 months: 14–17 h; 4–11 months: 12–16 h;
    /// 1–2 years: 11–14 h; 2–4 years: 10–13 h.
    static func sleepRangeMinutes(ageMonths: Int) -> ClosedRange<Int> {
        switch ageMonths {
        case 0...3:   return 840...1_020
        case 4...11:  return 720...960
        case 12...23: return 660...840
        default:      return 600...780
        }
    }

    /// Lower bound of the WHO sleep range. Existing alert rules use this value.
    static func minSleepMinutes(ageMonths: Int) -> Int {
        sleepRangeMinutes(ageMonths: ageMonths).lowerBound
    }

    /// WHO complementary-meal frequency for ages where a numeric recommendation exists.
    /// Milk feeding should continue; food-diary entries are not automatically equivalent to meals.
    static func complementaryMealsPerDay(ageMonths: Int) -> ClosedRange<Int>? {
        switch ageMonths {
        case 6...8:  return 2...3
        case 9...23: return 3...4
        default:      return nil
        }
    }

    /// WHO additional snack guidance where applicable and desired by the child.
    static func complementarySnacksPerDay(ageMonths: Int) -> ClosedRange<Int>? {
        (9...23).contains(ageMonths) ? 1...2 : nil
    }

    /// Max consecutive days without stool before alert triggers.
    static func maxDaysWithoutStool(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...2: return 3
        case 3...6: return 4
        default:    return 5
        }
    }

    /// App routine-planning estimate for an awake window. This is not a WHO standard.
    static func awakeWindowMax(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0:       return 45
        case 1:       return 60
        case 2:       return 75
        case 3:       return 90
        case 4...5:   return 110
        case 6...7:   return 130
        case 8...9:   return 150
        case 10...12: return 180
        case 13...18: return 240
        default:      return 300
        }
    }
}
