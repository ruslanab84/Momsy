import SwiftUI
import Combine

enum UnitSystem: String, CaseIterable {
    case metric   = "metric"
    case imperial = "imperial"
}

enum TempCategory {
    case normal, subfebr, high

    var color: Color {
        switch self {
        case .normal:  return .bbMintDeep
        case .subfebr: return .bbButterDeep
        case .high:    return .bbCoralDeep
        }
    }

    func label(loc: L10n) -> String {
        switch self {
        case .normal:  return loc.normalOk
        case .subfebr: return loc.subfebrLabel
        case .high:    return loc.highTemp
        }
    }
}

extension Array where Element == WHOPoint {
    func scaledBy(_ factor: Double) -> [WHOPoint] {
        map {
            WHOPoint(month: $0.month,
                     p3:  $0.p3  * factor,
                     p15: $0.p15 * factor,
                     p50: $0.p50 * factor,
                     p85: $0.p85 * factor,
                     p97: $0.p97 * factor)
        }
    }
}

final class UnitSystemManager: ObservableObject {
    static let shared = UnitSystemManager()

    @Published private(set) var current: UnitSystem

    private init() {
        let stored = UserDefaults.standard.string(forKey: "unitSystem") ?? "metric"
        current = UnitSystem(rawValue: stored) ?? .metric
    }

    func set(_ system: UnitSystem) {
        current = system
        UserDefaults.standard.set(system.rawValue, forKey: "unitSystem")
    }

    var isImperial: Bool { current == .imperial }

    // MARK: Unit labels
    var weightUnit: String { isImperial ? "lb" : "kg" }
    var heightUnit: String { isImperial ? "in" : "cm" }
    var tempUnit:   String { isImperial ? "°F" : "°C" }
    var volumeUnit: String { isImperial ? "oz" : "ml" }

    // MARK: Chart scale factors
    var weightChartFactor: Double { isImperial ? 2.20462 : 1.0 }
    var heightChartFactor: Double { isImperial ? 1.0 / 2.54 : 1.0 }

    // MARK: Metric → display strings
    func displayWeight(fromKg kg: Double, localizedMetricUnit: String = "kg") -> String {
        isImperial ? String(format: "%.1f lb", kg * 2.20462)
                   : String(format: "%.1f \(localizedMetricUnit)", kg)
    }
    func displayHeight(fromCm cm: Double, localizedMetricUnit: String = "cm") -> String {
        isImperial ? String(format: "%.1f in", cm / 2.54)
                   : String(format: "%.1f \(localizedMetricUnit)", cm)
    }
    func displayTemp(fromCelsius c: Double) -> Double {
        isImperial ? c * 9 / 5 + 32 : c
    }
    func displayVolume(fromMl ml: Int) -> String {
        isImperial ? String(format: "%.1f oz", Double(ml) / 29.5735) : "\(ml) ml"
    }

    // MARK: User input → metric storage
    func toKg(_ v: Double) -> Double      { isImperial ? v / 2.20462 : v }
    func toCm(_ v: Double) -> Double      { isImperial ? v * 2.54    : v }
    func toCelsius(_ v: Double) -> Double { isImperial ? (v - 32) * 5 / 9 : v }

    // MARK: Parse stored "6.5 kg" → display in current unit
    func displayWeightFromStored(_ s: String, localizedMetricUnit: String = "kg") -> String {
        guard s != "—", let v = parseNum(s) else { return s }
        return displayWeight(fromKg: v, localizedMetricUnit: localizedMetricUnit)
    }
    func displayHeightFromStored(_ s: String, localizedMetricUnit: String = "cm") -> String {
        guard s != "—", let v = parseNum(s) else { return s }
        return displayHeight(fromCm: v, localizedMetricUnit: localizedMetricUnit)
    }

    // MARK: Temperature category (always in Celsius)
    func tempCategory(_ celsius: Double) -> TempCategory {
        celsius >= 38.5 ? .high : celsius >= 37.5 ? .subfebr : .normal
    }

    // MARK: Temp legend labels
    var tempNormalLabel:  String { isImperial ? "normal < 99.5°"       : "normal < 37.5°" }
    var tempSubfebrLabel: String { isImperial ? "subfebr. 99.5–101.3°" : "subfebr. 37.5–38.4°" }
    var tempHighLabel:    String { isImperial ? "high ≥ 101.3°"        : "high ≥ 38.5°" }

    // MARK: Input placeholders
    var weightPlaceholder: String { isImperial ? "lb (e.g. 14.1)" : "kg (e.g. 6.4)" }
    var heightPlaceholder: String { isImperial ? "in (e.g. 25.2)" : "cm (e.g. 64)"  }
    var headPlaceholder:   String { isImperial ? "in (e.g. 16.5)" : "cm (e.g. 42)"  }
    var tempPlaceholder:   String { isImperial ? "e.g. 98.6"      : "e.g. 37.2"     }

    private func parseNum(_ s: String) -> Double? {
        let token = s.components(separatedBy: .whitespaces).first ?? s
        return Double(token.replacingOccurrences(of: ",", with: "."))
    }
}
