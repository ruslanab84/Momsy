import Foundation

protocol BabyRepository {
    func getProfile() async throws -> BabyProfile?
    func saveProfile(_ profile: BabyProfile) async throws
}
