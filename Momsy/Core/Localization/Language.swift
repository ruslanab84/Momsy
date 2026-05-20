import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"
    case german  = "de"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .german:  return "Deutsch"
        }
    }

    var isRTL: Bool { false }
}
