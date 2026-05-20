import Foundation

struct L10n {
    private let lang: Language

    init(_ lang: Language) { self.lang = lang }

    private func s(_ en: String, _ ru: String, _ de: String) -> String {
        switch lang {
        case .english: return en
        case .russian: return ru
        case .german:  return de
        }
    }

    // MARK: — General
    var done: String        { s("Done",         "Готово",       "Fertig") }
    var cancel: String      { s("Cancel",        "Отмена",       "Abbrechen") }
    var edit: String        { s("Edit",          "Правка",       "Bearbeiten") }
    var save: String        { s("Save",          "Сохранить",    "Speichern") }
    var today: String       { s("Today",         "Сегодня",      "Heute") }
    var yesterday: String   { s("Yesterday",     "Вчера",        "Gestern") }
    var now: String         { s("Now",           "Сейчас",       "Jetzt") }
    var active: String      { s("ACTIVE",        "ИДЁТ",         "AKTIV") }
    var paused: String      { s("PAUSED",        "ПАУЗА",        "PAUSE") }
    var add: String         { s("Add",           "Добавить",     "Hinzufügen") }
    var close: String       { s("Close",         "Закрыть",      "Schließen") }
    var confirm: String     { s("Confirm",       "Подтвердить",  "Bestätigen") }
    var note: String        { s("NOTE",          "ЗАМЕТКА",      "NOTIZ") }
    var history: String     { s("History",       "История",      "Verlauf") }

    // MARK: — Time units
    var unitDay: String     { s("d",    "дн",   "T") }
    var unitMonth: String   { s("mo",   "мес",  "M") }
    var unitYear: String    { s("yr",   "лет",  "J") }
    var unitHour: String    { s("h",    "ч",    "h") }
    var unitMin: String     { s("min",  "мин",  "min") }
    var unitSec: String     { s("sec",  "сек",  "s") }
    var unitKg: String      { s("kg",   "кг",   "kg") }
    var unitCm: String      { s("cm",   "см",   "cm") }

    // MARK: — Tabs / Sections
    var tabHome: String     { s("Home",     "Главная",   "Startseite") }
    var tabSleep: String    { s("Sleep",    "Сон",       "Schlaf") }
    var tabFeeding: String  { s("Feeding",  "Кормление", "Füttern") }
    var tabSounds: String   { s("Sounds",   "Звуки",     "Töne") }
    var tabDiary: String    { s("Diary",    "Дневник",   "Tagebuch") }
    var tabLeaps: String    { s("Leaps",    "Скачки",    "Schübe") }
    var tabReport: String   { s("Report",   "Отчёт",     "Bericht") }
    var tabTracking: String { s("Tracking", "Показатели","Messung") }
    var tabSharing: String  { s("Family",   "Семья",     "Familie") }

    // MARK: — Today / Home
    var goodMorning: String  { s("Good morning", "Доброе утро",  "Guten Morgen") }
    var goodAfternoon: String{ s("Good afternoon","Добрый день", "Guten Tag") }
    var goodEvening: String  { s("Good evening", "Добрый вечер", "Guten Abend") }
    var baby: String         { s("Baby",         "Малыш",        "Baby") }
    var logEntry: String     { s("Log",          "Журнал",       "Tagebuch") }
    var quickLog: String     { s("Quick Log",    "Быстрый лог",  "Schnellnotiz") }
    var feeding: String      { s("Feeding",      "Кормление",    "Fütterung") }
    var sleep: String        { s("Sleep",        "Сон",          "Schlaf") }
    var diaper: String       { s("Diaper",       "Подгузник",    "Windel") }
    var diapers: String      { s("Diapers",      "Подгузники",   "Windeln") }
    var diary: String        { s("Diary",        "Дневник",      "Tagebuch") }
    var symptom: String      { s("Symptom",      "Симптом",      "Symptom") }
    var mood: String         { s("Mood",         "Настроение",   "Stimmung") }

