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
    private let diaperRepo: any DiaperRepository
    private let temperatureRepo: any TemperatureRepository
    private let measurementRepo: any MeasurementRepository
    private let doctorVisitRepo: any DoctorVisitRepository

    init(
        feedingRepo: any FeedingRepository,
        sleepRepo: any SleepRepository,
        diaperRepo: any DiaperRepository,
        temperatureRepo: any TemperatureRepository,
        measurementRepo: any MeasurementRepository,
        doctorVisitRepo: any DoctorVisitRepository,
        appState: AppState,
        analytics: any AnalyticsServiceProtocol
    ) {
        self.feedingRepo = feedingRepo
        self.sleepRepo = sleepRepo
        self.diaperRepo = diaperRepo
        self.temperatureRepo = temperatureRepo
        self.measurementRepo = measurementRepo
        self.doctorVisitRepo = doctorVisitRepo
        self.appState = appState
        self.analytics = analytics
        self.generateReport = GenerateReportUseCase()
    }

    private var lm: LocalizationManager { .shared }
    private var units: UnitSystemManager { .shared }

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
        let visit = DoctorVisit(id: UUID(), date: date)
        try? await doctorVisitRepo.save(visit)
        pushDoctorVisitToFirestore(visit)
        lastVisitDate = date
        await loadData()
    }

    private func pushDoctorVisitToFirestore(_ visit: DoctorVisit) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = DoctorVisitLog(
            id: visit.id.uuidString, date: visit.date,
            addedBy: uid, addedByName: name
        )
        Task { try? await BabySyncService().setLog(DoctorVisitLogDTO(from: log), id: log.id, to: "doctorVisitLogs") }
    }

    // MARK: - Data loading

    func loadData() async {
        if selectedPeriod == 4 {
            lastVisitDate = (try? await doctorVisitRepo.getLast())?.date
        }

        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let to = cal.date(byAdding: .day, value: 1, to: todayStart) ?? Date()
        let from: Date
        let days: Int
        if selectedPeriod == 4, let visitDate = lastVisitDate {
            from = cal.startOfDay(for: visitDate)
            days = max(1, cal.dateComponents([.day], from: from, to: todayStart).day ?? 30) + 1
        } else {
            days = periodDays
            from = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        }

        async let feedingsResult      = feedingRepo.getEntries(from: from, to: to)
        async let sleepsResult        = sleepRepo.getEntries(from: from, to: to)
        async let diapersResult       = diaperRepo.getEntries(from: from, to: to)
        async let tempsResult         = temperatureRepo.getEntries(from: from, to: to)
        async let measurementsResult  = measurementRepo.getEntries(from: from, to: to)

        let feedings     = (try? await feedingsResult)     ?? []
        let sleeps       = (try? await sleepsResult)       ?? []
        let diapers      = (try? await diapersResult)      ?? []
        let temps        = (try? await tempsResult)        ?? []
        let measurements = (try? await measurementsResult) ?? []

        var feedPerDay    = [Double]()
        var sleepPerDay   = [Double]()
        var diaperPerDay  = [Double]()
        var rawTempPerDay = [Double]()

        for dayOffset in 0..<days {
            let dayStart = cal.date(byAdding: .day, value: dayOffset,
                                    to: cal.startOfDay(for: from)) ?? from

            feedPerDay.append(Double(feedings.filter { cal.isDate($0.date, inSameDayAs: dayStart) }.count))
            diaperPerDay.append(Double(diapers.filter { cal.isDate($0.date, inSameDayAs: dayStart) }.count))

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

        let feedCount    = feedings.count
        let feedAvg      = days > 0 ? Double(feedCount) / Double(days) : 0
        let medianSleep  = median(sleepPerDay)
        let diaperCount  = diapers.count
        let diaperAvg    = days > 0 ? Double(diaperCount) / Double(days) : 0
        let maxTemp   = temps.map(\.value).max() ?? 0
        let peakCount = temps.filter { $0.value > 37.5 }.count

        let sortedMeasurements = measurements.sorted { $0.date < $1.date }
        let weightValue: String
        let weightSub: String
        // Stored values already include the unit suffix (e.g. "5.2 кг", "60 см")
        // — strip it for numeric operations only, display as-is.
        func numericPart(_ s: String) -> Double? {
            Double((s.components(separatedBy: " ").first ?? s).replacingOccurrences(of: ",", with: "."))
        }
        if let last = sortedMeasurements.last, !last.weight.isEmpty, last.weight != "—" {
            weightValue = units.displayWeightFromStored(last.weight, localizedMetricUnit: lm.strings.unitKg)
            if let first = sortedMeasurements.first, first.id != last.id,
               let fw = numericPart(first.weight),
               let lw = numericPart(last.weight) {
                let dKg = lw - fw
                let dDisplay = units.isImperial ? dKg * 2.20462 : dKg
                let unit = units.isImperial ? "lb" : lm.strings.unitKg
                weightSub = String(format: dDisplay >= 0 ? "+%.2f \(unit)" : "%.2f \(unit)", dDisplay)
            } else {
                weightSub = last.height.isEmpty || last.height == "—" ? lm.strings.noData
                    : units.displayHeightFromStored(last.height, localizedMetricUnit: lm.strings.unitCm)
            }
        } else {
            weightValue = "—"
            weightSub = lm.strings.noData
        }

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
                diaperCount > 0 ? "\(diaperCount)" : "—",
                diaperCount > 0 ? lm.strings.reportFeedAvgSub(avg: diaperAvg) : lm.strings.noData,
                .bbSky
            ),
            (
                lm.strings.reportStatTempLabel,
                maxTemp > 0 ? String(format: "%.1f%@", units.displayTemp(fromCelsius: maxTemp), units.tempUnit) : "—",
                maxTemp > 0
                    ? (peakCount > 0 ? lm.strings.reportTempPeakSub(n: peakCount) : lm.strings.reportTempNormal)
                    : lm.strings.noData,
                maxTemp > 37.5 ? .bbCoralDeep : .bbMintDeep
            ),
            (
                lm.strings.reportStatWeightLabel,
                weightValue,
                weightSub,
                .bbMintDeep
            ),
        ]

        let tempForChart = rawTempPerDay.map { $0 > 0 ? $0 : 36.6 }
        let tempPeakStr  = rawTempPerDay.compactMap { $0 > 0 ? $0 : nil }.max()
            .map { String(format: "%.1f", $0) } ?? "—"

        let weightValues = sortedMeasurements.compactMap { numericPart($0.weight) }

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
                lm.strings.reportSparkDiapersLabel,
                diaperPerDay.isEmpty ? [0] : diaperPerDay,
                .bbSky,
                diaperPerDay.max().map { String(format: "%.0f", $0) } ?? "—"
            ),
            (
                lm.strings.reportSparkTempDynamicLabel(unit: units.tempUnit),
                tempForChart.isEmpty ? [36.6] : tempForChart,
                .bbCoralDeep,
                tempPeakStr
            ),
            (
                lm.strings.reportSparkWeightDynamicLabel(unit: units.isImperial ? "lb" : lm.strings.unitKg),
                weightValues.isEmpty ? [0] : weightValues.map { units.isImperial ? $0 * 2.20462 : $0 },
                .bbMintDeep,
                weightValues.last.map { String(format: "%.1f", units.isImperial ? $0 * 2.20462 : $0) } ?? "—"
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
