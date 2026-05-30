import FirebaseFirestore

struct SymptomLogDTO: Codable {
    @DocumentID var id: String?
    let loggedAt: Timestamp
    let description: String
    let severity: String
    let addedBy: String
    let addedByName: String

    init(from model: SymptomLog) {
        self.loggedAt    = Timestamp(date: model.loggedAt)
        self.description = model.description
        self.severity    = model.severity.rawValue
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: SymptomLog {
        SymptomLog(
            id:          id ?? UUID().uuidString,
            loggedAt:    loggedAt.dateValue(),
            description: description,
            severity:    SymptomSeverity(rawValue: severity) ?? .mild,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
