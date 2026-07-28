import Foundation
import FirebaseAI

final class GeminiWeeklyInsightService: WeeklyInsightService {

    private let modelName = "gemini-3.1-flash-lite"
    private let maxOutputTokens = 2_600

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        try await GeminiRetry.run(label: "GeminiWeeklyInsightService") {
            let config = GenerationConfig(
                temperature: 0.25,
                maxOutputTokens: maxOutputTokens,
                responseMIMEType: "application/json",
                responseSchema: Self.responseSchema(for: context.language)
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
    }

    /// Schema-enforced sentence arrays prevent the model from collapsing a section into
    /// one short sentence while keeping the persisted/UI model as simple joined strings.
    private static func responseSchema(for language: Language) -> Schema {
        let languageName = responseLanguageName(for: language)
        let sentence = Schema.string(
            description: "Exactly one complete, user-friendly sentence in \(languageName). Include concrete numbers when relevant and no markdown."
        )

        return Schema.object(
            properties: [
                "sleepSummary": .array(
                    items: sentence,
                    description: "4 to 6 sentences covering logged sleep, full WHO range, exact status/difference, night/day split, naps, trend, and logging caveat.",
                    minItems: 4,
                    maxItems: 6
                ),
                "sleepRecommendation": .array(
                    items: sentence,
                    description: "3 to 5 practical, age-appropriate sleep recommendations tied to the supplied deterministic status.",
                    minItems: 3,
                    maxItems: 5
                ),
                "feedingSummary": .array(
                    items: sentence,
                    description: "4 to 6 sentences covering logged milk feeds, age-specific WHO guidance, honest data limitations, foods, reactions, and diaper context.",
                    minItems: 4,
                    maxItems: 6
                ),
                "feedingRecommendation": .array(
                    items: sentence,
                    description: "3 to 5 age-safe feeding actions. Never recommend solids under 6 months or reintroducing a flagged food.",
                    minItems: 3,
                    maxItems: 5
                ),
                "overallSummary": .array(
                    items: sentence,
                    description: "3 to 5 sentences summarizing the week, the main point to watch, developmental-leap signals when provided, and supportive next steps.",
                    minItems: 3,
                    maxItems: 5
                ),
            ],
            propertyOrdering: [
                "sleepSummary",
                "sleepRecommendation",
                "feedingSummary",
                "feedingRecommendation",
                "overallSummary",
            ],
            description: "A detailed weekly baby-tracking report. Every property is required."
        )
    }

    /// Tolerant decode: structured sentence arrays are the current format. The legacy
    /// string format remains accepted so old fixtures and cached development responses decode.
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

        if let structured = try? JSONDecoder().decode(StructuredWeeklyInsightAI.self, from: data),
           structured.hasRequiredDepth {
            return structured.joined
        }
        return try? JSONDecoder().decode(WeeklyInsightAI.self, from: data)
    }

    private static func responseLanguageName(for language: Language) -> String {
        switch language {
        case .english: return "English"
        case .russian: return "Russian"
        case .german: return "German"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese"
        }
    }
}

private struct StructuredWeeklyInsightAI: Decodable {
    let sleepSummary: [String]
    let sleepRecommendation: [String]
    let feedingSummary: [String]
    let feedingRecommendation: [String]
    let overallSummary: [String]

    var hasRequiredDepth: Bool {
        (4...6).contains(sleepSummary.count)
            && (3...5).contains(sleepRecommendation.count)
            && (4...6).contains(feedingSummary.count)
            && (3...5).contains(feedingRecommendation.count)
            && (3...5).contains(overallSummary.count)
            && allSentences.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var joined: WeeklyInsightAI {
        WeeklyInsightAI(
            sleepSummary: join(sleepSummary),
            sleepRecommendation: join(sleepRecommendation),
            feedingSummary: join(feedingSummary),
            feedingRecommendation: join(feedingRecommendation),
            overallSummary: join(overallSummary)
        )
    }

    private var allSentences: [String] {
        sleepSummary + sleepRecommendation + feedingSummary + feedingRecommendation + overallSummary
    }

    private func join(_ sentences: [String]) -> String {
        sentences
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

enum WeeklyInsightError: Error {
    case emptyResponse
    case malformedResponse
}
