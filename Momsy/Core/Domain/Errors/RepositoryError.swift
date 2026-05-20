import Foundation

enum RepositoryError: LocalizedError {
    case notFound
    case saveFailed(Error)
    case notImplemented
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .notFound:           return "Record not found"
        case .saveFailed(let e):  return "Save failed: \(e.localizedDescription)"
        case .notImplemented:     return "Not yet implemented (Firebase SDK required)"
        case .networkUnavailable: return "Network unavailable"
        }
    }
}