    // MARK: — Feeding
    var feedingLeft: String   { s("Left",   "Левая",   "Links") }
    var feedingRight: String  { s("Right",  "Правая",  "Rechts") }
    var feedingBottle: String { s("Bottle", "Бутылка", "Flasche") }
    var typicalDuration: String { s("of ≈ 18 min typical", "из ≈ 18 мин обычно", "von ≈ 18 min üblich") }
    var pause: String         { s("‖ Pause",     "‖ Пауза",      "‖ Pause") }
    var resume: String        { s("▶ Resume",    "▶ Продолжить", "▶ Fortsetzen") }
    var stopDone: String      { s("■ Done",      "■ Закончить",  "■ Fertig") }
    var feedings: String      { s("feedings",    "кормлений",    "Mahlzeiten") }
    var tapTagMood: String    { s("tap a tag to add a mood note", "нажмите тег для записи настроения", "Tag antippen für Stimmungsnotiz") }
    var moodCalm: String      { s("😊 calm",        "😊 спокоен",    "😊 ruhig") }
    var moodAsleep: String    { s("😴 fell asleep",  "😴 уснул",      "😴 eingeschlafen") }
    var moodSpitUp: String    { s("🤢 spit up",      "🤢 срыгнул",    "🤢 gespuckt") }
    var customTag: String     { s("+ custom",       "+ свой",        "+ eigenes") }
    var cancelTag: String     { s("✕ cancel",       "✕ отмена",      "✕ abbrechen") }
    var customMoodPlaceholder: String { s("e.g. cried a bit, then calmed", "напр. немного поплакал, успокоился", "z.B. kurz geweint, dann ruhig") }
    var feedingsToday: String { s("feedings today", "кормлений сегодня", "Mahlzeiten heute") }

    // MARK: — Sleep
    var sleepStart: String  { s("Start sleep",   "Начать сон",   "Schlaf starten") }
    var sleepStop: String   { s("Wake up",        "Проснулся",    "Aufwachen") }
    var sleepDuration: String { s("Duration",     "Длительность", "Dauer") }
    var asleep: String      { s("Asleep",         "Спит",         "Schläft") }
    var awake: String       { s("Awake",          "Проснулся",    "Wach") }

    // MARK: — Diaper
    var diaperWet: String   { s("Wet",    "Мокрый",  "Nass") }
    var diaperDirty: String { s("Dirty",  "Грязный", "Schmutzig") }
    var diaperChange: String{ s("Change", "Смена",   "Wechsel") }
    var diaperCount: String { s("changes today", "смен сегодня", "Wechsel heute") }

    // MARK: — Diary
    var addNote: String     { s("Add note",      "Добавить заметку", "Notiz hinzufügen") }
    var addPhoto: String    { s("Add photo",     "Добавить фото",    "Foto hinzufügen") }
    var milestone: String   { s("Milestone",     "Веха",             "Meilenstein") }
    var milestones: String  { s("Milestones",    "Вехи",             "Meilensteine") }

    // MARK: — Leaps
    var leaps: String           { s("Leaps",             "Скачки развития",  "Entwicklungsschübe") }
    var leapWeeks: String       { s("weeks",             "недель",           "Wochen") }
    var leapCompleted: String   { s("Completed",         "Завершён",         "Abgeschlossen") }
    var leapInProgress: String  { s("In progress",       "В процессе",       "Im Gange") }
    var leapUpcoming: String    { s("Upcoming",          "Предстоит",        "Bevorstehend") }
    var markDone: String        { s("Mark complete",     "Отметить",         "Abschließen") }

    // MARK: — Tracking
    var weight: String          { s("Weight",        "Вес",           "Gewicht") }
    var height: String          { s("Height",        "Рост",          "Größe") }
    var headCircumference: String { s("Head circ.",  "Окруж. головы", "Kopfumfang") }
    var temperature: String     { s("Temperature",   "Температура",   "Temperatur") }
    var doctorVisit: String     { s("Doctor visit",  "Приём врача",   "Arztbesuch") }
    var addMeasurement: String  { s("Add measurement", "Добавить измерение", "Messung hinzufügen") }
    var logTemp: String         { s("Log temperature", "Записать температуру", "Temperatur erfassen") }
    var percentile: String      { s("Percentile",    "Перцентиль",    "Perzentile") }
    var normal: String          { s("Normal",        "Норма",         "Normal") }
    var elevated: String        { s("Elevated",      "Повышена",      "Erhöht") }
    var high: String            { s("High",          "Высокая",       "Hoch") }

