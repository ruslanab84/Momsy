import FirebaseFirestore

struct PumpingLogDTO: Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let durationSeconds: Int
    let side: String
    let volumeML: Int
    let endDate: Timestamp?
    let addedBy: String
    let addedByName: String
    @ServerTimestamp var updatedAt: Timestamp?

    init(from model: PumpingLog) {
        self.date            = Timestamp(date: model.date)
        self.durationSeconds = model.durationSeconds
        self.side            = model.side
        self.volumeML        = model.volumeML
        self.endDate         = model.endDate.map { Timestamp(date: $0) }
        self.addedBy         = model.addedBy
        self.addedByName     = model.addedByName
    }

    var domain: PumpingLog {
        PumpingLog(
            id:              id ?? UUID().uuidString,
            date:            date.dateValue(),
            durationSeconds: durationSeconds,
            side:            side,
            volumeML:        volumeML,
            endDate:         endDate?.dateValue(),
            addedBy:         addedBy,
            addedByName:     addedByName
        )
    }
}
