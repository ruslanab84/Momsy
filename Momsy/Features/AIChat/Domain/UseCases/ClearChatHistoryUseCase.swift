import Foundation

final class ClearChatHistoryUseCase {
    private let repository: any ChatRepository
    init(repository: any ChatRepository) { self.repository = repository }

    func execute() async throws {
        try await repository.clearHistory()
    }
}
