import Foundation
import FirebaseAI

final class GeminiDailyTipService: DailyTipService {

    private let modelName = "gemini-2.5-flash-lite"
    private let maxOutputTokens = 150

    func fetch(context: DailyContext) async throws -> String {
        var lastError: Error?

        for attempt in 0..<3 {
            do {
                let config = GenerationConfig(maxOutputTokens: maxOutputTokens)
                let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
                    modelName: modelName,
                    generationConfig: config,
                    systemInstruction: ModelContent(role: "system", parts: DailyTipPrompt.system(for: context.language))
                )
                let response = try await model.generateContent(DailyTipPrompt.user(ctx: context))
                guard let text = response.text, !text.isEmpty else {
                    throw DailyTipError.emptyResponse
                }
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                lastError = error
                Self.logError(error, attempt: attempt + 1)
                if !isRetriable(error) || attempt == 2 { break }
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * (1 << attempt)))
            }
        }
        throw lastError ?? DailyTipError.unknown
    }

    private func isRetriable(_ error: Error) -> Bool {
        if let genError = error as? GenerateContentError,
           case .internalError(let underlying) = genError {
            let httpCode = (underlying as NSError).code
            return httpCode == 500 || httpCode == 503 || httpCode == 0
        }
        if let urlError = error as? URLError {
            return [.timedOut, .networkConnectionLost, .cannotConnectToHost,
                    .cannotFindHost, .notConnectedToInternet].contains(urlError.code)
        }
        let desc = error.localizedDescription.lowercased()
        return desc.contains("503") || desc.contains("429") || desc.contains("unavailable")
            || desc.contains("timeout") || desc.contains("try again")
    }
}

enum DailyTipError: Error {
    case emptyResponse
    case unknown
}

private extension GeminiDailyTipService {
    static func logError(_ error: Error, attempt: Int) {
        if let genError = error as? GenerateContentError,
           case .internalError(let underlying) = genError {
            let ns = underlying as NSError
            print("[GeminiDailyTipService] attempt \(attempt) internalError — domain: \(ns.domain), code: \(ns.code), desc: \(ns.localizedDescription)")
        } else {
            print("[GeminiDailyTipService] attempt \(attempt) failed: \(error)")
        }
    }
}
