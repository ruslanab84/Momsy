import Foundation

protocol FamilyRepository {
    func getMembers() async throws -> [StoredFamilyMember]
    func add(_ member: StoredFamilyMember) async throws
    func update(_ member: StoredFamilyMember) async throws
    func remove(id: UUID) async throws
}
