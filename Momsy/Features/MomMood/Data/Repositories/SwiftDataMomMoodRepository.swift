import SwiftData
import Foundation

@MainActor
final class SwiftDataMomMoodRepository: MomMoodRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [MomMoodEntry] {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<MomMoodRecord>(
            predicate: #Predicate { $0.date >= from && $0.date <= to && $0.babyId == scope }
        )
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ entry: MomMoodEntry) async throws {
        context.insert(MomMoodRecord(
            id: entry.id,
            date: entry.date,
            mood: entry.mood,
            energy: entry.energy,
            note: entry.note,
            epdsScore: entry.epdsScore
        ))
        try context.save()
    }

    func latestEntry() async throws -> MomMoodEntry? {
        let scope = ActiveBaby.scope
        var descriptor = FetchDescriptor<MomMoodRecord>(
            predicate: #Predicate { $0.babyId == scope },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDomain()
    }
}
