import Foundation

/// Who stands behind a medical source. Policy: WHO first for every country;
/// NHS, then AAP, only where WHO has no document on the topic. Peer-reviewed
/// originals are reserved for instruments and theories (EPDS licence citation).
enum MedicalPublisher: String, Sendable, CaseIterable {
    case who, nhs, aap, peerReviewed

    var priority: Int {
        switch self {
        case .who: 0
        case .nhs: 1
        case .aap: 2
        case .peerReviewed: 3
        }
    }

    /// The only host a source of this publisher may link to; `nil` for print citations.
    var allowedHost: String? {
        switch self {
        case .who: "www.who.int"
        case .nhs: "www.nhs.uk"
        case .aap: "www.healthychildren.org"
        case .peerReviewed: nil
        }
    }

    /// Short badge label. Publisher acronyms are not translated.
    var badge: String {
        switch self {
        case .who: "WHO"
        case .nhs: "NHS"
        case .aap: "AAP"
        case .peerReviewed: "Study"
        }
    }
}

enum MedicalSourceID: String, Sendable, CaseIterable, Hashable, Codable {
    // WHO
    case whoGrowthStandards, whoImmunizationSchedule
    case whoInfantYoungChildFeeding, whoComplementaryFeeding2023, whoPowderedFormulaPreparation
    case whoPhysicalActivitySleepUnder5, whoPostnatalCare2022, whoPretermLBWCare2022
    case whoEarlyChildhoodDevelopment2020, whoMaternalMentalHealth
    case whoDrowningFactSheet, whoChildMaltreatmentFactSheet, whoRoadTrafficInjuriesFactSheet
    case whoPocketBookHospitalCareChildren, whoWorldReportChildInjury2008
    // Peer-reviewed
    case epdsCox1987
    // NHS / AAP fallbacks — only where WHO has no document on the topic
    case nhsSIDS, aapSafeSleep, aapSwaddling
    case nhsRefluxInBabies, nhsColic, nhsNappyRash, nhsCradleCap, nhsFeverInChildren
    case nhsFlatHeadSyndrome, nhsWashingBathingBaby, nhsHelpingBabySleep, nhsTeething
    case nhsBottleFeeding, nhsBabyFirstAid, nhsParentTiredness
}

struct MedicalSource: Identifiable, Hashable, Sendable {
    let id: MedicalSourceID
    let publisher: MedicalPublisher
    /// Original title, NOT localized — it is a bibliographic reference.
    let title: String
    /// `nil` only for peer-reviewed print citations.
    let url: URL?
    /// Full bibliographic string when the licence requires it (EPDS).
    let citation: String?
    let year: String
}
