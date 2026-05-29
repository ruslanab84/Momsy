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
        case .english, .spanish, .portuguese:
            switch self {
            case .morning:   return "morning"
            case .afternoon: return "afternoon"
            case .evening:   return "evening"
            case .night:     return "night"
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
    let daysSinceLastStool: Int          // 0=today, 1=yesterday, …
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
        daysSinceLastStool: Int = 0,
        appState: AppState
    ) -> DailyContext {
        let feedingEntries = entries.filter { $0.kind == .bottle }
        let sleepEntries   = entries.filter { $0.kind == .sleep }

        let feedingCount        = feedingEntries.count
        let totalFeedingMinutes = feedingEntries.reduce(0) { $0 + parseFeedingMinutes($1.label) }
        let minutesSinceLastFeed = feedingEntries.first.map {
            max(0, Int(-$0.time.timeIntervalSinceNow / 60))
        }
        let lastFeedSide = feedingEntries.first.flatMap { parseFeedSide($0.label) }

        let sleepCount        = sleepEntries.count
        let totalSleepMinutes = sleepEntries.reduce(0) { $0 + parseSleepMinutes($1.label) }

        let (ageMonths, ageDays) = babyAge(appState: appState)
        let currentLeapName = currentLeap(ageWeeks: ageWeeks(appState: appState))

        // New fields
        let hour = Calendar.current.component(.hour, from: Date())
        let walkCount = entries.filter { $0.kind == .walk }.count
        let bathCount = entries.filter { $0.kind == .bath }.count
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let lastFeedDurationMinutes = feedingEntries.first.map { parseFeedingMinutes($0.label) } ?? 0
        let recentFeedSides = feedingEntries.prefix(3).compactMap { parseFeedSide($0.label) }
            .filter { !$0.lowercased().contains("bottle") && !$0.contains("Бутылка") }
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

    // MARK: - Private helpers (existing)

    private static func parseFeedingMinutes(_ label: String) -> Int {
        let pattern = #"·\s*(\d+)\s*(?:min|мин)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)),
              let range = Range(match.range(at: 1), in: label) else { return 0 }
        return Int(label[range]) ?? 0
    }

    private static func parseFeedSide(_ label: String) -> String? {
        let parts = label.components(separatedBy: " · ")
        return parts.last.flatMap { $0.isEmpty ? nil : $0 }
    }

    private static func parseSleepMinutes(_ label: String) -> Int {
        if let enMatch = try? NSRegularExpression(pattern: #"(\d+)h(?:\s*(\d+)m)?"#),
           let m = enMatch.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)) {
            let hours   = m.range(at: 1).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 1))) ?? 0 : 0
            let minutes = m.range(at: 2).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 2))) ?? 0 : 0
            if hours > 0 || minutes > 0 { return hours * 60 + minutes }
        }
        if let ruMatch = try? NSRegularExpression(pattern: #"(\d+)\s*ч(?:\s*(\d+)\s*м)?"#),
           let m = ruMatch.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)) {
            let hours   = m.range(at: 1).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 1))) ?? 0 : 0
            let minutes = m.range(at: 2).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 2))) ?? 0 : 0
            return hours * 60 + minutes
        }
        return 0
    }

    // MARK: - New helper

    private static func computeMinutesSinceSleepEnd(from sleepEntries: [LogEntry]) -> Int? {
        guard let latest = sleepEntries.first else { return nil }
        let durationMinutes = parseSleepMinutes(latest.label)
        if durationMinutes == 0 { return 0 } // currently sleeping
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
        let catalog = DevelopmentLeap.catalog
        let lang = LocalizationManager.shared.lang
        let leap = catalog.first(where: { !$0.isDone && $0.week <= weeks + 4 })
            ?? catalog.last(where: { $0.week <= weeks })
        guard let leap else { return nil }
        return lang == "en" ? leap.nameEn : leap.name
    }
}
