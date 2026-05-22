import SwiftData
import Foundation

@Model
final class BabyRecord {
    var id: UUID
    var name: String
    var birthDate: Date
    var stage: String
    var gender: String

    init(_ profile: BabyProfile) {
        id        = profile.id
        name      = profile.name
        birthDate = profile.birthDate
        stage     = profile.stage
        gender    = profile.gender
    }

    func toDomain() -> BabyProfile {
        BabyProfile(id: id, name: name, birthDate: birthDate, stage: stage, gender: gender)
    }
}
