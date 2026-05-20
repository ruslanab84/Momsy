import Foundation

final class GetLeapsUseCase {
    private let repository: LeapsRepository
    init(repository: LeapsRepository) { self.repository = repository }

    func execute() async throws -> [LeapProgress] {
        try await repository.getAllProgress()
    }
}
