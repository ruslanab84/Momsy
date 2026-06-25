import FirebaseFirestore

struct SleepLogDTO: Codable {
    @DocumentID var id: String?
    let startedAt: Timestamp
    let endedAt: Timestamp?
    let durationMin: Int?
    let quality: String
    let addedBy: String
    let addedByName: String
    @ServerTimestamp var updatedAt: Timestamp?

    init(from model: SleepLog) {
        self.startedAt   = Timestamp(date: model.startedAt)
        self.endedAt     = model.endedAt.map { Timestamp(date: $0) }
        self.durationMin = model.durationMin
        self.quality     = Self.firestoreKey(for: model.quality)
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: SleepLog {
        SleepLog(
            id:          id ?? UUID().uuidString,
            startedAt:   startedAt.dateValue(),
            endedAt:     endedAt?.dateValue(),
            durationMin: durationMin,
            quality:     Self.sleepQuality(from: quality),
            addedBy:     addedBy,
            addedByName: addedByName,
            updatedAt:   updatedAt?.dateValue() ?? .distantPast
        )
    }

    // restless maps to "poor" in Firestore (spec uses good/normal/poor)
    private static func firestoreKey(for quality: SleepQuality) -> String {
        switch quality {
        case .good:     return "good"
        case .normal:   return "normal"
        case .restless: return "poor"
        }
    }

    private static func sleepQuality(from key: String) -> SleepQuality {
        switch key {
        case "good":   return .good
        case "normal": return .normal
        default:       return .restless
        }
    }
}
