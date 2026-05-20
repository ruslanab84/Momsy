import Foundation

final class AppendChatMessageUseCase {
    private let repository: any ChatRepository
    init(repository: any ChatRepository) { self.repository = repository }

    func execute(_ message: ChatMessage) async throws {
        try await repository.append(message)
    }
}
