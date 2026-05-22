import SwiftData
import Foundation

final class SwiftDataBabyRepository: BabyRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getProfile() async throws -> BabyProfile? {
        try context.fetch(FetchDescriptor<BabyRecord>()).first?.toDomain()
    }

    func saveProfile(_ profile: BabyProfile) async throws {
        let all = try context.fetch(FetchDescriptor<BabyRecord>())
        if let record = all.first {
            record.id        = profile.id
            record.name      = profile.name
            record.birthDate = profile.birthDate
            record.stage     = profile.stage
            record.gender    = profile.gender
        } else {
            context.insert(BabyRecord(profile))
        }
        try context.save()
    }
}
