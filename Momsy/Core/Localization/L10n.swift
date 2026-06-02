import Foundation

struct L10n {
    private let lang: Language

    init(_ lang: Language) { self.lang = lang }

    private func s(_ en: String, _ ru: String, _ de: String, _ es: String) -> String {
        switch lang {
        case .english:    return en
        case .russian:    return ru
        case .german:     return de
        case .spanish:    return es
        case .portuguese: return en
        }
    }

    // MARK: — General
    var done: String        { s("Done",         "Готово",       "Fertig",       "Hecho") }
    var cancel: String      { s("Cancel",        "Отмена",       "Abbrechen",    "Cancelar") }
    var edit: String        { s("Edit",          "Правка",       "Bearbeiten",   "Editar") }
    var save: String        { s("Save",          "Сохранить",    "Speichern",    "Guardar") }
    var today: String       { s("Today",         "Сегодня",      "Heute",        "Hoy") }
    var yesterday: String   { s("Yesterday",     "Вчера",        "Gestern",      "Ayer") }
    var now: String         { s("Now",           "Сейчас",       "Jetzt",        "Ahora") }
    var active: String      { s("ACTIVE",        "ИДЁТ",         "AKTIV",        "ACTIVO") }
    var paused: String      { s("PAUSED",        "ПАУЗА",        "PAUSE",        "EN PAUSA") }
    var add: String         { s("Add",           "Добавить",     "Hinzufügen",   "Añadir") }
    var close: String       { s("Close",         "Закрыть",      "Schließen",    "Cerrar") }
    var confirm: String     { s("Confirm",       "Подтвердить",  "Bestätigen",   "Confirmar") }
    var note: String        { s("NOTE",          "ЗАМЕТКА",      "NOTIZ",        "NOTA") }
    var history: String     { s("History",       "История",      "Verlauf",      "Historial") }
    var remove: String      { s("Remove",        "Удалить",      "Entfernen",    "Quitar") }
    var clear: String       { s("Clear",         "Очистить",     "Löschen",      "Borrar") }
    var saved: String       { s("Saved",         "Записано",     "Gespeichert",  "Guardado") }
    var start: String       { s("Start",         "Начать",       "Starten",      "Empezar") }
    var all: String         { s("All",           "Всё",          "Alle",         "Todo") }
    var you: String         { s("you",           "вы",           "du",           "tú") }
    var expired: String     { s("expired",       "истёк",        "abgelaufen",   "caducado") }
    var copied: String      { s("Copied!",       "Скопировано!", "Kopiert!",     "¡Copiado!") }
    var reset: String       { s("reset",         "сбросить",     "zurücksetzen", "reiniciar") }
    var call: String        { s("Call",          "Позвонить",    "Anrufen",      "Llamar") }
    var days: String        { s("days",          "дней",         "Tage",         "días") }
    var editSmall: String   { s("edit",          "правка",       "bearbeiten",   "editar") }
    var delete: String     { s("Delete",        "Удалить",      "Löschen",      "Eliminar") }
    var notes: String      { s("Notes",         "Заметки",      "Notizen",      "Notas") }
    var optional: String   { s("optional",      "необязательно","optional",     "opcional") }
    var photo: String      { s("Photo",         "Фото",         "Foto",         "Foto") }

    // MARK: — Time units
    var unitDay: String     { s("d",    "дн",   "T",   "d") }
    var unitMonth: String   { s("mo",   "мес",  "M",   "mes") }
    var unitYear: String    { s("yr",   "лет",  "J",   "año") }
    var unitHour: String    { s("h",    "ч",    "h",   "h") }
    var unitMin: String     { s("min",  "мин",  "min", "min") }
    var unitSec: String     { s("sec",  "сек",  "s",   "s") }
    var unitHr: String      { s("hr",   "ч",    "h",   "h") }
    var unitKg: String      { s("kg",   "кг",   "kg",  "kg") }
    var unitCm: String      { s("cm",   "см",   "cm",  "cm") }
    var justNow: String     { s("just now",    "только что",   "gerade eben",          "justo ahora") }
    var noSleepYet: String  { s("no sleep yet","не спал",      "noch nicht geschlafen","aún no durmió") }
    var noData: String      { s("no data",     "нет данных",   "keine Daten",          "sin datos") }
    var playingContinuously: String { s("playing continuously","играет непрерывно","spielt kontinuierlich","sonando sin parar") }
    var sleepStarted: String { s("Sleep · started", "Сон · начало", "Schlaf · begonnen", "Sueño · iniciado") }
    var symptomRecorded: String { s("Symptom · recorded","Симптом · записан","Symptom · erfasst","Síntoma · registrado") }
    var belowP3: String     { s("below P3",  "ниже P3",   "unter P3", "bajo P3") }
    var aboveP97: String    { s("above P97", "выше P97",  "über P97", "sobre P97") }
    var headShort: String   { s("Head",      "Голова",    "Kopf",     "Cabeza") }
    var hrToStop: String    { s("hr to stop",  "ч до выкл.",  "h bis Stopp",   "h para parar") }
    var minToStop: String   { s("min to stop", "мин до выкл.","min bis Stopp", "min para parar") }
    var secToStop: String   { s("sec to stop", "с до выкл.",  "s bis Stopp",   "s para parar") }
    func minsAgo(_ n: Int) -> String { s("\(n) min ago", "\(n) мин назад", "vor \(n) Min.", "hace \(n) min") }
    func hrsAgo(h: Int, m: Int) -> String { s("\(h) hr \(m) min ago", "\(h) ч \(m) мин назад", "vor \(h) h \(m) min", "hace \(h) h \(m) min") }
    func hrsAgoFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h ago", "\(h) ч назад", "vor \(h)h", "hace \(h)h") : s("\(h)h \(m)m ago", "\(h) ч \(m) мин назад", "vor \(h)h \(m)m", "hace \(h)h \(m)m") }
    func hrAgo(_ h: Int) -> String { s("\(h)h ago", "\(h) ч назад", "vor \(h)h", "hace \(h)h") }
    func sleepDurationFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h", "\(h) ч", "\(h)h", "\(h)h") : s("\(h)h \(m)m", "\(h) ч \(m) м", "\(h)h \(m)m", "\(h)h \(m)m") }
    /// Formats a duration in minutes into a localized string (e.g. "45 min" or "2h 30m").
    func durationFormatted(_ mins: Int) -> String {
        guard mins >= 60 else { return "\(mins) \(unitMin)" }
        let h = mins / 60, m = mins % 60
        return sleepDurationFormatted(h: h, m: m)
    }
    func diaperLogEntry(count: Int) -> String { s("Diaper #\(count) · wet", "Подгузник #\(count) · мокрый", "Windel #\(count) · nass", "Pañal #\(count) · mojado") }
    func feedingLogEntry(dur: Int, side: String) -> String { s("Feeding · \(dur) min · \(side)", "Кормление · \(dur) мин · \(side)", "Fütterung · \(dur) min · \(side)", "Toma · \(dur) min · \(side)") }
    func todayEntry(_ date: String) -> String { s("Today · \(date)", "Сегодня · \(date)", "Heute · \(date)", "Hoy · \(date)") }
    func yesterdayEntry(_ date: String) -> String { s("Yesterday · \(date)", "Вчера · \(date)", "Gestern · \(date)", "Ayer · \(date)") }

    // MARK: — Tabs / Sections
    var tabHome: String     { s("Home",     "Главная",   "Startseite", "Inicio") }
    var tabSleep: String    { s("Sleep",    "Сон",       "Schlaf",     "Sueño") }
    var tabFeeding: String  { s("Feeding",  "Кормление", "Füttern",    "Tomas") }
    var tabSounds: String   { s("Sounds",   "Звуки",     "Töne",       "Sonidos") }
    var tabDiary: String    { s("Diary",    "Дневник",   "Tagebuch",   "Diario") }
    var tabLeaps: String    { s("Leaps",    "Скачки",    "Schübe",     "Saltos") }
    var tabReport: String   { s("Report",   "Отчёт",     "Bericht",    "Informe") }
    var tabTracking: String { s("Tracking", "Показатели","Messung",    "Medidas") }
    var tabSharing: String  { s("Family",   "Семья",     "Familie",    "Familia") }

    // MARK: — Greetings
    var goodNight: String       { s("Good night,",     "Доброй ночи,",  "Gute Nacht,",  "Buenas noches,") }
    var goodMorning: String     { s("Good morning",    "Доброе утро",   "Guten Morgen", "Buenos días") }
    var goodAfternoon: String   { s("Good afternoon",  "Добрый день",   "Guten Tag",    "Buenas tardes") }
    var goodEvening: String     { s("Good evening",    "Добрый вечер",  "Guten Abend",  "Buenas tardes") }
    var goodMorningGreeting: String   { s("Good morning,",   "Доброе утро,",   "Guten Morgen,", "Buenos días,") }
    var goodAfternoonGreeting: String { s("Good afternoon,", "Добрый день,",   "Guten Tag,",    "Buenas tardes,") }
    var goodEveningGreeting: String   { s("Good evening,",   "Добрый вечер,",  "Guten Abend,",  "Buenas noches,") }

    // MARK: — Today / Home
    var baby: String         { s("Baby",         "Малыш",        "Baby",         "Bebé") }
    var logEntry: String     { s("Log",          "Журнал",       "Tagebuch",     "Registro") }
    var quickLog: String     { s("Quick Log",    "Быстрый лог",  "Schnellnotiz", "Registro rápido") }
    var quickLogLabel: String{ s("Quick log",    "Быстро записать", "Schnell erfassen", "Registrar rápido") }
    var feeding: String      { s("Feeding",      "Кормление",    "Fütterung",    "Toma") }
    var sleep: String        { s("Sleep",        "Сон",          "Schlaf",       "Sueño") }
    var diaper: String       { s("Diaper",       "Подгузник",    "Windel",       "Pañal") }
    var diaperQuick: String  { s("Diaper",       "Памп",         "Windel",       "Pañal") }
    var diapers: String      { s("Diapers",      "Подгузники",   "Windeln",      "Pañales") }
    var diary: String        { s("Diary",        "Дневник",      "Tagebuch",     "Diario") }
    var symptom: String      { s("Symptom",      "Симптом",      "Symptom",      "Síntoma") }
    var walk: String         { s("Walk",         "Прогулка",     "Spaziergang",  "Paseo") }
    var bath: String         { s("Bath",         "Купание",      "Bad",          "Baño") }
    var vitamins: String     { s("Vitamins",     "Витамины",     "Vitamine",     "Vitaminas") }
    var stoolLabel: String     { s("Stool",           "Стул",                  "Stuhlgang",        "Deposición") }
    var stoolLogged: String    { s("Stool · logged",  "Стул · записан",        "Stuhlgang · notiert", "Deposición · registrada") }
    var addStoolTitle: String  { s("Add Entry",       "Новая запись",          "Eintrag",          "Nueva entrada") }
    var stoolTimeLabel: String { s("Time",            "Время",                 "Zeit",             "Hora") }
    var walkLogged: String   { s("Walk · logged",    "Прогулка · записана",   "Spaziergang · erfasst", "Paseo · registrado") }
    var bathLogged: String   { s("Bath · logged",    "Купание · записано",    "Bad · erfasst",    "Baño · registrado") }
    var vitaminsGiven: String { s("Vitamins · given","Витамины · приняты",    "Vitamine · gegeben","Vitaminas · dadas") }
    var vitaminNamePlaceholder: String { s("e.g. Vitamin D", "напр. Витамин D",     "z.B. Vitamin D",   "p. ej. Vitamina D") }
    var todaysVitamins: String         { s("Today's vitamins","Витамины сегодня",    "Vitamine heute",   "Vitaminas de hoy") }
    var noVitaminsYet: String          { s("No vitamins added yet","Витамины ещё не добавлены","Noch keine Vitamine","Aún sin vitaminas") }
    var vitaminNameLabel: String       { s("VITAMIN NAME", "НАЗВАНИЕ ВИТАМИНА",    "VITAMINNAME",      "NOMBRE DE LA VITAMINA") }
    func vitaminAdded(name: String) -> String { s("Vitamins · \(name)", "Витамины · \(name)", "Vitamine · \(name)", "Vitaminas · \(name)") }
    var walkTracker: String  { s("WALK TRACKER",    "ТРЕКЕР ПРОГУЛКИ",       "GEHTRACKER",       "REGISTRO DE PASEO") }
    var walking: String      { s("walking…",        "гуляем…",               "gehen…",           "paseando…") }
    var startWalk: String    { s("Start Walk",      "Начать прогулку",       "Spaziergang starten", "Empezar paseo") }
    var stopWalk: String     { s("Stop Walk",       "Закончить прогулку",    "Spaziergang stoppen", "Terminar paseo") }
    var addWalkTitle: String { s("Add Walk",        "Добавить прогулку",     "Spaziergang erfassen", "Añadir paseo") }
    var noWalkYet: String    { s("no walk yet",     "ещё не гуляли",         "noch nicht spaziert", "aún sin paseo") }
    func walkLogEntry(dur: Int) -> String { s("Walk · \(dur) min", "Прогулка · \(dur) мин", "Spaziergang · \(dur) min", "Paseo · \(dur) min") }
    var bathTracker: String  { s("BATH TRACKER",     "ТРЕКЕР КУПАНИЯ",        "BADTRACKER",       "REGISTRO DE BAÑO") }
    var bathing: String      { s("bathing…",         "купаемся…",             "Baden…",           "bañando…") }
    var startBath: String    { s("Start Bath",       "Начать купание",        "Bad starten",      "Empezar baño") }
    var stopBath: String     { s("Stop Bath",        "Закончить купание",     "Bad stoppen",      "Terminar baño") }
    var noBathYet: String    { s("no bath yet",      "ещё не купались",       "noch nicht gebadet", "aún sin baño") }
    var addBathTitle: String { s("Add Bath",         "Добавить купание",      "Bad erfassen",     "Añadir baño") }
    func bathLogEntry(dur: Int) -> String { s("Bath · \(dur) min", "Купание · \(dur) мин", "Bad · \(dur) min", "Baño · \(dur) min") }

