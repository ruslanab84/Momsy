import SwiftData
import Foundation

final class SwiftDataLeapsRepository: LeapsRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAllProgress() async throws -> [LeapProgress] {
        try context.fetch(FetchDescriptor<LeapProgressRecord>()).map { $0.toDomain() }
    }

    func saveProgress(_ progress: LeapProgress) async throws {
        let all = try context.fetch(FetchDescriptor<LeapProgressRecord>())
        if let record = all.first(where: { $0.leapID == progress.id }) {
            record.isDone        = progress.isDone
            record.completedDate = progress.completedDate
        } else {
            context.insert(LeapProgressRecord(progress))
        }
        try context.save()
    }

    func resetProgress(id: Int) async throws {
        let all = try context.fetch(FetchDescriptor<LeapProgressRecord>())
        if let record = all.first(where: { $0.leapID == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
