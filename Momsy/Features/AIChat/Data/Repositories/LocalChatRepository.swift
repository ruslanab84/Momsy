import Foundation

final class LocalChatRepository: ChatRepository {
    private let key = "local_chat_history"
    private let maxMessages = 100

    func loadHistory() async throws -> [ChatMessage] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([ChatMessage].self, from: data)
    }

    func append(_ message: ChatMessage) async throws {
        var history = (try? await loadHistory()) ?? []
        history.append(message)
        if history.count > maxMessages {
            history = Array(history.suffix(maxMessages))
        }
        UserDefaults.standard.set(try JSONEncoder().encode(history), forKey: key)
    }

    func clearHistory() async throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