    var pumping: String         { s("Pumping",          "Сцеживание",          "Pumpen",      "Extracción") }
    var pumpingSideLabel: String { s("SIDE",            "СТОРОНА",             "SEITE",       "LADO") }
    var pumpingLeft: String     { s("Left",             "Левая",               "Links",       "Izquierdo") }
    var pumpingRight: String    { s("Right",            "Правая",              "Rechts",      "Derecho") }
    var pumpingBoth: String     { s("Both",             "Обе",                 "Beide",       "Ambos") }
    var pumpingVolume: String   { s("VOLUME (ML)",      "ОБЪЁМ (МЛ)",          "MENGE (ML)",  "VOLUMEN (ML)") }
    var pumpingStart: String    { s("Start",            "Начать",              "Starten",     "Empezar") }
    var pumpingStop: String     { s("Done",             "Готово",              "Fertig",      "Hecho") }
    var noPumpingYet: String    { s("No pumping today", "Сцеживаний ещё нет",  "Noch kein Pumpen", "Sin extracción hoy") }
    var pumpingTracker: String  { s("PUMPING TRACKER",  "ТРЕКЕР СЦЕЖИВАНИЯ",   "PUMPEN-TRACKER", "REGISTRO DE EXTRACCIÓN") }
    func pumpingLogEntry(dur: Int, ml: Int) -> String {
        ml > 0
            ? s("Pumping · \(dur) min · \(ml) ml",   "Сцеживание · \(dur) мин · \(ml) мл",   "Pumpen · \(dur) min · \(ml) ml",   "Extracción · \(dur) min · \(ml) ml")
            : s("Pumping · \(dur) min",               "Сцеживание · \(dur) мин",               "Pumpen · \(dur) min",              "Extracción · \(dur) min")
    }

    var mood: String         { s("Mood",         "Настроение",   "Stimmung",     "Ánimo") }
    var feedLabel: String    { s("Feed",         "Еда",          "Essen",        "Comida") }
    var sleeping: String     { s("sleeping…",    "спит…",        "schläft…",     "durmiendo…") }
    var feedingLabel: String { s("FEEDING",      "КОРМЛЕНИЕ",    "FÜTTERUNG",    "TOMA") }
    var typicalLengthHint: String { s("Typical length — 18 min. Tap pause or stop.", "Обычная длина — 18 мин. Нажмите паузу или стоп.", "Typische Länge — 18 Min. Pause oder Stop tippen.", "Duración típica — 18 min. Pulsa pausa o parar.") }
    var usuallyAroundThisTime: String { s("Usually around this time — tap to start.", "Обычно в это время — нажмите для старта.", "Normalerweise um diese Zeit — zum Starten tippen.", "Suele ser a esta hora — pulsa para empezar.") }
    var tipOfDay: String     { s("Tip of the day",   "Подсказка дня",      "Tipp des Tages", "Consejo del día") }
    var todaySoFar: String   { s("Today so far",     "Сегодня уже было",   "Heute bisher",   "Hoy hasta ahora") }
    var todayUpper: String   { s("TODAY",            "СЕГОДНЯ",            "HEUTE",          "HOY") }
    var leapPillLabel: String { s("Leap #4",         "Скачок №4",          "Schub #4",       "Salto n.º 4") }
    var leapDayCard: String  { s("LEAP #4 · DAY 3 OF ~5", "СКАЧОК №4 · ДЕНЬ 3 ИЗ ~5", "SCHUB #4 · TAG 3 VON ~5", "SALTO N.º 4 · DÍA 3 DE ~5") }
    var worldOfEventsLabel: String { s("«World of Events» — this is normal", "«Мир событий» — это нормально", "«Welt der Ereignisse» — das ist normal", "«El mundo de los eventos» — es normal") }
    var leapCryingNote: String { s("Crying, poor sleep, wants to be held. Not sick — growing.", "Плачет, плохо спит, просит руки. Он не болен — он растёт.", "Weint, schläft schlecht, will gehalten werden. Nicht krank — wächst.", "Llora, duerme mal, quiere brazos. No está enfermo — está creciendo.") }

    func howDidSleep(name: String) -> String { s("how did \(name) sleep?", "как \(name) спал?", "wie hat \(name) geschlafen?", "¿cómo durmió \(name)?") }
    func feedingActiveLabel(side: String) -> String { s("active · \(side)", "идёт · \(side)", "aktiv · \(side)", "activo · \(side)") }
    func feedingDuration(_ time: String) -> String { s("Feeding has been going for \(time). Typical length is 18 min.", "Кормление идёт уже \(time). Обычная длина — 18 мин.", "Fütterung dauert seit \(time). Typische Länge 18 Min.", "La toma lleva \(time). La duración típica es 18 min.") }
    func feedingTip(ago: String, name: String) -> String { s("\(ago) since last feeding — \(name) usually eats now. If crying — try breast first.", "Прошло \(ago) с прошлого кормления — обычно \(name) ест в это время. Если плачет — попробуйте сначала грудь.", "\(ago) seit der letzten Fütterung — \(name) isst normalerweise jetzt.", "\(ago) desde la última toma — \(name) suele comer ahora. Si llora, prueba primero el pecho.") }
    func leapContrastsTip(name: String) -> String { s("During this leap \(name) is especially drawn to contrasts — show a black-and-white book.", "В этот скачок \(name) особенно интересны контрасты — покажите чёрно-белую книжку.", "In diesem Schub ist \(name) besonders von Kontrasten angezogen.", "Durante este salto a \(name) le atraen los contrastes — muéstrale un libro en blanco y negro.") }
    func diaperCountDay(_ n: Int) -> String { s("\(n) / day", "\(n) / день", "\(n) / Tag", "\(n) / día") }
    func entriesCount(_ n: Int) -> String { s("\(n) entries", "\(n) записей", "\(n) Einträge", "\(n) entradas") }
    var noEntriesYet: String { s("Nothing logged yet today", "Ещё ничего не записано", "Noch nichts eingetragen", "Nada registrado hoy aún") }

    // MARK: — Feeding
    var feedingLeft: String   { s("Left",   "Левая",   "Links",   "Izquierdo") }
    var feedingRight: String  { s("Right",  "Правая",  "Rechts",  "Derecho") }
    var feedingBottle: String { s("Bottle", "Бутылка", "Flasche", "Biberón") }
    var typicalDuration: String { s("of ≈ 18 min typical", "из ≈ 18 мин обычно", "von ≈ 18 min üblich", "de ≈ 18 min típicos") }
    var pause: String         { s("‖ Pause",     "‖ Пауза",      "‖ Pause",      "‖ Pausa") }
    var resume: String        { s("▶ Resume",    "▶ Продолжить", "▶ Fortsetzen", "▶ Reanudar") }
    var stopDone: String      { s("■ Done",      "■ Закончить",  "■ Fertig",     "■ Terminar") }
    var feedings: String      { s("feedings",    "кормлений",    "Mahlzeiten",   "tomas") }
    var tapTagMood: String    { s("tap a tag to add a mood note", "нажмите тег для записи настроения", "Tag antippen für Stimmungsnotiz", "pulsa una etiqueta para añadir una nota de ánimo") }
    var moodCalm: String      { s("😊 calm",        "😊 спокоен",    "😊 ruhig",        "😊 tranquilo") }
    var moodAsleep: String    { s("😴 fell asleep",  "😴 уснул",      "😴 eingeschlafen", "😴 se durmió") }
    var moodSpitUp: String    { s("🤢 spit up",      "🤢 срыгнул",    "🤢 gespuckt",     "🤢 regurgitó") }
    var customTag: String     { s("+ custom",       "+ свой",        "+ eigenes",       "+ personalizado") }
    var cancelTag: String     { s("✕ cancel",       "✕ отмена",      "✕ abbrechen",     "✕ cancelar") }
    var customMoodPlaceholder: String { s("e.g. cried a bit, then calmed", "напр. немного поплакал, успокоился", "z.B. kurz geweint, dann ruhig", "p. ej. lloró un poco y se calmó") }
    var feedingsToday: String { s("feedings today", "кормлений сегодня", "Mahlzeiten heute", "tomas hoy") }
    var mlUnit: String        { s("ml", "мл", "ml", "ml") }
    var bottleVolume: String  { s("VOLUME", "ОБЪЁМ", "MENGE", "VOLUMEN") }

    func feedingsCount(_ n: Int) -> String { s("\(n) feedings", "\(n) кормлений", "\(n) Mahlzeiten", "\(n) tomas") }
    var addFeedingTitle: String      { s("Add Feeding",     "Добавить кормление",  "Fütterung eintragen", "Añadir toma") }
    var feedingStartedLabel: String  { s("STARTED",        "НАЧАЛО",              "BEGINN",     "INICIO") }
    var feedingEndedLabel: String    { s("ENDED",          "КОНЕЦ",               "ENDE",       "FIN") }
    var feedingSideLabel: String     { s("SIDE",           "СТОРОНА",             "SEITE",      "LADO") }
    var enterManuallyLabel: String   { s("enter manually", "ввести вручную",      "manuell eingeben", "introducir manual") }
    var addPumpingTitle: String      { s("Add Pumping",    "Добавить сцеживание", "Pumpen eintragen", "Añadir extracción") }
    var pumpingTypicalDuration: String { s("of ≈ 20 min typical", "из ≈ 20 мин обычно", "von ≈ 20 min üblich", "de ≈ 20 min típicos") }

