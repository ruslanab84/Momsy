import Foundation

final class GetAllBabiesUseCase {
    private let repository: BabyRepository
    init(repository: BabyRepository) { self.repository = repository }

    func execute() async throws -> [BabyProfile] {
        try await repository.getAllProfiles()
    }
}
