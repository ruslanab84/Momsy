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
    }

    func loadAll() async {
        measurements = (try? await measurementRepo.getAll()) ?? []
        tempLog = (try? await temperatureRepo.getAll()) ?? []
    }

    // MARK: - Growth Points

    var babyWeightPoints: [BabyGrowthPoint] {
        growthPoints(keyPath: \.weight)
    }
    var babyHeightPoints: [BabyGrowthPoint] {
        growthPoints(keyPath: \.height)
    }
    var babyHeadPoints: [BabyGrowthPoint] {
        growthPoints(keyPath: \.headCirc)
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
        let log = MeasurementLog(
            id: entry.id.uuidString, date: entry.date,
            weight: entry.weight, height: entry.height,
            headCirc: entry.headCirc, addedBy: "", addedByName: ""
        )
        Task { try? await BabySyncService().setLog(MeasurementLogDTO(from: log), id: log.id, to: "measurementLogs") }
    }

    func addTemp(_ entry: TemperatureEntry) {
        tempLog.insert(entry, at: 0)
        Task {
            do { try await temperatureRepo.add(entry) }
            catch { saveError = error.localizedDescription }
        }
        pushTemperatureToFirestore(entry)
    }

    private func pushTemperatureToFirestore(_ entry: TemperatureEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = TemperatureLog(
            id: entry.id.uuidString, date: entry.date,
            value: entry.value, note: entry.note,
            addedBy: "", addedByName: ""
        )
        Task { try? await BabySyncService().setLog(TemperatureLogDTO(from: log), id: log.id, to: "temperatureLogs") }
    }
}
