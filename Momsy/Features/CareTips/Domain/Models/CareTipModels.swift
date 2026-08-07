import Foundation

enum CareTipCategory: String, CaseIterable, Identifiable, Sendable {
    case feeding
    case sleep
    case hygiene
    case comfort
    case development
    case safety
    case parent

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .feeding:     return "fork.knife"
        case .sleep:       return "moon.zzz.fill"
        case .hygiene:     return "drop.fill"
        case .comfort:     return "heart.fill"
        case .development: return "figure.child"
        case .safety:      return "shield.lefthalf.filled"
        case .parent:      return "person.2.fill"
        }
    }

    var semanticColor: SemanticColor {
        switch self {
        case .feeding:     return .coral
        case .sleep:       return .lilac
        case .hygiene:     return .sky
        case .comfort:     return .butter
        case .development: return .mint
        case .safety:      return .rose
        case .parent:      return .lilac
        }
    }

    func title(_ lang: Language) -> String {
        L10n(lang).careTipsCategoryTitle(self)
    }
}

struct CareTip: Identifiable, Sendable {
    let id: Int
    let category: CareTipCategory
    let icon: String
    /// Inclusive age window in months. `0...24` means "the whole first two years".
    let ageFromMonths: Int
    let ageToMonths: Int

    let title: LocalizedText
    let summary: LocalizedText
    let whatToDo: LocalizedList
    let whyItMatters: LocalizedText
    let commonMistakes: LocalizedList
    let whenToCallDoctor: LocalizedList

    init(
        id: Int,
        category: CareTipCategory,
        icon: String,
        ageFrom: Int,
        ageTo: Int,
        title: LocalizedText,
        summary: LocalizedText,
        whatToDo: LocalizedList,
        whyItMatters: LocalizedText,
        commonMistakes: LocalizedList,
        whenToCallDoctor: LocalizedList
    ) {
        self.id = id
        self.category = category
        self.icon = icon
        self.ageFromMonths = ageFrom
        self.ageToMonths = ageTo
        self.title = title
        self.summary = summary
        self.whatToDo = whatToDo
        self.whyItMatters = whyItMatters
        self.commonMistakes = commonMistakes
        self.whenToCallDoctor = whenToCallDoctor
    }

    func matches(ageMonths: Int) -> Bool {
        ageMonths >= ageFromMonths && ageMonths <= ageToMonths
    }

    func ageLabel(_ lang: Language) -> String {
        L10n(lang).careTipAgeRange(from: ageFromMonths, to: ageToMonths)
    }

    func matches(query: String, lang: Language) -> Bool {
        guard !query.isEmpty else { return true }
        let haystack = [title(lang), summary(lang)].joined(separator: " ")
        return haystack.range(
            of: query,
            options: [.caseInsensitive, .diacriticInsensitive]
        ) != nil
    }
}
