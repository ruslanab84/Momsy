import Foundation

/// Minimal, self-contained localization for the Watch UI (RU / EN / DE), keyed off
/// the device language. Kept independent of the iOS `LocalizationManager` so the
/// watch target stays lightweight.
enum WatchStrings {
    private static var lang: String {
        let code = Locale.preferredLanguages.first ?? "en"
        if code.hasPrefix("ru") { return "ru" }
        if code.hasPrefix("de") { return "de" }
        return "en"
    }

    private static func t(_ ru: String, _ en: String, _ de: String) -> String {
        switch lang {
        case "ru": return ru
        case "de": return de
        default:   return en
        }
    }

    static var feeding: String   { t("Кормление", "Feeding", "Füttern") }
    static var sleep: String     { t("Сон", "Sleep", "Schlaf") }
    static var diaper: String    { t("Подгузник", "Diaper", "Windel") }

    static var left: String      { t("Левая", "Left", "Links") }
    static var right: String     { t("Правая", "Right", "Rechts") }
    static var bottle: String    { t("Бутылка", "Bottle", "Flasche") }

    static var start: String     { t("Старт", "Start", "Start") }
    static var stop: String      { t("Стоп", "Stop", "Stopp") }
    static var pause: String     { t("Пауза", "Pause", "Pause") }
    static var resume: String    { t("Продолжить", "Resume", "Fortsetzen") }
    static var add: String       { t("Добавить", "Add", "Hinzufügen") }

    static var quality: String   { t("Качество", "Quality", "Qualität") }
    static var qualityGood: String     { t("Хорошо", "Good", "Gut") }
    static var qualityNormal: String   { t("Норма", "Normal", "Normal") }
    static var qualityRestless: String { t("Беспокойно", "Restless", "Unruhig") }

    static var tapToStart: String     { t("Нажмите, чтобы начать", "Tap to start", "Zum Starten tippen") }
    static var diapersToday: String   { t("Подгузников сегодня", "Diapers today", "Windeln heute") }
    static var lastFeeding: String    { t("Посл. кормление", "Last feeding", "Letzte Fütterung") }
    static var noData: String         { t("—", "—", "—") }

    static func sideLabel(token: String) -> String {
        switch token {
        case "right":  return right
        case "bottle": return bottle
        default:       return left
        }
    }

    static func quality(for raw: String) -> String {
        switch raw {
        case "good":     return qualityGood
        case "restless": return qualityRestless
        default:         return qualityNormal
        }
    }
}
