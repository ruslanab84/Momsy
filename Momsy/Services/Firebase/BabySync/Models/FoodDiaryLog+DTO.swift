import FirebaseFirestore

struct FoodDiaryLogDTO: Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let foodName: String
    let category: String
    let reaction: String
    let isAllergen: Bool
    let notes: String
    let photoPath: String?
    let addedBy: String
    let addedByName: String

    init(from model: FoodDiaryLog) {
        self.date        = Timestamp(date: model.date)
        self.foodName    = model.foodName
        self.category    = model.category
        self.reaction    = model.reaction
        self.isAllergen  = model.isAllergen
        self.notes       = model.notes
        self.photoPath   = model.photoPath
        self.addedBy     = model.addedBy
        self.addedByName = model.addedByName
    }

    var domain: FoodDiaryLog {
        FoodDiaryLog(
            id:          id ?? UUID().uuidString,
            date:        date.dateValue(),
            foodName:    foodName,
            category:    category,
            reaction:    reaction,
            isAllergen:  isAllergen,
            notes:       notes,
            photoPath:   photoPath,
            addedBy:     addedBy,
            addedByName: addedByName
        )
    }
}
