import Foundation

/// Biological sex, as needed by sex-specific medical reference data (WHO growth
/// standards). Absent whenever `BabyProfile.gender` is unset or "unknown".
enum BabySex: String {
    case boy
    case girl
}

struct BabyProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var birthDate: Date
    var stage: String  // BabyAgeStage.rawValue
    var gender: String
    /// `VaccinationScheduleKey.rawValue`; `nil` = auto (device region). MUST stay
    /// optional: profiles are JSON-decoded from UserDefaults with synthesized
    /// Codable, and a non-optional field would fail every existing payload.
    var vaccinationScheduleKey: String?

    init(id: UUID = UUID(), name: String = "", birthDate: Date = Date(),
         stage: String = "newborn", gender: String = "", vaccinationScheduleKey: String? = nil) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.stage = stage
        self.gender = gender
        self.vaccinationScheduleKey = vaccinationScheduleKey
    }

    var sex: BabySex? { BabySex(rawValue: gender) }
}
