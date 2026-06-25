import FirebaseFirestore

struct VaccinationLogDTO: Codable {
    @DocumentID var id: String?
    let catalogId: Int
    let doneDate: Timestamp
    let vaccineName: String
    let notes: String
    let addedBy: String
    let addedByName: String
    @ServerTimestamp var updatedAt: Timestamp?

    init(from model: VaccinationLog) {
        self.catalogId   = model.catalogId
        self.doneDate    = Timestamp(date: model.doneDate)
        self.vaccineName = model.vaccineName
        self.notes       = model.notes
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: VaccinationLog {
        VaccinationLog(
            id:          id ?? UUID().uuidString,
            catalogId:   catalogId,
            doneDate:    doneDate.dateValue(),
            vaccineName: vaccineName,
            notes:       notes,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
