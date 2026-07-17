import SwiftData
import Foundation

@Model
final class ComplementaryFoodRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var foodName: String = ""
    var category: String = ""
    var reaction: String = ""
    var isAllergen: Bool = false
    var notes: String = ""
    var updatedAt: Date?

    init(id: UUID = UUID(), date: Date, foodName: String,
         category: String, reaction: String,
         isAllergen: Bool, notes: String, updatedAt: Date? = nil) {
        self.id = id
        self.babyId = ActiveBaby.scope
        self.date = date
        self.foodName = foodName
        self.category = category
        self.reaction = reaction
        self.isAllergen = isAllergen
        self.notes = notes
        self.updatedAt = updatedAt
    }

    func apply(_ entry: ComplementaryFoodEntry) {
        date = entry.date
        foodName = entry.foodName
        category = entry.category.rawValue
        reaction = entry.reaction.rawValue
        isAllergen = entry.isAllergen
        notes = entry.notes
        updatedAt = entry.updatedAt
    }

    func toDomain() -> ComplementaryFoodEntry {
        ComplementaryFoodEntry(
            id: id, date: date, foodName: foodName,
            category: FoodCategory(rawValue: category) ?? .other,
            reaction: FoodReaction(rawValue: reaction) ?? .none,
            isAllergen: isAllergen, notes: notes,
            updatedAt: updatedAt
        )
    }
}
