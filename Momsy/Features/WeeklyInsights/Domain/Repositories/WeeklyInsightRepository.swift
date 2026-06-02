import Foundation

/// Local (SwiftData) persistence of generated weekly reports. Never synced to Firestore.
protocol WeeklyInsightRepository {
    func all() async throws -> [WeeklyInsight]
    func latest() async throws -> WeeklyInsight?
    func report(forWeekStarting weekStart: Date) async throws -> WeeklyInsight?
    func save(_ insight: WeeklyInsight) async throws
}
