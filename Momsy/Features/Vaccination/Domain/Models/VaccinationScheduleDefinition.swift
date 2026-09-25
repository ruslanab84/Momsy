import Foundation

/// A national/international schedule. `sourceID` is intentionally non-optional:
/// a schedule cannot exist in the app without an official citation.
struct VaccinationScheduleDefinition: Sendable {
    let key: VaccinationScheduleKey
    let sourceID: MedicalSourceID
    let idRange: ClosedRange<Int>      // catalogIds never collide across schedules
    let lastReviewed: String           // ISO date data was checked against sourceID
    let items: [VaccinationScheduleItem]
}

/// Identifies a national/international vaccination schedule. Stored on the child
/// (`BabyProfile.vaccinationScheduleKey`) by rawValue — never rename a case.
/// Id ranges: who 100–199, usAAP 200–299, caNational 300–399, deSTIKO 400–499,
/// frNational 500–599, itNational 600–699, esNational 700–799, brNational 800–899.
/// 900–999 is reserved for a future China schedule.
enum VaccinationScheduleKey: String, CaseIterable, Identifiable, Sendable {
    case who, usAAP, caNational, deSTIKO, frNational, itNational, esNational, brNational
    case ukNHS, ruNational
    var id: String { rawValue }

    func displayName(_ s: L10n) -> String {
        switch self {
        case .who:        s.vaccinationScheduleName_who
        case .usAAP:      s.vaccinationScheduleName_usAAP
        case .caNational: s.vaccinationScheduleName_caNational
        case .deSTIKO:    s.vaccinationScheduleName_deSTIKO
        case .frNational: s.vaccinationScheduleName_frNational
        case .itNational: s.vaccinationScheduleName_itNational
        case .esNational: s.vaccinationScheduleName_esNational
        case .brNational: s.vaccinationScheduleName_brNational
        case .ukNHS:      s.vaccinationScheduleName_ukNHS
        case .ruNational: s.vaccinationScheduleName_ruNational
        }
    }
}
