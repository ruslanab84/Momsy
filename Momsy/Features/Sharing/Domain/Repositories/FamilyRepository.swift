import Foundation

protocol FamilyRepository {
    func getMembers() async throws -> [StoredFamilyMember]
    func update(_ member: StoredFamilyMember) async throws
    func prepareForRosterManagement(currentMember: StoredFamilyMember) async throws
    func remove(_ member: StoredFamilyMember) async throws
}
