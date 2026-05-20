import Foundation

final class LocalBabyRepository: BabyRepository {
    private let key = "local_baby_profile"

    func getProfile() async throws -> BabyProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(BabyProfile.self, from: data)
    }

    func saveProfile(_ profile: BabyProfile) async throws {
        let data = try JSONEncoder().encode(profile)
        UserDefaults.standard.set(data, forKey: key)
    }
}
