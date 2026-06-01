import SwiftData
import Foundation

final class SwiftDataLeapsRepository: LeapsRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAllProgress() async throws -> [LeapProgress] {
        try context.fetch(FetchDescriptor<LeapProgressRecord>())
            .uniqued(by: { $0.leapID }).map { $0.toDomain() }
    }

    func saveProgress(_ progress: LeapProgress) async throws {
        let all = try context.fetch(FetchDescriptor<LeapProgressRecord>())
        // Duplicate rows per leapID can exist defensively; update them all.
        let matches = all.filter { $0.leapID == progress.id }
        if matches.isEmpty {
            context.insert(LeapProgressRecord(progress))
        } else {
            for record in matches {
                record.isDone        = progress.isDone
                record.completedDate = progress.completedDate
            }
        }
        try context.save()
    }

    /// Merges downloaded leap progress, keyed by leapID. Updates existing rows
    /// (all of them, in case duplicates exist) or inserts when absent.
    func upsert(_ entries: [LeapProgress]) async throws {
        guard !entries.isEmpty else { return }
        let all = try context.fetch(FetchDescriptor<LeapProgressRecord>())
        var changed = false
        for progress in entries {
            let matches = all.filter { $0.leapID == progress.id }
            if matches.isEmpty {
                context.insert(LeapProgressRecord(progress))
                changed = true
            } else {
                for record in matches where record.isDone != progress.isDone
                    || record.completedDate != progress.completedDate {
                    record.isDone        = progress.isDone
                    record.completedDate = progress.completedDate
                    changed = true
                }
            }
        }
        if changed { try context.save() }
    }

    func resetProgress(id: Int) async throws {
        let all = try context.fetch(FetchDescriptor<LeapProgressRecord>())
        let matches = all.filter { $0.leapID == id }
        guard !matches.isEmpty else { return }
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
