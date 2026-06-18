import Foundation
import FirebaseAI

final class GeminiWeeklyInsightService: WeeklyInsightService {

    private let modelName = "gemini-3.1-flash-lite"
    private let maxOutputTokens = 700

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        try await GeminiRetry.run(label: "GeminiWeeklyInsightService") {
            // Prompt-enforced JSON (system prompt mandates it) + tolerant decode,
            // matching the GenerationConfig surface proven in GeminiDailyTipService.
            let config = GenerationConfig(maxOutputTokens: maxOutputTokens)
            let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
                modelName: modelName,
                generationConfig: config,
                safetySettings: GeminiSafety.settings,
                systemInstruction: ModelContent(role: "system", parts: WeeklyInsightPrompt.system(for: context.language))
            )
            let response = try await model.generateContent(WeeklyInsightPrompt.user(ctx: context))
            guard let text = response.text, !text.isEmpty else {
                throw WeeklyInsightError.emptyResponse
            }
            guard let ai = Self.decode(text) else {
                throw WeeklyInsightError.malformedResponse
            }
            return ai
        }
    }

    /// Tolerant decode: strips markdown fences and extracts the first JSON object.
    static func decode(_ raw: String) -> WeeklyInsightAI? {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            text = text.replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            text = String(text[start...end])
        }
        guard let data = text.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(WeeklyInsightAI.self, from: data)
    }
}

enum WeeklyInsightError: Error {
    case emptyResponse
    case malformedResponse
}
