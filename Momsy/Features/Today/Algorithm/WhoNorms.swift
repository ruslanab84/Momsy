import Foundation

enum WhoNorms {

    /// Maximum feeding interval in minutes before alert triggers.
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

    /// Minimum total sleep per day in minutes (alert threshold is this minus 90).
    static func minSleepMinutes(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...1:  return 840   // 14 h
        case 2...3:  return 810   // 13.5 h
        case 4...5:  return 780   // 13 h
        case 6...8:  return 720   // 12 h
        case 9...12: return 700   // ~11.7 h
        default:     return 660   // 11 h
        }
    }

    /// Max consecutive days without stool before alert triggers.
    static func maxDaysWithoutStool(ageMonths: Int) -> Int {
        switch ageMonths {
        case 0...2: return 3
        case 3...6: return 4
        default:    return 5
        }
    }

    /// Maximum awake window in minutes before overtiredness tip triggers.
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
