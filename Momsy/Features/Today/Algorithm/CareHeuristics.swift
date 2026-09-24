import Foundation

/// In-app thresholds that decide when a Today tip fires.
/// Only `minSleepMinutes` comes from a published guideline; the other values
/// are in-house heuristics with no WHO source, so tips built on them must stay
/// neutral observations of the user's own log (no "norm", no "see a doctor").
enum CareHeuristics {

    /// Feeding gap in minutes after which Today mentions the time since the last feed.
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

    /// Lower bound of recommended total sleep per 24 h, naps included, in minutes.
    /// Source: MedicalSourceID.whoPhysicalActivitySleepUnder5 (WHO 2019:
    /// 0–3 mo 14–17 h, 4–11 mo 12–16 h, 1–2 y 11–14 h, 3–4 y 10–13 h).
    static func minSleepMinutes(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...3:   return 840   // 14 h
        case 4...11:  return 720   // 12 h
        case 12...35: return 660   // 11 h
        default:      return 600   // 10 h
        }
    }

    /// Days without a logged stool after which Today mentions it.
    static func maxDaysWithoutStool(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...2: return 3
        case 3...6: return 4
        default:    return 5
        }
    }

    /// Awake minutes after which Today mentions the time since the last sleep.
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
