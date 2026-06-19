import SwiftData
import Foundation

@MainActor
final class SwiftDataLeapsRepository: LeapsRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAllProgress() async throws -> [LeapProgress] {
        let scope = ActiveBaby.scope
        return try context.fetch(FetchDescriptor<LeapProgressRecord>(predicate: #Predicate { $0.babyId == scope }))
            .uniqued(by: { $0.leapID }).map { $0.toDomain() }
    }

    func saveProgress(_ progress: LeapProgress) async throws {
        let leapID = progress.id
        let scope = ActiveBaby.scope
        // Duplicate rows per leapID can exist defensively; update them all (active child only).
        let matches = try context.fetch(
            FetchDescriptor<LeapProgressRecord>(predicate: #Predicate { $0.leapID == leapID && $0.babyId == scope })
        )
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
        let incomingIDs = entries.map(\.id)
        let scope = ActiveBaby.scope
        let scoped = try context.fetch(
            FetchDescriptor<LeapProgressRecord>(predicate: #Predicate { incomingIDs.contains($0.leapID) && $0.babyId == scope })
        )
        var changed = false
        for progress in entries {
            let matches = scoped.filter { $0.leapID == progress.id }
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
        let scope = ActiveBaby.scope
        let matches = try context.fetch(
            FetchDescriptor<LeapProgressRecord>(predicate: #Predicate { $0.leapID == id && $0.babyId == scope })
        )
        guard !matches.isEmpty else { return }
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
