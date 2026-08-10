import Foundation
import FirebaseAI

final class GeminiWeeklyInsightService: WeeklyInsightService {

    private let modelName = "gemini-3.1-flash-lite"
    /// Gemini 3.x always uses dynamic thinking and counts thinking tokens against
    /// `maxOutputTokens`. The budget must cover thinking *and* the five narrative
    /// fields, otherwise the response comes back with `finishReason == .maxTokens`
    /// and the SDK throws before any text is produced.
    private let maxOutputTokens = 4000

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        /* Gemini generation is temporarily disabled for the App Store release.
        try await GeminiRetry.run(label: "GeminiWeeklyInsightService") {
            // Prompt-enforced JSON (system prompt mandates it) + tolerant decode.
            let config = GenerationConfig(
                maxOutputTokens: maxOutputTokens,
                thinkingConfig: ThinkingConfig(thinkingLevel: .low)
            )
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
        */
        throw WeeklyInsightError.temporarilyDisabled
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
    case temporarilyDisabled
    case emptyResponse
    case malformedResponse
}
