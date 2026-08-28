import SwiftUI
import Combine
import WidgetKit

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    private enum Defaults {
        static let appLanguageKey = "appLanguage"
        static let appGroupSuiteName = "group.RuslanAbd.Momsy"
        /// Read by iOS (not by us) to pick which bundle localization the app
        /// runs in. Writing it is what makes the sheets iOS draws for us —
        /// Sign in with Apple, permission alerts, the StoreKit purchase
        /// confirmation — follow the in-app language picker instead of the
        /// device language. It takes effect on the next launch.
        static let appleLanguagesKey = "AppleLanguages"
    }

    @Published private(set) var current: Language

    private init() {
        let stored = UserDefaults.standard.string(forKey: Defaults.appLanguageKey)
            ?? UserDefaults(suiteName: Defaults.appGroupSuiteName)?.string(forKey: Defaults.appLanguageKey)
        // No stored choice yet (first launch, or a fresh install): follow the
        // language iOS resolved the bundle to rather than forcing English.
        current = stored.flatMap { Language(rawValue: $0) } ?? .systemPreferred
        persist(current, reloadWidgets: false, syncSystemLanguage: false)
    }

    func set(_ lang: Language) {
        current = lang
        persist(lang, reloadWidgets: true, syncSystemLanguage: true)
    }

    var strings: L10n { L10n(current) }
    var lang: String { current.rawValue }

    /// - Parameter syncSystemLanguage: only `true` for an explicit user choice.
    ///   Pinning `AppleLanguages` on every launch would freeze the app to
    ///   whatever language it happened to start in, so the automatic
    ///   device-driven resolution is left alone until the user picks one.
    private func persist(_ lang: Language, reloadWidgets: Bool, syncSystemLanguage: Bool) {
        UserDefaults.standard.set(lang.rawValue, forKey: Defaults.appLanguageKey)
        UserDefaults(suiteName: Defaults.appGroupSuiteName)?.set(lang.rawValue, forKey: Defaults.appLanguageKey)
        if syncSystemLanguage {
            UserDefaults.standard.set([lang.rawValue], forKey: Defaults.appleLanguagesKey)
        }
        if reloadWidgets {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