    // MARK: — Sleep
    var sleepStart: String   { s("Start sleep",   "Начать сон",    "Schlaf starten", "Empezar sueño") }
    var sleepStop: String    { s("Wake up",        "Проснулся",     "Aufwachen",     "Despertar") }
    var stopSleep: String    { s("Stop Sleep",     "Остановить сон","Schlaf stoppen", "Parar sueño") }
    var sleepDuration: String { s("Duration",      "Длительность",  "Dauer",         "Duración") }
    var asleep: String       { s("Asleep",         "Спит",          "Schläft",       "Dormido") }
    var awake: String        { s("Awake",          "Проснулся",     "Wach",          "Despierto") }
    var sleepTracker: String { s("SLEEP TRACKER",  "ТРЕКЕР СНА",    "SCHLAFTRACKER", "REGISTRO DE SUEÑO") }
    var totalToday: String   { s("Total today",    "Всего сегодня", "Heute gesamt",  "Total hoy") }
    var sessions: String     { s("Sessions",       "Сессий",        "Sitzungen",     "Sesiones") }
    var sleepQuality: String { s("SLEEP QUALITY",  "КАЧЕСТВО СНА",  "SCHLAFQUALITÄT", "CALIDAD DEL SUEÑO") }
    var qualityGood: String    { s("😌 Good",      "😌 Хорошо",     "😌 Gut",        "😌 Bueno") }
    var qualityNormal: String  { s("😐 Normal",    "😐 Нормально",  "😐 Normal",     "😐 Normal") }
    var qualityRestless: String{ s("😣 Restless",  "😣 Беспокойно", "😣 Unruhig",    "😣 Inquieto") }

    var feedingChartTitle: String  { s("Feeding",          "Кормление",             "Stillen",        "Tomas") }
    var feedingPeriodWeek: String  { s("7 days",           "7 дней",                "7 Tage",         "7 días") }
    var feedingPeriodMonth: String { s("30 days",          "30 дней",               "30 Tage",        "30 días") }
    var feedingAvgPerDay: String   { s("avg/day",          "ср/день",               "Ø/Tag",          "med/día") }
    var feedingTotalSessions: String { s("total",          "всего",                 "gesamt",         "total") }
    var feedingAvgDuration: String { s("avg dur.",         "ср. длит.",             "Ø Dauer",        "dur. med.") }
    var feedingNoData: String      { s("No data for period", "Нет данных за период", "Keine Daten",   "Sin datos del periodo") }

    var sleepChartTitle: String  { s("Sleep chart",   "График сна",    "Schlafdiagramm", "Gráfico de sueño") }
    var sleepPeriodWeek: String  { s("7 days",        "7 дней",        "7 Tage",         "7 días") }
    var sleepPeriodMonth: String { s("30 days",       "30 дней",       "30 Tage",        "30 días") }
    var sleepAverage: String     { s("Average",       "Среднее",       "Durchschn.",     "Media") }
    var sleepNormLabel: String   { s("Norm",          "Норма",         "Norm",           "Norma") }
    var sleepInNorm: String      { s("In norm",       "В норме",       "In Norm",        "En la norma") }
    var sleepBelowNorm: String   { s("Below norm",    "Ниже нормы",    "Unter Norm",     "Bajo la norma") }
    var sleepAboveNorm: String   { s("Above norm",    "Выше нормы",    "Über Norm",      "Sobre la norma") }
    var sleepNoData: String      { s("No sleep data yet", "Данных о сне пока нет", "Noch keine Schlafdaten", "Aún sin datos de sueño") }
    var addSleepTitle: String    { s("Add Sleep",          "Добавить сон",           "Schlaf eintragen", "Añadir sueño") }

    // MARK: — Diaper
    var diaperWet: String   { s("Wet",    "Мокрый",  "Nass",      "Mojado") }
    var diaperDirty: String { s("Dirty",  "Грязный", "Schmutzig", "Sucio") }
    var diaperChange: String{ s("Change", "Смена",   "Wechsel",   "Cambio") }
    var diaperCount: String { s("changes today", "смен сегодня", "Wechsel heute", "cambios hoy") }

    // MARK: — Diary
    var addNote: String     { s("Add note",      "Добавить заметку", "Notiz hinzufügen", "Añadir nota") }
    var addPhoto: String    { s("Add photo",     "Добавить фото",    "Foto hinzufügen",  "Añadir foto") }
    var milestone: String   { s("Milestone",     "Веха",             "Meilenstein",      "Hito") }
    var milestones: String  { s("Milestones",    "Вехи",             "Meilensteine",     "Hitos") }
    var feed: String        { s("Feed",          "Лента",            "Feed",             "Muro") }
    var empty: String       { s("Empty",         "Пусто",            "Leer",             "Vacío") }
    var diaryEmptyHint: String { s("Nothing in this category yet.\nAdd the first — tap +", "В этой категории пока нет записей.\nДобавьте первую — нажмите +", "Noch nichts hier.\nAuf + tippen", "Aún no hay nada en esta categoría.\nAñade la primera — pulsa +") }
    var filterPhoto: String { s("📷 Photo",      "📷 Фото",          "📷 Foto",          "📷 Foto") }
    var filterNotes: String { s("✎ Notes",       "✎ Заметки",        "✎ Notizen",        "✎ Notas") }
    var diaryQuote: String  { s("A year from now you'll open this and smile ✿", "через год вы откроете это и будете улыбаться ✿", "In einem Jahr wirst du das öffnen und lächeln ✿", "Dentro de un año abrirás esto y sonreirás ✿") }
    var babyPhotoLabel: String { s("baby's photo", "фото малыша",    "Babyfoto",         "foto del bebé") }
    var entryType: String   { s("Type",          "Тип",              "Typ",              "Tipo") }
    var addToDiary: String  { s("Add to Diary",  "Добавить в дневник","Zum Tagebuch",    "Añadir al diario") }
    var newEntry: String    { s("New Entry",     "Новая запись",     "Neuer Eintrag",    "Nueva entrada") }
    var whatToWrite: String { s("WHAT DO YOU WANT TO WRITE?", "ЧТО ХОТИТЕ ЗАПИСАТЬ?", "WAS MÖCHTEN SIE SCHREIBEN?", "¿QUÉ QUIERES ESCRIBIR?") }
    var noteExamplePlaceholder: String { s("E.g. Laughed out loud for the first time!", "Например: «Впервые засмеялся в голос!»", "Z.B. Zum ersten Mal laut gelacht!", "P. ej. ¡Se rió a carcajadas por primera vez!") }
    var chooseIcon: String  { s("CHOOSE ICON",   "ВЫБЕРИТЕ ИКОНКУ",  "SYMBOL WÄHLEN",    "ELIGE UN ICONO") }
    var orWriteYourOwn: String { s("OR WRITE YOUR OWN", "ИЛИ НАПИШИТЕ СВОЁ", "ODER EIGENES SCHREIBEN", "O ESCRIBE EL TUYO") }
    var milestoneExamplePlaceholder: String { s("E.g. First roll-over", "Например: «Первый переворот»", "Z.B. Erste Drehung", "P. ej. Primera vuelta") }
    var choosePhoto: String { s("CHOOSE PHOTO",  "ВЫБЕРИТЕ ФОТО",    "FOTO WÄHLEN",      "ELIGE UNA FOTO") }
    var tapToChoose: String { s("Tap to choose", "Нажмите, чтобы выбрать", "Zum Auswählen tippen", "Pulsa para elegir") }
    var placeholderColor: String { s("Placeholder color:", "Цвет плейсхолдера:", "Platzhalterfarbe:", "Color del marcador:") }
    var captionHandwriting: String { s("CAPTION (handwriting style)", "ПОДПИСЬ (рукописный стиль)", "BILDUNTERSCHRIFT (Handschrift)", "TEXTO (estilo manuscrito)") }
    var captionExamplePlaceholder: String { s("E.g. first laugh", "Например: «первый смех»", "Z.B. erstes Lachen", "P. ej. primera risa") }
    var moment: String      { s("moment",        "момент",           "Moment",           "momento") }
    var toDiary: String     { s("To diary",      "В дневник",        "Zum Tagebuch",     "Al diario") }

    func diaryTitle(name: String) -> String { s("\(name)'s Diary", "Дневник \(name)", "Tagebuch von \(name)", "Diario de \(name)") }

    // MARK: — Leaps
    var leaps: String           { s("Leaps",             "Скачки развития",  "Entwicklungsschübe", "Saltos") }
    var developmentalLeaps: String { s("Developmental Leaps", "Скачки развития", "Entwicklungsschübe", "Saltos del desarrollo") }
    var leapWeeks: String       { s("weeks",             "недель",           "Wochen",          "semanas") }
    var leapCompleted: String   { s("Completed",         "Завершён",         "Abgeschlossen",   "Completado") }
    var leapInProgress: String  { s("In progress",       "В процессе",       "Im Gange",        "En curso") }
    var leapUpcoming: String    { s("Upcoming",          "Предстоит",        "Bevorstehend",    "Próximo") }
    var markDone: String        { s("Mark complete",     "Отметить",         "Abschließen",     "Marcar hecho") }
    var day3HardDays: String    { s("Day 3 of ~5 hard days.", "День 3 из ~5 трудных.", "Tag 3 von ~5 schweren.", "Día 3 de ~5 días difíciles.") }
    var hangInThere: String     { s("hang in there, mama ✿", "держитесь, мама ✿", "Haltet durch, Mama ✿", "ánimo, mamá ✿") }
    var whatYouNotice: String   { s("WHAT YOU NOTICE",   "ЧТО ЗАМЕТНО",      "WAS SIE BEMERKEN", "LO QUE NOTAS") }
    var comingSoon: String      { s("COMING SOON",       "СКОРО НАУЧИТСЯ",   "KOMMT BALD",      "PRONTO") }
    var leapWillPass: String    { s("✿ This will pass. Usually lasts ~1 week. Hold them more — it doesn't spoil.", "✿ Это пройдёт. Обычно длится ~1 неделю. Чаще берите на руки — это не балует.", "✿ Das geht vorüber. Dauert ~1 Woche. Öfter auf den Arm nehmen.", "✿ Esto pasará. Suele durar ~1 semana. Cógelo más en brazos — no lo malcría.") }
    var leapCalendar: String    { s("Leap Calendar",     "Календарь скачков","Schub-Kalender",  "Calendario de saltos") }
    var tipOfTheDay: String     { s("TIP OF THE DAY",    "СОВЕТ НА СЕГОДНЯ", "TIPP DES TAGES",  "CONSEJO DEL DÍA") }
    var leapInProgressStatus: String { s("in progress",  "идёт сейчас",      "im Gange",        "en curso") }
    var leapCompletedStatus: String  { s("completed",    "завершён",         "abgeschlossen",   "completado") }
    var notice: String          { s("notice",            "замечают",         "bemerken",        "notas") }
    var willLearn: String       { s("will learn",        "научится",         "wird lernen",     "aprenderá") }

    func currentLeapTitle(id: Int) -> String { s("Now — leap #\(id)", "Сейчас — скачок №\(id)", "Jetzt — Schub №\(id)", "Ahora — salto n.º \(id)") }
    func weekPill(n: Int) -> String { s("week \(n)", "\(n)-я неделя", "Woche \(n)", "semana \(n)") }
    func weekRow(n: Int) -> String  { s("\(n) wk",   "\(n) нед",     "\(n) W",      "\(n) sem") }
    func leapAhead(week: Int) -> String { s("ahead · week \(week)", "впереди · \(week)-я неделя", "bald · Woche \(week)", "próximo · semana \(week)") }
    func forLeapTip(name: String) -> String { s("For leap «\(name)»", "Для скачка «\(name)»", "Für Schub «\(name)»", "Para el salto «\(name)»") }

