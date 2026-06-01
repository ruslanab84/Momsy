import FirebaseFirestore

/// Firestore representation of the baby profile, stored as the `babies/{familyId}`
/// PARENT document (not a subcollection) so the document is real rather than a ghost
/// parent, and the baby's identity (name/birthDate/gender/stage) is available for
/// cross-device sync.
struct BabyProfileDTO: Codable {
    let id: String          // local BabyProfile.id (UUID); doc id is the familyId
    let name: String
    let birthDate: Timestamp
    let stage: String
    let gender: String
    let updatedAt: Timestamp

    init(from profile: BabyProfile, updatedAt: Date = Date()) {
        self.id        = profile.id.uuidString
        self.name      = profile.name
        self.birthDate = Timestamp(date: profile.birthDate)
        self.stage     = profile.stage
        self.gender    = profile.gender
        self.updatedAt = Timestamp(date: updatedAt)
    }

    var updatedAtDate: Date { updatedAt.dateValue() }

    var domain: BabyProfile {
        BabyProfile(
            id:        UUID(uuidString: id) ?? UUID(),
            name:      name,
            birthDate: birthDate.dateValue(),
            stage:     stage,
            gender:    gender
        )
    }
}
