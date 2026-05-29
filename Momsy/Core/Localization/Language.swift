import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english    = "en"
    case russian    = "ru"
    case german     = "de"
    case spanish    = "es"
    case portuguese = "pt"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:    return "English"
        case .russian:    return "Русский"
        case .german:     return "Deutsch"
        case .spanish:    return "Español"
        case .portuguese: return "Português"
        }
    }

    var isRTL: Bool { false }
}
