import Foundation

/// A single string that may exist in several languages.
/// Any language that is not authored yet falls back to English.
struct LocalizedText: Sendable, ExpressibleByStringLiteral {
    private let values: [Language: String]

    init(
        en: String,
        ru: String? = nil,
        de: String? = nil,
        es: String? = nil,
        fr: String? = nil,
        pt: String? = nil,
        zh: String? = nil
    ) {
        var map: [Language: String] = [.english: en]
        if let ru { map[.russian] = ru }
        if let de { map[.german] = de }
        if let es { map[.spanish] = es }
        if let fr { map[.french] = fr }
        if let pt { map[.portuguese] = pt }
        if let zh { map[.chinese] = zh }
        values = map
    }

    init(stringLiteral value: String) {
        self.init(en: value)
    }

    func callAsFunction(_ lang: Language) -> String {
        values[lang] ?? values[.english] ?? ""
    }

    func isTranslated(into lang: Language) -> Bool {
        values[lang] != nil
    }
}

/// A bullet list that may exist in several languages.
struct LocalizedList: Sendable, ExpressibleByArrayLiteral {
    private let values: [Language: [String]]

    init(
        en: [String],
        ru: [String]? = nil,
        de: [String]? = nil,
        es: [String]? = nil,
        fr: [String]? = nil,
        pt: [String]? = nil,
        zh: [String]? = nil
    ) {
        var map: [Language: [String]] = [.english: en]
        if let ru { map[.russian] = ru }
        if let de { map[.german] = de }
        if let es { map[.spanish] = es }
        if let fr { map[.french] = fr }
        if let pt { map[.portuguese] = pt }
        if let zh { map[.chinese] = zh }
        values = map
    }

    init(arrayLiteral elements: String...) {
        self.init(en: elements)
    }

    func callAsFunction(_ lang: Language) -> [String] {
        values[lang] ?? values[.english] ?? []
    }

    func isTranslated(into lang: Language) -> Bool {
        values[lang] != nil
    }
}