    // MARK: — Tracking
    var weight: String          { s("Weight",        "Вес",           "Gewicht",       "Peso") }
    var height: String          { s("Height",        "Рост",          "Größe",         "Altura") }
    var headCircumference: String { s("Head circ.",  "Окруж. головы", "Kopfumfang",    "Perím. cefálico") }
    var temperature: String     { s("Temperature",   "Температура",   "Temperatur",    "Temperatura") }
    var doctorVisit: String     { s("Doctor visit",  "Приём врача",   "Arztbesuch",    "Visita médica") }
    var addMeasurement: String  { s("Add measurement", "Добавить измерение", "Messung hinzufügen", "Añadir medida") }
    var logTemp: String         { s("Log temperature", "Записать температуру", "Temperatur erfassen", "Registrar temperatura") }
    var percentile: String      { s("Percentile",    "Перцентиль",    "Perzentile",    "Percentil") }
    var normal: String          { s("Normal",        "Норма",         "Normal",        "Normal") }
    var elevated: String        { s("Elevated",      "Повышена",      "Erhöht",        "Elevada") }
    var high: String            { s("High",          "Высокая",       "Hoch",          "Alta") }
    var health: String          { s("Health",        "Здоровье",      "Gesundheit",    "Salud") }
    var heightAndWeight: String { s("Height & Weight","Рост и вес",   "Größe & Gewicht", "Altura y peso") }
    var whoRange: String        { s("0–24 mo · WHO", "0–24 мес · ВОЗ","0–24 Mon. · WHO", "0–24 meses · OMS") }
    var median: String          { s("Median",        "Медиана",       "Median",        "Mediana") }
    var temperatureHistory: String { s("Temperature history", "История температуры", "Temperaturverlauf", "Historial de temperatura") }
    var recentMeasurements: String { s("Recent measurements", "Последние замеры", "Letzte Messungen", "Medidas recientes") }
    var weightKg: String        { s("Weight, kg",    "Вес, кг",       "Gewicht, kg",   "Peso, kg") }
    var heightCm: String        { s("Height, cm",    "Рост, см",      "Größe, cm",     "Altura, cm") }
    var headCircCm: String      { s("Head circ., cm","Окруж. головы, см","Kopfumfang, cm", "Perím. cefálico, cm") }
    var normalRange: String      { s("normal",        "в норме",        "normal",       "normal") }
    var subfebr: String         { s("subfebr.",      "субфебр.",       "subfebr.",     "subfebril") }
    var subfebrLabel: String    { s("Subfebr.",      "Субфебрильная", "Subfebril",     "Subfebril") }
    var highTemp: String        { s("High 🌡",       "Высокая 🌡",    "Hoch 🌡",       "Alta 🌡") }
    var normalOk: String        { s("Normal ✓",      "Норма ✓",       "Normal ✓",      "Normal ✓") }
    var addWeightHeight: String { s("+ Weight / Height", "+ Вес / рост", "+ Gewicht / Größe", "+ Peso / altura") }
    var addTemperature: String  { s("+ Temperature", "+ Температура", "+ Temperatur",  "+ Temperatura") }
    var measurements: String    { s("Measurements",  "Замеры",        "Messungen",     "Medidas") }
    var weightPlaceholder: String { s("kg (e.g. 6.4)", "кг (напр. 6.4)", "kg (z.B. 6.4)", "kg (p. ej. 6.4)") }
    var heightPlaceholder: String { s("cm (e.g. 64)",  "см (напр. 64)",  "cm (z.B. 64)",  "cm (p. ej. 64)") }
    var headCirc: String        { s("Head circ.",    "Окр. головы",   "Kopfumfang",    "Perím. cefálico") }
    var headCircPlaceholder: String { s("cm (e.g. 42)", "см (напр. 42)", "cm (z.B. 42)", "cm (p. ej. 42)") }
    var fillAtLeastOneField: String { s("Fill in at least one field.", "Заполните хотя бы одно поле.", "Mindestens ein Feld ausfüllen.", "Rellena al menos un campo.") }
    var newMeasurement: String  { s("New measurement","Новый замер",   "Neue Messung",  "Nueva medida") }
    var tempPlaceholder: String { s("e.g. 37.2",     "напр. 37.2",    "z.B. 37.2",     "p. ej. 37.2") }
    var noteSectionLabel: String { s("Note",         "Заметка",       "Notiz",         "Nota") }
    var optionalNote: String    { s("Optional note…","Необязательная заметка…", "Optionale Notiz…", "Nota opcional…") }
    var temperatureCelsius: String { s("Temperature, °C", "Температура, °C", "Temperatur, °C", "Temperatura, °C") }
    var recentReadings: String  { s("recent readings", "последние замеры", "letzte Messungen", "últimas medidas") }
    var noTemperatureData: String { s("No temperature data", "Нет данных о температуре", "Keine Temperaturdaten", "Sin datos de temperatura") }
    var tempNormalRange: String { s("normal < 37.5°", "норма < 37.5°", "normal < 37.5°", "normal < 37.5°") }
    var tempSubfebrRange: String { s("subfebr. 37.5–38.4°", "субфебр. 37.5–38.4°", "subfebril. 37.5–38.4°", "subfebril 37.5–38.4°") }
    var tempHighRange: String   { s("high ≥ 38.5°", "высокая ≥ 38.5°", "hoch ≥ 38.5°", "alta ≥ 38.5°") }

    // MARK: — Sounds / Lullaby
    var sounds: String          { s("Sounds",        "Звуки",         "Klänge",        "Sonidos") }
    var lullaby: String         { s("Lullaby",       "Колыбельная",   "Schlaflied",    "Nana") }
    var nowPlaying: String      { s("NOW PLAYING",   "ИГРАЕТ",        "SPIELT",        "SONANDO") }
    var nowPlayingFull: String  { s("NOW PLAYING",   "СЕЙЧАС ИГРАЕТ", "SPIELT GERADE", "SONANDO AHORA") }
    var tapToPlay: String       { s("Tap to play",   "Нажмите чтобы играть", "Zum Abspielen tippen", "Pulsa para reproducir") }
    var sleepTight: String      { s("sleep tight",   "пусть спит крепко", "schlaf gut", "que duerma bien") }
    var playing: String         { s("playing",       "играет",        "spielt",        "sonando") }

    func forBabyName(_ name: String) -> String { s(" for \(name)", " для \(name)", " für \(name)", " para \(name)") }

    // MARK: — Family / Sharing
    var family: String          { s("Family",        "Семья",         "Familie",       "Familia") }
    var invite: String          { s("Invite",        "Пригласить",    "Einladen",      "Invitar") }
    var inviteSent: String      { s("Invite sent",   "Приглашение отправлено", "Einladung gesendet", "Invitación enviada") }
    var role: String            { s("Role",          "Роль",          "Rolle",         "Rol") }
    var roleMom: String         { s("Mom",           "Мама",          "Mama",          "Mamá") }
    var roleDad: String         { s("Dad",           "Папа",          "Papa",          "Papá") }
    var roleGrandma: String     { s("Grandma",       "Бабушка",       "Oma",           "Abuela") }
    var roleGrandpa: String     { s("Grandpa",       "Дедушка",       "Opa",           "Abuelo") }
    var roleNanny: String       { s("Nanny",         "Няня",          "Nanny",         "Niñera") }
    var roleOther: String       { s("Other",         "Другой",        "Andere",        "Otro") }
    var familyRoleHint: String  { s("Everyone has a role — each with their own access level.", "У всех своя роль — у каждой свой уровень доступа.", "Jeder hat eine Rolle — mit eigenem Zugangslevel.", "Cada uno tiene un rol — con su propio nivel de acceso.") }
    var inviteFamilyMember: String { s("Invite family member", "Пригласить члена семьи", "Familienmitglied einladen", "Invitar a un familiar") }
    var inviteQrHint: String    { s("QR code or link · choose role", "QR-код или ссылка · выбор роли", "QR-Code oder Link · Rolle wählen", "Código QR o enlace · elige rol") }
    var matrixFeedingSleep: String { s("Feedings & sleep", "Кормления и сон", "Fütterung & Schlaf", "Tomas y sueño") }
    var matrixTempMedicine: String { s("Temp / medicine", "Температура / лекарства", "Temperatur / Medizin", "Temp. / medicina") }
    var matrixPhotosDiary: String  { s("Photos & diary", "Фото и дневник", "Fotos & Tagebuch", "Fotos y diario") }
    var matrixPaedsReport: String  { s("Paediatric report", "Отчёт педиатру", "Kinderbericht", "Informe pediátrico") }
    var whatEachRoleSees: String{ s("What each role sees", "Что видит каждая роль", "Was jede Rolle sieht", "Qué ve cada rol") }
    var joinFamilyTitle: String { s("Join a Family",    "Присоединиться к семье", "Familie beitreten", "Unirse a una familia") }
    var joinAction: String      { s("Join",             "Войти",                  "Beitreten",     "Unirse") }
    var joinSuccessMessage: String { s("You joined the family!", "Вы присоединились к семье!", "Du bist der Familie beigetreten!", "¡Te uniste a la familia!") }
    var roleLabel: String       { s("ROLE",          "РОЛЬ",          "ROLLE",         "ROL") }
    var saveRole: String        { s("Save role",     "Сохранить роль","Rolle speichern", "Guardar rol") }
    var removeFromTeamAction: String { s("Remove from team", "Удалить из команды", "Aus Team entfernen", "Quitar del equipo") }
    var editMember: String      { s("Edit",          "Редактировать", "Bearbeiten",    "Editar") }
    var roleInTeam: String      { s("ROLE IN TEAM",  "РОЛЬ В КОМАНДЕ","ROLLE IM TEAM", "ROL EN EL EQUIPO") }
    var nameOptional: String    { s("NAME (optional)","ИМЯ (необязательно)","NAME (optional)", "NOMBRE (opcional)") }
    var memberNamePlaceholder: String { s("E.g.: Mike, Grandma Olga…", "Например: Миша, Бабушка Оля…", "Z.B.: Mike, Oma Olga…", "P. ej.: Miguel, Abuela Olga…") }
    var shareLink: String       { s("Share link",    "Поделиться ссылкой", "Link teilen", "Compartir enlace") }
    var invitationSent: String  { s("invitation sent","приглашение отправлено", "Einladung gesendet", "invitación enviada") }
    var addToTeam: String       { s("Add to team",   "Добавить в команду", "Zum Team hinzufügen", "Añadir al equipo") }
    var copyLink: String        { s("Copy link",     "Копировать",    "Link kopieren", "Copiar enlace") }
    var newCode: String         { s("New code",      "Новый код",     "Neuer Code",    "Nuevo código") }

    func teamTitle(name: String) -> String { s("\(name)'s Team", "Команда \(name)", "Team von \(name)", "Equipo de \(name)") }
    func removeConfirm(name: String) -> String { s("Remove \(name) from team?", "Удалить \(name) из команды?", "\(name) aus Team entfernen?", "¿Quitar a \(name) del equipo?") }
    func expiryHoursLeft(hrs: Int, mins: Int) -> String { s("\(hrs)h \(mins)m left", "\(hrs)ч \(mins)м", "\(hrs)h \(mins)m übrig", "quedan \(hrs)h \(mins)m") }
    func expiryMinsLeft(_ mins: Int) -> String { s("\(mins)m left", "\(mins) мин", "\(mins)m übrig", "quedan \(mins)m") }

