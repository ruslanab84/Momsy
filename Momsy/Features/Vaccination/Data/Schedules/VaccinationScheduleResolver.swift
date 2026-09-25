import Foundation

protocol VaccinationScheduleResolving {
    var availableKeys: [VaccinationScheduleKey] { get }
    func definition(for baby: BabyProfile?) -> VaccinationScheduleDefinition
    func item(forCatalogId id: Int) -> (item: VaccinationScheduleItem, key: VaccinationScheduleKey)?
}

/// Stateless: the schedule lives on the child (`BabyProfile.vaccinationScheduleKey`),
/// `nil` meaning "auto" (device region, clamped to registered schedules).
struct VaccinationScheduleResolver: VaccinationScheduleResolving {
    /// Only schedules whose official source was fetched and transcribed are registered.
    static let definitions: [VaccinationScheduleKey: VaccinationScheduleDefinition] = [
        .who: WHOSchedule.definition,
        .usAAP: USAAPSchedule.definition,
        .deSTIKO: GermanySTIKOSchedule.definition,
        .esNational: SpainSchedule.definition,
        .brNational: BrazilSchedule.definition,
    ]

    var regionProvider: () -> String? = { Locale.current.region?.identifier }

    var availableKeys: [VaccinationScheduleKey] {
        VaccinationScheduleKey.allCases.filter { Self.definitions[$0] != nil }
    }

    func definition(for baby: BabyProfile?) -> VaccinationScheduleDefinition {
        // An unknown stored rawValue (e.g. written by a newer app version) falls back
        // to auto for display only — the stored value is never overwritten here.
        if let raw = baby?.vaccinationScheduleKey,
           let key = VaccinationScheduleKey(rawValue: raw),
           let def = Self.definitions[key] {
            return def
        }
        return Self.definitions[autoDetect()] ?? WHOSchedule.definition
    }

    func item(forCatalogId id: Int) -> (item: VaccinationScheduleItem, key: VaccinationScheduleKey)? {
        for def in Self.definitions.values where def.idRange.contains(id) {
            if let item = def.items.first(where: { $0.id == id }) { return (item, def.key) }
        }
        return nil
    }

    /// Maps the device region to a schedule, clamped to registered schedules.
    func autoDetect() -> VaccinationScheduleKey {
        let mapped: VaccinationScheduleKey
        switch regionProvider() {
        case "US": mapped = .usAAP
        case "CA": mapped = .caNational
        case "DE": mapped = .deSTIKO
        case "FR": mapped = .frNational
        case "IT": mapped = .itNational
        case "ES": mapped = .esNational
        case "BR": mapped = .brNational
        case "GB": mapped = .ukNHS
        case "RU": mapped = .ruNational
        default:   mapped = .who
        }
        return Self.definitions[mapped] != nil ? mapped : .who
    }
}
