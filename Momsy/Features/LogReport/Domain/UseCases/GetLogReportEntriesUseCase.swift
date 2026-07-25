import Foundation

final class GetLogReportEntriesUseCase {
    private let feedingRepo: any FeedingRepository
    private let sleepRepo: any SleepRepository
    private let diaperRepo: any DiaperRepository
    private let stoolRepo: any StoolRepository
    private let walkRepo: any WalkRepository
    private let bathRepo: any BathRepository
    private let pumpingRepo: any PumpingRepository
    private let vitaminRepo: any VitaminRepository

    init(feedingRepo: any FeedingRepository,
         sleepRepo: any SleepRepository,
         diaperRepo: any DiaperRepository,
         stoolRepo: any StoolRepository,
         walkRepo: any WalkRepository,
         bathRepo: any BathRepository,
         pumpingRepo: any PumpingRepository,
         vitaminRepo: any VitaminRepository) {
        self.feedingRepo = feedingRepo
        self.sleepRepo = sleepRepo
        self.diaperRepo = diaperRepo
        self.stoolRepo = stoolRepo
        self.walkRepo = walkRepo
        self.bathRepo = bathRepo
        self.pumpingRepo = pumpingRepo
        self.vitaminRepo = vitaminRepo
    }

    /// Every local log whose activity overlaps [from, to), newest first.
    func execute(from: Date, to: Date) async throws -> [LogReportItem] {
        let lm = LocalizationManager.shared
        let cal = Calendar.current

        let feedings = try await feedingRepo.getEntries(from: from, to: to)
        let sleeps   = try await sleepRepo.getEntries(overlapping: from, until: to)
        let diapers  = try await diaperRepo.getEntries(from: from, to: to)
        let stools   = try await stoolRepo.getEntries(from: from, to: to)
        let walks    = try await walkRepo.getEntries(from: from, to: to)
        let baths    = try await bathRepo.getEntries(from: from, to: to)
        let pumpings = try await pumpingRepo.getEntries(from: from, to: to)
        let vitamins = try await vitaminRepo.getEntries(from: from, to: to)

        let feedingItems = feedings.map { entry -> LogReportItem in
            let side = entry.side.displayName(lang: lm.lang).lowercased()
            let end = entry.durationSeconds > 0
                ? entry.date.addingTimeInterval(TimeInterval(entry.durationSeconds))
                : nil
            return LogReportItem(id: "feeding:\(entry.id.uuidString)", kind: .bottle,
                                 label: lm.strings.feedingLogEntry(dur: entry.durationMinutes, side: side),
                                 start: entry.date, end: end)
        }

        let sleepItems = sleeps.map { entry -> LogReportItem in
            let label: String
            if let mins = entry.durationMinutes {
                label = lm.strings.sleepLogEntry(dur: lm.strings.sleepDurationFormatted(h: mins / 60, m: mins % 60))
            } else {
                label = lm.strings.sleepStarted
            }
            return LogReportItem(id: "sleep:\(entry.id.uuidString)", kind: .sleep,
                                 label: label, start: entry.startDate, end: entry.endDate)
        }

        // Diapers keep the per-day running number used in "Today so far".
        let diaperItems = Dictionary(grouping: diapers) { cal.startOfDay(for: $0.date) }
            .values
            .flatMap { day in
                day.sorted { $0.date < $1.date }.enumerated().map { index, entry in
                    LogReportItem(id: "diaper:\(entry.id.uuidString)", kind: .drop,
                                  label: lm.strings.diaperLogEntry(count: index + 1),
                                  start: entry.date, end: nil)
                }
            }

        let stoolItems = stools.map {
            LogReportItem(id: "stool:\(Int($0.timeIntervalSince1970))", kind: .stool,
                          label: lm.strings.stoolLogged, start: $0, end: nil)
        }
        let walkItems = walks.map {
            LogReportItem(id: "walk:\($0.id.uuidString)", kind: .walk,
                          label: lm.strings.walkLogged, start: $0.startDate, end: $0.endDate)
        }
        let bathItems = baths.map {
            LogReportItem(id: "bath:\($0.id.uuidString)", kind: .bath,
                          label: lm.strings.bathLogged, start: $0.startDate, end: $0.endDate)
        }
        let pumpingItems = pumpings.map { entry -> LogReportItem in
            let end = entry.endDate ?? entry.date.addingTimeInterval(TimeInterval(entry.durationSeconds))
            return LogReportItem(id: "pump:\(entry.id.uuidString)", kind: .pump,
                                 label: lm.strings.pumpingLogEntry(dur: entry.durationMinutes, ml: entry.volumeML),
                                 start: entry.date, end: end)
        }
        let vitaminItems = vitamins.map {
            LogReportItem(id: "vitamin:\($0.id.uuidString)", kind: .vitamin,
                          label: $0.label.isEmpty ? lm.strings.vitaminsGiven : $0.label,
                          start: $0.date, end: nil)
        }

        return (feedingItems + sleepItems + diaperItems + stoolItems
                + walkItems + bathItems + pumpingItems + vitaminItems)
            .sorted { $0.start > $1.start }
    }
}
