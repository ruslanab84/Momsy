import Foundation
import Combine

/// Identifies a national/international vaccination schedule.
enum VaccinationScheduleKey: String, CaseIterable, Identifiable {
    case who, usCDC, ukNHS, ruNational
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .who:        return "International (WHO)"
        case .usCDC:      return "United States (CDC)"
        case .ukNHS:      return "United Kingdom (NHS)"
        case .ruNational: return "Russia (National)"
        }
    }
}

/// Selects the active vaccination schedule by region, with a persisted user override.
///
/// Only `.who` has data authored for v1; every other region/key falls back to WHO.
/// Adding a national schedule later is a pure data change: author a `*Schedule.swift`,
/// add the key to `populated`, and wire it in `schedule(for:)`.
final class VaccinationScheduleProvider: ObservableObject {
    static let shared = VaccinationScheduleProvider()

    private static let storageKey = "vaccinationScheduleKey"

    /// Schedules that actually have data. Others auto-fall back to WHO.
    static let populated: Set<VaccinationScheduleKey> = [.who]

    @Published private(set) var activeKey: VaccinationScheduleKey

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let stored = VaccinationScheduleKey(rawValue: raw),
           Self.populated.contains(stored) {
            activeKey = stored
        } else {
            activeKey = Self.autoDetect()
        }
    }

    /// Schedules selectable by the user today (only populated ones).
    var availableKeys: [VaccinationScheduleKey] {
        VaccinationScheduleKey.allCases.filter { Self.populated.contains($0) }
    }

    func items() -> [VaccinationScheduleItem] {
        Self.schedule(for: activeKey)
    }

    func setKey(_ key: VaccinationScheduleKey) {
        let resolved = Self.populated.contains(key) ? key : .who
        activeKey = resolved
        UserDefaults.standard.set(resolved.rawValue, forKey: Self.storageKey)
    }

    private static func schedule(for key: VaccinationScheduleKey) -> [VaccinationScheduleItem] {
        switch key {
        case .who, .usCDC, .ukNHS, .ruNational:
            return WHOSchedule.items   // only WHO authored for v1
        }
    }

    /// Maps the device region to a schedule, clamped to schedules that have data.
    static func autoDetect() -> VaccinationScheduleKey {
        let region = Locale.current.region?.identifier
        let mapped: VaccinationScheduleKey
        switch region {
        case "US": mapped = .usCDC
        case "GB": mapped = .ukNHS
        case "RU": mapped = .ruNational
        default:   mapped = .who
        }
        return populated.contains(mapped) ? mapped : .who
    }
}
