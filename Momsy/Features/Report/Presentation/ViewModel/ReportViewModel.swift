import SwiftUI
import Combine
import UIKit

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedPeriod = 1
    @Published var isOnStates: [Bool] = [true, true, true, true, true, false, false]
    @Published var isGenerating = false
    @Published var shareURL: URL? = nil
    @Published var showShare = false
    @Published private(set) var currentStats: [(label: String, value: String, sub: String, tone: Color)] = []
    @Published private(set) var currentSparklines: [(label: String, values: [Double], color: Color, peak: String)] = []
    @Published var lastVisitDate: Date? = nil

    private let generateReport: GenerateReportUseCase
    private let analytics: any AnalyticsServiceProtocol
    private let appState: AppState
    private let feedingRepo: any FeedingRepository
    private let sleepRepo: any SleepRepository
    private let temperatureRepo: any TemperatureRepository
    private let doctorVisitRepo: any DoctorVisitRepository

    init(
        feedingRepo: any FeedingRepository,
        sleepRepo: any SleepRepository,
        temperatureRepo: any TemperatureRepository,
        doctorVisitRepo: any DoctorVisitRepository,
        appState: AppState,
        analytics: any AnalyticsServiceProtocol
    ) {
        self.feedingRepo = feedingRepo
        self.sleepRepo = sleepRepo
        self.temperatureRepo = temperatureRepo
        self.doctorVisitRepo = doctorVisitRepo
        self.appState = appState
        self.analytics = analytics
        self.generateReport = GenerateReportUseCase()
    }

    private var lm: LocalizationManager { .shared }

    var displayName: String { appState.displayName }

    var periods: [String] {
        [lm.strings.reportPeriod3Days, lm.strings.reportPeriodWeek,
         lm.strings.reportPeriod2Weeks, lm.strings.reportPeriodMonth,
         lm.strings.reportPeriodSinceVisit]
    }

    var periodLabel: String {
        [lm.strings.reportPeriod3Days, lm.strings.reportPeriodLabelWeek,
         lm.strings.reportPeriod2Weeks, lm.strings.reportPeriodLabelMonth,
         lm.strings.reportPeriodLabelLastVisit][selectedPeriod]
    }

    var sectionLabels: [String] {
        [
            lm.strings.reportSectionFeedings,
            lm.strings.reportSectionSleepByDay,
            lm.strings.reportSectionDiapers,
            lm.strings.reportSectionTempSymptoms,
            lm.strings.reportSectionWeightHeight,
            lm.strings.reportSectionMedicine,
            lm.strings.reportSectionPhotosNotes,
        ]
    }

    private var periodDays: Int {
        switch selectedPeriod {
        case 0: return 3
        case 1: return 7
        case 2: return 14
        case 3: return 30
        default: return 30
        }
    }

    func saveVisitDate(_ date: Date) async {
        try? await doctorVisitRepo.save(DoctorVisit(id: UUID(), date: date))
        lastVisitDate = date
        await loadData()
    }

    // MARK: - Data loading

    func loadData() async {
        if selectedPeriod == 4 {
            lastVisitDate = (try? await doctorVisitRepo.getLast())?.date
        }

        let to = Date()
        let from: Date
        let days: Int
        if selectedPeriod == 4, let visitDate = lastVisitDate {
            from = visitDate
            days = max(1, Calendar.current.dateComponents([.day], from: visitDate, to: to).day ?? 30)
        } else {
            days = periodDays
            from = Calendar.current.date(byAdding: .day, value: -days, to: to) ?? to
        }
        let cal = Calendar.current

        async let feedingsResult = feedingRepo.getEntries(from: from, to: to)
        async let sleepsResult   = sleepRepo.getEntries(from: from, to: to)
        async let tempsResult    = temperatureRepo.getEntries(from: from, to: to)

        let feedings = (try? await feedingsResult) ?? []
        let sleeps   = (try? await sleepsResult)   ?? []
        let temps    = (try? await tempsResult)    ?? []

        var feedPerDay  = [Double]()
        var sleepPerDay = [Double]()
        var rawTempPerDay = [Double]()

        for dayOffset in 0..<days {
            let dayStart = cal.date(byAdding: .day, value: dayOffset,
                                    to: cal.startOfDay(for: from)) ?? from

            feedPerDay.append(Double(feedings.filter { cal.isDate($0.date, inSameDayAs: dayStart) }.count))

            let sleepMins = sleeps
                .filter { cal.isDate($0.startDate, inSameDayAs: dayStart) }
                .compactMap { $0.durationMinutes }
                .reduce(0, +)
            sleepPerDay.append(Double(sleepMins) / 60.0)

            let maxT = temps
                .filter { cal.isDate($0.date, inSameDayAs: dayStart) }
                .map(\.value)
                .max()
            rawTempPerDay.append(maxT ?? 0)
        }

        let feedCount = feedings.count
        let feedAvg   = days > 0 ? Double(feedCount) / Double(days) : 0
        let medianSleep = median(sleepPerDay)
        let maxTemp   = temps.map(\.value).max() ?? 0
        let peakCount = temps.filter { $0.value > 37.5 }.count

        currentStats = [
            (
                lm.strings.reportStatFeedingsLabel,
                feedCount > 0 ? "\(feedCount)" : "—",
                feedCount > 0 ? lm.strings.reportFeedAvgSub(avg: feedAvg) : lm.strings.noData,
                .bbCoral
            ),
            (
                lm.strings.reportStatSleepLabel,
                medianSleep > 0 ? formatHM(medianSleep) : "—",
                medianSleep > 0 ? lm.strings.reportStatSleepSub : lm.strings.noData,
                .bbLilac
            ),
            (
                lm.strings.reportStatDiapersLabel,
                "—",
                lm.strings.reportNotTracked,
                .bbSky
            ),
            (
                lm.strings.reportStatTempLabel,
                maxTemp > 0 ? String(format: "%.1f°", maxTemp) : "—",
                maxTemp > 0
                    ? (peakCount > 0 ? lm.strings.reportTempPeakSub(n: peakCount) : lm.strings.reportTempNormal)
                    : lm.strings.noData,
                maxTemp > 37.5 ? .bbCoralDeep : .bbMintDeep
            ),
        ]

        let tempForChart = rawTempPerDay.map { $0 > 0 ? $0 : 36.6 }
        let tempPeakStr  = rawTempPerDay.compactMap { $0 > 0 ? $0 : nil }.max()
            .map { String(format: "%.1f", $0) } ?? "—"

        currentSparklines = [
            (
                lm.strings.reportSparkFeedingsLabel,
                feedPerDay.isEmpty ? [0] : feedPerDay,
                .bbCoralDeep,
                feedPerDay.max().map { String(format: "%.0f", $0) } ?? "—"
            ),
            (
                lm.strings.reportSparkSleepLabel,
                sleepPerDay.isEmpty ? [0] : sleepPerDay,
                .bbLilacDeep,
                sleepPerDay.max().map { formatHM($0) } ?? "—"
            ),
            (
                lm.strings.reportSparkTempLabel,
                tempForChart.isEmpty ? [36.6] : tempForChart,
                .bbCoralDeep,
                tempPeakStr
            ),
        ]
    }

    // MARK: - Helpers

    private func median(_ values: [Double]) -> Double {
        let sorted = values.filter { $0 > 0 }.sorted()
        guard !sorted.isEmpty else { return 0 }
        let mid = sorted.count / 2
        return sorted.count % 2 == 0 ? (sorted[mid - 1] + sorted[mid]) / 2.0 : sorted[mid]
    }

    private func formatHM(_ hours: Double) -> String {
        guard hours > 0 else { return "—" }
        let h = Int(hours)
        let m = min(Int(round((hours - Double(h)) * 60)), 59)
        return lm.strings.sleepDurationFormatted(h: h, m: m)
    }

    // MARK: - Actions

    func generateAndShare() async {
        guard !isGenerating else { return }
        isGenerating = true
        defer { isGenerating = false }
        await loadData()
        guard let url = generateReport.execute(
            babyName: displayName,
            periodLabel: periods[selectedPeriod],
            stats: currentStats,
            sparklines: currentSparklines,
            lang: lm.lang
        ) else { return }
        analytics.track(.reportGenerated(period: periods[selectedPeriod]))
        shareURL = url
        showShare = true
    }

    func printReport() async {
        guard !isGenerating else { return }
        isGenerating = true
        defer { isGenerating = false }
        await loadData()
        guard let url = generateReport.execute(
            babyName: displayName,
            periodLabel: periods[selectedPeriod],
            stats: currentStats,
            sparklines: currentSparklines,
            lang: lm.lang
        ) else { return }
        let info = UIPrintInfo.printInfo()
        info.outputType = .general
        info.jobName = lm.strings.reportJobName
        let controller = UIPrintInteractionController.shared
        controller.printInfo = info
        controller.printingItem = url
        controller.present(animated: true)
    }
}
