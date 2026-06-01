import SwiftData
import Foundation

@Model
final class ComplementaryFoodRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var foodName: String = ""
    var category: String = ""
    var reaction: String = ""
    var isAllergen: Bool = false
    var notes: String = ""
    var photoPath: String?

    init(id: UUID = UUID(), date: Date, foodName: String,
         category: String, reaction: String,
         isAllergen: Bool, notes: String, photoPath: String?) {
        self.id = id
        self.date = date
        self.foodName = foodName
        self.category = category
        self.reaction = reaction
        self.isAllergen = isAllergen
        self.notes = notes
        self.photoPath = photoPath
    }

    func toDomain() -> ComplementaryFoodEntry {
        ComplementaryFoodEntry(
            id: id, date: date, foodName: foodName,
            category: FoodCategory(rawValue: category) ?? .other,
            reaction: FoodReaction(rawValue: reaction) ?? .none,
            isAllergen: isAllergen, notes: notes, photoPath: photoPath
        )
    }
}
