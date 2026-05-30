import FirebaseFirestore

struct DiaryLogDTO: Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let kind: String
    let text: String
    let iconName: String
    let addedBy: String
    let addedByName: String

    init(from model: DiaryLog) {
        self.date        = Timestamp(date: model.date)
        self.kind        = model.kind
        self.text        = model.text
        self.iconName    = model.iconName
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: DiaryLog {
        DiaryLog(
            id:          id ?? UUID().uuidString,
            date:        date.dateValue(),
            kind:        kind,
            text:        text,
            iconName:    iconName,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
