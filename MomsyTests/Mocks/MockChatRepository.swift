@testable import Momsy
import Foundation

final class MockChatRepository: ChatRepository, @unchecked Sendable {
    var history: [ChatMessage] = []
    var shouldThrow = false

    func loadHistory() async throws -> [ChatMessage] {
        if shouldThrow { throw TestError.mock }
        return history
    }

    func append(_ message: ChatMessage) async throws {
        if shouldThrow { throw TestError.mock }
        history.append(message)
    }

    func clearHistory() async throws {
        history = []
    }
}
