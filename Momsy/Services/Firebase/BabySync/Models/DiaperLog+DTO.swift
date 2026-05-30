import FirebaseFirestore

struct DiaperLogDTO: Codable {
    @DocumentID var id: String?
    let loggedAt: Timestamp
    let type: String
    let addedBy: String
    let addedByName: String

    init(from model: DiaperLog) {
        self.loggedAt    = Timestamp(date: model.loggedAt)
        self.type        = model.type.rawValue
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: DiaperLog {
        DiaperLog(
            id:          id ?? UUID().uuidString,
            loggedAt:    loggedAt.dateValue(),
            type:        DiaperType(rawValue: type) ?? .wet,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
