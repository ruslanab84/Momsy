import Foundation

/// Who stands behind a medical source. Policy: WHO first for every country;
/// NHS, then AAP, only where WHO has no document on the topic. Peer-reviewed
/// originals are reserved for instruments and theories (EPDS licence citation).
/// National vaccination schedules cite their national authority; the WHO-first
/// policy applies to every other topic.
enum MedicalPublisher: String, Sendable, CaseIterable {
    case who, nhs, aap, peerReviewed
    case phac, stiko, frHealthMinistry, itHealthMinistry, esHealthMinistry, brHealthMinistry

    var priority: Int {
        switch self {
        case .who: 0
        case .nhs: 1
        case .aap: 2
        case .peerReviewed: 3
        case .phac, .stiko, .frHealthMinistry, .itHealthMinistry, .esHealthMinistry, .brHealthMinistry: 1
        }
    }

    /// The only host a source of this publisher may link to; `nil` for print citations.
    var allowedHost: String? {
        switch self {
        case .who: "www.who.int"
        case .nhs: "www.nhs.uk"
        case .aap: "www.healthychildren.org"
        case .peerReviewed: nil
        case .phac: "www.canada.ca"
        case .stiko: "www.rki.de"
        case .frHealthMinistry: "sante.gouv.fr"
        case .itHealthMinistry: "www.salute.gov.it"
        case .esHealthMinistry: "www.sanidad.gob.es"
        case .brHealthMinistry: "www.gov.br"
        }
    }

    /// Path every URL of this publisher must start with, when the host is shared
    /// by unrelated government bodies (gov.br hosts every federal ministry).
    var allowedPathPrefix: String? {
        switch self {
        case .brHealthMinistry: "/saude/"
        default: nil
        }
    }

    /// Short badge label. Publisher acronyms are not translated.
    var badge: String {
        switch self {
        case .who: "WHO"
        case .nhs: "NHS"
        case .aap: "AAP"
        case .peerReviewed: "Study"
        case .phac: "PHAC"
        case .stiko: "STIKO"
        case .frHealthMinistry: "Ministère"
        case .itHealthMinistry: "Ministero"
        case .esHealthMinistry: "SNS"
        case .brHealthMinistry: "PNI"
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
    case whoMotorDevelopmentMilestones
    // Peer-reviewed
    case epdsCox1987, leapsVanDeRijtPlooij1992
    // NHS / AAP fallbacks — only where WHO has no document on the topic
    case nhsSIDS, aapSafeSleep, aapSwaddling
    case nhsRefluxInBabies, nhsColic, nhsNappyRash, nhsCradleCap, nhsFeverInChildren
    case nhsFlatHeadSyndrome, nhsWashingBathingBaby, nhsHelpingBabySleep, nhsTeething
    case nhsBottleFeeding, nhsBabyFirstAid, nhsParentTiredness
    // National vaccination schedules — cited only by their own schedule
    case aapImmunizationSchedule, stikoImpfkalender, esCalendarioComun, brCalendarioNacional
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
