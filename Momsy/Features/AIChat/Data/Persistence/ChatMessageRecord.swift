import SwiftData
import Foundation

@Model
final class ChatMessageRecord {
    var id: UUID
    var roleRaw: String
    var content: String
    var timestamp: Date

    init(_ message: ChatMessage) {
        id        = message.id
        roleRaw   = message.role.rawValue
        content   = message.content
        timestamp = message.timestamp
    }

    func toDomain() -> ChatMessage {
        ChatMessage(
            id: id,
            role: ChatRole(rawValue: roleRaw) ?? .user,
            content: content,
            timestamp: timestamp
        )
    }
}
