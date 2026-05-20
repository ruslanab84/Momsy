import Foundation

final class GetFamilyUseCase {
    private let repository: FamilyRepository
    init(repository: FamilyRepository) { self.repository = repository }

    func execute() async throws -> [StoredFamilyMember] {
        try await repository.getMembers()
    }
}
