import SwiftData
import Foundation

final class SwiftDataBabyRepository: BabyRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getProfile() async throws -> BabyProfile? {
        var descriptor = FetchDescriptor<BabyRecord>()
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDomain()
    }

    func saveProfile(_ profile: BabyProfile) async throws {
        var descriptor = FetchDescriptor<BabyRecord>()
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            record.id        = profile.id
            record.name      = profile.name
            record.birthDate = profile.birthDate
            record.stage     = profile.stage
            record.gender    = profile.gender
        } else {
            context.insert(BabyRecord(profile))
        }
        try context.save()
        // Mirror the baby id for non-actor cloud-path resolution (see BabySyncService).
        // This is the single chokepoint for every local save: onboarding, profile edit,
        // and cloud-profile adoption all route through here.
        UserDefaults.standard.set(profile.id.uuidString, forKey: kBabyIdDefaultsKey)
    }
}
