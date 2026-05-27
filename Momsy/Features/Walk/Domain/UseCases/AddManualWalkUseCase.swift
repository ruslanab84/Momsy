import Foundation

final class AddManualWalkUseCase {
    private let repository: any WalkRepository
    init(repository: any WalkRepository) { self.repository = repository }

    func execute(startDate: Date, endDate: Date) async throws -> WalkEntry {
        let entry = WalkEntry(startDate: startDate, endDate: endDate)
        try await repository.add(entry)
        return entry
    }
}
