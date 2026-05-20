import Foundation
import FirebaseAI

final class GeminiChatService: AIChatService {
    private let modelName = "gemini-2.0-flash"

    func stream(
        userText: String,
        history: [ChatMessage],
        context: BabyContext
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
                        modelName: modelName,
                        systemInstruction: ModelContent(role: "system", parts: systemPrompt(context))
                    )

                    let chatHistory = history.map { msg in
                        ModelContent(role: msg.role == .user ? "user" : "model", parts: msg.content)
                    }

                    let chat = model.startChat(history: chatHistory)
                    let responseStream = try chat.sendMessageStream(userText)

                    for try await chunk in responseStream {
                        if let text = chunk.text {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func systemPrompt(_ ctx: BabyContext) -> String {
        var lines = [
            "You are Momsy AI — a warm, evidence-based assistant for parents of young babies.",
            "",
            "Baby: \(ctx.babyName), \(ctx.ageWeeks) weeks old (\(ctx.ageMonths) months).",
        ]
        if !ctx.currentLeap.isEmpty {
            lines.append("Current developmental leap: \(ctx.currentLeap) — \(ctx.leapDescription)")
        }
        lines += [
            "",
            "Guidelines:",
            "• Give practical, actionable advice about sleep, feeding, development, and health.",
            "• Be warm, concise, and reassuring — parenting is hard.",
            "• For medical symptoms, always recommend consulting a paediatrician.",
            "• Use the baby's name when relevant.",
            "• Respond in the same language as the user's message (English or Russian).",
        ]
        return lines.joined(separator: "\n")
    }
}
