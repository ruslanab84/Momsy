import Foundation

struct ComplementaryFoodEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var foodName: String
    var category: FoodCategory
    var reaction: FoodReaction
    var isAllergen: Bool
    var notes: String
    var photoPath: String?
    var updatedAt: Date? = Date()
}

enum FoodCategory: String, Codable, CaseIterable {
    case vegetable, fruit, cereal, meat, dairy, fish, egg, other
}

enum FoodReaction: String, Codable, CaseIterable {
    case none, mild, severe
}
