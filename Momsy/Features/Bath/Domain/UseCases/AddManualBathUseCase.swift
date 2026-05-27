import Foundation

final class AddManualBathUseCase {
    private let repository: any BathRepository
    init(repository: any BathRepository) { self.repository = repository }

    func execute(startDate: Date, endDate: Date) async throws -> BathEntry {
        let entry = BathEntry(startDate: startDate, endDate: endDate)
        try await repository.add(entry)
        return entry
    }
}
