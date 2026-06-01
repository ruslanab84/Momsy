import FirebaseFirestore

struct TemperatureLogDTO: Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let value: Double
    let note: String
    let addedBy: String
    let addedByName: String

    init(from model: TemperatureLog) {
        self.date        = Timestamp(date: model.date)
        self.value       = model.value
        self.note        = model.note
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: TemperatureLog {
        TemperatureLog(
            id:          id ?? UUID().uuidString,
            date:        date.dateValue(),
            value:       value,
            note:        note,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
