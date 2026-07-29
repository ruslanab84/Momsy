import Foundation

final class LocalFamilyRepository: FamilyRepository {
    private let key = "local_family_members"

    private func load() throws -> [StoredFamilyMember] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([StoredFamilyMember].self, from: data)
    }

    private func save(_ members: [StoredFamilyMember]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(members), forKey: key)
    }

    func getMembers() async throws -> [StoredFamilyMember] {
        try load()
    }

    func update(_ member: StoredFamilyMember) async throws {
        var members = try load()
        if let idx = members.firstIndex(where: { $0.id == member.id }) { members[idx] = member }
        try save(members)
    }

    func prepareForRosterManagement(currentMember: StoredFamilyMember) async throws { }

    func remove(_ member: StoredFamilyMember) async throws {
        var members = try load()
        members.removeAll { $0.id == member.id }
        try save(members)
    }
}
