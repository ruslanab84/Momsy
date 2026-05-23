import Foundation

struct GetFoodEntriesUseCase {
    let repository: any ComplementaryFeedingRepository

    func execute() async throws -> [ComplementaryFoodEntry] {
        try await repository.getAll()
    }
}
