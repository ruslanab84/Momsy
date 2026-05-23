@testable import Momsy

final class MockBabyRepository: BabyRepository {
    private var profile: BabyProfile?

    init(initialProfile: BabyProfile? = nil) {
        self.profile = initialProfile
    }

    func getProfile() async throws -> BabyProfile? { profile }
    func saveProfile(_ p: BabyProfile) async throws { profile = p }
}
