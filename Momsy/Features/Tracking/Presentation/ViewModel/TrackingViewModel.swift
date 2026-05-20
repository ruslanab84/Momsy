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

    var tabs: [String] {
        [lm.t("Weight", "Вес"), lm.t("Height", "Рост"), lm.t("Head", "Голова"), lm.t("Temperature", "Температура")]
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
