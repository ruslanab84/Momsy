import Foundation

enum Language: String, CaseIterable, Identifiable, Codable {
    case english    = "en"
    case russian    = "ru"
    case german     = "de"
    case spanish    = "es"
    case french     = "fr"
    case portuguese = "pt"
    case chinese    = "zh"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:    return "English"
        case .russian:    return "Русский"
        case .german:     return "Deutsch"
        case .spanish:    return "Español"
        case .french:     return "Français"
        case .portuguese: return "Português"
        case .chinese:    return "中文"
        }
    }

    var isRTL: Bool { false }
}
