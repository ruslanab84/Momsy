import FirebaseFirestore

struct MeasurementLogDTO: Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let weight: String
    let height: String
    let headCirc: String
    let addedBy: String
    let addedByName: String
    var updatedAt: Timestamp? = Timestamp(date: Date())

    init(from model: MeasurementLog) {
        self.date        = Timestamp(date: model.date)
        self.weight      = model.weight
        self.height      = model.height
        self.headCirc    = model.headCirc
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: MeasurementLog {
        MeasurementLog(
            id:          id ?? UUID().uuidString,
            date:        date.dateValue(),
            weight:      weight,
            height:      height,
            headCirc:    headCirc,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
