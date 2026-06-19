@testable import Momsy
import Foundation

final class MockBabyRepository: BabyRepository {
    private var profiles: [BabyProfile]

    init(initialProfile: BabyProfile? = nil) {
        self.profiles = initialProfile.map { [$0] } ?? []
    }

    init(initialProfiles: [BabyProfile]) {
        self.profiles = initialProfiles
    }

    func getProfile() async throws -> BabyProfile? {
        if let activeId = ActiveBaby.currentId, let match = profiles.first(where: { $0.id == activeId }) {
            return match
        }
        return profiles.sorted { $0.birthDate < $1.birthDate }.first
    }

    func getAllProfiles() async throws -> [BabyProfile] {
        profiles.sorted { $0.birthDate < $1.birthDate }
    }

    func saveProfile(_ p: BabyProfile) async throws {
        if let idx = profiles.firstIndex(where: { $0.id == p.id }) {
            profiles[idx] = p
        } else {
            guard profiles.count < ActiveBaby.maxChildren else { throw BabyError.maxChildrenReached }
            profiles.append(p)
        }
        if ActiveBaby.currentId == nil { ActiveBaby.currentId = p.id }
    }

    func deleteProfile(id: UUID) async throws {
        profiles.removeAll { $0.id == id }
    }
}
