import SwiftUI
import Combine

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published private(set) var current: Language

    private init() {
        let stored = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        current = Language(rawValue: stored) ?? .english
    }

    func set(_ lang: Language) {
        current = lang
        UserDefaults.standard.set(lang.rawValue, forKey: "appLanguage")
    }

    var strings: L10n { L10n(current) }
    var lang: String { current.rawValue }
}
