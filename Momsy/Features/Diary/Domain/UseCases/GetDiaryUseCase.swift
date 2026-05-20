import Foundation

final class GetDiaryUseCase {
    private let repository: DiaryRepository
    init(repository: DiaryRepository) { self.repository = repository }

    func execute(from: Date, to: Date) async throws -> [StoredDiaryItem] {
        try await repository.getEntries(from: from, to: to)
    }
}
