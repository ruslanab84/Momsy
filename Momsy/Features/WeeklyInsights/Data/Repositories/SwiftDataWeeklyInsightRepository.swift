import SwiftData
import Foundation

@MainActor
final class SwiftDataWeeklyInsightRepository: WeeklyInsightRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() async throws -> [WeeklyInsight] {
        let scope = ActiveBaby.scope
        guard scope != ActiveBaby.unassigned else { return [] }
        let predicate = #Predicate<WeeklyInsightRecord> { $0.babyId == scope }
        let records = try context.fetch(FetchDescriptor<WeeklyInsightRecord>(predicate: predicate))
        return records.map { $0.toDomain() }.sorted { $0.weekStart > $1.weekStart }
    }

    func latest() async throws -> WeeklyInsight? {
        let scope = ActiveBaby.scope
        guard scope != ActiveBaby.unassigned else { return nil }
        var descriptor = FetchDescriptor<WeeklyInsightRecord>(
            predicate: #Predicate { $0.babyId == scope },
            sortBy: [SortDescriptor(\.weekStart, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDomain()
    }

    func report(forWeekStarting weekStart: Date) async throws -> WeeklyInsight? {
        let scope = ActiveBaby.scope
        guard scope != ActiveBaby.unassigned else { return nil }
        let day = Calendar.current.startOfDay(for: weekStart)
        let next = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day
        let predicate = #Predicate<WeeklyInsightRecord> {
            $0.babyId == scope && $0.weekStart >= day && $0.weekStart < next
        }
        let records = try context.fetch(FetchDescriptor<WeeklyInsightRecord>(predicate: predicate))
        return records.first?.toDomain()
    }

    func save(_ insight: WeeklyInsight) async throws {
        let scope = ActiveBaby.scope
        guard scope != ActiveBaby.unassigned else { throw WeeklyInsightRepositoryError.missingBabyScope }
        let start = Calendar.current.startOfDay(for: insight.weekStart)
        let next = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let predicate = #Predicate<WeeklyInsightRecord> {
            $0.babyId == scope && $0.weekStart >= start && $0.weekStart < next
        }
        for record in try context.fetch(FetchDescriptor<WeeklyInsightRecord>(predicate: predicate)) {
            context.delete(record)
        }
        context.insert(WeeklyInsightRecord(insight, babyId: scope))
        try context.save()
    }
}

private enum WeeklyInsightRepositoryError: Error {
    case missingBabyScope
}
