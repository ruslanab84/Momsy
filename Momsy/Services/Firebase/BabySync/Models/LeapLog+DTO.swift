import FirebaseFirestore

struct LeapLogDTO: Codable {
    @DocumentID var id: String?
    let leapId: Int
    let isDone: Bool
    let completedDate: Timestamp?
    let addedBy: String
    let addedByName: String
    @ServerTimestamp var updatedAt: Timestamp?

    init(from model: LeapLog) {
        self.leapId        = model.leapId
        self.isDone        = model.isDone
        self.completedDate = model.completedDate.map { Timestamp(date: $0) }
        self.addedBy       = model.addedBy
        self.addedByName   = model.addedByName
    }

    var domain: LeapLog {
        LeapLog(
            id:            id ?? String(leapId),
            leapId:        leapId,
            isDone:        isDone,
            completedDate: completedDate?.dateValue(),
            addedBy:       addedBy,
            addedByName:   addedByName
        )
    }
}
