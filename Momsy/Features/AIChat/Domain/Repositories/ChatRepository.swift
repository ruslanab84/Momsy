import Foundation

protocol ChatRepository {
    func loadHistory() async throws -> [ChatMessage]
    func append(_ message: ChatMessage) async throws
    func clearHistory() async throws
}
