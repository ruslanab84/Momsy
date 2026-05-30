import FirebaseFirestore

struct QuickEventLogDTO: Codable {
    @DocumentID var id: String?
    let kind: String
    let loggedAt: Timestamp
    let label: String
    let addedBy: String
    let addedByName: String

    init(from model: QuickEventLog) {
        self.kind        = model.kind
        self.loggedAt    = Timestamp(date: model.loggedAt)
        self.label       = model.label
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: QuickEventLog {
        QuickEventLog(
            id:          id ?? UUID().uuidString,
            kind:        kind,
            loggedAt:    loggedAt.dateValue(),
            label:       label,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