    // MARK: — Report
    var report: String          { s("Report",        "Отчёт",         "Bericht",       "Informe") }
    var weekly: String          { s("Weekly",        "Недельный",     "Wöchentlich",   "Semanal") }
    var daily: String           { s("Daily",         "Дневной",       "Täglich",       "Diario") }
    var exportPDF: String       { s("Export PDF",    "Экспорт PDF",   "PDF exportieren", "Exportar PDF") }
    var shareReport: String     { s("Share",         "Поделиться",    "Teilen",        "Compartir") }
    var paediatricReport: String { s("Paediatric Report", "Отчёт для педиатра", "Kinderbericht", "Informe pediátrico") }
    var prepareFor: String      { s("Prepare for",   "Подготовить за","Vorbereiten für", "Preparar para") }
    var visitSummaryHint: String { s("Visit summary: sleep · food · weight · temp · stool", "Итог визита: сон · еда · вес · темп · стул", "Besuchszusammenfassung: Schlaf · Essen · Gewicht · Temp · Stuhl", "Resumen de visita: sueño · comida · peso · temp · deposiciones") }
    var includeInReport: String { s("INCLUDE IN REPORT", "ВКЛЮЧИТЬ В ОТЧЁТ", "IN BERICHT EINSCHLIESSEN", "INCLUIR EN EL INFORME") }
    var preparingPdf: String    { s("Preparing PDF…","Готовим PDF…",  "PDF vorbereiten…", "Preparando PDF…") }
    var sharePdf: String        { s("Share PDF",     "Поделиться PDF","PDF teilen",     "Compartir PDF") }
    var printAction: String     { s("Print",         "Распечатать",   "Drucken",       "Imprimir") }
    var reportJobName: String   { s("Momsy — report","Momsy — отчёт", "Momsy — Bericht", "Momsy — informe") }
    var reportPeriod3Days: String      { s("3 days",       "3 дня",                "3 Tage",        "3 días") }
    var reportPeriodWeek: String       { s("Week",          "Неделя",               "Woche",         "Semana") }
    var reportPeriod2Weeks: String     { s("2 weeks",       "2 недели",             "2 Wochen",      "2 semanas") }
    var reportPeriodMonth: String      { s("Month",         "Месяц",                "Monat",         "Mes") }
    var reportPeriodSinceVisit: String { s("Since visit",   "С визита",             "Seit Besuch",   "Desde la visita") }
    var reportPeriodLabelWeek: String  { s("a week",        "неделю",               "eine Woche",    "una semana") }
    var reportPeriodLabelMonth: String { s("a month",       "месяц",                "einen Monat",   "un mes") }
    var reportPeriodLabelLastVisit: String { s("last visit","последний визит",       "letzten Besuch", "última visita") }
    var noVisitRecorded: String        { s("No visit recorded",  "Визит не записан",  "Kein Besuch eingetragen", "Sin visita registrada") }
    var lastVisitDate: String          { s("Last visit date",    "Дата последнего визита", "Datum des letzten Besuchs", "Fecha de la última visita") }
    var setVisitDate: String           { s("Set visit date",     "Указать дату визита",    "Besuchsdatum setzen", "Fijar fecha de visita") }
    var reportSectionFeedings: String  { s("Feedings & spit-ups",  "Кормления и срыгивания",  "Mahlzeiten & Spucken", "Tomas y regurgitaciones") }
    var reportSectionSleepByDay: String { s("Sleep by day",        "Сон по дням",             "Schlaf täglich", "Sueño por día") }
    var reportSectionDiapers: String   { s("Diapers & stool",      "Подгузники и стул",       "Windeln & Stuhl", "Pañales y deposiciones") }
    var reportSectionTempSymptoms: String { s("Temp / symptoms",   "Температура / симптомы",  "Temp / Symptome", "Temp. / síntomas") }
    var reportSectionWeightHeight: String { s("Weight & height",   "Вес и рост (график)",     "Gewicht & Größe", "Peso y altura") }
    var reportSectionMedicine: String  { s("Medicine & vitamins",  "Лекарства и витамины",    "Medizin & Vitamine", "Medicina y vitaminas") }
    var reportSectionPhotosNotes: String { s("Photos & notes",     "Фото и заметки",          "Fotos & Notizen", "Fotos y notas") }
    var reportStatFeedingsLabel: String { s("Feedings",    "Кормлений",               "Mahlzeiten",   "Tomas") }
    func reportFeedAvgSub(avg: Double) -> String { s(String(format: "%.1f / day", avg), String(format: "%.1f / день", avg), String(format: "%.1f / Tag", avg), String(format: "%.1f / día", avg)) }
    var reportStatSleepLabel: String   { s("Sleep",        "Сон",                     "Schlaf",       "Sueño") }
    var reportStatSleepSub: String     { s("median / day", "медиана / сутки",          "Median / Tag", "mediana / día") }
    var reportStatDiapersLabel: String { s("Diapers",      "Подгузники",              "Windeln",      "Pañales") }
    var reportNotTracked: String       { s("not tracked",  "не отслеживается",         "nicht verfolgt", "no registrado") }
    var reportStatTempLabel: String    { s("Temperature",  "Температура",             "Temperatur",   "Temperatura") }
    func reportTempPeakSub(n: Int) -> String { s("peak · \(n)×", "пик · \(n)×",      "Peak · \(n)×",  "pico · \(n)×") }
    var reportTempNormal: String       { s("normal",       "норма",                   "normal",       "normal") }
    var reportStatWeightLabel: String  { s("Weight & Height", "Вес и рост",           "Gewicht & Größe", "Peso y altura") }
    var reportSparkWeightLabel: String { s("Weight, kg",      "Вес, кг",              "Gewicht, kg",  "Peso, kg") }
    func reportSparkWeightDynamicLabel(unit: String) -> String { s("Weight, \(unit)", "Вес, \(unit)", "Gewicht, \(unit)", "Peso, \(unit)") }
    var reportSparkFeedingsLabel: String { s("Feedings / day",  "Кормления / сут",    "Mahlzeiten / Tag", "Tomas / día") }
    var reportSparkSleepLabel: String  { s("Sleep / day (h)",   "Сон / сут (ч)",      "Schlaf / Tag (h)", "Sueño / día (h)") }
    var reportSparkTempLabel: String   { s("Temperature °C",    "Температура °C",     "Temperatur °C", "Temperatura °C") }
    func reportSparkTempDynamicLabel(unit: String) -> String { s("Temperature \(unit)", "Температура \(unit)", "Temperatur \(unit)", "Temperatura \(unit)") }
    var reportSparkDiapersLabel: String { s("Diapers / day",   "Подгузники / сут",   "Windeln / Tag", "Pañales / día") }
    func reportPreviewPeriod(label: String) -> String { s("Period: \(label)", "Период: \(label)", "Zeitraum: \(label)", "Periodo: \(label)") }
    var reportPreviewNotes: String     { s("NOTES",         "ЗАМЕТКИ",                 "NOTIZEN",      "NOTAS") }
    var reportPreviewDoctorNotes: String { s("DOCTOR'S NOTES", "ЗАМЕТКИ ВРАЧА",        "ARZTNOTIZEN",  "NOTAS DEL MÉDICO") }
    func reportSparkPeak(value: String) -> String { s("peak: \(value)", "пик: \(value)", "Peak: \(value)", "pico: \(value)") }

    // MARK: — Symptoms
    var symptomLabelTemperature: String  { s("Temperature",    "Температура",     "Temperatur",   "Temperatura") }
    var symptomLabelRash: String         { s("Rash",           "Сыпь",            "Ausschlag",    "Sarpullido") }
    var symptomLabelVomiting: String     { s("Vomiting",       "Рвота",           "Erbrechen",    "Vómitos") }
    var symptomLabelLongCrying: String   { s("Long crying",    "Долгий плач",     "Langes Weinen", "Llanto prolongado") }
    var symptomLabelStool: String        { s("Stool",          "Стул",            "Stuhl",        "Deposición") }
    var symptomLabelRefusingFood: String { s("Refusing food",  "Отказ от еды",    "Nahrungsverweigerung", "Rechazo de comida") }
    var symptomLabelSleepIssues: String  { s("Sleep issues",   "Нарушение сна",   "Schlafprobleme", "Problemas de sueño") }
    var symptomLabelOther: String        { s("Other",          "Другое",          "Sonstiges",    "Otro") }
    var symptomSubChooseArea: String     { s("choose area",    "выберите место",   "Bereich wählen", "elige zona") }
    var symptomSubNone: String           { s("none",           "нет",             "keine",        "ninguno") }
    var symptomSubStoolNormal: String    { s("normal",         "обычный",         "normal",       "normal") }
    var symptomSubSelect: String         { s("select",         "выбрать",         "auswählen",    "seleccionar") }
    var symptomSubShortPhases: String    { s("short phases",   "короткие фазы",   "kurze Phasen", "fases cortas") }
    var symptomSubDescribe: String       { s("describe",       "описать",         "beschreiben",  "describir") }
    var symptomUrgencyWatching: String   { s("Watching",       "Наблюдаем",       "Beobachten",   "Observando") }
    var symptomUrgencyLikely: String     { s("Likely",         "Скорее всего",    "Wahrscheinlich", "Probable") }
    var symptomUrgencySeeDoctor: String  { s("See Doctor",     "Нужен врач",      "Arzt aufsuchen", "Ver al médico") }
    var symptomResultNothingTitle: String  { s("Nothing marked",      "Ничего не отмечено",          "Nichts markiert", "Nada marcado") }
    var symptomResultNothingDetail: String { s("Mark symptoms above — we'll suggest what might be happening.", "Отметьте симптомы выше — мы подскажем, что может происходить.", "Markieren Sie Symptome oben — wir schlagen vor, was passieren könnte.", "Marca los síntomas arriba — te sugeriremos qué puede estar pasando.") }
    var symptomResultExamTitle: String   { s("Needs Examination",     "Требует осмотра",             "Untersuchung nötig", "Necesita revisión") }
    var symptomResultExamDetail: String  { s("Fever combined with a rash needs a paediatrician's attention. Don't delay — call your doctor today.", "Сочетание температуры и сыпи требует внимания педиатра. Не откладывайте — позвоните врачу сегодня.", "Fieber mit Ausschlag erfordert einen Kinderarzt. Nicht verzögern — rufen Sie heute an.", "La fiebre junto con sarpullido requiere un pediatra. No lo demores — llama hoy al médico.") }
    var symptomResultExamWarning: String { s("rash + fever · face or throat swelling · difficulty breathing", "сыпь + температура · отёк лица или горла · затруднённое дыхание", "Ausschlag + Fieber · Gesichts-/Halschwellung · Atembeschwerden", "sarpullido + fiebre · hinchazón de cara o garganta · dificultad para respirar") }
    var symptomResultGastroTitle: String   { s("Gastroenteritis",    "Гастроэнтерит",               "Gastroenteritis", "Gastroenteritis") }
    var symptomResultGastroDetail: String  { s("Vomiting with fever may indicate a gut infection. Keep fluids up: offer breast and water more often.", "Рвота с температурой — возможна кишечная инфекция. Следите за водным балансом: грудь и вода чаще обычного.", "Erbrechen mit Fieber kann auf eine Darminfektion hinweisen. Mehr Flüssigkeit anbieten.", "Los vómitos con fiebre pueden indicar una infección intestinal. Mantén los líquidos: ofrece pecho y agua más a menudo.") }
    var symptomResultGastroWarning: String { s("refusing fluids 6+ hrs · sunken fontanelle · dry mouth · bloody vomit", "отказ от воды дольше 6 ч · запавший родничок · сухой рот · рвота с кровью", "Flüssigkeitsverweigerung 6+ Std. · eingesunkene Fontanelle · trockener Mund · blutiges Erbrechen", "rechazo de líquidos 6+ h · fontanela hundida · boca seca · vómito con sangre") }
    var symptomResultDigestTitle: String   { s("Digestive Upset",    "Расстройство ЖКТ",            "Verdauungsstörung", "Malestar digestivo") }
    var symptomResultDigestDetail: String  { s("Possible overfeeding, gas, or food reaction. Hold baby upright 20 min after feeding.", "Возможен перекорм, газы или реакция на питание. Держите малыша вертикально 20 мин после еды.", "Mögliche Überernährung, Blähungen oder Nahrungsreaktion. 20 Min. nach dem Füttern aufrichten.", "Posible sobrealimentación, gases o reacción a un alimento. Mantén al bebé erguido 20 min tras la toma.") }
    var symptomResultDigestWarning: String { s("projectile vomiting · vomiting 3+ times in 2 hrs · blood in vomit", "рвота фонтаном · рвота более 3 раз за 2 ч · кровь в рвоте", "Schwallartigem Erbrechen · 3+ Erbrechen in 2 Std. · Blut im Erbrechen", "vómito en escopetazo · vómitos 3+ veces en 2 h · sangre en el vómito") }
    var symptomResultTeethTitle: String    { s("Teething",           "Прорезывание зубов",          "Zahnen", "Dentición") }
    var symptomResultTeethDetail: String   { s("Temp up to 38°, crying, disturbed sleep — classic signs. Try a cold teether, carry more.", "Температура до 38°, плач, нарушение сна — частые спутники. Попробуйте холодный прорезыватель, носите на руках.", "Temp bis 38°, Weinen, gestörter Schlaf — klassische Anzeichen. Kühler Beißring, mehr tragen.", "Temp. hasta 38°, llanto, sueño alterado — signos típicos. Prueba un mordedor frío y cárgalo más.") }
    var symptomResultTeethWarning: String  { s("t° > 38.5° for more than a day · refusing fluids · lethargy · unusual rash", "t° > 38.5° дольше суток · отказ от воды · вялость · необычная сыпь", "t° > 38,5° mehr als einen Tag · Flüssigkeitsverweigerung · Lethargie · ungewöhnlicher Ausschlag", "t° > 38.5° más de un día · rechazo de líquidos · letargo · sarpullido inusual") }
    var symptomResultArviTitle: String     { s("ARVI / Sore Throat", "ОРВИ / воспаление горла",     "Virusinfektion / Halsschmerzen", "Infección viral / dolor de garganta") }
    var symptomResultArviDetail: String    { s("Refusing food with fever is a common sign of a viral infection. Offer fluids and breast more often.", "Отказ от еды при температуре — частый признак вирусной инфекции. Предлагайте воду и грудь чаще обычного.", "Nahrungsverweigerung mit Fieber ist häufig bei Virusinfektionen. Mehr Flüssigkeit anbieten.", "El rechazo de comida con fiebre es un signo común de infección viral. Ofrece líquidos y pecho más a menudo.") }
    var symptomResultArviWarning: String   { s("t° > 39° · difficulty breathing · lethargy · refusing all fluids", "t° > 39° · затруднённое дыхание · вялость · отказ от воды", "t° > 39° · Atembeschwerden · Lethargie · Flüssigkeitsverweigerung", "t° > 39° · dificultad para respirar · letargo · rechazo de todo líquido") }
    var symptomResultViralTitle: String    { s("Viral Infection",    "Вирусная инфекция",           "Virale Infektion", "Infección viral") }
    var symptomResultViralDetail: String   { s("Monitor closely. Use fever reducer at t° > 38.5°. Ensure adequate fluids.", "Следите за динамикой. Жаропонижающее при t° > 38.5°. Обеспечьте достаточное питьё.", "Genau beobachten. Fiebermittel bei t° > 38,5°. Ausreichend Flüssigkeit sicherstellen.", "Vigila de cerca. Usa antitérmico a t° > 38.5°. Asegura líquidos suficientes.") }
    var symptomResultViralWarning: String  { s("t° > 38° in babies under 3 mo · t° > 39° in older babies · seizures · lethargy", "t° > 38° у детей до 3 мес · t° > 39° у старших · судороги · вялость", "t° > 38° bei Säuglingen unter 3 Mo · t° > 39° bei älteren · Krämpfe · Lethargie", "t° > 38° en bebés menores de 3 meses · t° > 39° en mayores · convulsiones · letargo") }
    var symptomResultLeapTitle: String     { s("Leap or Colic",      "Скачок или колики",           "Entwicklungsschub oder Koliken", "Salto o cólico") }
    var symptomResultLeapDetail: String    { s("Crying and disturbed sleep without fever are usually a developmental leap or colic. Try tummy massage and the 'tiger position'.", "Плач и нарушение сна без температуры чаще всего — скачок развития или колики. Попробуйте массаж животика и «позицию тигра».", "Weinen und gestörter Schlaf ohne Fieber sind meist ein Entwicklungsschub oder Koliken. Bauchmassage und 'Tigerposition' versuchen.", "El llanto y el sueño alterado sin fiebre suelen ser un salto del desarrollo o cólicos. Prueba masaje en la tripita y la 'posición del tigre'.") }
    var symptomResultLeapWarning: String   { s("crying 3+ hrs non-stop · hard bloated belly", "плач дольше 3 часов без перерыва · живот твёрдый и вздутый", "Weinen 3+ Std. ohne Unterbrechung · harter aufgeblähter Bauch", "llanto 3+ h sin parar · tripita dura e hinchada") }
    var symptomResultCryingTitle: String   { s("Prolonged Crying",   "Долгий плач",                "Anhaltender Weinkrampf", "Llanto prolongado") }
    var symptomResultCryingDetail: String  { s("Check the basics: hunger, diaper, room temperature, tiredness. Peak colic age is 6 weeks.", "Проверьте основные причины: голод, подгузник, температура в комнате, усталость. Пик колик — 6 недель.", "Grundlegendes prüfen: Hunger, Windel, Raumtemperatur, Müdigkeit. Höhepunkt der Koliken: 6 Wochen.", "Revisa lo básico: hambre, pañal, temperatura del cuarto, cansancio. El pico de cólicos es a las 6 semanas.") }
    var symptomResultCryingWarning: String { s("unusual tone of cry · arching back · no urination 8+ hrs", "плач необычного тона · выгибание спины · нет мочеиспускания 8+ ч", "Ungewöhnlicher Weinton · Rücken wölben · kein Wasserlassen 8+ Std.", "tono de llanto inusual · arquea la espalda · sin orinar 8+ h") }
    var symptomResultWatchingTitle: String   { s("Watching",         "Наблюдаем",                  "Beobachten", "Observando") }
    var symptomResultWatchingDetail: String  { s("The marked symptoms aren't alarming. Keep observing and log any changes.", "Отмеченные симптомы не вызывают тревоги. Продолжайте наблюдать и записывайте любые изменения.", "Die markierten Symptome sind nicht besorgniserregend. Weiter beobachten.", "Los síntomas marcados no son alarmantes. Sigue observando y registra cualquier cambio.") }
    var symptomResultWatchingWarning: String { s("any worsening · new symptoms · your gut — you know your baby best", "любое ухудшение · новые симптомы · ваша интуиция — вы лучше знаете малыша", "Jede Verschlechterung · neue Symptome · Ihr Instinkt — Sie kennen Ihr Baby am besten", "cualquier empeoramiento · síntomas nuevos · tu instinto — conoces mejor a tu bebé") }

