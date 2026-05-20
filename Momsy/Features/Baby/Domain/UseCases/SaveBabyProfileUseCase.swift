import Foundation

final class SaveBabyProfileUseCase {
    private let repository: BabyRepository
    init(repository: BabyRepository) { self.repository = repository }

    func execute(_ profile: BabyProfile) async throws {
        try await repository.saveProfile(profile)
    }
}
