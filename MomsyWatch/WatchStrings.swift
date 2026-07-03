import Foundation

/// Minimal, self-contained localization for the Watch UI, keyed off
/// the device language. Kept independent of the iOS `LocalizationManager` so the
/// watch target stays lightweight.
enum WatchStrings {
    private static var lang: String {
        let code = Locale.preferredLanguages.first ?? "en"
        if code.hasPrefix("ru") { return "ru" }
        if code.hasPrefix("de") { return "de" }
        if code.hasPrefix("es") { return "es" }
        if code.hasPrefix("fr") { return "fr" }
        if code.hasPrefix("pt") { return "pt" }
        if code.hasPrefix("zh") { return "zh" }
        return "en"
    }

    private static func t(_ en: String, _ ru: String, _ de: String, _ es: String, _ fr: String, _ pt: String, _ zh: String) -> String {
        switch lang {
        case "ru": return ru
        case "de": return de
        case "es": return es
        case "fr": return fr
        case "pt": return pt
        case "zh": return zh
        default:   return en
        }
    }

    static var feeding: String   { t("Feeding", "Кормление", "Füttern", "Toma", "Tétée", "Mamada", "喂养") }
    static var sleep: String     { t("Sleep", "Сон", "Schlaf", "Sueño", "Sommeil", "Sono", "睡眠") }
    static var diaper: String    { t("Diaper", "Подгузник", "Windel", "Pañal", "Couche", "Fralda", "尿布") }

    static var left: String      { t("Left", "Левая", "Links", "Izquierdo", "Gauche", "Esquerdo", "左侧") }
    static var right: String     { t("Right", "Правая", "Rechts", "Derecho", "Droite", "Direito", "右侧") }
    static var bottle: String    { t("Bottle", "Бутылка", "Flasche", "Biberón", "Biberon", "Biberão", "奶瓶") }

    static var start: String     { t("Start", "Старт", "Start", "Empezar", "Démarrer", "Iniciar", "开始") }
    static var stop: String      { t("Stop", "Стоп", "Stopp", "Parar", "Arrêter", "Parar", "停止") }
    static var pause: String     { t("Pause", "Пауза", "Pause", "Pausa", "Pause", "Pausa", "暂停") }
    static var resume: String    { t("Resume", "Продолжить", "Fortsetzen", "Reanudar", "Reprendre", "Retomar", "继续") }
    static var add: String       { t("Add", "Добавить", "Hinzufügen", "Añadir", "Ajouter", "Adicionar", "添加") }

    static var quality: String   { t("Quality", "Качество", "Qualität", "Calidad", "Qualité", "Qualidade", "质量") }
    static var qualityGood: String     { t("Good", "Хорошо", "Gut", "Bueno", "Bon", "Bom", "好") }
    static var qualityNormal: String   { t("Normal", "Норма", "Normal", "Normal", "Normal", "Normal", "一般") }
    static var qualityRestless: String { t("Restless", "Беспокойно", "Unruhig", "Inquieto", "Agité", "Agitado", "不安稳") }

    static var tapToStart: String     { t("Tap to start", "Нажмите, чтобы начать", "Zum Starten tippen", "Toca para empezar", "Touchez pour démarrer", "Toque para iniciar", "点按开始") }
    static var diapersToday: String   { t("Diapers today", "Подгузников сегодня", "Windeln heute", "Pañales hoy", "Couches aujourd’hui", "Fraldas hoje", "今日尿布") }
    static var lastFeeding: String    { t("Last feeding", "Посл. кормление", "Letzte Fütterung", "Última toma", "Dernière tétée", "Última mamada", "上次喂养") }
    static var noData: String         { t("—", "—", "—", "—", "—", "—", "—") }

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
