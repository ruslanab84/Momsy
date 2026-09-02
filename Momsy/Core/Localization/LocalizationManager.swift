import SwiftUI
import Combine
import WidgetKit

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    private enum Defaults {
        static let appLanguageKey = "appLanguage"
        static let appGroupSuiteName = "group.RuslanAbd.Momsy"
    }

    @Published private(set) var current: Language

    /// Device language narrowed to a supported `Language`. Region and script
    /// subtags are dropped: `de-AT` → `de`, `zh-Hans-CN` → `zh`, `pt-BR` → `pt`.
    nonisolated static var systemLanguage: Language {
        for identifier in Locale.preferredLanguages {
            let code = identifier.split(separator: "-").first.map(String.init) ?? identifier
            if let language = Language(rawValue: code) { return language }
        }
        return .english
    }

    /// The user's explicit choice, or the device language on first launch.
    /// `nonisolated` so that non-isolated call sites — `LocalizedError`
    /// conformances in particular — can read it without hopping to the main actor.
    nonisolated static var currentLanguage: Language {
        let stored = UserDefaults.standard.string(forKey: Defaults.appLanguageKey)
            ?? UserDefaults(suiteName: Defaults.appGroupSuiteName)?.string(forKey: Defaults.appLanguageKey)
        return stored.flatMap(Language.init(rawValue:)) ?? systemLanguage
    }

    nonisolated static var strings: L10n { L10n(currentLanguage) }

    private init() {
        current = Self.currentLanguage
        persist(current, reloadWidgets: false)
    }

    func set(_ lang: Language) {
        current = lang
        persist(lang, reloadWidgets: true)
    }

    var strings: L10n { L10n(current) }
    var lang: String { current.rawValue }

    private func persist(_ lang: Language, reloadWidgets: Bool) {
        UserDefaults.standard.set(lang.rawValue, forKey: Defaults.appLanguageKey)
        UserDefaults(suiteName: Defaults.appGroupSuiteName)?.set(lang.rawValue, forKey: Defaults.appLanguageKey)
        if reloadWidgets {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
