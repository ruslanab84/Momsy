import Foundation

final class GetPumpingEntriesUseCase {
    private let repository: any PumpingRepository

    init(repository: any PumpingRepository) {
        self.repository = repository
    }

    func execute(from: Date, to: Date) async throws -> [PumpingEntry] {
        try await repository.getEntries(from: from, to: to)
    }

    func executeToday() async throws -> [PumpingEntry] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? Date()
        return try await repository.getEntries(from: start, to: end)
    }
}
