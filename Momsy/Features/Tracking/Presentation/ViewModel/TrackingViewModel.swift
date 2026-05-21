import SwiftUI
import Combine

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var measurements: [MeasurementEntry] = []
    @Published var tempLog: [TemperatureEntry] = []
    @Published var showAddMeasurement = false
    @Published var showAddTemp = false

    private let measurementRepo: any MeasurementRepository
    private let temperatureRepo: any TemperatureRepository

    private var lm: LocalizationManager { .shared }

    private var babyBirthInterval: Double { UserDefaults.standard.double(forKey: "babyBirthDate") }

    init(measurementRepo: any MeasurementRepository,
         temperatureRepo: any TemperatureRepository) {
        self.measurementRepo = measurementRepo
        self.temperatureRepo = temperatureRepo
        Task { await loadAll() }
    }

    func loadAll() async {
        measurements = (try? await measurementRepo.getAll()) ?? []
        tempLog = (try? await temperatureRepo.getAll()) ?? []
    }

    // MARK: - WHO Baby Points

    var babyWeightPoints: [BabyGrowthPoint] {
        growthPoints(keyPath: \.weight)
    }
    var babyHeightPoints: [BabyGrowthPoint] {
        growthPoints(keyPath: \.height)
    }
    var babyHeadPoints: [BabyGrowthPoint] {
        growthPoints(keyPath: \.headCirc)
    }

    var currentPercentileLabel: String {
        switch selectedTab {
        case 0: return percentileLabel(babyPoints: babyWeightPoints, reference: whoWeightData)
        case 1: return percentileLabel(babyPoints: babyHeightPoints, reference: whoHeightData)
        case 2: return percentileLabel(babyPoints: babyHeadPoints,  reference: whoHeadData)
        default: return ""
        }
    }

    private func growthPoints(keyPath: KeyPath<MeasurementEntry, String>) -> [BabyGrowthPoint] {
        guard babyBirthInterval > 0 else { return [] }
        let birth = Date(timeIntervalSince1970: babyBirthInterval)
        return measurements.compactMap { m in
            let months = Calendar.current.dateComponents([.month], from: birth, to: m.date).month ?? 0
            guard let val = parseNumber(from: m[keyPath: keyPath]),
                  months >= 0, months <= 24 else { return nil }
            return BabyGrowthPoint(month: months, value: val)
        }
    }

    private func parseNumber(from s: String) -> Double? {
        guard s != "—" else { return nil }
        let token = s.components(separatedBy: .whitespaces).first ?? s
        return Double(token.replacingOccurrences(of: ",", with: "."))
    }

    private func percentileLabel(babyPoints: [BabyGrowthPoint], reference: [WHOPoint]) -> String {
        guard let latest = babyPoints.max(by: { $0.month < $1.month }),
              let ref = reference.min(by: { abs($0.month - latest.month) < abs($1.month - latest.month) })
        else { return "" }
        let v = latest.value
        if v < ref.p3  { return lm.t("below P3",  "ниже P3") }
        if v < ref.p15 { return "P3–P15" }
        if v < ref.p50 { return "P15–P50" }
        if v < ref.p85 { return "P50–P85" }
        if v < ref.p97 { return "P85–P97" }
        return lm.t("above P97", "выше P97")
    }

    // MARK: - Tabs

    var tabs: [String] {
        [lm.t("Weight", "Вес"), lm.t("Height", "Рост"), lm.t("Head", "Голова"), lm.t("Temperature", "Температура")]
    }

    var displayName: String {
        let name = UserDefaults.standard.string(forKey: "babyName") ?? ""
        return name.isEmpty ? lm.t("Baby", "Малыш") : name
    }

    var headerSummary: String {
        switch selectedTab {
        case 0: return "\(measurements.first?.weight ?? "—") · \(lm.t("today", "сегодня"))"
        case 1: return "\(measurements.first?.height ?? "—") · \(lm.t("today", "сегодня"))"
        case 2: return "\(measurements.first?.headCirc ?? "—") · \(lm.t("today", "сегодня"))"
        case 3:
            guard let e = tempLog.first else { return lm.t("no data", "нет данных") }
            return String(format: "%.1f°C · %@ %@", e.value, e.dateLabel, e.timeLabel)
        default: return ""
        }
    }

    var pillText: String {
        if selectedTab == 3, let v = tempLog.first?.value {
            return v >= 38.5 ? lm.t("high", "высокая") : v >= 37.5 ? lm.t("subfebr.", "субфебрильная") : lm.t("normal", "норма")
        }
        return lm.t("normal", "в норме")
    }

    var pillColor: Color {
        if selectedTab == 3, let v = tempLog.first?.value {
            return v >= 38.5 ? .bbRose : v >= 37.5 ? .bbButter : .bbMint
        }
        return .bbMint
    }

    var pillFg: Color {
        if selectedTab == 3, let v = tempLog.first?.value {
            return v >= 38.5 ? .bbCoralDeep : v >= 37.5 ? .bbButterDeep : .bbMintDeep
        }
        return .bbMintDeep
    }

    func addMeasurement(_ entry: MeasurementEntry) {
        measurements.insert(entry, at: 0)
        Task { try? await measurementRepo.add(entry) }
    }

    func addTemp(_ entry: TemperatureEntry) {
        tempLog.insert(entry, at: 0)
        Task { try? await temperatureRepo.add(entry) }
    }
}
