@testable import Momsy

final class MockAIChatService: AIChatService, @unchecked Sendable {
    var chunks: [String] = ["Hello", " World"]
    var shouldThrow = false

    func stream(
        userText: String,
        history: [ChatMessage],
        context: BabyContext
    ) -> AsyncThrowingStream<String, Error> {
        let chunks = self.chunks
        let shouldThrow = self.shouldThrow
        return AsyncThrowingStream { continuation in
            Task {
                if shouldThrow {
                    continuation.finish(throwing: TestError.mock)
                    return
                }
                for chunk in chunks {
                    continuation.yield(chunk)
                }
                continuation.finish()
            }
        }
    }
}
