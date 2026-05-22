import SwiftData
import Foundation

final class SwiftDataChatRepository: ChatRepository {
    private let context: ModelContext
    private let maxMessages = 100

    init(context: ModelContext) { self.context = context }

    func loadHistory() async throws -> [ChatMessage] {
        let descriptor = FetchDescriptor<ChatMessageRecord>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func append(_ message: ChatMessage) async throws {
        context.insert(ChatMessageRecord(message))
        try context.save()
        try trimToLimit()
    }

    func clearHistory() async throws {
        let all = try context.fetch(FetchDescriptor<ChatMessageRecord>())
        all.forEach { context.delete($0) }
        try context.save()
    }

    private func trimToLimit() throws {
        let descriptor = FetchDescriptor<ChatMessageRecord>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        let all = try context.fetch(descriptor)
        guard all.count > maxMessages else { return }
        all.prefix(all.count - maxMessages).forEach { context.delete($0) }
        try context.save()
    }
}
