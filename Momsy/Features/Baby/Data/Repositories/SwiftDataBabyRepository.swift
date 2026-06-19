import SwiftData
import Foundation

@MainActor
final class SwiftDataBabyRepository: BabyRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getProfile() async throws -> BabyProfile? {
        if let activeId = ActiveBaby.currentId {
            var descriptor = FetchDescriptor<BabyRecord>(predicate: #Predicate { $0.id == activeId })
            descriptor.fetchLimit = 1
            if let record = try context.fetch(descriptor).first { return record.toDomain() }
        }
        // Fallback for legacy state where no active id is set yet: the oldest child.
        var any = FetchDescriptor<BabyRecord>(sortBy: [SortDescriptor(\.birthDate)])
        any.fetchLimit = 1
        return try context.fetch(any).first?.toDomain()
    }

    func getAllProfiles() async throws -> [BabyProfile] {
        let descriptor = FetchDescriptor<BabyRecord>(sortBy: [SortDescriptor(\.birthDate)])
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func saveProfile(_ profile: BabyProfile) async throws {
        let id = profile.id
        var descriptor = FetchDescriptor<BabyRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            record.name      = profile.name
            record.birthDate = profile.birthDate
            record.stage     = profile.stage
            record.gender    = profile.gender
        } else {
            let count = try context.fetchCount(FetchDescriptor<BabyRecord>())
            guard count < ActiveBaby.maxChildren else { throw BabyError.maxChildrenReached }
            context.insert(BabyRecord(profile))
        }
        try context.save()
        // First child in the roster becomes active. Subsequent children do not steal
        // focus implicitly — switching is an explicit user action (see AppContainer).
        if ActiveBaby.currentId == nil { ActiveBaby.currentId = profile.id }
    }

    func deleteProfile(id: UUID) async throws {
        var descriptor = FetchDescriptor<BabyRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }
}
