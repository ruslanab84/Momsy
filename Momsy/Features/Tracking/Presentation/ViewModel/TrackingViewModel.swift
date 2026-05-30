import SwiftUI
import Combine

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var measurements: [MeasurementEntry] = []
    @Published var tempLog: [TemperatureEntry] = []
    @Published var showAddMeasurement = false
    @Published var showAddTemp = false
    @Published var saveError: String?

    private let measurementRepo: any MeasurementRepository
    private let temperatureRepo: any TemperatureRepository
    private let appState: AppState

    private var lm: LocalizationManager { .shared }

    private var babyBirthDate: Date? { appState.babyProfile?.birthDate }

    init(measurementRepo: any MeasurementRepository,
         temperatureRepo: any TemperatureRepository,
         appState: AppState) {
        self.measurementRepo = measurementRepo
        self.temperatureRepo = temperatureRepo
        self.appState = appState
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
        guard let birth = babyBirthDate else { return [] }
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
        if v < ref.p3  { return lm.strings.belowP3 }
        if v < ref.p15 { return "P3–P15" }
        if v < ref.p50 { return "P15–P50" }
        if v < ref.p85 { return "P50–P85" }
        if v < ref.p97 { return "P85–P97" }
        return lm.strings.aboveP97
    }

    // MARK: - Tabs

    var tabs: [String] {
        [lm.strings.weight, lm.strings.height, lm.strings.headShort, lm.strings.temperature]
    }

    var displayName: String { appState.displayName }

    var headerSummary: String {
        let latestDate = measurements.first?.date
        switch selectedTab {
        case 0: return "\(measurements.first?.weight ?? "—") · \(formattedDate(latestDate))"
        case 1: return "\(measurements.first?.height ?? "—") · \(formattedDate(latestDate))"
        case 2: return "\(measurements.first?.headCirc ?? "—") · \(formattedDate(latestDate))"
        case 3:
            guard let e = tempLog.first else { return lm.strings.noData }
            return String(format: "%.1f°C · %@ %@", e.value, e.dateLabel, e.timeLabel)
        default: return ""
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return lm.strings.today.lowercased() }
        if Calendar.current.isDateInToday(date) {
            return lm.strings.today.lowercased()
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM"
        fmt.locale = Locale(identifier: lm.lang)
        return fmt.string(from: date)
    }

    var pillText: String {
        if selectedTab == 3, let v = tempLog.first?.value {
            return v >= 38.5 ? lm.strings.high.lowercased() : v >= 37.5 ? lm.strings.subfebrLabel.lowercased() : lm.strings.normal.lowercased()
        }
        return lm.strings.normalRange
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
        Task {
            do { try await measurementRepo.add(entry) }
            catch { saveError = error.localizedDescription }
        }
        pushMeasurementToFirestore(entry)
    }

    private func pushMeasurementToFirestore(_ entry: MeasurementEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = MeasurementLog(
            id: entry.id.uuidString, date: entry.date,
            weight: entry.weight, height: entry.height,
            headCirc: entry.headCirc, addedBy: uid, addedByName: name
        )
        Task { try? await BabySyncService().addLog(MeasurementLogDTO(from: log), to: "measurementLogs") }
    }

    func addTemp(_ entry: TemperatureEntry) {
        tempLog.insert(entry, at: 0)
        Task {
            do { try await temperatureRepo.add(entry) }
            catch { saveError = error.localizedDescription }
        }
    }
}
