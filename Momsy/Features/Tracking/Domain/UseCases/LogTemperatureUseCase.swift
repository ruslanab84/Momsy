import Foundation

final class LogTemperatureUseCase {
    private let repository: TemperatureRepository
    init(repository: TemperatureRepository) { self.repository = repository }

    @discardableResult
    func execute(value: Double, note: String = "") async throws -> TemperatureEntry {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let now = Date()
        let entry = TemperatureEntry(
            date: now,
            dateLabel: formatter.string(from: now),
            timeLabel: timeFormatter.string(from: now),
            value: value,
            note: note
        )
        try await repository.add(entry)
        return entry
    }
}
