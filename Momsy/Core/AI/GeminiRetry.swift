import Foundation
import FirebaseAI
import os

/// Shared retry/backoff for Firebase AI Logic (Gemini) calls.
/// Retries transient failures up to 3 times,
/// exponential backoff, retry only on transient (429/500/503/network) errors.
enum GeminiRetry {

    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "GeminiRetry")

    static func run<T>(
        maxAttempts: Int = 3,
        label: String = "Gemini",
        _ operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        for attempt in 0..<maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                logError(error, attempt: attempt + 1, label: label)
                if !isRetriable(error) || attempt == maxAttempts - 1 { break }
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * (1 << attempt)))
            }
        }
        throw lastError ?? GeminiRetryError.unknown
    }

    static func isRetriable(_ error: Error) -> Bool {
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

    private static func logError(_ error: Error, attempt: Int, label: String) {
        if let genError = error as? GenerateContentError,
           case .internalError(let underlying) = genError {
            let ns = underlying as NSError
            log.error("[\(label, privacy: .public)] attempt \(attempt, privacy: .public) internalError — domain: \(ns.domain, privacy: .public), code: \(ns.code, privacy: .public), desc: \(ns.localizedDescription, privacy: .private)")
        } else {
            log.error("[\(label, privacy: .public)] attempt \(attempt, privacy: .public) failed: \(error.localizedDescription, privacy: .private)")
        }
    }
}

enum GeminiRetryError: Error {
    case unknown
}
