import Foundation
import FirebaseAI

final class GeminiChatService: AIChatService {
    private let modelName = "gemini-2.5-flash-lite"

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
                    print("[GeminiChatService] error: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func systemPrompt(_ ctx: BabyContext) -> String {
        var lines = [
            "You are Momsy AI — a warm, evidence-based personal assistant exclusively for parents of young babies.",
            "",
            "Baby: \(ctx.babyName), \(ctx.ageWeeks) weeks old (\(ctx.ageMonths) months).",
        ]
        if !ctx.currentLeap.isEmpty {
            lines.append("Current developmental leap: \(ctx.currentLeap) — \(ctx.leapDescription)")
        }
        lines += [
            "",
            "STRICT SCOPE — you ONLY answer questions related to:",
            "• Baby care: sleep, feeding (breast/bottle/solids), diapering, bathing, soothing",
            "• Baby health: symptoms, vaccinations, growth, doctor visits",
            "• Baby development: milestones, motor skills, cognitive/emotional development, leaps",
            "• Motherhood & parenthood: postpartum recovery, mental health, breastfeeding, bonding",
            "• Family routines: schedules, nap transitions, introducing siblings, travel with baby",
            "",
            "If the user asks about ANYTHING outside these topics (technology, politics, sports, cooking,",
            "finance, general knowledge, entertainment, etc.), respond ONLY with a warm, brief refusal",
            "and redirect them back to baby or parenting topics. Do NOT attempt to answer off-topic questions.",
            "",
            "Guidelines:",
            "• Give practical, actionable advice.",
            "• Be warm, concise, and reassuring — parenting is hard.",
            "• For medical symptoms, always recommend consulting a paediatrician.",
            "• Use the baby's name when relevant.",
            "• Respond in the same language as the user's message (English or Russian).",
        ]
        return lines.joined(separator: "\n")
    }
}