    // MARK: — Sounds / Lullaby
    var sounds: String          { s("Sounds",        "Звуки",         "Klänge") }
    var lullaby: String         { s("Lullaby",       "Колыбельная",   "Schlaflied") }
    var nowPlaying: String      { s("NOW PLAYING",   "ИГРАЕТ",        "SPIELT") }
    var tapToPlay: String       { s("Tap to play",   "Нажмите чтобы играть", "Zum Abspielen tippen") }

    // MARK: — Family / Sharing
    var family: String          { s("Family",        "Семья",         "Familie") }
    var invite: String          { s("Invite",        "Пригласить",    "Einladen") }
    var inviteSent: String      { s("Invite sent",   "Приглашение отправлено", "Einladung gesendet") }
    var role: String            { s("Role",          "Роль",          "Rolle") }
    var roleMom: String         { s("Mom",           "Мама",          "Mama") }
    var roleDad: String         { s("Dad",           "Папа",          "Papa") }
    var roleGrandma: String     { s("Grandma",       "Бабушка",       "Oma") }
    var roleGrandpa: String     { s("Grandpa",       "Дедушка",       "Opa") }
    var roleNanny: String       { s("Nanny",         "Няня",          "Nanny") }

    // MARK: — Report
    var report: String          { s("Report",        "Отчёт",         "Bericht") }
    var weekly: String          { s("Weekly",        "Недельный",     "Wöchentlich") }
    var daily: String           { s("Daily",         "Дневной",       "Täglich") }
    var exportPDF: String       { s("Export PDF",    "Экспорт PDF",   "PDF exportieren") }
    var shareReport: String     { s("Share",         "Поделиться",    "Teilen") }

    // MARK: — Settings
    var settings: String        { s("Settings",      "Настройки",     "Einstellungen") }
    var language: String        { s("Language",      "Язык",          "Sprache") }
    var theme: String           { s("Theme",         "Тема",          "Design") }
    var themeSystem: String     { s("System",        "Системная",     "System") }
    var themeLight: String      { s("Light",         "Светлая",       "Hell") }
    var themeDark: String       { s("Dark",          "Тёмная",        "Dunkel") }
    var notifications: String   { s("Notifications", "Уведомления",   "Benachrichtigungen") }
    var babyProfile: String     { s("Baby profile",  "Профиль малыша","Baby-Profil") }
    var subscription: String    { s("Subscription",  "Подписка",      "Abonnement") }
    var privacyPolicy: String   { s("Privacy Policy","Политика конфид.", "Datenschutz") }
    var termsOfUse: String      { s("Terms of Use",  "Условия использования", "Nutzungsbedingungen") }

    // MARK: — Onboarding
    var onboardingWelcome: String { s("Welcome to Momsy", "Добро пожаловать в Momsy", "Willkommen bei Momsy") }
    var onboardingSubtitle: String { s("Your smart baby tracker", "Умный трекер малыша", "Dein smarter Baby-Tracker") }
    var babyName: String        { s("Baby's name",   "Имя малыша",    "Name des Babys") }
    var birthDate: String       { s("Birth date",    "Дата рождения", "Geburtsdatum") }
    var getStarted: String      { s("Get started",   "Начать",        "Loslegen") }
    var continueLabel: String   { s("Continue",      "Продолжить",    "Weiter") }
    var skip: String            { s("Skip",          "Пропустить",    "Überspringen") }

    // MARK: — Symptoms
    var symptoms: String        { s("Symptoms",      "Симптомы",      "Symptome") }
    var addSymptom: String      { s("Add symptom",   "Добавить симптом", "Symptom hinzufügen") }
    var fever: String           { s("Fever",         "Температура",   "Fieber") }
    var cough: String           { s("Cough",         "Кашель",        "Husten") }
    var runnyNose: String       { s("Runny nose",    "Насморк",       "Schnupfen") }
    var rash: String            { s("Rash",          "Сыпь",          "Ausschlag") }
    var teething: String        { s("Teething",      "Зубы",          "Zahnen") }
}
