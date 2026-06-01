import FirebaseFirestore

struct DoctorVisitLogDTO: Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let addedBy: String
    let addedByName: String

    init(from model: DoctorVisitLog) {
        self.date        = Timestamp(date: model.date)
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: DoctorVisitLog {
        DoctorVisitLog(
            id:          id ?? UUID().uuidString,
            date:        date.dateValue(),
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
