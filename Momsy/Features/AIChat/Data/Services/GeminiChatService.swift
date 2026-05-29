import Foundation
import FirebaseAI

final class GeminiChatService: AIChatService {
    private let modelName = "gemini-3.1-flash-lite"

    func stream(
        userText: String,
        history: [ChatMessage],
        context: BabyContext
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                var lastError: Error?
                for attempt in 0..<3 {
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
                            if let text = chunk.text { continuation.yield(text) }
                        }
                        continuation.finish()
                        return
                    } catch {
                        lastError = error
                        Self.logError(error, attempt: attempt + 1)
                        if !isRetriable(error) || attempt == 2 { break }
                        // 429: rate-limited — use longer fixed delay; others: exponential backoff
                        let delayNs: UInt64 = Self.is429(error)
                            ? 3_000_000_000
                            : UInt64(1_000_000_000 * (1 << attempt))
                        try? await Task.sleep(nanoseconds: delayNs)
                    }
                }
                continuation.finish(throwing: lastError!)
            }
        }
    }

    private func isRetriable(_ error: Error) -> Bool {
        if let genError = error as? GenerateContentError,
           case .internalError(let underlying) = genError {
            let httpCode = (underlying as NSError).code
            // 429 = rate limit (server provides RetryInfo delay); 5xx = transient server error
            // 4xx config errors (400/403/404) are not retriable — won't self-heal
            return httpCode == 429 || httpCode == 500 || httpCode == 503 || httpCode == 0
        }
        if let urlError = error as? URLError {
            return [.timedOut, .networkConnectionLost, .cannotConnectToHost,
                    .cannotFindHost, .notConnectedToInternet].contains(urlError.code)
        }
        let desc = error.localizedDescription.lowercased()
        return desc.contains("503") || desc.contains("429") || desc.contains("unavailable")
            || desc.contains("timeout") || desc.contains("try again")
    }

    private static func is429(_ error: Error) -> Bool {
        guard let genError = error as? GenerateContentError,
              case .internalError(let underlying) = genError else { return false }
        return (underlying as NSError).code == 429
    }

    private static func logError(_ error: Error, attempt: Int) {
        if let genError = error as? GenerateContentError,
           case .internalError(let underlying) = genError {
            let ns = underlying as NSError
            print("[GeminiChatService] attempt \(attempt) internalError — domain: \(ns.domain), code: \(ns.code), desc: \(ns.localizedDescription)")
        } else {
            print("[GeminiChatService] attempt \(attempt) failed: \(error)")
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
