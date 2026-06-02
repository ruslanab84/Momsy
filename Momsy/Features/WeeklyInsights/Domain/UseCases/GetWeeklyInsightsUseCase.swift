import Foundation

final class GetWeeklyInsightsUseCase {
    private let repository: any WeeklyInsightRepository

    init(repository: any WeeklyInsightRepository) {
        self.repository = repository
    }

    func all() async throws -> [WeeklyInsight] {
        try await repository.all()
    }

    func latest() async throws -> WeeklyInsight? {
        try await repository.latest()
    }
}
