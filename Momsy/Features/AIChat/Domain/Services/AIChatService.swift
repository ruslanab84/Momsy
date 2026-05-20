import Foundation

protocol AIChatService {
    func stream(
        userText: String,
        history: [ChatMessage],
        context: BabyContext
    ) -> AsyncThrowingStream<String, Error>
}
