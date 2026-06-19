import Foundation

final class LocalBabyRepository: BabyRepository {
    private let key = "local_baby_roster"

    private func loadAll() -> [BabyProfile] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([BabyProfile].self, from: data)) ?? []
    }

    private func persist(_ profiles: [BabyProfile]) {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func getProfile() async throws -> BabyProfile? {
        let all = loadAll()
        if let activeId = ActiveBaby.currentId, let match = all.first(where: { $0.id == activeId }) {
            return match
        }
        return all.sorted { $0.birthDate < $1.birthDate }.first
    }

    func getAllProfiles() async throws -> [BabyProfile] {
        loadAll().sorted { $0.birthDate < $1.birthDate }
    }

    func saveProfile(_ profile: BabyProfile) async throws {
        var all = loadAll()
        if let idx = all.firstIndex(where: { $0.id == profile.id }) {
            all[idx] = profile
        } else {
            guard all.count < ActiveBaby.maxChildren else { throw BabyError.maxChildrenReached }
            all.append(profile)
        }
        persist(all)
        if ActiveBaby.currentId == nil { ActiveBaby.currentId = profile.id }
    }

    func deleteProfile(id: UUID) async throws {
        persist(loadAll().filter { $0.id != id })
    }
}
