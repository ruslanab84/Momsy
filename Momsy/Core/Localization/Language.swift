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

    var flag: String {
        switch self {
        case .english:    return "🇬🇧"
        case .russian:    return "🇷🇺"
        case .german:     return "🇩🇪"
        case .spanish:    return "🇪🇸"
        case .french:     return "🇫🇷"
        case .portuguese: return "🇵🇹"
        case .chinese:    return "🇨🇳"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .english:    return "en_US"
        case .russian:    return "ru_RU"
        case .german:     return "de_DE"
        case .spanish:    return "es_ES"
        case .french:     return "fr_FR"
        case .portuguese: return "pt_PT"
        case .chinese:    return "zh_CN"
        }
    }

    static func from(_ code: String) -> Language {
        Language(rawValue: code) ?? .english
    }

    /// Resolves a BCP-47 identifier (`pt-BR`, `zh-Hans-CN`, `de_DE`) onto a
    /// supported language, or `nil` when the app does not ship that language.
    static func matching(_ identifier: String) -> Language? {
        let normalized = identifier.replacingOccurrences(of: "_", with: "-")
        let firstSubtag = normalized.split(separator: "-").first.map { String($0) } ?? normalized
        let code = Locale(identifier: normalized).language.languageCode?.identifier ?? firstSubtag
        return Language(rawValue: code.lowercased())
    }

    /// The language iOS resolved this bundle to for the current launch.
    ///
    /// `Momsy/Info.plist` declares every supported language in
    /// `CFBundleLocalizations`, so `preferredLocalizations` reflects the per-app
    /// language chosen in Settings ▸ Momsy ▸ Language, falling back to the
    /// device's preferred language order. Seeding the in-app language from it
    /// keeps our own UI in the same language as the sheets iOS draws for us
    /// (Sign in with Apple, permission alerts, StoreKit purchase confirmation).
    static var systemPreferred: Language {
        for identifier in Bundle.main.preferredLocalizations + Locale.preferredLanguages {
            if let match = matching(identifier) { return match }
        }
        return .english
    }

    static func localeIdentifier(for code: String) -> String {
        from(code).localeIdentifier
    }

    var isRTL: Bool { false }
}