    // MARK: — Navigation tabs
    var tabDoctor: String       { s("Doctor",        "Доктор",        "Arzt",          "Médico") }
    var tabMe: String           { s("Me",            "Я",             "Ich",           "Yo") }
    var profile: String         { s("Profile",       "Профиль",       "Profil",        "Perfil") }

    // MARK: — Splash
    var splashTagline: String   { s("Your baby's little diary", "Дневник вашего малыша", "Das Tagebuch deines Babys", "El pequeño diario de tu bebé") }

    // MARK: — Settings
    var settings: String        { s("Settings",      "Настройки",     "Einstellungen", "Ajustes") }
    var language: String        { s("Language",      "Язык",          "Sprache",       "Idioma") }
    var theme: String           { s("Theme",         "Тема",          "Design",        "Tema") }
    var appTheme: String        { s("App Theme",     "Тема приложения","App-Design",    "Tema de la app") }
    var themeAuto: String       { s("Auto",          "Авто",          "Auto",          "Auto") }
    var autoThemeHint: String   { s("Auto follows the system appearance.", "Авто — следует системной теме устройства.", "Auto folgt der Systemdarstellung.", "Auto sigue la apariencia del sistema.") }
    var appLanguage: String     { s("App Language",  "Язык приложения","App-Sprache",   "Idioma de la app") }
    var languageComingSoon: String { s("More languages coming soon.", "Больше языков — скоро.", "Weitere Sprachen folgen bald.", "Pronto habrá más idiomas.") }
    var unitSystem: String      { s("Units",           "Единицы",       "Einheiten",     "Unidades") }
    var unitMetric: String      { s("Metric",          "Метрическая",   "Metrisch",      "Métrico") }
    var unitImperial: String    { s("Imperial",        "Имперская",     "Imperial",      "Imperial") }
    var unitSystemHint: String  { s("Metric: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Метр.: кг, см, °C, мл · Импер.: lb, in, °F, oz",
                                     "Metrisch: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Métrico: kg, cm, °C, ml · Imperial: lb, in, °F, oz") }
    var about: String           { s("About",         "О приложении",  "Über",          "Acerca de") }
    var version: String         { s("Version",       "Версия",        "Version",       "Versión") }
    var madeWithLove: String    { s("Made with love","Сделано с любовью","Mit Liebe gemacht", "Hecho con amor") }
    var forMoms: String         { s("for moms",      "для мам",       "für Mütter",    "para mamás") }
    var privacy: String         { s("Privacy",       "Конфиденциальность","Datenschutz", "Privacidad") }
    var feedback: String        { s("Feedback",      "Обратная связь", "Feedback",      "Comentarios") }
    var icloudSyncTitle: String { s("Cloud Sync",    "Облачная синхронизация", "Cloud-Synchronisierung", "Sincronización en la nube") }
    var icloudSyncDisclosure: String {
        s("Your baby's health records and your well-being entries (including the EPDS screening) are stored on this device and synced through your private Firebase account so they stay in sync across your devices. They are never shared with third parties or used for ads.",
          "Записи о здоровье малыша и ваши записи о самочувствии (включая скрининг EPDS) хранятся на этом устройстве и синхронизируются через ваш личный аккаунт Firebase, чтобы данные совпадали на всех ваших устройствах. Они никогда не передаются третьим лицам и не используются для рекламы.",
          "Die Gesundheitsdaten deines Babys und deine Wohlbefinden-Einträge (einschließlich des EPDS-Screenings) werden auf diesem Gerät gespeichert und über dein privates Firebase-Konto synchronisiert, damit sie auf deinen Geräten übereinstimmen. Sie werden nie an Dritte weitergegeben oder für Werbung verwendet.",
          "Los registros de salud de tu bebé y tus entradas de bienestar (incluido el cribado EPDS) se guardan en este dispositivo y se sincronizan a través de tu cuenta privada de Firebase para mantenerlos sincronizados entre tus dispositivos. Nunca se comparten con terceros ni se usan para publicidad.")
    }
    var dangerZone: String      { s("Data & Privacy", "Данные и конфиденциальность", "Daten & Datenschutz", "Datos y privacidad") }
    var deleteAllData: String   { s("Delete all data", "Удалить все данные", "Alle Daten löschen", "Eliminar todos los datos") }
    var deleteAllDataConfirm: String {
        s("This permanently deletes your account and every record — on this device and in the cloud — including health and well-being data and diary photos. This cannot be undone.",
          "Это навсегда удалит ваш аккаунт и все записи — на этом устройстве и в облаке — включая данные о здоровье и самочувствии и фото из дневника. Это действие необратимо.",
          "Dies löscht dauerhaft dein Konto und alle Einträge – auf diesem Gerät und in der Cloud – einschließlich Gesundheits- und Wohlbefindensdaten sowie Tagebuchfotos. Dies kann nicht rückgängig gemacht werden.",
          "Esto elimina permanentemente tu cuenta y todos los registros — en este dispositivo y en la nube — incluidos los datos de salud y bienestar y las fotos del diario. Esto no se puede deshacer.")
    }
    var deleting: String        { s("Deleting…",     "Удаление…",     "Wird gelöscht…", "Eliminando…") }
    var deleteFailed: String    { s("Couldn't delete your data. Please try again.", "Не удалось удалить данные. Попробуйте ещё раз.", "Daten konnten nicht gelöscht werden. Bitte versuche es erneut.", "No se pudieron eliminar los datos. Inténtalo de nuevo.") }
    var themeSystem: String     { s("System",        "Системная",     "System",        "Sistema") }
    var themeLight: String      { s("Light",         "Светлая",       "Hell",          "Claro") }
    var themeDark: String       { s("Dark",          "Тёмная",        "Dunkel",        "Oscuro") }
    var notifications: String   { s("Notifications", "Уведомления",   "Benachrichtigungen", "Notificaciones") }
    var babyProfile: String     { s("Baby profile",  "Профиль малыша","Baby-Profil",   "Perfil del bebé") }
    var editProfile: String     { s("Edit Profile",  "Редактировать", "Bearbeiten",    "Editar perfil") }
    var saveChanges: String     { s("Save changes",  "Сохранить",     "Speichern",     "Guardar cambios") }
    var profileUpdated: String  { s("Profile saved", "Профиль сохранён","Profil gespeichert", "Perfil guardado") }
    var subscription: String    { s("Subscription",  "Подписка",      "Abonnement",    "Suscripción") }
    var privacyPolicy: String   { s("Privacy Policy","Политика конфид.", "Datenschutz", "Política de privacidad") }
    var termsOfUse: String      { s("Terms of Use",  "Условия использования", "Nutzungsbedingungen", "Términos de uso") }

