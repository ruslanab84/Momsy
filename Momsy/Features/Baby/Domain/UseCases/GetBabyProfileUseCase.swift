import Foundation

final class GetBabyProfileUseCase {
    private let repository: BabyRepository
    init(repository: BabyRepository) { self.repository = repository }

    func execute() async throws -> BabyProfile? {
        try await repository.getProfile()
    }
}
