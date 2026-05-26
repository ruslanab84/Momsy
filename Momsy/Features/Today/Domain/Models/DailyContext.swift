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

    var displayName: String {
        switch self {
        case .morning:   return "утро"
        case .afternoon: return "день"
        case .evening:   return "вечер"
        case .night:     return "ночь"
        }
    }
}

// MARK: - DailyContext

struct DailyContext {
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

    /// Simple string hash for cache deduplication — no CryptoKit needed
    var contextHash: String {
        "\(feedingCount)-\(totalFeedingMinutes)-\(minutesSinceLastFeed ?? -1)-\(sleepCount)-\(totalSleepMinutes)-\(diaperCount)"
    }
}

// MARK: - DailyContextBuilder

enum DailyContextBuilder {

    static func build(
        from entries: [LogEntry],
        diaperCount: Int,
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
            timeOfDay: .current()
        )
    }

    // MARK: - Private parsing helpers

    /// Extracts feeding duration from labels like "Feeding · 15 min · left" / "Кормление · 15 мин · левая"
    private static func parseFeedingMinutes(_ label: String) -> Int {
        // Match number between "· N min" or "· N мин"
        let pattern = #"·\s*(\d+)\s*(?:min|мин)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)),
              let range = Range(match.range(at: 1), in: label) else { return 0 }
        return Int(label[range]) ?? 0
    }

    /// Extracts last feed side from labels like "Feeding · 15 min · left" — last component after "· "
    private static func parseFeedSide(_ label: String) -> String? {
        let parts = label.components(separatedBy: " · ")
        return parts.last.flatMap { $0.isEmpty ? nil : $0 }
    }

    /// Extracts total sleep minutes from labels like "Sleep · 4h 12m" / "Сон · 4 ч 12 м" / "Сон · 2 ч"
    private static func parseSleepMinutes(_ label: String) -> Int {
        // EN: "4h 12m" or "4h"
        if let enMatch = try? NSRegularExpression(pattern: #"(\d+)h(?:\s*(\d+)m)?"#),
           let m = enMatch.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)) {
            let hours   = m.range(at: 1).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 1))) ?? 0 : 0
            let minutes = m.range(at: 2).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 2))) ?? 0 : 0
            if hours > 0 || minutes > 0 { return hours * 60 + minutes }
        }
        // RU: "4 ч 12 м" or "4 ч"
        if let ruMatch = try? NSRegularExpression(pattern: #"(\d+)\s*ч(?:\s*(\d+)\s*м)?"#),
           let m = ruMatch.firstMatch(in: label, range: NSRange(label.startIndex..., in: label)) {
            let hours   = m.range(at: 1).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 1))) ?? 0 : 0
            let minutes = m.range(at: 2).location != NSNotFound ? Int((label as NSString).substring(with: m.range(at: 2))) ?? 0 : 0
            return hours * 60 + minutes
        }
        return 0
    }

    // MARK: - Age helpers

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

    /// Find the current developmental leap name based on baby age in weeks
    private static func currentLeap(ageWeeks weeks: Int) -> String? {
        let catalog = DevelopmentLeap.catalog
        let lang = LocalizationManager.shared.lang
        // Current leap = last leap whose window has started (within 4-week look-ahead)
        let leap = catalog.first(where: { !$0.isDone && $0.week <= weeks + 4 })
            ?? catalog.last(where: { $0.week <= weeks })
        guard let leap else { return nil }
        return lang == "en" ? leap.nameEn : leap.name
    }
}
