import Foundation

struct AddFoodEntryUseCase {
    let repository: any ComplementaryFeedingRepository

    @discardableResult
    func execute(name: String, category: FoodCategory, reaction: FoodReaction,
                 isAllergen: Bool, notes: String, photoPath: String?) async throws -> ComplementaryFoodEntry {
        let entry = ComplementaryFoodEntry(
            id: UUID(), date: Date(),
            foodName: name, category: category,
            reaction: reaction, isAllergen: isAllergen,
            notes: notes, photoPath: photoPath
        )
        try await repository.add(entry)
        return entry
    }
}
