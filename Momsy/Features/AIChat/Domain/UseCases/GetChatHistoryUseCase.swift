import Foundation

final class GetChatHistoryUseCase {
    private let repository: any ChatRepository
    init(repository: any ChatRepository) { self.repository = repository }

    func execute() async throws -> [ChatMessage] {
        try await repository.loadHistory()
    }
}
