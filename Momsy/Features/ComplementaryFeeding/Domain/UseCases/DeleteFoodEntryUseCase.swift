import Foundation

struct DeleteFoodEntryUseCase {
    let repository: any ComplementaryFeedingRepository

    func execute(id: UUID) async {
        try? await repository.delete(id: id)
    }
}
