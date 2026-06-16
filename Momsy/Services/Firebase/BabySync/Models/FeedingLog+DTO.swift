import FirebaseFirestore

struct FeedingLogDTO: Codable {
    @DocumentID var id: String?
    let startedAt: Timestamp
    let endedAt: Timestamp?
    let durationMin: Int
    let side: String
    let amountMl: Int?
    let addedBy: String
    let addedByName: String
    /// Last-write-wins stamp. Defaults to now on push (a local write); decodes to
    /// nil for legacy docs written before this field existed.
    var updatedAt: Timestamp? = Timestamp(date: Date())

    init(from model: FeedingLog) {
        self.startedAt   = Timestamp(date: model.startedAt)
        self.endedAt     = model.endedAt.map { Timestamp(date: $0) }
        self.durationMin = model.durationMin
        self.side        = Self.firestoreKey(for: model.side)
        self.amountMl    = model.amountMl
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: FeedingLog {
        FeedingLog(
            id:           id ?? UUID().uuidString,
            startedAt:    startedAt.dateValue(),
            endedAt:      endedAt?.dateValue(),
            durationMin:  durationMin,
            side:         Self.feedingSide(from: side),
            amountMl:     amountMl,
            addedBy:      addedBy,
            addedByName:  addedByName
        )
    }

    private static func firestoreKey(for side: FeedingSide) -> String {
        switch side {
        case .left:   return "left"
        case .right:  return "right"
        case .bottle: return "bottle"
        }
    }

    private static func feedingSide(from key: String) -> FeedingSide {
        switch key {
        case "left":  return .left
        case "right": return .right
        default:      return .bottle
        }
    }
}
