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

    private let generateReport: GenerateReportUseCase
    private let analytics: any AnalyticsServiceProtocol
    private let appState: AppState
    private let feedingRepo: any FeedingRepository
    private let sleepRepo: any SleepRepository
    private let temperatureRepo: any TemperatureRepository

    init(
        feedingRepo: any FeedingRepository,
        sleepRepo: any SleepRepository,
        temperatureRepo: any TemperatureRepository,
        appState: AppState,
        analytics: any AnalyticsServiceProtocol
    ) {
        self.feedingRepo = feedingRepo
        self.sleepRepo = sleepRepo
        self.temperatureRepo = temperatureRepo
        self.appState = appState
        self.analytics = analytics
        self.generateReport = GenerateReportUseCase()
    }

    private var lm: LocalizationManager { .shared }
    private var lang: String { lm.lang }
    private func t(_ en: String, _ ru: String) -> String { lang == "ru" ? ru : en }

    var displayName: String { appState.displayName }

    var periods: [String] {
        [t("3 days", "3 дня"), t("Week", "Неделя"), t("2 weeks", "2 недели"), t("Month", "Месяц"), t("Since visit", "С визита")]
    }

    var periodLabel: String {
        [t("3 days", "3 дня"), t("a week", "неделю"), t("2 weeks", "2 недели"),
         t("a month", "месяц"), t("last visit", "последний визит")][selectedPeriod]
    }

    var sectionLabels: [String] {
        [
            t("Feedings & spit-ups",   "Кормления и срыгивания"),
            t("Sleep by day",          "Сон по дням"),
            t("Diapers & stool",       "Подгузники и стул"),
            t("Temp / symptoms",       "Температура / симптомы"),
            t("Weight & height",       "Вес и рост (график)"),
            t("Medicine & vitamins",   "Лекарства и витамины"),
            t("Photos & notes",        "Фото и заметки"),
        ]
    }

    private var periodDays: Int {
        switch selectedPeriod {
        case 0: return 3
        case 1: return 7
        case 2: return 14
        default: return 30
        }
    }

    private var dateRange: (from: Date, to: Date) {
        let to = Date()
        let from = Calendar.current.date(byAdding: .day, value: -periodDays, to: to) ?? to
        return (from, to)
    }

    // MARK: - Data loading

    func loadData() async {
        let (from, to) = dateRange
        let days = periodDays
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
                t("Feedings", "Кормлений"),
                feedCount > 0 ? "\(feedCount)" : "—",
                feedCount > 0 ? String(format: t("%.1f / day", "%.1f / день"), feedAvg) : t("no data", "нет данных"),
                .bbCoral
            ),
            (
                t("Sleep", "Сон"),
                medianSleep > 0 ? formatHM(medianSleep) : "—",
                medianSleep > 0 ? t("median / day", "медиана / сутки") : t("no data", "нет данных"),
                .bbLilac
            ),
            (
                t("Diapers", "Подгузники"),
                "—",
                t("not tracked", "не отслеживается"),
                .bbSky
            ),
            (
                t("Temperature", "Температура"),
                maxTemp > 0 ? String(format: "%.1f°", maxTemp) : "—",
                maxTemp > 0
                    ? (peakCount > 0 ? t("peak · \(peakCount)×", "пик · \(peakCount)×") : t("normal", "норма"))
                    : t("no data", "нет данных"),
                maxTemp > 37.5 ? .bbCoralDeep : .bbMintDeep
            ),
        ]

        let tempForChart = rawTempPerDay.map { $0 > 0 ? $0 : 36.6 }
        let tempPeakStr  = rawTempPerDay.compactMap { $0 > 0 ? $0 : nil }.max()
            .map { String(format: "%.1f", $0) } ?? "—"

        currentSparklines = [
            (
                t("Feedings / day", "Кормления / сут"),
                feedPerDay.isEmpty ? [0] : feedPerDay,
                .bbCoralDeep,
                feedPerDay.max().map { String(format: "%.0f", $0) } ?? "—"
            ),
            (
                t("Sleep / day (h)", "Сон / сут (ч)"),
                sleepPerDay.isEmpty ? [0] : sleepPerDay,
                .bbLilacDeep,
                sleepPerDay.max().map { formatHM($0) } ?? "—"
            ),
            (
                t("Temperature °C", "Температура °C"),
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
        return lang == "ru"
            ? (m > 0 ? "\(h)ч \(m)м" : "\(h)ч")
            : (m > 0 ? "\(h)h \(m)m" : "\(h)h")
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
            lang: lang
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
            lang: lang
        ) else { return }
        let info = UIPrintInfo.printInfo()
        info.outputType = .general
        info.jobName = t("Momsy — report", "Momsy — отчёт")
        let controller = UIPrintInteractionController.shared
        controller.printInfo = info
        controller.printingItem = url
        controller.present(animated: true)
    }
}
