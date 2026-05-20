import Foundation

final class AddDiaryEntryUseCase {
    private let repository: DiaryRepository
    init(repository: DiaryRepository) { self.repository = repository }

    @discardableResult
    func execute(_ item: StoredDiaryItem) async throws -> StoredDiaryItem {
        try await repository.add(item)
        return item
    }
}