    // MARK: — Onboarding
    var onboardingWelcome: String { s("Welcome to Momsy", "Добро пожаловать в Momsy", "Willkommen bei Momsy", "Bienvenida a Momsy") }
    var onboardingSubtitle: String { s("Your smart baby tracker", "Умный трекер малыша", "Dein smarter Baby-Tracker", "Tu rastreador inteligente del bebé") }
    var babyName: String        { s("Baby's name",   "Имя малыша",    "Name des Babys", "Nombre del bebé") }
    var birthDate: String       { s("Birth date",    "Дата рождения", "Geburtsdatum",  "Fecha de nacimiento") }
    var getStarted: String      { s("Get started",   "Начать",        "Loslegen",      "Empezar") }
    var continueLabel: String   { s("Continue",      "Продолжить",    "Weiter",        "Continuar") }
    var continueArrow: String   { s("Continue →",    "Продолжить →",  "Weiter →",      "Continuar →") }
    var skip: String            { s("Skip",          "Пропустить",    "Überspringen",  "Omitir") }
    var helloMama: String       { s("Hello, mama!",  "Привет, мама!", "Hallo, Mama!",  "¡Hola, mamá!") }
    var howOldIsYourBaby: String { s("How old is your baby?\nWe'll tailor everything to their age.", "Сколько малышу?\nМы всё адаптируем под его возраст.", "Wie alt ist Ihr Baby?\nWir passen alles an.", "¿Cuántos meses tiene tu bebé?\nLo adaptaremos todo a su edad.") }
    var ageChangeNote: String   { s("Age can be changed later. We'll highlight developmental leaps specifically for you.", "Возраст можно изменить позже. Мы выделим скачки развития специально для вас.", "Alter kann später geändert werden.", "La edad se puede cambiar después. Destacaremos los saltos del desarrollo especialmente para ti.") }
    var whatsYourBabyName: String { s("What's your baby's name?", "Как зовут малыша?", "Wie heißt Ihr Baby?", "¿Cómo se llama tu bebé?") }
    var nameBirthHelp: String   { s("Name and birth date help track\nleaps and development more accurately.", "Имя и дата рождения помогают точнее\nотслеживать скачки и развитие.", "Name und Geburtsdatum helfen genauer.", "El nombre y la fecha de nacimiento ayudan a seguir\nlos saltos y el desarrollo con más precisión.") }
    var babyNameLabel: String   { s("BABY'S NAME",   "ИМЯ МАЛЫША",   "NAME DES BABYS", "NOMBRE DEL BEBÉ") }
    var babyNamePlaceholder: String { s("E.g., Leo", "Например, Лёва","Z.B. Leon",     "P. ej., Leo") }
    var dateOfBirthLabel: String { s("DATE OF BIRTH","ДАТА РОЖДЕНИЯ", "GEBURTSDATUM",  "FECHA DE NACIMIENTO") }
    var whoAreYou: String       { s("Who are you to the baby?", "Кто ты для малыша?", "Wer bist du für das Baby?", "¿Quién eres para el bebé?") }
    var roleHelp: String        { s("This helps configure\nnotifications and access rights.", "Это помогает настроить\nуведомления и права доступа.", "Das hilft bei der Konfiguration.", "Esto ayuda a configurar\nnotificaciones y permisos de acceso.") }
    var yourNameOptional: String { s("YOUR NAME (optional)", "ВАШЕ ИМЯ (необязательно)", "IHR NAME (optional)", "TU NOMBRE (opcional)") }
    var yourNamePlaceholder: String { s("E.g., Anna", "Например, Аня","Z.B. Anna",     "P. ej., Ana") }
    var greetMom: String        { s("Mama!",         "Мама!",         "Mama!",         "¡Mamá!") }
    var greetDad: String        { s("Papa!",         "Папа!",         "Papa!",         "¡Papá!") }
    var greetNanny: String      { s("Nanny!",        "Няня!",         "Nanny!",        "¡Niñera!") }
    var greetDefault: String    { s("Hello!",        "Привет!",       "Hallo!",        "¡Hola!") }
    var allSet: String          { s("All set,",      "Всё готово,",   "Fertig,",       "Todo listo,") }
    var age: String             { s("Age",           "Возраст",       "Alter",         "Edad") }
    var caregiver: String       { s("Caregiver",     "Кто следит",    "Betreuer",      "Cuidador") }
    var stage: String           { s("Stage",         "Стадия",        "Stufe",         "Etapa") }
    var dataStoredLocally: String { s("Data is stored only on your phone. Nothing extra.", "Данные хранятся только на вашем телефоне. Ничего лишнего.", "Daten werden nur auf Ihrem Telefon gespeichert.", "Los datos se guardan solo en tu teléfono. Nada más.") }
    var genderLabel: String      { s("GENDER",         "ПОЛ",           "GESCHLECHT",   "SEXO") }
    var genderBoy: String        { s("Boy",            "Мальчик",       "Junge",        "Niño") }
    var genderGirl: String       { s("Girl",           "Девочка",       "Mädchen",      "Niña") }
    var genderUnknown: String    { s("Don't know yet", "Пока неизвестно","Noch unklar", "Aún no lo sé") }

    func ageDescription(_ ageStr: String) -> String { s("Age: \(ageStr)", "Возраст: \(ageStr)", "Alter: \(ageStr)", "Edad: \(ageStr)") }

    // MARK: — Symptoms
    var symptoms: String        { s("Symptoms",      "Симптомы",      "Symptome",      "Síntomas") }
    var addSymptom: String      { s("Add symptom",   "Добавить симптом", "Symptom hinzufügen", "Añadir síntoma") }
    var fever: String           { s("Fever",         "Температура",   "Fieber",        "Fiebre") }
    var cough: String           { s("Cough",         "Кашель",        "Husten",        "Tos") }
    var runnyNose: String       { s("Runny nose",    "Насморк",       "Schnupfen",     "Mocos") }
    var rash: String            { s("Rash",          "Сыпь",          "Ausschlag",     "Sarpullido") }
    var teething: String        { s("Teething",      "Зубы",          "Zahnen",        "Dentición") }
    var somethingWrong: String  { s("Something wrong?", "Что-то не так?", "Etwas nicht in Ordnung?", "¿Algo va mal?") }
    var markItGuide: String     { s("Mark it — we'll guide you on what to do", "Отметьте — мы подскажем, что делать", "Markieren — wir führen Sie.", "Márcalo — te guiaremos sobre qué hacer") }
    var notADiagnosis: String   { s("NOT A DIAGNOSIS","Это не диагноз","KEINE DIAGNOSE", "NO ES UN DIAGNÓSTICO") }
    var symptomDisclaimer: String { s("We help you navigate. The decision is yours and your doctor's.", "Помогаем сориентироваться. Решение принимаете вы и врач.", "Wir helfen bei der Orientierung.", "Te ayudamos a orientarte. La decisión es tuya y de tu médico.") }
    var seeDoctorUrgently: String { s("See doctor urgently if:", "Срочно к врачу, если:", "Arzt dringend aufsuchen wenn:", "Ve al médico con urgencia si:") }
    var symptomFooterDisclaimer: String { s("Symptom hints are navigation, not a diagnosis.\nWhen in doubt — always see your paediatrician.", "Подсказки на основе симптомов — это навигация, не диагноз.\nПри любых сомнениях — всегда к педиатру.", "Symptomhinweise sind Orientierung, keine Diagnose.\nIm Zweifel — immer zum Kinderarzt.", "Las pistas de síntomas son orientación, no un diagnóstico.\nAnte la duda — siempre acude a tu pediatra.") }
    var symptomsUpper: String   { s("SYMPTOMS",      "СИМПТОМЫ",      "SYMPTOME",      "SÍNTOMAS") }
    var noteSymptoms: String    { s("Note symptoms — get guidance. Not a diagnosis, just navigation.", "Отметьте симптомы — подскажем, что делать. Не диагноз, только навигация.", "Symptome notieren — Orientierung erhalten. Keine Diagnose.", "Anota los síntomas — recibe orientación. No es un diagnóstico, solo orientación.") }

    // MARK: — Doctor Menu
    var pediatricianReport: String { s("Pediatrician Report","Отчёт для педиатра","Kinderarztbericht", "Informe para el pediatra") }
    var pdfForWeek: String      { s("PDF for the week — sleep, feeding, weight", "PDF за неделю — сон, кормление, вес", "PDF für die Woche — Schlaf, Ernährung, Gewicht", "PDF de la semana — sueño, tomas, peso") }
    var whoPercentileChart: String { s("WHO percentile chart", "График по перцентилям ВОЗ", "WHO-Perzentilkurve", "Gráfico de percentiles OMS") }
    var vaccinations: String            { s("Vaccinations",          "Прививки",                     "Impfungen", "Vacunas") }
    var vaccinationCalendar: String     { s("Vaccination calendar",   "Календарь прививок",           "Impfkalender", "Calendario de vacunas") }
    var vaccinationCalendarSub: String  { s("Schedule & reminders",   "Расписание и напоминания",     "Zeitplan & Erinnerungen", "Calendario y recordatorios") }
    var vaccinationSchedule: String     { s("Vaccination schedule",   "Календарь прививок",           "Impfkalender", "Calendario de vacunación") }
    var vaccinationScheduleHint: String { s("Based on your region. The WHO international schedule is used by default.", "На основе вашего региона. По умолчанию используется международный календарь ВОЗ.", "Basierend auf Ihrer Region. Standardmäßig wird der internationale WHO-Impfkalender verwendet.", "Según tu región. Se usa el calendario internacional de la OMS por defecto.") }
    var vaccinationMarkDone: String     { s("Mark as done",           "Отметить выполненной",         "Als erledigt markieren", "Marcar como hecha") }
    var vaccinationUndo: String         { s("Undo",                   "Отменить",                     "Rückgängig", "Deshacer") }

    // MARK: — Food Diary
    var foodDiary: String           { s("Food Diary",          "Прикорм-дневник",        "Beikost-Tagebuch", "Diario de alimentación") }
    var foodDiarySub: String        { s("New foods, reactions, allergies", "Новые продукты, реакции, аллергии", "Neue Lebensmittel, Reaktionen, Allergien", "Nuevos alimentos, reacciones, alergias") }
    var addFood: String             { s("Add food",             "Добавить продукт",        "Lebensmittel hinzufügen", "Añadir alimento") }
    var foodName: String            { s("Food name",            "Название продукта",       "Lebensmittelname", "Nombre del alimento") }
    var foodCategory: String        { s("Category",             "Категория",               "Kategorie", "Categoría") }
    var foodReaction: String        { s("Reaction",             "Реакция",                 "Reaktion", "Reacción") }
    var foodReactionNone: String    { s("No reaction",          "Без реакции",             "Keine Reaktion", "Sin reacción") }
    var foodReactionMild: String    { s("Mild",                 "Лёгкая",                  "Leicht", "Leve") }
    var foodReactionSevere: String  { s("Severe",               "Сильная",                 "Schwer", "Grave") }
    var foodAllergen: String        { s("Allergen",             "Аллерген",                "Allergen", "Alérgeno") }
    var foodAllergens: String       { s("Allergens",            "Аллергены",               "Allergene", "Alérgenos") }
    var foodAllergensNone: String   { s("No allergens logged",  "Аллергены не зафиксированы", "Keine Allergene erfasst", "Sin alérgenos registrados") }
    var foodCatVegetable: String    { s("Vegetable",            "Овощ",                    "Gemüse", "Verdura") }
    var foodCatFruit: String        { s("Fruit",                "Фрукт",                   "Frucht", "Fruta") }
    var foodCatCereal: String       { s("Cereal",               "Каша",                    "Getreide", "Cereal") }
    var foodCatMeat: String         { s("Meat",                 "Мясо",                    "Fleisch", "Carne") }
    var foodCatDairy: String        { s("Dairy",                "Молочное",                "Milchprodukt", "Lácteo") }
    var foodCatFish: String         { s("Fish",                 "Рыба",                    "Fisch", "Pescado") }
    var foodCatEgg: String          { s("Egg",                  "Яйцо",                    "Ei", "Huevo") }
    var foodCatOther: String        { s("Other",                "Другое",                  "Sonstiges", "Otro") }
    var foodStartHint: String       { s("Log first solid foods for your baby", "Записывайте первые продукты прикорма", "Erste Beikost für Ihr Baby protokollieren", "Registra los primeros sólidos de tu bebé") }

