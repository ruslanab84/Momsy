import Foundation

// TODO: Implement with Firebase SDK. Firestore path: families/{familyId}/members/{docId}
final class FirestoreFamilyRepository: FamilyRepository {
    func getMembers() async throws -> [StoredFamilyMember] { throw RepositoryError.notImplemented }
    func add(_ member: StoredFamilyMember) async throws { throw RepositoryError.notImplemented }
    func update(_ member: StoredFamilyMember) async throws { throw RepositoryError.notImplemented }
    func remove(id: UUID) async throws { throw RepositoryError.notImplemented }
}
