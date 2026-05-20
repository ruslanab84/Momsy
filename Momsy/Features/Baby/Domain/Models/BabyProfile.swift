import Foundation

struct BabyProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var birthDate: Date
    var stage: String  // BabyAgeStage.rawValue
    var gender: String

    init(id: UUID = UUID(), name: String = "", birthDate: Date = Date(),
         stage: String = "newborn", gender: String = "") {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.stage = stage
        self.gender = gender
    }
}
