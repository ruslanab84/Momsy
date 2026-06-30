import FirebaseFirestore

struct QuickEventLogDTO: Codable {
    @DocumentID var id: String?
    let kind: String
    let loggedAt: Timestamp
    let label: String
    let startDate: Timestamp?
    let endDate: Timestamp?
    let addedBy: String
    let addedByName: String
    @ServerTimestamp var updatedAt: Timestamp?

    init(from model: QuickEventLog) {
        self.kind        = model.kind
        self.loggedAt    = Timestamp(date: model.loggedAt)
        self.label       = model.label
        self.startDate   = model.startDate.map { Timestamp(date: $0) }
        self.endDate     = model.endDate.map { Timestamp(date: $0) }
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: QuickEventLog {
        QuickEventLog(
            id:          id ?? UUID().uuidString,
            kind:        kind,
            loggedAt:    loggedAt.dateValue(),
            label:       label,
            startDate:   startDate?.dateValue(),
            endDate:     endDate?.dateValue(),
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
