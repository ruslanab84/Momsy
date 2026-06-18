import Foundation
import FirebaseAI
import os

final class GeminiDailyTipService: DailyTipService {

    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "GeminiDailyTip")

    private let modelName = "gemini-3.1-flash-lite"
    private let maxOutputTokens = 150

    func fetch(context: DailyContext) async throws -> String {
        var lastError: Error?

        for attempt in 0..<3 {
            do {
                let config = GenerationConfig(maxOutputTokens: maxOutputTokens)
                let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
                    modelName: modelName,
                    generationConfig: config,
                    safetySettings: GeminiSafety.settings,
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
            log.error("attempt \(attempt, privacy: .public) internalError — domain: \(ns.domain, privacy: .public), code: \(ns.code, privacy: .public), desc: \(ns.localizedDescription, privacy: .private)")
        } else {
            log.error("attempt \(attempt, privacy: .public) failed: \(error.localizedDescription, privacy: .private)")
        }
    }
}
