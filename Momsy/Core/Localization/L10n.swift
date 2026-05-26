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
    var remove: String      { s("Remove",        "Удалить",      "Entfernen") }
    var clear: String       { s("Clear",         "Очистить",     "Löschen") }
    var saved: String       { s("Saved",         "Записано",     "Gespeichert") }
    var start: String       { s("Start",         "Начать",       "Starten") }
    var all: String         { s("All",           "Всё",          "Alle") }
    var you: String         { s("you",           "вы",           "du") }
    var expired: String     { s("expired",       "истёк",        "abgelaufen") }
    var copied: String      { s("Copied!",       "Скопировано!", "Kopiert!") }
    var reset: String       { s("reset",         "сбросить",     "zurücksetzen") }
    var call: String        { s("Call",          "Позвонить",    "Anrufen") }
    var days: String        { s("days",          "дней",         "Tage") }
    var editSmall: String   { s("edit",          "правка",       "bearbeiten") }
    var delete: String     { s("Delete",        "Удалить",      "Löschen") }
    var notes: String      { s("Notes",         "Заметки",      "Notizen") }
    var optional: String   { s("optional",      "необязательно","optional") }
    var photo: String      { s("Photo",         "Фото",         "Foto") }

    // MARK: — Time units
    var unitDay: String     { s("d",    "дн",   "T") }
    var unitMonth: String   { s("mo",   "мес",  "M") }
    var unitYear: String    { s("yr",   "лет",  "J") }
    var unitHour: String    { s("h",    "ч",    "h") }
    var unitMin: String     { s("min",  "мин",  "min") }
    var unitSec: String     { s("sec",  "сек",  "s") }
    var unitHr: String      { s("hr",   "ч",    "h") }
    var unitKg: String      { s("kg",   "кг",   "kg") }
    var unitCm: String      { s("cm",   "см",   "cm") }
    var justNow: String     { s("just now",    "только что",   "gerade eben") }
    var noSleepYet: String  { s("no sleep yet","не спал",      "noch nicht geschlafen") }
    var noData: String      { s("no data",     "нет данных",   "keine Daten") }
    var playingContinuously: String { s("playing continuously","играет непрерывно","spielt kontinuierlich") }
    var sleepStarted: String { s("Sleep · started", "Сон · начало", "Schlaf · begonnen") }
    var symptomRecorded: String { s("Symptom · recorded","Симптом · записан","Symptom · erfasst") }
    var belowP3: String     { s("below P3",  "ниже P3",   "unter P3") }
    var aboveP97: String    { s("above P97", "выше P97",  "über P97") }
    var headShort: String   { s("Head",      "Голова",    "Kopf") }
    var hrToStop: String    { s("hr to stop",  "ч до выкл.",  "h bis Stopp") }
    var minToStop: String   { s("min to stop", "мин до выкл.","min bis Stopp") }
    var secToStop: String   { s("sec to stop", "с до выкл.",  "s bis Stopp") }
    func minsAgo(_ n: Int) -> String { s("\(n) min ago", "\(n) мин назад", "vor \(n) Min.") }
    func hrsAgo(h: Int, m: Int) -> String { s("\(h) hr \(m) min ago", "\(h) ч \(m) мин назад", "vor \(h) h \(m) min") }
    func hrsAgoFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h ago", "\(h) ч назад", "vor \(h)h") : s("\(h)h \(m)m ago", "\(h) ч \(m) мин назад", "vor \(h)h \(m)m") }
    func hrAgo(_ h: Int) -> String { s("\(h)h ago", "\(h) ч назад", "vor \(h)h") }
    func sleepDurationFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h", "\(h) ч", "\(h)h") : s("\(h)h \(m)m", "\(h) ч \(m) м", "\(h)h \(m)m") }
    func diaperLogEntry(count: Int) -> String { s("Diaper #\(count) · wet", "Подгузник #\(count) · мокрый", "Windel #\(count) · nass") }
    func feedingLogEntry(dur: Int, side: String) -> String { s("Feeding · \(dur) min · \(side)", "Кормление · \(dur) мин · \(side)", "Fütterung · \(dur) min · \(side)") }
    func todayEntry(_ date: String) -> String { s("Today · \(date)", "Сегодня · \(date)", "Heute · \(date)") }
    func yesterdayEntry(_ date: String) -> String { s("Yesterday · \(date)", "Вчера · \(date)", "Gestern · \(date)") }

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

    // MARK: — Greetings
    var goodNight: String       { s("Good night,",     "Доброй ночи,",  "Gute Nacht,") }
    var goodMorning: String     { s("Good morning",    "Доброе утро",   "Guten Morgen") }
    var goodAfternoon: String   { s("Good afternoon",  "Добрый день",   "Guten Tag") }
    var goodEvening: String     { s("Good evening",    "Добрый вечер",  "Guten Abend") }
    var goodMorningGreeting: String   { s("Good morning,",   "Доброе утро,",   "Guten Morgen,") }
    var goodAfternoonGreeting: String { s("Good afternoon,", "Добрый день,",   "Guten Tag,") }
    var goodEveningGreeting: String   { s("Good evening,",   "Добрый вечер,",  "Guten Abend,") }

    // MARK: — Today / Home
    var baby: String         { s("Baby",         "Малыш",        "Baby") }
    var logEntry: String     { s("Log",          "Журнал",       "Tagebuch") }
    var quickLog: String     { s("Quick Log",    "Быстрый лог",  "Schnellnotiz") }
    var quickLogLabel: String{ s("Quick log",    "Быстро записать", "Schnell erfassen") }
    var feeding: String      { s("Feeding",      "Кормление",    "Fütterung") }
    var sleep: String        { s("Sleep",        "Сон",          "Schlaf") }
    var diaper: String       { s("Diaper",       "Подгузник",    "Windel") }
    var diaperQuick: String  { s("Diaper",       "Памп",         "Windel") }
    var diapers: String      { s("Diapers",      "Подгузники",   "Windeln") }
    var diary: String        { s("Diary",        "Дневник",      "Tagebuch") }
    var symptom: String      { s("Symptom",      "Симптом",      "Symptom") }
    var walk: String         { s("Walk",         "Прогулка",     "Spaziergang") }
    var bath: String         { s("Bath",         "Купание",      "Bad") }
    var vitamins: String     { s("Vitamins",     "Витамины",     "Vitamine") }
    var walkLogged: String   { s("Walk · logged",    "Прогулка · записана",   "Spaziergang · erfasst") }
    var bathLogged: String   { s("Bath · logged",    "Купание · записано",    "Bad · erfasst") }
    var vitaminsGiven: String { s("Vitamins · given","Витамины · приняты",    "Vitamine · gegeben") }
    var walkTracker: String  { s("WALK TRACKER",    "ТРЕКЕР ПРОГУЛКИ",       "GEHTRACKER") }
    var walking: String      { s("walking…",        "гуляем…",               "gehen…") }
    var startWalk: String    { s("Start Walk",      "Начать прогулку",       "Spaziergang starten") }
    var stopWalk: String     { s("Stop Walk",       "Закончить прогулку",    "Spaziergang stoppen") }
    var noWalkYet: String    { s("no walk yet",     "ещё не гуляли",         "noch nicht spaziert") }
    func walkLogEntry(dur: Int) -> String { s("Walk · \(dur) min", "Прогулка · \(dur) мин", "Spaziergang · \(dur) min") }
    var bathTracker: String  { s("BATH TRACKER",     "ТРЕКЕР КУПАНИЯ",        "BADTRACKER") }
    var bathing: String      { s("bathing…",         "купаемся…",             "Baden…") }
    var startBath: String    { s("Start Bath",       "Начать купание",        "Bad starten") }
    var stopBath: String     { s("Stop Bath",        "Закончить купание",     "Bad stoppen") }
    var noBathYet: String    { s("no bath yet",      "ещё не купались",       "noch nicht gebadet") }
    func bathLogEntry(dur: Int) -> String { s("Bath · \(dur) min", "Купание · \(dur) мин", "Bad · \(dur) min") }
    var mood: String         { s("Mood",         "Настроение",   "Stimmung") }
    var feedLabel: String    { s("Feed",         "Еда",          "Essen") }
    var sleeping: String     { s("sleeping…",    "спит…",        "schläft…") }
    var feedingLabel: String { s("FEEDING",      "КОРМЛЕНИЕ",    "FÜTTERUNG") }
    var typicalLengthHint: String { s("Typical length — 18 min. Tap pause or stop.", "Обычная длина — 18 мин. Нажмите паузу или стоп.", "Typische Länge — 18 Min. Pause oder Stop tippen.") }
    var usuallyAroundThisTime: String { s("Usually around this time — tap to start.", "Обычно в это время — нажмите для старта.", "Normalerweise um diese Zeit — zum Starten tippen.") }
    var tipOfDay: String     { s("Tip of the day",   "Подсказка дня",      "Tipp des Tages") }
    var todaySoFar: String   { s("Today so far",     "Сегодня уже было",   "Heute bisher") }
    var todayUpper: String   { s("TODAY",            "СЕГОДНЯ",            "HEUTE") }
    var leapPillLabel: String { s("Leap #4",         "Скачок №4",          "Schub #4") }
    var leapDayCard: String  { s("LEAP #4 · DAY 3 OF ~5", "СКАЧОК №4 · ДЕНЬ 3 ИЗ ~5", "SCHUB #4 · TAG 3 VON ~5") }
    var worldOfEventsLabel: String { s("«World of Events» — this is normal", "«Мир событий» — это нормально", "«Welt der Ereignisse» — das ist normal") }
    var leapCryingNote: String { s("Crying, poor sleep, wants to be held. Not sick — growing.", "Плачет, плохо спит, просит руки. Он не болен — он растёт.", "Weint, schläft schlecht, will gehalten werden. Nicht krank — wächst.") }

    func howDidSleep(name: String) -> String { s("how did \(name) sleep?", "как \(name) спал?", "wie hat \(name) geschlafen?") }
    func feedingActiveLabel(side: String) -> String { s("active · \(side)", "идёт · \(side)", "aktiv · \(side)") }
    func feedingDuration(_ time: String) -> String { s("Feeding has been going for \(time). Typical length is 18 min.", "Кормление идёт уже \(time). Обычная длина — 18 мин.", "Fütterung dauert seit \(time). Typische Länge 18 Min.") }
    func feedingTip(ago: String, name: String) -> String { s("\(ago) since last feeding — \(name) usually eats now. If crying — try breast first.", "Прошло \(ago) с прошлого кормления — обычно \(name) ест в это время. Если плачет — попробуйте сначала грудь.", "\(ago) seit der letzten Fütterung — \(name) isst normalerweise jetzt.") }
    func leapContrastsTip(name: String) -> String { s("During this leap \(name) is especially drawn to contrasts — show a black-and-white book.", "В этот скачок \(name) особенно интересны контрасты — покажите чёрно-белую книжку.", "In diesem Schub ist \(name) besonders von Kontrasten angezogen.") }
    func diaperCountDay(_ n: Int) -> String { s("\(n) / day", "\(n) / день", "\(n) / Tag") }
    func entriesCount(_ n: Int) -> String { s("\(n) entries", "\(n) записей", "\(n) Einträge") }

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

    func feedingsCount(_ n: Int) -> String { s("\(n) feedings", "\(n) кормлений", "\(n) Mahlzeiten") }
    var addFeedingTitle: String      { s("Add Feeding",     "Добавить кормление",  "Fütterung eintragen") }
    var feedingStartedLabel: String  { s("STARTED",        "НАЧАЛО",              "BEGINN") }
    var feedingEndedLabel: String    { s("ENDED",          "КОНЕЦ",               "ENDE") }
    var feedingSideLabel: String     { s("SIDE",           "СТОРОНА",             "SEITE") }
    var enterManuallyLabel: String   { s("enter manually", "ввести вручную",      "manuell eingeben") }

    // MARK: — Sleep
    var sleepStart: String   { s("Start sleep",   "Начать сон",    "Schlaf starten") }
    var sleepStop: String    { s("Wake up",        "Проснулся",     "Aufwachen") }
    var stopSleep: String    { s("Stop Sleep",     "Остановить сон","Schlaf stoppen") }
    var sleepDuration: String { s("Duration",      "Длительность",  "Dauer") }
    var asleep: String       { s("Asleep",         "Спит",          "Schläft") }
    var awake: String        { s("Awake",          "Проснулся",     "Wach") }
    var sleepTracker: String { s("SLEEP TRACKER",  "ТРЕКЕР СНА",    "SCHLAFTRACKER") }
    var totalToday: String   { s("Total today",    "Всего сегодня", "Heute gesamt") }
    var sessions: String     { s("Sessions",       "Сессий",        "Sitzungen") }
    var sleepQuality: String { s("SLEEP QUALITY",  "КАЧЕСТВО СНА",  "SCHLAFQUALITÄT") }
    var qualityGood: String    { s("😌 Good",      "😌 Хорошо",     "😌 Gut") }
    var qualityNormal: String  { s("😐 Normal",    "😐 Нормально",  "😐 Normal") }
    var qualityRestless: String{ s("😣 Restless",  "😣 Беспокойно", "😣 Unruhig") }

    var sleepChartTitle: String  { s("Sleep chart",   "График сна",    "Schlafdiagramm") }
    var sleepPeriodWeek: String  { s("7 days",        "7 дней",        "7 Tage") }
    var sleepPeriodMonth: String { s("30 days",       "30 дней",       "30 Tage") }
    var sleepAverage: String     { s("Average",       "Среднее",       "Durchschn.") }
    var sleepNormLabel: String   { s("Norm",          "Норма",         "Norm") }
    var sleepInNorm: String      { s("In norm",       "В норме",       "In Norm") }
    var sleepBelowNorm: String   { s("Below norm",    "Ниже нормы",    "Unter Norm") }
    var sleepAboveNorm: String   { s("Above norm",    "Выше нормы",    "Über Norm") }
    var sleepNoData: String      { s("No sleep data yet", "Данных о сне пока нет", "Noch keine Schlafdaten") }

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
    var feed: String        { s("Feed",          "Лента",            "Feed") }
    var empty: String       { s("Empty",         "Пусто",            "Leer") }
    var diaryEmptyHint: String { s("Nothing in this category yet.\nAdd the first — tap +", "В этой категории пока нет записей.\nДобавьте первую — нажмите +", "Noch nichts hier.\nAuf + tippen") }
    var filterPhoto: String { s("📷 Photo",      "📷 Фото",          "📷 Foto") }
    var filterNotes: String { s("✎ Notes",       "✎ Заметки",        "✎ Notizen") }
    var diaryQuote: String  { s("A year from now you'll open this and smile ✿", "через год вы откроете это и будете улыбаться ✿", "In einem Jahr wirst du das öffnen und lächeln ✿") }
    var babyPhotoLabel: String { s("baby's photo", "фото малыша",    "Babyfoto") }
    var entryType: String   { s("Type",          "Тип",              "Typ") }
    var addToDiary: String  { s("Add to Diary",  "Добавить в дневник","Zum Tagebuch") }
    var newEntry: String    { s("New Entry",     "Новая запись",     "Neuer Eintrag") }
    var whatToWrite: String { s("WHAT DO YOU WANT TO WRITE?", "ЧТО ХОТИТЕ ЗАПИСАТЬ?", "WAS MÖCHTEN SIE SCHREIBEN?") }
    var noteExamplePlaceholder: String { s("E.g. Laughed out loud for the first time!", "Например: «Впервые засмеялся в голос!»", "Z.B. Zum ersten Mal laut gelacht!") }
    var chooseIcon: String  { s("CHOOSE ICON",   "ВЫБЕРИТЕ ИКОНКУ",  "SYMBOL WÄHLEN") }
    var orWriteYourOwn: String { s("OR WRITE YOUR OWN", "ИЛИ НАПИШИТЕ СВОЁ", "ODER EIGENES SCHREIBEN") }
    var milestoneExamplePlaceholder: String { s("E.g. First roll-over", "Например: «Первый переворот»", "Z.B. Erste Drehung") }
    var choosePhoto: String { s("CHOOSE PHOTO",  "ВЫБЕРИТЕ ФОТО",    "FOTO WÄHLEN") }
    var tapToChoose: String { s("Tap to choose", "Нажмите, чтобы выбрать", "Zum Auswählen tippen") }
    var placeholderColor: String { s("Placeholder color:", "Цвет плейсхолдера:", "Platzhalterfarbe:") }
    var captionHandwriting: String { s("CAPTION (handwriting style)", "ПОДПИСЬ (рукописный стиль)", "BILDUNTERSCHRIFT (Handschrift)") }
    var captionExamplePlaceholder: String { s("E.g. first laugh", "Например: «первый смех»", "Z.B. erstes Lachen") }
    var moment: String      { s("moment",        "момент",           "Moment") }
    var toDiary: String     { s("To diary",      "В дневник",        "Zum Tagebuch") }

    func diaryTitle(name: String) -> String { s("\(name)'s Diary", "Дневник \(name)", "Tagebuch von \(name)") }

    // MARK: — Leaps
    var leaps: String           { s("Leaps",             "Скачки развития",  "Entwicklungsschübe") }
    var developmentalLeaps: String { s("Developmental Leaps", "Скачки развития", "Entwicklungsschübe") }
    var leapWeeks: String       { s("weeks",             "недель",           "Wochen") }
    var leapCompleted: String   { s("Completed",         "Завершён",         "Abgeschlossen") }
    var leapInProgress: String  { s("In progress",       "В процессе",       "Im Gange") }
    var leapUpcoming: String    { s("Upcoming",          "Предстоит",        "Bevorstehend") }
    var markDone: String        { s("Mark complete",     "Отметить",         "Abschließen") }
    var day3HardDays: String    { s("Day 3 of ~5 hard days.", "День 3 из ~5 трудных.", "Tag 3 von ~5 schweren.") }
    var hangInThere: String     { s("hang in there, mama ✿", "держитесь, мама ✿", "Haltet durch, Mama ✿") }
    var whatYouNotice: String   { s("WHAT YOU NOTICE",   "ЧТО ЗАМЕТНО",      "WAS SIE BEMERKEN") }
    var comingSoon: String      { s("COMING SOON",       "СКОРО НАУЧИТСЯ",   "KOMMT BALD") }
    var leapWillPass: String    { s("✿ This will pass. Usually lasts ~1 week. Hold them more — it doesn't spoil.", "✿ Это пройдёт. Обычно длится ~1 неделю. Чаще берите на руки — это не балует.", "✿ Das geht vorüber. Dauert ~1 Woche. Öfter auf den Arm nehmen.") }
    var leapCalendar: String    { s("Leap Calendar",     "Календарь скачков","Schub-Kalender") }
    var tipOfTheDay: String     { s("TIP OF THE DAY",    "СОВЕТ НА СЕГОДНЯ", "TIPP DES TAGES") }
    var leapInProgressStatus: String { s("in progress",  "идёт сейчас",      "im Gange") }
    var leapCompletedStatus: String  { s("completed",    "завершён",         "abgeschlossen") }
    var notice: String          { s("notice",            "замечают",         "bemerken") }
    var willLearn: String       { s("will learn",        "научится",         "wird lernen") }

    func currentLeapTitle(id: Int) -> String { s("Now — leap #\(id)", "Сейчас — скачок №\(id)", "Jetzt — Schub №\(id)") }
    func weekPill(n: Int) -> String { s("week \(n)", "\(n)-я неделя", "Woche \(n)") }
    func weekRow(n: Int) -> String  { s("\(n) wk",   "\(n) нед",     "\(n) W") }
    func leapAhead(week: Int) -> String { s("ahead · week \(week)", "впереди · \(week)-я неделя", "bald · Woche \(week)") }
    func forLeapTip(name: String) -> String { s("For leap «\(name)»", "Для скачка «\(name)»", "Für Schub «\(name)»") }

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
    var health: String          { s("Health",        "Здоровье",      "Gesundheit") }
    var heightAndWeight: String { s("Height & Weight","Рост и вес",   "Größe & Gewicht") }
    var whoRange: String        { s("0–24 mo · WHO", "0–24 мес · ВОЗ","0–24 Mon. · WHO") }
    var median: String          { s("Median",        "Медиана",       "Median") }
    var temperatureHistory: String { s("Temperature history", "История температуры", "Temperaturverlauf") }
    var recentMeasurements: String { s("Recent measurements", "Последние замеры", "Letzte Messungen") }
    var weightKg: String        { s("Weight, kg",    "Вес, кг",       "Gewicht, kg") }
    var heightCm: String        { s("Height, cm",    "Рост, см",      "Größe, cm") }
    var headCircCm: String      { s("Head circ., cm","Окруж. головы, см","Kopfumfang, cm") }
    var normalRange: String      { s("normal",        "в норме",        "normal") }
    var subfebr: String         { s("subfebr.",      "субфебр.",       "subfebr.") }
    var subfebrLabel: String    { s("Subfebr.",      "Субфебрильная", "Subfebril") }
    var highTemp: String        { s("High 🌡",       "Высокая 🌡",    "Hoch 🌡") }
    var normalOk: String        { s("Normal ✓",      "Норма ✓",       "Normal ✓") }
    var addWeightHeight: String { s("+ Weight / Height", "+ Вес / рост", "+ Gewicht / Größe") }
    var addTemperature: String  { s("+ Temperature", "+ Температура", "+ Temperatur") }
    var measurements: String    { s("Measurements",  "Замеры",        "Messungen") }
    var weightPlaceholder: String { s("kg (e.g. 6.4)", "кг (напр. 6.4)", "kg (z.B. 6.4)") }
    var heightPlaceholder: String { s("cm (e.g. 64)",  "см (напр. 64)",  "cm (z.B. 64)") }
    var headCirc: String        { s("Head circ.",    "Окр. головы",   "Kopfumfang") }
    var headCircPlaceholder: String { s("cm (e.g. 42)", "см (напр. 42)", "cm (z.B. 42)") }
    var fillAtLeastOneField: String { s("Fill in at least one field.", "Заполните хотя бы одно поле.", "Mindestens ein Feld ausfüllen.") }
    var newMeasurement: String  { s("New measurement","Новый замер",   "Neue Messung") }
    var tempPlaceholder: String { s("e.g. 37.2",     "напр. 37.2",    "z.B. 37.2") }
    var noteSectionLabel: String { s("Note",         "Заметка",       "Notiz") }
    var optionalNote: String    { s("Optional note…","Необязательная заметка…", "Optionale Notiz…") }
    var temperatureCelsius: String { s("Temperature, °C", "Температура, °C", "Temperatur, °C") }
    var recentReadings: String  { s("recent readings", "последние замеры", "letzte Messungen") }
    var noTemperatureData: String { s("No temperature data", "Нет данных о температуре", "Keine Temperaturdaten") }
    var tempNormalRange: String { s("normal < 37.5°", "норма < 37.5°", "normal < 37.5°") }
    var tempSubfebrRange: String { s("subfebr. 37.5–38.4°", "субфебр. 37.5–38.4°", "subfebril. 37.5–38.4°") }
    var tempHighRange: String   { s("high ≥ 38.5°", "высокая ≥ 38.5°", "hoch ≥ 38.5°") }

    // MARK: — Sounds / Lullaby
    var sounds: String          { s("Sounds",        "Звуки",         "Klänge") }
    var lullaby: String         { s("Lullaby",       "Колыбельная",   "Schlaflied") }
    var nowPlaying: String      { s("NOW PLAYING",   "ИГРАЕТ",        "SPIELT") }
    var nowPlayingFull: String  { s("NOW PLAYING",   "СЕЙЧАС ИГРАЕТ", "SPIELT GERADE") }
    var tapToPlay: String       { s("Tap to play",   "Нажмите чтобы играть", "Zum Abspielen tippen") }
    var sleepTight: String      { s("sleep tight",   "пусть спит крепко", "schlaf gut") }
    var playing: String         { s("playing",       "играет",        "spielt") }

    func forBabyName(_ name: String) -> String { s(" for \(name)", " для \(name)", " für \(name)") }

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
    var roleOther: String       { s("Other",         "Другой",        "Andere") }
    var familyRoleHint: String  { s("Everyone has a role — each with their own access level.", "У всех своя роль — у каждой свой уровень доступа.", "Jeder hat eine Rolle — mit eigenem Zugangslevel.") }
    var inviteFamilyMember: String { s("Invite family member", "Пригласить члена семьи", "Familienmitglied einladen") }
    var inviteQrHint: String    { s("QR code or link · choose role", "QR-код или ссылка · выбор роли", "QR-Code oder Link · Rolle wählen") }
    var matrixFeedingSleep: String { s("Feedings & sleep", "Кормления и сон", "Fütterung & Schlaf") }
    var matrixTempMedicine: String { s("Temp / medicine", "Температура / лекарства", "Temperatur / Medizin") }
    var matrixPhotosDiary: String  { s("Photos & diary", "Фото и дневник", "Fotos & Tagebuch") }
    var matrixPaedsReport: String  { s("Paediatric report", "Отчёт педиатру", "Kinderbericht") }
    var whatEachRoleSees: String{ s("What each role sees", "Что видит каждая роль", "Was jede Rolle sieht") }
    var roleLabel: String       { s("ROLE",          "РОЛЬ",          "ROLLE") }
    var saveRole: String        { s("Save role",     "Сохранить роль","Rolle speichern") }
    var removeFromTeamAction: String { s("Remove from team", "Удалить из команды", "Aus Team entfernen") }
    var editMember: String      { s("Edit",          "Редактировать", "Bearbeiten") }
    var roleInTeam: String      { s("ROLE IN TEAM",  "РОЛЬ В КОМАНДЕ","ROLLE IM TEAM") }
    var nameOptional: String    { s("NAME (optional)","ИМЯ (необязательно)","NAME (optional)") }
    var memberNamePlaceholder: String { s("E.g.: Mike, Grandma Olga…", "Например: Миша, Бабушка Оля…", "Z.B.: Mike, Oma Olga…") }
    var shareLink: String       { s("Share link",    "Поделиться ссылкой", "Link teilen") }
    var invitationSent: String  { s("invitation sent","приглашение отправлено", "Einladung gesendet") }
    var addToTeam: String       { s("Add to team",   "Добавить в команду", "Zum Team hinzufügen") }
    var copyLink: String        { s("Copy link",     "Копировать",    "Link kopieren") }
    var newCode: String         { s("New code",      "Новый код",     "Neuer Code") }

    func teamTitle(name: String) -> String { s("\(name)'s Team", "Команда \(name)", "Team von \(name)") }
    func removeConfirm(name: String) -> String { s("Remove \(name) from team?", "Удалить \(name) из команды?", "\(name) aus Team entfernen?") }
    func expiryHoursLeft(hrs: Int, mins: Int) -> String { s("\(hrs)h \(mins)m left", "\(hrs)ч \(mins)м", "\(hrs)h \(mins)m übrig") }
    func expiryMinsLeft(_ mins: Int) -> String { s("\(mins)m left", "\(mins) мин", "\(mins)m übrig") }

    // MARK: — Report
    var report: String          { s("Report",        "Отчёт",         "Bericht") }
    var weekly: String          { s("Weekly",        "Недельный",     "Wöchentlich") }
    var daily: String           { s("Daily",         "Дневной",       "Täglich") }
    var exportPDF: String       { s("Export PDF",    "Экспорт PDF",   "PDF exportieren") }
    var shareReport: String     { s("Share",         "Поделиться",    "Teilen") }
    var paediatricReport: String { s("Paediatric Report", "Отчёт для педиатра", "Kinderbericht") }
    var prepareFor: String      { s("Prepare for",   "Подготовить за","Vorbereiten für") }
    var visitSummaryHint: String { s("Visit summary: sleep · food · weight · temp · stool", "Итог визита: сон · еда · вес · темп · стул", "Besuchszusammenfassung: Schlaf · Essen · Gewicht · Temp · Stuhl") }
    var includeInReport: String { s("INCLUDE IN REPORT", "ВКЛЮЧИТЬ В ОТЧЁТ", "IN BERICHT EINSCHLIESSEN") }
    var preparingPdf: String    { s("Preparing PDF…","Готовим PDF…",  "PDF vorbereiten…") }
    var sharePdf: String        { s("Share PDF",     "Поделиться PDF","PDF teilen") }
    var printAction: String     { s("Print",         "Распечатать",   "Drucken") }
    var reportJobName: String   { s("Momsy — report","Momsy — отчёт", "Momsy — Bericht") }
    var reportPeriod3Days: String      { s("3 days",       "3 дня",                "3 Tage") }
    var reportPeriodWeek: String       { s("Week",          "Неделя",               "Woche") }
    var reportPeriod2Weeks: String     { s("2 weeks",       "2 недели",             "2 Wochen") }
    var reportPeriodMonth: String      { s("Month",         "Месяц",                "Monat") }
    var reportPeriodSinceVisit: String { s("Since visit",   "С визита",             "Seit Besuch") }
    var reportPeriodLabelWeek: String  { s("a week",        "неделю",               "eine Woche") }
    var reportPeriodLabelMonth: String { s("a month",       "месяц",                "einen Monat") }
    var reportPeriodLabelLastVisit: String { s("last visit","последний визит",       "letzten Besuch") }
    var noVisitRecorded: String        { s("No visit recorded",  "Визит не записан",  "Kein Besuch eingetragen") }
    var lastVisitDate: String          { s("Last visit date",    "Дата последнего визита", "Datum des letzten Besuchs") }
    var setVisitDate: String           { s("Set visit date",     "Указать дату визита",    "Besuchsdatum setzen") }
    var reportSectionFeedings: String  { s("Feedings & spit-ups",  "Кормления и срыгивания",  "Mahlzeiten & Spucken") }
    var reportSectionSleepByDay: String { s("Sleep by day",        "Сон по дням",             "Schlaf täglich") }
    var reportSectionDiapers: String   { s("Diapers & stool",      "Подгузники и стул",       "Windeln & Stuhl") }
    var reportSectionTempSymptoms: String { s("Temp / symptoms",   "Температура / симптомы",  "Temp / Symptome") }
    var reportSectionWeightHeight: String { s("Weight & height",   "Вес и рост (график)",     "Gewicht & Größe") }
    var reportSectionMedicine: String  { s("Medicine & vitamins",  "Лекарства и витамины",    "Medizin & Vitamine") }
    var reportSectionPhotosNotes: String { s("Photos & notes",     "Фото и заметки",          "Fotos & Notizen") }
    var reportStatFeedingsLabel: String { s("Feedings",    "Кормлений",               "Mahlzeiten") }
    func reportFeedAvgSub(avg: Double) -> String { s(String(format: "%.1f / day", avg), String(format: "%.1f / день", avg), String(format: "%.1f / Tag", avg)) }
    var reportStatSleepLabel: String   { s("Sleep",        "Сон",                     "Schlaf") }
    var reportStatSleepSub: String     { s("median / day", "медиана / сутки",          "Median / Tag") }
    var reportStatDiapersLabel: String { s("Diapers",      "Подгузники",              "Windeln") }
    var reportNotTracked: String       { s("not tracked",  "не отслеживается",         "nicht verfolgt") }
    var reportStatTempLabel: String    { s("Temperature",  "Температура",             "Temperatur") }
    func reportTempPeakSub(n: Int) -> String { s("peak · \(n)×", "пик · \(n)×",      "Peak · \(n)×") }
    var reportTempNormal: String       { s("normal",       "норма",                   "normal") }
    var reportStatWeightLabel: String  { s("Weight & Height", "Вес и рост",           "Gewicht & Größe") }
    var reportSparkWeightLabel: String { s("Weight, kg",      "Вес, кг",              "Gewicht, kg") }
    var reportSparkFeedingsLabel: String { s("Feedings / day",  "Кормления / сут",    "Mahlzeiten / Tag") }
    var reportSparkSleepLabel: String  { s("Sleep / day (h)",   "Сон / сут (ч)",      "Schlaf / Tag (h)") }
    var reportSparkTempLabel: String   { s("Temperature °C",    "Температура °C",     "Temperatur °C") }
    var reportSparkDiapersLabel: String { s("Diapers / day",   "Подгузники / сут",   "Windeln / Tag") }
    func reportPreviewPeriod(label: String) -> String { s("Period: \(label)", "Период: \(label)", "Zeitraum: \(label)") }
    var reportPreviewNotes: String     { s("NOTES",         "ЗАМЕТКИ",                 "NOTIZEN") }
    var reportPreviewDoctorNotes: String { s("DOCTOR'S NOTES", "ЗАМЕТКИ ВРАЧА",        "ARZTNOTIZEN") }
    func reportSparkPeak(value: String) -> String { s("peak: \(value)", "пик: \(value)", "Peak: \(value)") }

    // MARK: — Symptoms
    var symptomLabelTemperature: String  { s("Temperature",    "Температура",     "Temperatur") }
    var symptomLabelRash: String         { s("Rash",           "Сыпь",            "Ausschlag") }
    var symptomLabelVomiting: String     { s("Vomiting",       "Рвота",           "Erbrechen") }
    var symptomLabelLongCrying: String   { s("Long crying",    "Долгий плач",     "Langes Weinen") }
    var symptomLabelStool: String        { s("Stool",          "Стул",            "Stuhl") }
    var symptomLabelRefusingFood: String { s("Refusing food",  "Отказ от еды",    "Nahrungsverweigerung") }
    var symptomLabelSleepIssues: String  { s("Sleep issues",   "Нарушение сна",   "Schlafprobleme") }
    var symptomLabelOther: String        { s("Other",          "Другое",          "Sonstiges") }
    var symptomSubChooseArea: String     { s("choose area",    "выберите место",   "Bereich wählen") }
    var symptomSubNone: String           { s("none",           "нет",             "keine") }
    var symptomSubStoolNormal: String    { s("normal",         "обычный",         "normal") }
    var symptomSubSelect: String         { s("select",         "выбрать",         "auswählen") }
    var symptomSubShortPhases: String    { s("short phases",   "короткие фазы",   "kurze Phasen") }
    var symptomSubDescribe: String       { s("describe",       "описать",         "beschreiben") }
    var symptomUrgencyWatching: String   { s("Watching",       "Наблюдаем",       "Beobachten") }
    var symptomUrgencyLikely: String     { s("Likely",         "Скорее всего",    "Wahrscheinlich") }
    var symptomUrgencySeeDoctor: String  { s("See Doctor",     "Нужен врач",      "Arzt aufsuchen") }
    var symptomResultNothingTitle: String  { s("Nothing marked",      "Ничего не отмечено",          "Nichts markiert") }
    var symptomResultNothingDetail: String { s("Mark symptoms above — we'll suggest what might be happening.", "Отметьте симптомы выше — мы подскажем, что может происходить.", "Markieren Sie Symptome oben — wir schlagen vor, was passieren könnte.") }
    var symptomResultExamTitle: String   { s("Needs Examination",     "Требует осмотра",             "Untersuchung nötig") }
    var symptomResultExamDetail: String  { s("Fever combined with a rash needs a paediatrician's attention. Don't delay — call your doctor today.", "Сочетание температуры и сыпи требует внимания педиатра. Не откладывайте — позвоните врачу сегодня.", "Fieber mit Ausschlag erfordert einen Kinderarzt. Nicht verzögern — rufen Sie heute an.") }
    var symptomResultExamWarning: String { s("rash + fever · face or throat swelling · difficulty breathing", "сыпь + температура · отёк лица или горла · затруднённое дыхание", "Ausschlag + Fieber · Gesichts-/Halschwellung · Atembeschwerden") }
    var symptomResultGastroTitle: String   { s("Gastroenteritis",    "Гастроэнтерит",               "Gastroenteritis") }
    var symptomResultGastroDetail: String  { s("Vomiting with fever may indicate a gut infection. Keep fluids up: offer breast and water more often.", "Рвота с температурой — возможна кишечная инфекция. Следите за водным балансом: грудь и вода чаще обычного.", "Erbrechen mit Fieber kann auf eine Darminfektion hinweisen. Mehr Flüssigkeit anbieten.") }
    var symptomResultGastroWarning: String { s("refusing fluids 6+ hrs · sunken fontanelle · dry mouth · bloody vomit", "отказ от воды дольше 6 ч · запавший родничок · сухой рот · рвота с кровью", "Flüssigkeitsverweigerung 6+ Std. · eingesunkene Fontanelle · trockener Mund · blutiges Erbrechen") }
    var symptomResultDigestTitle: String   { s("Digestive Upset",    "Расстройство ЖКТ",            "Verdauungsstörung") }
    var symptomResultDigestDetail: String  { s("Possible overfeeding, gas, or food reaction. Hold baby upright 20 min after feeding.", "Возможен перекорм, газы или реакция на питание. Держите малыша вертикально 20 мин после еды.", "Mögliche Überernährung, Blähungen oder Nahrungsreaktion. 20 Min. nach dem Füttern aufrichten.") }
    var symptomResultDigestWarning: String { s("projectile vomiting · vomiting 3+ times in 2 hrs · blood in vomit", "рвота фонтаном · рвота более 3 раз за 2 ч · кровь в рвоте", "Schwallartigem Erbrechen · 3+ Erbrechen in 2 Std. · Blut im Erbrechen") }
    var symptomResultTeethTitle: String    { s("Teething",           "Прорезывание зубов",          "Zahnen") }
    var symptomResultTeethDetail: String   { s("Temp up to 38°, crying, disturbed sleep — classic signs. Try a cold teether, carry more.", "Температура до 38°, плач, нарушение сна — частые спутники. Попробуйте холодный прорезыватель, носите на руках.", "Temp bis 38°, Weinen, gestörter Schlaf — klassische Anzeichen. Kühler Beißring, mehr tragen.") }
    var symptomResultTeethWarning: String  { s("t° > 38.5° for more than a day · refusing fluids · lethargy · unusual rash", "t° > 38.5° дольше суток · отказ от воды · вялость · необычная сыпь", "t° > 38,5° mehr als einen Tag · Flüssigkeitsverweigerung · Lethargie · ungewöhnlicher Ausschlag") }
    var symptomResultArviTitle: String     { s("ARVI / Sore Throat", "ОРВИ / воспаление горла",     "Virusinfektion / Halsschmerzen") }
    var symptomResultArviDetail: String    { s("Refusing food with fever is a common sign of a viral infection. Offer fluids and breast more often.", "Отказ от еды при температуре — частый признак вирусной инфекции. Предлагайте воду и грудь чаще обычного.", "Nahrungsverweigerung mit Fieber ist häufig bei Virusinfektionen. Mehr Flüssigkeit anbieten.") }
    var symptomResultArviWarning: String   { s("t° > 39° · difficulty breathing · lethargy · refusing all fluids", "t° > 39° · затруднённое дыхание · вялость · отказ от воды", "t° > 39° · Atembeschwerden · Lethargie · Flüssigkeitsverweigerung") }
    var symptomResultViralTitle: String    { s("Viral Infection",    "Вирусная инфекция",           "Virale Infektion") }
    var symptomResultViralDetail: String   { s("Monitor closely. Use fever reducer at t° > 38.5°. Ensure adequate fluids.", "Следите за динамикой. Жаропонижающее при t° > 38.5°. Обеспечьте достаточное питьё.", "Genau beobachten. Fiebermittel bei t° > 38,5°. Ausreichend Flüssigkeit sicherstellen.") }
    var symptomResultViralWarning: String  { s("t° > 38° in babies under 3 mo · t° > 39° in older babies · seizures · lethargy", "t° > 38° у детей до 3 мес · t° > 39° у старших · судороги · вялость", "t° > 38° bei Säuglingen unter 3 Mo · t° > 39° bei älteren · Krämpfe · Lethargie") }
    var symptomResultLeapTitle: String     { s("Leap or Colic",      "Скачок или колики",           "Entwicklungsschub oder Koliken") }
    var symptomResultLeapDetail: String    { s("Crying and disturbed sleep without fever are usually a developmental leap or colic. Try tummy massage and the 'tiger position'.", "Плач и нарушение сна без температуры чаще всего — скачок развития или колики. Попробуйте массаж животика и «позицию тигра».", "Weinen und gestörter Schlaf ohne Fieber sind meist ein Entwicklungsschub oder Koliken. Bauchmassage und 'Tigerposition' versuchen.") }
    var symptomResultLeapWarning: String   { s("crying 3+ hrs non-stop · hard bloated belly", "плач дольше 3 часов без перерыва · живот твёрдый и вздутый", "Weinen 3+ Std. ohne Unterbrechung · harter aufgeblähter Bauch") }
    var symptomResultCryingTitle: String   { s("Prolonged Crying",   "Долгий плач",                "Anhaltender Weinkrampf") }
    var symptomResultCryingDetail: String  { s("Check the basics: hunger, diaper, room temperature, tiredness. Peak colic age is 6 weeks.", "Проверьте основные причины: голод, подгузник, температура в комнате, усталость. Пик колик — 6 недель.", "Grundlegendes prüfen: Hunger, Windel, Raumtemperatur, Müdigkeit. Höhepunkt der Koliken: 6 Wochen.") }
    var symptomResultCryingWarning: String { s("unusual tone of cry · arching back · no urination 8+ hrs", "плач необычного тона · выгибание спины · нет мочеиспускания 8+ ч", "Ungewöhnlicher Weinton · Rücken wölben · kein Wasserlassen 8+ Std.") }
    var symptomResultWatchingTitle: String   { s("Watching",         "Наблюдаем",                  "Beobachten") }
    var symptomResultWatchingDetail: String  { s("The marked symptoms aren't alarming. Keep observing and log any changes.", "Отмеченные симптомы не вызывают тревоги. Продолжайте наблюдать и записывайте любые изменения.", "Die markierten Symptome sind nicht besorgniserregend. Weiter beobachten.") }
    var symptomResultWatchingWarning: String { s("any worsening · new symptoms · your gut — you know your baby best", "любое ухудшение · новые симптомы · ваша интуиция — вы лучше знаете малыша", "Jede Verschlechterung · neue Symptome · Ihr Instinkt — Sie kennen Ihr Baby am besten") }

    // MARK: — Navigation tabs
    var tabDoctor: String       { s("Doctor",        "Доктор",        "Arzt") }
    var tabMe: String           { s("Me",            "Я",             "Ich") }
    var profile: String         { s("Profile",       "Профиль",       "Profil") }

    // MARK: — Splash
    var splashTagline: String   { s("Your baby's little diary", "Дневник вашего малыша", "Das Tagebuch deines Babys") }

    // MARK: — Settings
    var settings: String        { s("Settings",      "Настройки",     "Einstellungen") }
    var language: String        { s("Language",      "Язык",          "Sprache") }
    var theme: String           { s("Theme",         "Тема",          "Design") }
    var appTheme: String        { s("App Theme",     "Тема приложения","App-Design") }
    var themeAuto: String       { s("Auto",          "Авто",          "Auto") }
    var autoThemeHint: String   { s("Auto follows the system appearance.", "Авто — следует системной теме устройства.", "Auto folgt der Systemdarstellung.") }
    var appLanguage: String     { s("App Language",  "Язык приложения","App-Sprache") }
    var languageComingSoon: String { s("More languages coming soon.", "Больше языков — скоро.", "Weitere Sprachen folgen bald.") }
    var about: String           { s("About",         "О приложении",  "Über") }
    var version: String         { s("Version",       "Версия",        "Version") }
    var madeWithLove: String    { s("Made with love","Сделано с любовью","Mit Liebe gemacht") }
    var forMoms: String         { s("for moms",      "для мам",       "für Mütter") }
    var privacy: String         { s("Privacy",       "Конфиденциальность","Datenschutz") }
    var contactUs: String       { s("Contact Us",    "Написать нам",  "Kontakt") }
    var themeSystem: String     { s("System",        "Системная",     "System") }
    var themeLight: String      { s("Light",         "Светлая",       "Hell") }
    var themeDark: String       { s("Dark",          "Тёмная",        "Dunkel") }
    var notifications: String   { s("Notifications", "Уведомления",   "Benachrichtigungen") }
    var babyProfile: String     { s("Baby profile",  "Профиль малыша","Baby-Profil") }
    var editProfile: String     { s("Edit Profile",  "Редактировать", "Bearbeiten") }
    var saveChanges: String     { s("Save changes",  "Сохранить",     "Speichern") }
    var profileUpdated: String  { s("Profile saved", "Профиль сохранён","Profil gespeichert") }
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
    var continueArrow: String   { s("Continue →",    "Продолжить →",  "Weiter →") }
    var skip: String            { s("Skip",          "Пропустить",    "Überspringen") }
    var helloMama: String       { s("Hello, mama!",  "Привет, мама!", "Hallo, Mama!") }
    var howOldIsYourBaby: String { s("How old is your baby?\nWe'll tailor everything to their age.", "Сколько малышу?\nМы всё адаптируем под его возраст.", "Wie alt ist Ihr Baby?\nWir passen alles an.") }
    var ageChangeNote: String   { s("Age can be changed later. We'll highlight developmental leaps specifically for you.", "Возраст можно изменить позже. Мы выделим скачки развития специально для вас.", "Alter kann später geändert werden.") }
    var whatsYourBabyName: String { s("What's your baby's name?", "Как зовут малыша?", "Wie heißt Ihr Baby?") }
    var nameBirthHelp: String   { s("Name and birth date help track\nleaps and development more accurately.", "Имя и дата рождения помогают точнее\nотслеживать скачки и развитие.", "Name und Geburtsdatum helfen genauer.") }
    var babyNameLabel: String   { s("BABY'S NAME",   "ИМЯ МАЛЫША",   "NAME DES BABYS") }
    var babyNamePlaceholder: String { s("E.g., Leo", "Например, Лёва","Z.B. Leon") }
    var dateOfBirthLabel: String { s("DATE OF BIRTH","ДАТА РОЖДЕНИЯ", "GEBURTSDATUM") }
    var whoAreYou: String       { s("Who are you to the baby?", "Кто ты для малыша?", "Wer bist du für das Baby?") }
    var roleHelp: String        { s("This helps configure\nnotifications and access rights.", "Это помогает настроить\nуведомления и права доступа.", "Das hilft bei der Konfiguration.") }
    var yourNameOptional: String { s("YOUR NAME (optional)", "ВАШЕ ИМЯ (необязательно)", "IHR NAME (optional)") }
    var yourNamePlaceholder: String { s("E.g., Anna", "Например, Аня","Z.B. Anna") }
    var greetMom: String        { s("Mama!",         "Мама!",         "Mama!") }
    var greetDad: String        { s("Papa!",         "Папа!",         "Papa!") }
    var greetNanny: String      { s("Nanny!",        "Няня!",         "Nanny!") }
    var greetDefault: String    { s("Hello!",        "Привет!",       "Hallo!") }
    var allSet: String          { s("All set,",      "Всё готово,",   "Fertig,") }
    var age: String             { s("Age",           "Возраст",       "Alter") }
    var caregiver: String       { s("Caregiver",     "Кто следит",    "Betreuer") }
    var stage: String           { s("Stage",         "Стадия",        "Stufe") }
    var dataStoredLocally: String { s("Data is stored only on your phone. Nothing extra.", "Данные хранятся только на вашем телефоне. Ничего лишнего.", "Daten werden nur auf Ihrem Telefon gespeichert.") }
    var genderLabel: String      { s("GENDER",         "ПОЛ",           "GESCHLECHT") }
    var genderBoy: String        { s("Boy",            "Мальчик",       "Junge") }
    var genderGirl: String       { s("Girl",           "Девочка",       "Mädchen") }
    var genderUnknown: String    { s("Don't know yet", "Пока неизвестно","Noch unklar") }

    func ageDescription(_ ageStr: String) -> String { s("Age: \(ageStr)", "Возраст: \(ageStr)", "Alter: \(ageStr)") }

    // MARK: — Symptoms
    var symptoms: String        { s("Symptoms",      "Симптомы",      "Symptome") }
    var addSymptom: String      { s("Add symptom",   "Добавить симптом", "Symptom hinzufügen") }
    var fever: String           { s("Fever",         "Температура",   "Fieber") }
    var cough: String           { s("Cough",         "Кашель",        "Husten") }
    var runnyNose: String       { s("Runny nose",    "Насморк",       "Schnupfen") }
    var rash: String            { s("Rash",          "Сыпь",          "Ausschlag") }
    var teething: String        { s("Teething",      "Зубы",          "Zahnen") }
    var somethingWrong: String  { s("Something wrong?", "Что-то не так?", "Etwas nicht in Ordnung?") }
    var markItGuide: String     { s("Mark it — we'll guide you on what to do", "Отметьте — мы подскажем, что делать", "Markieren — wir führen Sie.") }
    var notADiagnosis: String   { s("NOT A DIAGNOSIS","Это не диагноз","KEINE DIAGNOSE") }
    var symptomDisclaimer: String { s("We help you navigate. The decision is yours and your doctor's.", "Помогаем сориентироваться. Решение принимаете вы и врач.", "Wir helfen bei der Orientierung.") }
    var seeDoctorUrgently: String { s("See doctor urgently if:", "Срочно к врачу, если:", "Arzt dringend aufsuchen wenn:") }
    var symptomFooterDisclaimer: String { s("Symptom hints are navigation, not a diagnosis.\nWhen in doubt — always see your paediatrician.", "Подсказки на основе симптомов — это навигация, не диагноз.\nПри любых сомнениях — всегда к педиатру.", "Symptomhinweise sind Orientierung, keine Diagnose.\nIm Zweifel — immer zum Kinderarzt.") }
    var symptomsUpper: String   { s("SYMPTOMS",      "СИМПТОМЫ",      "SYMPTOME") }
    var noteSymptoms: String    { s("Note symptoms — get guidance. Not a diagnosis, just navigation.", "Отметьте симптомы — подскажем, что делать. Не диагноз, только навигация.", "Symptome notieren — Orientierung erhalten. Keine Diagnose.") }

    // MARK: — Doctor Menu
    var askMomsyAI: String      { s("Ask Momsy AI",  "Спросить ИИ",   "Momsy KI fragen") }
    var aiMenuSub: String       { s("Sleep, feeding, development — ask anything", "Сон, кормление, развитие — спросите всё", "Schlaf, Ernährung, Entwicklung — alles fragen") }
    var pediatricianReport: String { s("Pediatrician Report","Отчёт для педиатра","Kinderarztbericht") }
    var pdfForWeek: String      { s("PDF for the week — sleep, feeding, weight", "PDF за неделю — сон, кормление, вес", "PDF für die Woche — Schlaf, Ernährung, Gewicht") }
    var whoPercentileChart: String { s("WHO percentile chart", "График по перцентилям ВОЗ", "WHO-Perzentilkurve") }
    var vaccinations: String            { s("Vaccinations",          "Прививки",                     "Impfungen") }
    var vaccinationCalendar: String     { s("Vaccination calendar",   "Календарь прививок",           "Impfkalender") }
    var vaccinationCalendarSub: String  { s("Schedule & reminders",   "Расписание и напоминания",     "Zeitplan & Erinnerungen") }
    var vaccinationMarkDone: String     { s("Mark as done",           "Отметить выполненной",         "Als erledigt markieren") }
    var vaccinationUndo: String         { s("Undo",                   "Отменить",                     "Rückgängig") }

    // MARK: — Food Diary
    var foodDiary: String           { s("Food Diary",          "Прикорм-дневник",        "Beikost-Tagebuch") }
    var foodDiarySub: String        { s("New foods, reactions, allergies", "Новые продукты, реакции, аллергии", "Neue Lebensmittel, Reaktionen, Allergien") }
    var addFood: String             { s("Add food",             "Добавить продукт",        "Lebensmittel hinzufügen") }
    var foodName: String            { s("Food name",            "Название продукта",       "Lebensmittelname") }
    var foodCategory: String        { s("Category",             "Категория",               "Kategorie") }
    var foodReaction: String        { s("Reaction",             "Реакция",                 "Reaktion") }
    var foodReactionNone: String    { s("No reaction",          "Без реакции",             "Keine Reaktion") }
    var foodReactionMild: String    { s("Mild",                 "Лёгкая",                  "Leicht") }
    var foodReactionSevere: String  { s("Severe",               "Сильная",                 "Schwer") }
    var foodAllergen: String        { s("Allergen",             "Аллерген",                "Allergen") }
    var foodAllergens: String       { s("Allergens",            "Аллергены",               "Allergene") }
    var foodAllergensNone: String   { s("No allergens logged",  "Аллергены не зафиксированы", "Keine Allergene erfasst") }
    var foodCatVegetable: String    { s("Vegetable",            "Овощ",                    "Gemüse") }
    var foodCatFruit: String        { s("Fruit",                "Фрукт",                   "Frucht") }
    var foodCatCereal: String       { s("Cereal",               "Каша",                    "Getreide") }
    var foodCatMeat: String         { s("Meat",                 "Мясо",                    "Fleisch") }
    var foodCatDairy: String        { s("Dairy",                "Молочное",                "Milchprodukt") }
    var foodCatFish: String         { s("Fish",                 "Рыба",                    "Fisch") }
    var foodCatEgg: String          { s("Egg",                  "Яйцо",                    "Ei") }
    var foodCatOther: String        { s("Other",                "Другое",                  "Sonstiges") }
    var foodStartHint: String       { s("Log first solid foods for your baby", "Записывайте первые продукты прикорма", "Erste Beikost für Ihr Baby protokollieren") }

    // MARK: — Me / Profile
    var familyMembersHint: String { s("Mom, dad, nanny, grandma", "Мама, папа, няня, бабушка", "Mama, Papa, Nanny, Oma") }
    var lullabiesSounds: String { s("Lullabies & Sounds", "Колыбельные и шум", "Lieder & Klänge") }
    var lullabiesHint: String   { s("White noise, melodies, timer", "Белый шум, мелодии, таймер", "Weißes Rauschen, Melodien, Timer") }
    var settingsHint: String    { s("Theme, language",  "Тема, язык",    "Design, Sprache") }

    // MARK: — AI Chat
    var aiChatTitle: String     { s("Ask Momsy AI", "Спросить ИИ",   "Momsy KI fragen") }
    var momsyAI: String         { s("Momsy AI",     "Momsy ИИ",      "Momsy KI") }
    var aiChatSubtitle: String  { s("Ask about sleep, feeding, development,\nor anything on your mind.", "Спросите о сне, кормлении, развитии\nили о том, что вас беспокоит.", "Fragen zu Schlaf, Ernährung, Entwicklung\noder allem, was Sie beschäftigt.") }
    var askAnything: String     { s("Ask anything…","Спросить…",     "Alles fragen…") }

    // MARK: — Mom Mood Tracker
    var momMoodTitle: String          { s("My Wellbeing",            "Моё самочувствие",           "Mein Wohlbefinden") }
    var momMoodSub: String            { s("Mood & PPD screening",    "Настроение и PPD скрининг",  "Stimmung & PPD-Screening") }
    var momMoodSectionLabel: String   { s("WELLBEING",               "САМОЧУВСТВИЕ",               "WOHLBEFINDEN") }
    var momMoodTodayPrompt: String    { s("How are you feeling today?", "Как вы себя чувствуете сегодня?", "Wie geht es Ihnen heute?") }
    var momMoodEnergyLabel: String    { s("Energy",                  "Энергия",                    "Energie") }
    var momMoodCheckin: String        { s("Daily Check-in",          "Ежедневная отметка",         "Tägliches Check-in") }
    var momMoodCheckinSub: String     { s("Rate your mood & energy", "Оцените настроение и силы",  "Stimmung & Energie bewerten") }
    var momMoodHistory: String        { s("30-day history",          "История за 30 дней",         "30-Tage-Verlauf") }
    var momMoodNoData: String         { s("No check-ins yet",        "Пока нет отметок",           "Noch keine Einträge") }
    var momMoodNoteSub: String        { s("optional note",           "заметка (необязательно)",    "Notiz (optional)") }
    var epdsTitle: String             { s("EPDS Screening",          "Скрининг EPDS",              "EPDS-Screening") }
    var epdsSubtitle: String          { s("Edinburgh Postnatal Depression Scale", "Эдинбургская шкала послеродовой депрессии", "Edinburgher Wochenbettdepressionsskala") }
    var epdsStartCTA: String          { s("Take Screening",          "Пройти скрининг",            "Screening starten") }
    var epdsLastScore: String         { s("Last score",              "Последний результат",        "Letztes Ergebnis") }
    var epdsProgress: String          { s("Question",                "Вопрос",                     "Frage") }
    var epdsOf: String                { s("of",                      "из",                         "von") }
    var epdsYourScore: String         { s("Your score",              "Ваш результат",              "Ihr Ergebnis") }
    var epdsLowRisk: String           { s("Low risk",                "Низкий риск",                "Geringes Risiko") }
    var epdsMildRisk: String          { s("Possible mild depression","Возможная лёгкая депрессия", "Mögliche leichte Depression") }
    var epdsHighRisk: String          { s("Seek support",            "Обратитесь за помощью",      "Unterstützung suchen") }
    var epdsDisclaimer: String        { s("This tool is not a diagnosis. If your score is 10 or above, please consult your doctor.",
                                          "Этот инструмент не является диагнозом. При результате 10 и выше обратитесь к врачу.",
                                          "Dieses Tool ist keine Diagnose. Bei einem Score von 10 oder mehr wenden Sie sich an Ihren Arzt.") }
    var epdsDoneButton: String        { s("Done",                    "Готово",                     "Fertig") }
    var epdsNextButton: String        { s("Next",                    "Далее",                      "Weiter") }
    var epdsQ1: String  { s("I have been able to laugh and see the funny side of things.",
                             "Я была способна смеяться и видеть смешную сторону вещей.",
                             "Ich konnte lachen und die lustige Seite der Dinge sehen.") }
    var epdsQ2: String  { s("I have looked forward with enjoyment to things.",
                             "Я с удовольствием ждала каких-то событий.",
                             "Ich habe mich auf kommende Dinge gefreut.") }
    var epdsQ3: String  { s("I have blamed myself unnecessarily when things went wrong.",
                             "Я напрасно винила себя, когда что-то шло не так.",
                             "Ich habe mich unnötig beschuldigt, wenn etwas schief lief.") }
    var epdsQ4: String  { s("I have been anxious or worried for no good reason.",
                             "Я испытывала тревогу или беспокойство без видимой причины.",
                             "Ich war ängstlich oder besorgt ohne triftigen Grund.") }
    var epdsQ5: String  { s("I have felt scared or panicky for no very good reason.",
                             "Я чувствовала страх или панику без особой причины.",
                             "Ich hatte Angst oder Panik ohne besonderen Grund.") }
    var epdsQ6: String  { s("Things have been getting on top of me.",
                             "Всё навалилось на меня.",
                             "Die Dinge häuften sich für mich.") }
    var epdsQ7: String  { s("I have been so unhappy that I have had difficulty sleeping.",
                             "Мне было так плохо, что я с трудом засыпала.",
                             "Ich war so unglücklich, dass ich Schwierigkeiten beim Schlafen hatte.") }
    var epdsQ8: String  { s("I have felt sad or miserable.",
                             "Я чувствовала себя грустной или несчастной.",
                             "Ich fühlte mich traurig oder elend.") }
    var epdsQ9: String  { s("I have been so unhappy that I have been crying.",
                             "Мне было так плохо, что я плакала.",
                             "Ich war so unglücklich, dass ich geweint habe.") }
    var epdsQ10: String { s("The thought of harming myself has occurred to me.",
                             "У меня возникали мысли о причинении себе вреда.",
                             "Der Gedanke, mir selbst Schaden zuzufügen, kam mir.") }
}
