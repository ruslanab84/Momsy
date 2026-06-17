import Foundation

enum WakeWindowCatalog {
    static func profile(forAgeInDays days: Int) -> WakeWindowProfile {
        profile(for: band(forAgeInDays: days))
    }

    static func band(forAgeInDays days: Int) -> SleepAgeBand {
        for band in SleepAgeBand.allCases {
            if let upper = band.upperBoundDays, days <= upper { return band }
        }
        return .months24plus
    }

    static func profile(for band: SleepAgeBand) -> WakeWindowProfile {
        switch band {
        case .weeks0to6:    return .init(band: band, minMinutes:  35, maxMinutes:  60, napsPerDay: 4...8, typicalNapMinutes:  50)
        case .weeks6to12:   return .init(band: band, minMinutes:  60, maxMinutes:  90, napsPerDay: 4...5, typicalNapMinutes:  60)
        case .months3to4:   return .init(band: band, minMinutes:  75, maxMinutes: 120, napsPerDay: 3...4, typicalNapMinutes:  60)
        case .months4to6:   return .init(band: band, minMinutes: 105, maxMinutes: 150, napsPerDay: 3...4, typicalNapMinutes:  75)
        case .months6to9:   return .init(band: band, minMinutes: 120, maxMinutes: 180, napsPerDay: 2...3, typicalNapMinutes:  90)
        case .months9to12:  return .init(band: band, minMinutes: 150, maxMinutes: 210, napsPerDay: 2...2, typicalNapMinutes:  90)
        case .months12to18: return .init(band: band, minMinutes: 180, maxMinutes: 270, napsPerDay: 1...2, typicalNapMinutes: 120)
        case .months18to24: return .init(band: band, minMinutes: 270, maxMinutes: 360, napsPerDay: 1...1, typicalNapMinutes: 120)
        case .months24plus: return .init(band: band, minMinutes: 300, maxMinutes: 360, napsPerDay: 0...1, typicalNapMinutes: 120)
        }
    }
}
