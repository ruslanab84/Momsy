import Foundation

final class MarkLeapCompleteUseCase {
    private let repository: LeapsRepository
    init(repository: LeapsRepository) { self.repository = repository }

    func execute(leapId: Int) async throws {
        let progress = LeapProgress(id: leapId, isDone: true, completedDate: Date())
        try await repository.saveProgress(progress)
    }
}
