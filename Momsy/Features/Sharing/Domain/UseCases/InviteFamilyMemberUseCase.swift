import Foundation

final class InviteFamilyMemberUseCase {
    private let repository: FamilyRepository
    init(repository: FamilyRepository) { self.repository = repository }

    @discardableResult
    func execute(name: String, role: FamilyRole, email: String?) async throws -> StoredFamilyMember {
        let member = StoredFamilyMember(name: name, roleRaw: role.rawValue, inviteEmail: email)
        try await repository.add(member)
        return member
    }
}
