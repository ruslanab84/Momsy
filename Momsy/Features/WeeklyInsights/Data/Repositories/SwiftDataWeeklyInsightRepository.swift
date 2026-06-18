import SwiftData
import Foundation

@MainActor
final class SwiftDataWeeklyInsightRepository: WeeklyInsightRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() async throws -> [WeeklyInsight] {
        let records = try context.fetch(FetchDescriptor<WeeklyInsightRecord>())
        return records.map { $0.toDomain() }.sorted { $0.weekStart > $1.weekStart }
    }

    func latest() async throws -> WeeklyInsight? {
        var descriptor = FetchDescriptor<WeeklyInsightRecord>(
            sortBy: [SortDescriptor(\.weekStart, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDomain()
    }

    func report(forWeekStarting weekStart: Date) async throws -> WeeklyInsight? {
        let day = Calendar.current.startOfDay(for: weekStart)
        let next = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day
        let predicate = #Predicate<WeeklyInsightRecord> { $0.weekStart >= day && $0.weekStart < next }
        let records = try context.fetch(FetchDescriptor<WeeklyInsightRecord>(predicate: predicate))
        return records.first?.toDomain()
    }

    func save(_ insight: WeeklyInsight) async throws {
        // Replace any existing report for the same week (unique weekStart).
        if let existing = try await report(forWeekStarting: insight.weekStart) {
            let start = Calendar.current.startOfDay(for: existing.weekStart)
            let next = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
            let predicate = #Predicate<WeeklyInsightRecord> { $0.weekStart >= start && $0.weekStart < next }
            for rec in try context.fetch(FetchDescriptor<WeeklyInsightRecord>(predicate: predicate)) {
                context.delete(rec)
            }
        }
        context.insert(WeeklyInsightRecord(insight))
        try context.save()
    }
}
