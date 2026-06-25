import FirebaseFirestore

struct WaterIntakeLogDTO: Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let amountMl: Int
    let addedBy: String
    let addedByName: String
    @ServerTimestamp var updatedAt: Timestamp?

    init(from model: WaterIntakeLog) {
        self.date        = Timestamp(date: model.date)
        self.amountMl    = model.amountMl
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: WaterIntakeLog {
        WaterIntakeLog(
            id:          id ?? UUID().uuidString,
            date:        date.dateValue(),
            amountMl:    amountMl,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
