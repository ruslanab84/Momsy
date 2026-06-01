import Foundation

struct FoodDiaryLog: Identifiable, Equatable {
    let id: String
    let date: Date
    let foodName: String
    let category: String
    let reaction: String
    let isAllergen: Bool
    let notes: String
    let photoPath: String?
    let addedBy: String
    let addedByName: String
}
