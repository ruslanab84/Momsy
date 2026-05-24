import SwiftData
import Foundation

final class SwiftDataMomMoodRepository: MomMoodRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getEntries(from: Date, to: Date) async throws -> [MomMoodEntry] {
        let all = try context.fetch(FetchDescriptor<MomMoodRecord>())
        return all.filter { $0.date >= from && $0.date <= to }
                  .sorted { $0.date > $1.date }
                  .map { $0.toDomain() }
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
        var descriptor = FetchDescriptor<MomMoodRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDomain()
    }
}
