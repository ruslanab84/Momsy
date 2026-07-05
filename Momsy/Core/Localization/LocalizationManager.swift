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

    private init() {
        let stored = UserDefaults.standard.string(forKey: Defaults.appLanguageKey)
            ?? UserDefaults(suiteName: Defaults.appGroupSuiteName)?.string(forKey: Defaults.appLanguageKey)
            ?? Language.english.rawValue
        current = Language(rawValue: stored) ?? .english
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