    // MARK: — Me / Profile
    var familyMembersHint: String { s("Mom, dad, nanny, grandma", "Мама, папа, няня, бабушка", "Mama, Papa, Nanny, Oma", "Mamá, papá, niñera, abuela") }
    var lullabiesSounds: String { s("Lullabies & Sounds", "Колыбельные и шум", "Lieder & Klänge", "Nanas y sonidos") }
    var lullabiesHint: String   { s("White noise, melodies, timer", "Белый шум, мелодии, таймер", "Weißes Rauschen, Melodien, Timer", "Ruido blanco, melodías, temporizador") }
    var settingsHint: String    { s("Theme, language",  "Тема, язык",    "Design, Sprache", "Tema, idioma") }

    // MARK: — Mom Mood Tracker
    var momMoodTitle: String          { s("My Wellbeing",            "Моё самочувствие",           "Mein Wohlbefinden", "Mi bienestar") }
    var momMoodSub: String            { s("Mood & PPD screening",    "Настроение и PPD скрининг",  "Stimmung & PPD-Screening", "Ánimo y cribado de DPP") }
    var momMoodSectionLabel: String   { s("WELLBEING",               "САМОЧУВСТВИЕ",               "WOHLBEFINDEN", "BIENESTAR") }
    var momMoodTodayPrompt: String    { s("How are you feeling today?", "Как вы себя чувствуете сегодня?", "Wie geht es Ihnen heute?", "¿Cómo te sientes hoy?") }
    var momMoodEnergyLabel: String    { s("Energy",                  "Энергия",                    "Energie", "Energía") }
    var momMoodCheckin: String        { s("Daily Check-in",          "Ежедневная отметка",         "Tägliches Check-in", "Registro diario") }
    var momMoodCheckinSub: String     { s("Rate your mood & energy", "Оцените настроение и силы",  "Stimmung & Energie bewerten", "Valora tu ánimo y energía") }
    var momMoodHistory: String        { s("30-day history",          "История за 30 дней",         "30-Tage-Verlauf", "Historial de 30 días") }
    var momMoodNoData: String         { s("No check-ins yet",        "Пока нет отметок",           "Noch keine Einträge", "Aún sin registros") }
    var momSleepTitle: String         { s("Mom's Sleep",             "Сон мамы",                   "Schlaf der Mutter", "Sueño de mamá") }
    var momSleepCardSub: String       { s("Track your rest",         "Отслеживайте свой отдых",    "Ihren Schlaf verfolgen", "Sigue tu descanso") }
    var momMoodNoteSub: String        { s("optional note",           "заметка (необязательно)",    "Notiz (optional)", "nota opcional") }
    var epdsTitle: String             { s("EPDS Screening",          "Скрининг EPDS",              "EPDS-Screening", "Cribado EPDS") }
    var epdsSubtitle: String          { s("Edinburgh Postnatal Depression Scale", "Эдинбургская шкала послеродовой депрессии", "Edinburgher Wochenbettdepressionsskala", "Escala de Depresión Posnatal de Edimburgo") }
    var epdsStartCTA: String          { s("Take Screening",          "Пройти скрининг",            "Screening starten", "Hacer el cribado") }
    var epdsLastScore: String         { s("Last score",              "Последний результат",        "Letztes Ergebnis", "Última puntuación") }
    var epdsProgress: String          { s("Question",                "Вопрос",                     "Frage", "Pregunta") }
    var epdsOf: String                { s("of",                      "из",                         "von", "de") }
    var epdsYourScore: String         { s("Your score",              "Ваш результат",              "Ihr Ergebnis", "Tu puntuación") }
    var epdsLowRisk: String           { s("Low risk",                "Низкий риск",                "Geringes Risiko", "Riesgo bajo") }
    var epdsMildRisk: String          { s("Possible mild depression","Возможная лёгкая депрессия", "Mögliche leichte Depression", "Posible depresión leve") }
    var epdsHighRisk: String          { s("Seek support",            "Обратитесь за помощью",      "Unterstützung suchen", "Busca apoyo") }
    var epdsDisclaimer: String        { s("This tool is not a diagnosis. If your score is 10 or above, please consult your doctor.",
                                          "Этот инструмент не является диагнозом. При результате 10 и выше обратитесь к врачу.",
                                          "Dieses Tool ist keine Diagnose. Bei einem Score von 10 oder mehr wenden Sie sich an Ihren Arzt.",
                                          "Esta herramienta no es un diagnóstico. Si tu puntuación es 10 o más, consulta a tu médico.") }
    var epdsDoneButton: String        { s("Done",                    "Готово",                     "Fertig", "Hecho") }
    var epdsNextButton: String        { s("Next",                    "Далее",                      "Weiter", "Siguiente") }
    var epdsQ1: String  { s("I have been able to laugh and see the funny side of things.",
                             "Я была способна смеяться и видеть смешную сторону вещей.",
                             "Ich konnte lachen und die lustige Seite der Dinge sehen.",
                             "He sido capaz de reír y ver el lado divertido de las cosas.") }
    var epdsQ2: String  { s("I have looked forward with enjoyment to things.",
                             "Я с удовольствием ждала каких-то событий.",
                             "Ich habe mich auf kommende Dinge gefreut.",
                             "He esperado las cosas con ilusión.") }
    var epdsQ3: String  { s("I have blamed myself unnecessarily when things went wrong.",
                             "Я напрасно винила себя, когда что-то шло не так.",
                             "Ich habe mich unnötig beschuldigt, wenn etwas schief lief.",
                             "Me he culpado innecesariamente cuando las cosas salían mal.") }
    var epdsQ4: String  { s("I have been anxious or worried for no good reason.",
                             "Я испытывала тревогу или беспокойство без видимой причины.",
                             "Ich war ängstlich oder besorgt ohne triftigen Grund.",
                             "He estado ansiosa o preocupada sin un buen motivo.") }
    var epdsQ5: String  { s("I have felt scared or panicky for no very good reason.",
                             "Я чувствовала страх или панику без особой причины.",
                             "Ich hatte Angst oder Panik ohne besonderen Grund.",
                             "He sentido miedo o pánico sin un buen motivo.") }
    var epdsQ6: String  { s("Things have been getting on top of me.",
                             "Всё навалилось на меня.",
                             "Die Dinge häuften sich für mich.",
                             "Las cosas me han superado.") }
    var epdsQ7: String  { s("I have been so unhappy that I have had difficulty sleeping.",
                             "Мне было так плохо, что я с трудом засыпала.",
                             "Ich war so unglücklich, dass ich Schwierigkeiten beim Schlafen hatte.",
                             "He estado tan infeliz que me ha costado dormir.") }
    var epdsQ8: String  { s("I have felt sad or miserable.",
                             "Я чувствовала себя грустной или несчастной.",
                             "Ich fühlte mich traurig oder elend.",
                             "Me he sentido triste o desdichada.") }
    var epdsQ9: String  { s("I have been so unhappy that I have been crying.",
                             "Мне было так плохо, что я плакала.",
                             "Ich war so unglücklich, dass ich geweint habe.",
                             "He estado tan infeliz que he llorado.") }
    var epdsQ10: String { s("The thought of harming myself has occurred to me.",
                             "У меня возникали мысли о причинении себе вреда.",
                             "Der Gedanke, mir selbst Schaden zuzufügen, kam mir.",
                             "Se me ha pasado por la cabeza la idea de hacerme daño.") }

    // MARK: — Water Intake
    var waterIntakeTitle: String       { s("Water Intake",               "Жидкость мамы",                "Flüssigkeit", "Hidratación") }
    var waterIntakeLabel: String       { s("HYDRATION",                  "ГИДРАТАЦИЯ",                   "HYDRATION", "HIDRATACIÓN") }
    var waterIntakeSub: String         { s("Daily hydration",            "Суточное потребление жидкости", "Tagesflüssigkeit", "Hidratación diaria") }
    var waterGoalLabel: String         { s("Goal",                       "Цель",                          "Ziel", "Objetivo") }
    var waterTodayLabel: String        { s("today",                      "сегодня",                       "heute", "hoy") }
    var waterAdd150: String            { s("+150 ml",                    "+150 мл",                       "+150 ml", "+150 ml") }
    var waterAdd250: String            { s("+250 ml",                    "+250 мл",                       "+250 ml", "+250 ml") }
    var waterAdd500: String            { s("+500 ml",                    "+500 мл",                       "+500 ml", "+500 ml") }
    var waterNoEntries: String         { s("No logs today",              "Записей нет",                   "Keine Einträge", "Sin registros hoy") }
    var waterWeekLabel: String         { s("LAST 7 DAYS",                "ПОСЛЕДНИЕ 7 ДНЕЙ",              "LETZTE 7 TAGE", "ÚLTIMOS 7 DÍAS") }
    var waterTodayEntriesLabel: String { s("TODAY",                      "СЕГОДНЯ",                       "HEUTE", "HOY") }

    // MARK: — Auth / Sign-In
    var authStepTitle: String      { s("Create Account",                   "Создай аккаунт",                    "Konto erstellen", "Crear cuenta") }
    var authStepSubtitle: String   { s("Back up your data & restore it\non any device",
                                       "Сохрани данные и восстанови\nна любом устройстве",
                                       "Daten sichern & auf jedem\nGerät wiederherstellen",
                                       "Respalda tus datos y restáuralos\nen cualquier dispositivo") }
    var signInWithApple: String    { s("Sign in with Apple",               "Войти через Apple",                 "Mit Apple anmelden", "Iniciar sesión con Apple") }
    var signInWithGoogle: String   { s("Sign in with Google",              "Войти через Google",                "Mit Google anmelden", "Iniciar sesión con Google") }
    var mayBeLater: String         { s("Maybe Later",                      "Позже",                             "Vielleicht später", "Quizá más tarde") }

    // MARK: — Paywall
    var trialBadge: String         { s("7 days free",
                                       "7 дней бесплатно",
                                       "7 Tage gratis",
                                       "7 días gratis") }
    var startTrial: String         { s("Start Free Trial",
                                       "Начать бесплатно на 7 дней",
                                       "7 Tage gratis starten",
                                       "Empezar prueba gratis") }
    var paywallPriceNote: String   { s("Then $4.99/month · Cancel anytime",
                                       "Затем 299 ₽/мес · Отменить в любое время",
                                       "Dann 4,99 €/Monat · Jederzeit kündbar",
                                       "Luego 4,99 $/mes · Cancela cuando quieras") }
    var restorePurchases: String   { s("Restore Purchases",
                                       "Восстановить покупки",
                                       "Käufe wiederherstellen",
                                       "Restaurar compras") }
    var featureAll: String         { s("All features, no limits",
                                       "Все функции без ограничений",
                                       "Alle Funktionen ohne Limits",
                                       "Todas las funciones, sin límites") }
    var featureSync: String        { s("Family sync across devices",
                                       "Синхронизация и семейный доступ",
                                       "Familiensync über Geräte hinweg",
                                       "Sincronización familiar entre dispositivos") }
    var featureDiary: String       { s("Unlimited diary & statistics",
                                       "Журнал и статистика без лимитов",
                                       "Unbegrenzte Statistiken",
                                       "Diario y estadísticas sin límites") }
    var authSignedIn: String       { s("Signed in ✓",                      "Вы вошли ✓",                        "Angemeldet ✓", "Sesión iniciada ✓") }
    var signInFailed: String       { s("Sign in failed. Please try again.",
                                       "Не удалось войти. Попробуйте ещё раз.",
                                       "Anmeldung fehlgeschlagen. Bitte erneut versuchen.",
                                       "Error al iniciar sesión. Inténtalo de nuevo.") }
    var googleComingSoon: String   { s("Google Sign-In is coming soon.",    "Вход через Google скоро появится.", "Google-Anmeldung kommt bald.", "El inicio de sesión con Google llegará pronto.") }
    var appleSignInHint: String    { s("Please sign in with your Apple ID in Settings → [Your Name] to use Sign in with Apple.",
                                       "Войдите в Apple ID в Настройках → [Ваше имя], чтобы использовать Sign in with Apple.",
                                       "Bitte melde dich in Einstellungen → [Dein Name] mit deiner Apple ID an.",
                                       "Inicia sesión con tu Apple ID en Ajustes → [Tu nombre] para usar Iniciar sesión con Apple.") }
}
