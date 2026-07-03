import Foundation

// MARK: - TimeOfDay

enum TimeOfDay: String {
    case morning, afternoon, evening, night

    static func current() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }

    func displayName(for lang: Language) -> String {
        switch lang {
        case .english:
            switch self {
            case .morning:   return "morning"
            case .afternoon: return "afternoon"
            case .evening:   return "evening"
            case .night:     return "night"
            }
        case .spanish:
            switch self {
            case .morning:   return "mañana"
            case .afternoon: return "tarde"
            case .evening:   return "noche"
            case .night:     return "madrugada"
            }
        case .portuguese:
            switch self {
            case .morning:   return "manhã"
            case .afternoon: return "tarde"
            case .evening:   return "fim de tarde"
            case .night:     return "noite"
            }
        case .russian:
            switch self {
            case .morning:   return "утро"
            case .afternoon: return "день"
            case .evening:   return "вечер"
            case .night:     return "ночь"
            }
        case .german:
            switch self {
            case .morning:   return "Morgen"
            case .afternoon: return "Nachmittag"
            case .evening:   return "Abend"
            case .night:     return "Nacht"
            }
        case .french:
            switch self {
            case .morning:   return "matin"
            case .afternoon: return "après-midi"
            case .evening:   return "soir"
            case .night:     return "nuit"
            }
        case .chinese:
            switch self {
            case .morning:   return "上午"
            case .afternoon: return "下午"
            case .evening:   return "傍晚"
            case .night:     return "夜晚"
            }
        }
    }
}

// MARK: - DailyContext

struct DailyContext {
    // Existing fields
    let babyName: String
    let ageMonths: Int
    let ageDays: Int
    let currentLeapName: String?
    let feedingCount: Int
    let totalFeedingMinutes: Int
    let minutesSinceLastFeed: Int?
    let lastFeedSide: String?
    let sleepCount: Int
    let totalSleepMinutes: Int
    let diaperCount: Int
    let timeOfDay: TimeOfDay
    let language: Language

    // New fields for deterministic algorithm
    let hour: Int                        // 0–23
    let minutesSinceLastSleepEnd: Int?   // nil=no sleep today, 0=currently sleeping
    let walkCount: Int
    let bathCount: Int
    let daysSinceLastStool: Int?         // nil=never logged, 0=today, 1=yesterday, …
    let dayOfYear: Int                   // 1–366 for tip rotation
    let lastFeedDurationMinutes: Int     // 0 if no feeding
    let recentFeedSides: [String]        // last ≤3 non-bottle sides (newest first)

    var contextHash: String {
        "\(language.rawValue)-\(feedingCount)-\(totalFeedingMinutes)-\(sleepCount)-\(totalSleepMinutes)-\(diaperCount)"
    }
}

// MARK: - DailyContextBuilder

enum DailyContextBuilder {

    static func build(
        from entries: [LogEntry],
        diaperCount: Int,
        daysSinceLastStool: Int? = nil,
        appState: AppState
    ) -> DailyContext {
        let feedingEntries = entries.filter { $0.kind == .bottle }
        let sleepEntries   = entries.filter { $0.kind == .sleep }

        let feedingCount        = feedingEntries.count
        let totalFeedingMinutes = feedingEntries.reduce(0) { $0 + ($1.durationMinutes ?? 0) }
        let minutesSinceLastFeed = feedingEntries.first.map {
            max(0, Int(-$0.time.timeIntervalSinceNow / 60))
        }
        let lastFeedSide = feedingEntries.first?.feedSide

        let sleepCount        = sleepEntries.count
        let totalSleepMinutes = sleepEntries.reduce(0) { $0 + ($1.durationMinutes ?? 0) }

        let (ageMonths, ageDays) = babyAge(appState: appState)
        let currentLeapName = currentLeap(ageWeeks: ageWeeks(appState: appState))

        // New fields
        let hour = Calendar.current.component(.hour, from: Date())
        let walkCount = entries.filter { $0.kind == .walk }.count
        let bathCount = entries.filter { $0.kind == .bath }.count
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let lastFeedDurationMinutes = feedingEntries.first?.durationMinutes ?? 0
        let recentFeedSides = feedingEntries.prefix(3)
            .filter { !$0.isBottleFeed }
            .compactMap { $0.feedSide }
        let minutesSinceLastSleepEnd = computeMinutesSinceSleepEnd(from: sleepEntries)

        return DailyContext(
            babyName: appState.displayName,
            ageMonths: ageMonths,
            ageDays: ageDays,
            currentLeapName: currentLeapName,
            feedingCount: feedingCount,
            totalFeedingMinutes: totalFeedingMinutes,
            minutesSinceLastFeed: minutesSinceLastFeed,
            lastFeedSide: lastFeedSide,
            sleepCount: sleepCount,
            totalSleepMinutes: totalSleepMinutes,
            diaperCount: diaperCount,
            timeOfDay: .current(),
            language: LocalizationManager.shared.current,
            hour: hour,
            minutesSinceLastSleepEnd: minutesSinceLastSleepEnd,
            walkCount: walkCount,
            bathCount: bathCount,
            daysSinceLastStool: daysSinceLastStool,
            dayOfYear: dayOfYear,
            lastFeedDurationMinutes: lastFeedDurationMinutes,
            recentFeedSides: Array(recentFeedSides)
        )
    }

    // MARK: - Sleep helper

    private static func computeMinutesSinceSleepEnd(from sleepEntries: [LogEntry]) -> Int? {
        guard let latest = sleepEntries.first else { return nil }
        guard let durationMinutes = latest.durationMinutes, durationMinutes > 0 else { return 0 } // currently sleeping
        let endTime = latest.time.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return max(0, Int(-endTime.timeIntervalSinceNow / 60))
    }

    // MARK: - Age helpers (existing)

    private static func babyAge(appState: AppState) -> (months: Int, days: Int) {
        guard let birth = appState.babyProfile?.birthDate else { return (0, 0) }
        let comps = Calendar.current.dateComponents([.month, .day], from: birth, to: Date())
        return (max(0, comps.month ?? 0), max(0, comps.day ?? 0))
    }

    private static func ageWeeks(appState: AppState) -> Int {
        guard let birth = appState.babyProfile?.birthDate else { return 0 }
        let comps = Calendar.current.dateComponents([.weekOfYear], from: birth, to: Date())
        return max(0, comps.weekOfYear ?? 0)
    }

    private static func currentLeap(ageWeeks weeks: Int) -> String? {
        BabyAgeContext.currentLeapName(ageWeeks: weeks, lang: LocalizationManager.shared.lang)
    }
}
