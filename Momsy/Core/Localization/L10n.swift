import Foundation

struct L10n {
    private let lang: Language

    init(_ lang: Language) { self.lang = lang }

    private func s(_ en: String, _ ru: String, _ de: String, _ es: String, _ fr: String, _ pt: String) -> String {
        switch lang {
        case .english:    return en
        case .russian:    return ru
        case .german:     return de
        case .spanish:    return es
        case .french:     return fr
        case .portuguese: return pt
        }
    }

    // MARK: — General
    var done: String        { s("Done",         "Готово",       "Fertig",       "Hecho",        "Terminé",      "Concluído") }
    var cancel: String      { s("Cancel",        "Отмена",       "Abbrechen",    "Cancelar",     "Annuler",      "Cancelar") }
    var edit: String        { s("Edit",          "Правка",       "Bearbeiten",   "Editar",       "Modifier",     "Editar") }
    var save: String        { s("Save",          "Сохранить",    "Speichern",    "Guardar",      "Enregistrer",  "Guardar") }
    var today: String       { s("Today",         "Сегодня",      "Heute",        "Hoy",          "Aujourd’hui",  "Hoje") }
    var yesterday: String   { s("Yesterday",     "Вчера",        "Gestern",      "Ayer",         "Hier",         "Ontem") }
    var now: String         { s("Now",           "Сейчас",       "Jetzt",        "Ahora",        "Maintenant",   "Agora") }
    var active: String      { s("ACTIVE",        "ИДЁТ",         "AKTIV",        "ACTIVO",       "EN COURS",     "A DECORRER") }
    var paused: String      { s("PAUSED",        "ПАУЗА",        "PAUSE",        "EN PAUSA",     "EN PAUSE",     "EM PAUSA") }
    var add: String         { s("Add",           "Добавить",     "Hinzufügen",   "Añadir",       "Ajouter",      "Adicionar") }
    var close: String       { s("Close",         "Закрыть",      "Schließen",    "Cerrar",       "Fermer",       "Fechar") }
    var confirm: String     { s("Confirm",       "Подтвердить",  "Bestätigen",   "Confirmar",    "Confirmer",    "Confirmar") }

    // MARK: — Weekly Insights (AI weekly report)
    var weeklyInsightTitle: String {
        s("Weekly Report", "Отчёт за неделю", "Wochenbericht", "Informe semanal", "Rapport hebdomadaire", "Relatório semanal")
    }
    var weeklyInsightSub: String {
        s("AI summary of sleep & feeding", "AI-сводка сна и кормления",
          "KI-Zusammenfassung Schlaf & Ernährung", "Resumen IA de sueño y alimentación",
          "Résumé IA du sommeil et de l’alimentation",
          "Resumo de IA do sono e da alimentação")
    }
    var weeklyInsightSleepHeader: String {
        s("Sleep", "Сон", "Schlaf", "Sueño", "Sommeil", "Sono")
    }
    var weeklyInsightFeedingHeader: String {
        s("Feeding & solids", "Кормление и прикорм", "Ernährung & Beikost", "Alimentación y sólidos",
          "Alimentation et diversification", "Alimentação e sólidos")
    }
    var weeklyInsightEmpty: String {
        s("Your first weekly report will appear here after a full week of tracking.",
          "Ваш первый недельный отчёт появится здесь после недели записей.",
          "Dein erster Wochenbericht erscheint hier nach einer Woche mit Einträgen.",
          "Tu primer informe semanal aparecerá aquí tras una semana de registros.",
          "Votre premier rapport hebdomadaire apparaîtra ici après une semaine de suivi.",
          "O seu primeiro relatório semanal aparecerá aqui após uma semana de registos.")
    }
    var weeklyInsightLocked: String {
        s("Weekly AI reports are a Premium feature.",
          "Недельные AI-отчёты доступны в Premium.",
          "Wöchentliche KI-Berichte sind eine Premium-Funktion.",
          "Los informes semanales con IA son una función Premium.",
          "Les rapports IA hebdomadaires sont une fonction Premium.",
          "Os relatórios semanais com IA são uma funcionalidade Premium.")
    }
    var weeklyInsightError: String {
        s("Couldn't load the report. Please try again.",
          "Не удалось загрузить отчёт. Попробуйте ещё раз.",
          "Bericht konnte nicht geladen werden. Bitte erneut versuchen.",
          "No se pudo cargar el informe. Inténtalo de nuevo.",
          "Impossible de charger le rapport. Veuillez réessayer.",
          "Não foi possível carregar o relatório. Tente novamente.")
    }
    var unlockPremium: String {
        s("Unlock Premium", "Открыть Premium", "Premium freischalten", "Desbloquear Premium",
          "Débloquer Premium", "Desbloquear Premium")
    }
    var weeklyReportNotificationTitle: String {
        s("Your weekly report is ready", "Ваш недельный отчёт готов",
          "Dein Wochenbericht ist fertig", "Tu informe semanal está listo",
          "Votre rapport hebdomadaire est prêt", "O seu relatório semanal está pronto")
    }
    var weeklyReportNotificationBody: String {
        s("See how your baby slept and ate this week",
          "Посмотрите, как малыш спал и ел на этой неделе",
          "Sieh, wie dein Baby diese Woche geschlafen und gegessen hat",
          "Mira cómo durmió y comió tu bebé esta semana",
          "Découvrez comment votre bébé a dormi et mangé cette semaine",
          "Veja como o seu bebé dormiu e comeu esta semana")
    }
    var note: String        { s("NOTE",          "ЗАМЕТКА",      "NOTIZ",        "NOTA",         "NOTE",         "NOTA") }
    var history: String     { s("History",       "История",      "Verlauf",      "Historial",    "Historique",   "Histórico") }
    var remove: String      { s("Remove",        "Удалить",      "Entfernen",    "Quitar",       "Retirer",      "Remover") }
    var clear: String       { s("Clear",         "Очистить",     "Löschen",      "Borrar",       "Effacer",      "Limpar") }
    var saved: String       { s("Saved",         "Записано",     "Gespeichert",  "Guardado",     "Enregistré",   "Guardado") }
    var start: String       { s("Start",         "Начать",       "Starten",      "Empezar",      "Démarrer",     "Iniciar") }
    var all: String         { s("All",           "Всё",          "Alle",         "Todo",         "Tout",         "Tudo") }
    var you: String         { s("you",           "вы",           "du",           "tú",           "vous",         "você") }
    var expired: String     { s("expired",       "истёк",        "abgelaufen",   "caducado",     "expiré",       "expirado") }
    var copied: String      { s("Copied!",       "Скопировано!", "Kopiert!",     "¡Copiado!",    "Copié !",      "Copiado!") }
    var reset: String       { s("reset",         "сбросить",     "zurücksetzen", "reiniciar",    "réinitialiser","repor") }
    var call: String        { s("Call",          "Позвонить",    "Anrufen",      "Llamar",       "Appeler",      "Ligar") }
    var days: String        { s("days",          "дней",         "Tage",         "días",         "jours",        "dias") }
    var editSmall: String   { s("edit",          "правка",       "bearbeiten",   "editar",       "modifier",     "editar") }
    var delete: String     { s("Delete",        "Удалить",      "Löschen",      "Eliminar",     "Supprimer",    "Eliminar") }
    var notes: String      { s("Notes",         "Заметки",      "Notizen",      "Notas",        "Notes",        "Notas") }
    var optional: String   { s("optional",      "необязательно","optional",     "opcional",     "facultatif",   "opcional") }
    var photo: String      { s("Photo",         "Фото",         "Foto",         "Foto",         "Photo",        "Foto") }

    // MARK: — Time units
    var unitDay: String     { s("d",    "дн",   "T",   "d",    "j",    "d") }
    var unitMonth: String   { s("mo",   "мес",  "M",   "mes",  "mois", "mês") }
    var unitYear: String    { s("yr",   "лет",  "J",   "año",  "an",   "ano") }
    var unitHour: String    { s("h",    "ч",    "h",   "h",    "h",    "h") }
    var unitMin: String     { s("min",  "мин",  "min", "min",  "min",  "min") }
    var unitSec: String     { s("sec",  "сек",  "s",   "s",    "s",    "s") }
    var unitHr: String      { s("hr",   "ч",    "h",   "h",    "h",    "h") }
    var unitKg: String      { s("kg",   "кг",   "kg",  "kg",   "kg",   "kg") }
    var unitCm: String      { s("cm",   "см",   "cm",  "cm",   "cm",   "cm") }
    var justNow: String     { s("just now",    "только что",   "gerade eben",          "justo ahora",  "à l’instant",  "agora mesmo") }
    var noSleepYet: String  { s("no sleep yet","не спал",      "noch nicht geschlafen","aún no durmió", "pas encore de sommeil", "ainda sem sono") }
    var noData: String      { s("no data",     "нет данных",   "keine Daten",          "sin datos",    "aucune donnée", "sem dados") }
    var playingContinuously: String { s("playing continuously","играет непрерывно","spielt kontinuierlich","sonando sin parar","lecture en continu","a tocar continuamente") }
    var sleepStarted: String { s("Sleep · started", "Сон · начало", "Schlaf · begonnen", "Sueño · iniciado", "Sommeil · commencé", "Sono · iniciado") }
    var symptomRecorded: String { s("Symptom · recorded","Симптом · записан","Symptom · erfasst","Síntoma · registrado","Symptôme · enregistré","Sintoma · registado") }
    var belowP3: String     { s("below P3",  "ниже P3",   "unter P3", "bajo P3",  "sous P3",  "abaixo de P3") }
    var aboveP97: String    { s("above P97", "выше P97",  "über P97", "sobre P97","au-dessus de P97","acima de P97") }
    var headShort: String   { s("Head",      "Голова",    "Kopf",     "Cabeza",   "Tête",     "Cabeça") }
    var hrToStop: String    { s("hr to stop",  "ч до выкл.",  "h bis Stopp",   "h para parar", "h avant l’arrêt", "h até parar") }
    var minToStop: String   { s("min to stop", "мин до выкл.","min bis Stopp", "min para parar","min avant l’arrêt", "min até parar") }
    var secToStop: String   { s("sec to stop", "с до выкл.",  "s bis Stopp",   "s para parar", "s avant l’arrêt", "s até parar") }
    func minsAgo(_ n: Int) -> String { s("\(n) min ago", "\(n) мин назад", "vor \(n) Min.", "hace \(n) min", "il y a \(n) min", "há \(n) min") }
    func hrsAgo(h: Int, m: Int) -> String { s("\(h) hr \(m) min ago", "\(h) ч \(m) мин назад", "vor \(h) h \(m) min", "hace \(h) h \(m) min", "il y a \(h) h \(m) min", "há \(h) h \(m) min") }
    func hrsAgoFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h ago", "\(h) ч назад", "vor \(h)h", "hace \(h)h", "il y a \(h)h", "há \(h)h") : s("\(h)h \(m)m ago", "\(h) ч \(m) мин назад", "vor \(h)h \(m)m", "hace \(h)h \(m)m", "il y a \(h)h \(m)m", "há \(h)h \(m)m") }
    func hrAgo(_ h: Int) -> String { s("\(h)h ago", "\(h) ч назад", "vor \(h)h", "hace \(h)h", "il y a \(h)h", "há \(h)h") }
    func sleepDurationFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h", "\(h) ч", "\(h)h", "\(h)h", "\(h)h", "\(h)h") : s("\(h)h \(m)m", "\(h) ч \(m) м", "\(h)h \(m)m", "\(h)h \(m)m", "\(h)h \(m)m", "\(h)h \(m)m") }
    /// Formats a duration in minutes into a localized string (e.g. "45 min" or "2h 30m").
    func durationFormatted(_ mins: Int) -> String {
        guard mins >= 60 else { return "\(mins) \(unitMin)" }
        let h = mins / 60, m = mins % 60
        return sleepDurationFormatted(h: h, m: m)
    }
    func diaperLogEntry(count: Int) -> String { s("Diaper #\(count) · wet", "Подгузник #\(count) · мокрый", "Windel #\(count) · nass", "Pañal #\(count) · mojado", "Couche #\(count) · mouillée", "Fralda #\(count) · molhada") }
    func feedingLogEntry(dur: Int, side: String) -> String { s("Feeding · \(dur) min · \(side)", "Кормление · \(dur) мин · \(side)", "Fütterung · \(dur) min · \(side)", "Toma · \(dur) min · \(side)", "Tétée · \(dur) min · \(side)", "Mamada · \(dur) min · \(side)") }
    func sleepLogEntry(dur: String) -> String { s("Sleep · \(dur)", "Сон · \(dur)", "Schlaf · \(dur)", "Sueño · \(dur)", "Sommeil · \(dur)", "Sono · \(dur)") }
    func todayEntry(_ date: String) -> String { s("Today · \(date)", "Сегодня · \(date)", "Heute · \(date)", "Hoy · \(date)", "Aujourd’hui · \(date)", "Hoje · \(date)") }
    func yesterdayEntry(_ date: String) -> String { s("Yesterday · \(date)", "Вчера · \(date)", "Gestern · \(date)", "Ayer · \(date)", "Hier · \(date)", "Ontem · \(date)") }

    // MARK: — Tabs / Sections
    var tabHome: String     { s("Home",     "Главная",   "Startseite", "Inicio", "Accueil", "Início") }
    var tabSleep: String    { s("Sleep",    "Сон",       "Schlaf",     "Sueño",  "Sommeil", "Sono") }
    var tabFeeding: String  { s("Feeding",  "Кормление", "Füttern",    "Tomas",  "Tétées",  "Mamadas") }
    var tabSounds: String   { s("Sounds",   "Звуки",     "Töne",       "Sonidos","Sons",    "Sons") }
    var tabDiary: String    { s("Diary",    "Дневник",   "Tagebuch",   "Diario", "Journal", "Diário") }
    var tabLeaps: String    { s("Leaps",    "Скачки",    "Schübe",     "Saltos", "Bonds",   "Saltos") }
    var tabReport: String   { s("Report",   "Отчёт",     "Bericht",    "Informe","Rapport", "Relatório") }
    var tabTracking: String { s("Tracking", "Показатели","Messung",    "Medidas","Mesures", "Medições") }
    var tabSharing: String  { s("Family",   "Семья",     "Familie",    "Familia","Famille", "Família") }

    // MARK: — Greetings
    var goodNight: String       { s("Good night,",     "Доброй ночи,",  "Gute Nacht,",  "Buenas noches,", "Bonne nuit,", "Boa noite,") }
    var goodMorning: String     { s("Good morning",    "Доброе утро",   "Guten Morgen", "Buenos días",    "Bonjour", "Bom dia") }
    var goodAfternoon: String   { s("Good afternoon",  "Добрый день",   "Guten Tag",    "Buenas tardes",  "Bon après-midi", "Boa tarde") }
    var goodEvening: String     { s("Good evening",    "Добрый вечер",  "Guten Abend",  "Buenas tardes",  "Bonsoir", "Boa noite") }
    var goodMorningGreeting: String   { s("Good morning,",   "Доброе утро,",   "Guten Morgen,", "Buenos días,",   "Bonjour,", "Bom dia,") }
    var goodAfternoonGreeting: String { s("Good afternoon,", "Добрый день,",   "Guten Tag,",    "Buenas tardes,", "Bon après-midi,", "Boa tarde,") }
    var goodEveningGreeting: String   { s("Good evening,",   "Добрый вечер,",  "Guten Abend,",  "Buenas noches,", "Bonsoir,", "Boa noite,") }

    // MARK: — Today / Home
    var baby: String         { s("Baby",         "Малыш",        "Baby",         "Bebé",     "Bébé", "Bebé") }
    var logEntry: String     { s("Log",          "Журнал",       "Tagebuch",     "Registro", "Journal", "Registo") }
    var quickLog: String     { s("Quick Log",    "Быстрый лог",  "Schnellnotiz", "Registro rápido", "Saisie rapide", "Registo rápido") }
    var quickLogLabel: String{ s("Quick log",    "Быстро записать", "Schnell erfassen", "Registrar rápido", "Saisie rapide", "Registar rápido") }
    var feeding: String      { s("Feeding",      "Кормление",    "Fütterung",    "Toma",     "Tétée", "Mamada") }
    var sleep: String        { s("Sleep",        "Сон",          "Schlaf",       "Sueño",    "Sommeil", "Sono") }
    var diaper: String       { s("Diaper",       "Подгузник",    "Windel",       "Pañal",    "Couche", "Fralda") }
    var diaperQuick: String  { s("Diaper",       "Памп",         "Windel",       "Pañal",    "Couche", "Fralda") }
    var diapers: String      { s("Diapers",      "Подгузники",   "Windeln",      "Pañales",  "Couches", "Fraldas") }
    var diary: String        { s("Diary",        "Дневник",      "Tagebuch",     "Diario",   "Journal", "Diário") }
    var symptom: String      { s("Symptom",      "Симптом",      "Symptom",      "Síntoma",  "Symptôme", "Sintoma") }
    var walk: String         { s("Walk",         "Прогулка",     "Spaziergang",  "Paseo",    "Promenade", "Passeio") }
    var bath: String         { s("Bath",         "Купание",      "Bad",          "Baño",     "Bain", "Banho") }
    var vitamins: String     { s("Vitamins",     "Витамины",     "Vitamine",     "Vitaminas","Vitamines", "Vitaminas") }
    var stoolLabel: String     { s("Stool",           "Стул",                  "Stuhlgang",        "Deposición", "Selles", "Fezes") }
    var stoolLogged: String    { s("Stool · logged",  "Стул · записан",        "Stuhlgang · notiert", "Deposición · registrada", "Selles · enregistrées", "Fezes · registadas") }
    var addStoolTitle: String  { s("Add Entry",       "Новая запись",          "Eintrag",          "Nueva entrada", "Nouvelle entrée", "Novo registo") }
    var stoolTimeLabel: String { s("Time",            "Время",                 "Zeit",             "Hora",       "Heure", "Hora") }
    var walkLogged: String   { s("Walk · logged",    "Прогулка · записана",   "Spaziergang · erfasst", "Paseo · registrado", "Promenade · enregistrée", "Passeio · registado") }
    var bathLogged: String   { s("Bath · logged",    "Купание · записано",    "Bad · erfasst",    "Baño · registrado", "Bain · enregistré", "Banho · registado") }
    var vitaminsGiven: String { s("Vitamins · given","Витамины · приняты",    "Vitamine · gegeben","Vitaminas · dadas", "Vitamines · données", "Vitaminas · dadas") }
    var vitaminNamePlaceholder: String { s("e.g. Vitamin D", "напр. Витамин D",     "z.B. Vitamin D",   "p. ej. Vitamina D", "p. ex. Vitamine D", "ex.: Vitamina D") }
    var todaysVitamins: String         { s("Today's vitamins","Витамины сегодня",    "Vitamine heute",   "Vitaminas de hoy", "Vitamines du jour", "Vitaminas de hoje") }
    var noVitaminsYet: String          { s("No vitamins added yet","Витамины ещё не добавлены","Noch keine Vitamine","Aún sin vitaminas", "Aucune vitamine ajoutée", "Ainda sem vitaminas") }
    var vitaminNameLabel: String       { s("VITAMIN NAME", "НАЗВАНИЕ ВИТАМИНА",    "VITAMINNAME",      "NOMBRE DE LA VITAMINA", "NOM DE LA VITAMINE", "NOME DA VITAMINA") }
    func vitaminAdded(name: String) -> String { s("Vitamins · \(name)", "Витамины · \(name)", "Vitamine · \(name)", "Vitaminas · \(name)", "Vitamines · \(name)", "Vitaminas · \(name)") }
    var walkTracker: String  { s("WALK TRACKER",    "ТРЕКЕР ПРОГУЛКИ",       "GEHTRACKER",       "REGISTRO DE PASEO", "SUIVI DE PROMENADE", "REGISTO DE PASSEIO") }
    var walking: String      { s("walking…",        "гуляем…",               "gehen…",           "paseando…", "en promenade…", "a passear…") }
    var startWalk: String    { s("Start Walk",      "Начать прогулку",       "Spaziergang starten", "Empezar paseo", "Démarrer la promenade", "Iniciar passeio") }
    var stopWalk: String     { s("Stop Walk",       "Закончить прогулку",    "Spaziergang stoppen", "Terminar paseo", "Terminer la promenade", "Terminar passeio") }
    var addWalkTitle: String { s("Add Walk",        "Добавить прогулку",     "Spaziergang erfassen", "Añadir paseo", "Ajouter une promenade", "Adicionar passeio") }
    var noWalkYet: String    { s("no walk yet",     "ещё не гуляли",         "noch nicht spaziert", "aún sin paseo", "pas encore de promenade", "ainda sem passeio") }
    func walkLogEntry(dur: Int) -> String { s("Walk · \(dur) min", "Прогулка · \(dur) мин", "Spaziergang · \(dur) min", "Paseo · \(dur) min", "Promenade · \(dur) min", "Passeio · \(dur) min") }
    var bathTracker: String  { s("BATH TRACKER",     "ТРЕКЕР КУПАНИЯ",        "BADTRACKER",       "REGISTRO DE BAÑO", "SUIVI DU BAIN", "REGISTO DE BANHO") }
    var bathing: String      { s("bathing…",         "купаемся…",             "Baden…",           "bañando…", "au bain…", "a tomar banho…") }
    var startBath: String    { s("Start Bath",       "Начать купание",        "Bad starten",      "Empezar baño", "Démarrer le bain", "Iniciar banho") }
    var stopBath: String     { s("Stop Bath",        "Закончить купание",     "Bad stoppen",      "Terminar baño", "Terminer le bain", "Terminar banho") }
    var noBathYet: String    { s("no bath yet",      "ещё не купались",       "noch nicht gebadet", "aún sin baño", "pas encore de bain", "ainda sem banho") }
    var addBathTitle: String { s("Add Bath",         "Добавить купание",      "Bad erfassen",     "Añadir baño", "Ajouter un bain", "Adicionar banho") }
    func bathLogEntry(dur: Int) -> String { s("Bath · \(dur) min", "Купание · \(dur) мин", "Bad · \(dur) min", "Baño · \(dur) min", "Bain · \(dur) min", "Banho · \(dur) min") }

    var pumping: String         { s("Pumping",          "Сцеживание",          "Pumpen",      "Extracción", "Tire-lait", "Extração") }
    var pumpingSideLabel: String { s("SIDE",            "СТОРОНА",             "SEITE",       "LADO",       "CÔTÉ", "LADO") }
    var pumpingLeft: String     { s("Left",             "Левая",               "Links",       "Izquierdo",  "Gauche", "Esquerdo") }
    var pumpingRight: String    { s("Right",            "Правая",              "Rechts",      "Derecho",    "Droite", "Direito") }
    var pumpingBoth: String     { s("Both",             "Обе",                 "Beide",       "Ambos",      "Les deux", "Ambos") }
    var pumpingVolume: String   { s("VOLUME (ML)",      "ОБЪЁМ (МЛ)",          "MENGE (ML)",  "VOLUMEN (ML)","VOLUME (ML)", "VOLUME (ML)") }
    var pumpingStart: String    { s("Start",            "Начать",              "Starten",     "Empezar",    "Démarrer", "Iniciar") }
    var pumpingStop: String     { s("Done",             "Готово",              "Fertig",      "Hecho",      "Terminé", "Concluído") }
    var noPumpingYet: String    { s("No pumping today", "Сцеживаний ещё нет",  "Noch kein Pumpen", "Sin extracción hoy", "Aucun tirage aujourd’hui", "Sem extração hoje") }
    var pumpingTracker: String  { s("PUMPING TRACKER",  "ТРЕКЕР СЦЕЖИВАНИЯ",   "PUMPEN-TRACKER", "REGISTRO DE EXTRACCIÓN", "SUIVI DU TIRE-LAIT", "REGISTO DE EXTRAÇÃO") }
    func pumpingLogEntry(dur: Int, ml: Int) -> String {
        ml > 0
            ? s("Pumping · \(dur) min · \(ml) ml",   "Сцеживание · \(dur) мин · \(ml) мл",   "Pumpen · \(dur) min · \(ml) ml",   "Extracción · \(dur) min · \(ml) ml",   "Tire-lait · \(dur) min · \(ml) ml",   "Extração · \(dur) min · \(ml) ml")
            : s("Pumping · \(dur) min",               "Сцеживание · \(dur) мин",               "Pumpen · \(dur) min",              "Extracción · \(dur) min",              "Tire-lait · \(dur) min",              "Extração · \(dur) min")
    }

    var mood: String         { s("Mood",         "Настроение",   "Stimmung",     "Ánimo",   "Humeur", "Humor") }
    var feedLabel: String    { s("Feed",         "Еда",          "Essen",        "Comida",  "Repas", "Refeição") }
    var sleeping: String     { s("sleeping…",    "спит…",        "schläft…",     "durmiendo…", "dort…", "a dormir…") }
    var feedingLabel: String { s("FEEDING",      "КОРМЛЕНИЕ",    "FÜTTERUNG",    "TOMA",    "TÉTÉE", "MAMADA") }
    var typicalLengthHint: String { s("Typical length — 18 min. Tap pause or stop.", "Обычная длина — 18 мин. Нажмите паузу или стоп.", "Typische Länge — 18 Min. Pause oder Stop tippen.", "Duración típica — 18 min. Pulsa pausa o parar.", "Durée typique — 18 min. Touchez pause ou stop.", "Duração típica — 18 min. Toque em pausa ou parar.") }
    var usuallyAroundThisTime: String { s("Usually around this time — tap to start.", "Обычно в это время — нажмите для старта.", "Normalerweise um diese Zeit — zum Starten tippen.", "Suele ser a esta hora — pulsa para empezar.", "Habituellement à cette heure — touchez pour démarrer.", "Normalmente a esta hora — toque para iniciar.") }
    var tipOfDay: String     { s("Tip of the day",   "Подсказка дня",      "Tipp des Tages", "Consejo del día", "Conseil du jour", "Dica do dia") }
    var todaySoFar: String   { s("Today so far",     "Сегодня уже было",   "Heute bisher",   "Hoy hasta ahora", "Aujourd’hui jusqu’ici", "Hoje até agora") }
    var todayUpper: String   { s("TODAY",            "СЕГОДНЯ",            "HEUTE",          "HOY",     "AUJOURD’HUI", "HOJE") }
    func leapPill(_ n: Int) -> String { s("Leap #\(n)", "Скачок №\(n)", "Schub #\(n)", "Salto n.º \(n)", "Bond n° \(n)", "Salto n.º \(n)") }
    func leapDayCard(n: Int, day: Int, total: Int) -> String { s("LEAP #\(n) · DAY \(day) OF ~\(total)", "СКАЧОК №\(n) · ДЕНЬ \(day) ИЗ ~\(total)", "SCHUB #\(n) · TAG \(day) VON ~\(total)", "SALTO N.º \(n) · DÍA \(day) DE ~\(total)", "BOND N° \(n) · JOUR \(day) SUR ~\(total)", "SALTO N.º \(n) · DIA \(day) DE ~\(total)") }
    func leapNumberCard(_ n: Int) -> String { s("LEAP #\(n)", "СКАЧОК №\(n)", "SCHUB #\(n)", "SALTO N.º \(n)", "BOND N° \(n)", "SALTO N.º \(n)") }
    func leapNormalLabel(name: String) -> String { s("«\(name)» — this is normal", "«\(name)» — это нормально", "«\(name)» — das ist normal", "«\(name)» — es normal", "«\(name)» — c’est normal", "«\(name)» — é normal") }
    var leapCryingNote: String { s("Crying, poor sleep, wants to be held. Not sick — growing.", "Плачет, плохо спит, просит руки. Он не болен — он растёт.", "Weint, schläft schlecht, will gehalten werden. Nicht krank — wächst.", "Llora, duerme mal, quiere brazos. No está enfermo — está creciendo.", "Pleure, dort mal, réclame les bras. Pas malade — il grandit.", "Chora, dorme mal, quer colo. Não está doente — está a crescer.") }
    var leapSettledNote: String { s("The hard part has passed — practicing new skills.", "Самое сложное позади — осваивает новые навыки.", "Das Schwerste ist vorbei — übt neue Fähigkeiten.", "Lo más difícil ya pasó — practica nuevas habilidades.", "Le plus dur est passé — il s’exerce à de nouvelles compétences.", "A parte mais difícil passou — está a praticar novas competências.") }

    func howDidSleep(name: String) -> String { s("how did \(name) sleep?", "как \(name) спал?", "wie hat \(name) geschlafen?", "¿cómo durmió \(name)?", "comment \(name) a-t-il dormi ?", "como dormiu \(name)?") }
    func feedingActiveLabel(side: String) -> String { s("active · \(side)", "идёт · \(side)", "aktiv · \(side)", "activo · \(side)", "en cours · \(side)", "a decorrer · \(side)") }
    func feedingDuration(_ time: String) -> String { s("Feeding has been going for \(time). Typical length is 18 min.", "Кормление идёт уже \(time). Обычная длина — 18 мин.", "Fütterung dauert seit \(time). Typische Länge 18 Min.", "La toma lleva \(time). La duración típica es 18 min.", "La tétée dure depuis \(time). La durée typique est de 18 min.", "A mamada já dura \(time). A duração típica é de 18 min.") }
    func feedingTip(ago: String, name: String) -> String { s("\(ago) since last feeding — \(name) usually eats now. If crying — try breast first.", "Прошло \(ago) с прошлого кормления — обычно \(name) ест в это время. Если плачет — попробуйте сначала грудь.", "\(ago) seit der letzten Fütterung — \(name) isst normalerweise jetzt.", "\(ago) desde la última toma — \(name) suele comer ahora. Si llora, prueba primero el pecho.", "\(ago) depuis la dernière tétée — \(name) mange habituellement maintenant. S’il pleure, proposez d’abord le sein.", "\(ago) desde a última mamada — \(name) costuma comer agora. Se chorar, ofereça primeiro o peito.") }
    func leapContrastsTip(name: String) -> String { s("During this leap \(name) is especially drawn to contrasts — show a black-and-white book.", "В этот скачок \(name) особенно интересны контрасты — покажите чёрно-белую книжку.", "In diesem Schub ist \(name) besonders von Kontrasten angezogen.", "Durante este salto a \(name) le atraen los contrastes — muéstrale un libro en blanco y negro.", "Pendant ce bond, \(name) est particulièrement attiré par les contrastes — montrez-lui un livre en noir et blanc.", "Durante este salto, \(name) sente-se especialmente atraído por contrastes — mostre um livro a preto e branco.") }
    func diaperCountDay(_ n: Int) -> String { s("\(n) / day", "\(n) / день", "\(n) / Tag", "\(n) / día", "\(n) / jour", "\(n) / dia") }
    func entriesCount(_ n: Int) -> String { s("\(n) entries", "\(n) записей", "\(n) Einträge", "\(n) entradas", "\(n) entrées", "\(n) registos") }
    var noEntriesYet: String { s("Nothing logged yet today", "Ещё ничего не записано", "Noch nichts eingetragen", "Nada registrado hoy aún", "Rien d’enregistré aujourd’hui", "Ainda nada registado hoje") }

    // MARK: — Feeding
    var feedingLeft: String   { s("Left",   "Левая",   "Links",   "Izquierdo", "Gauche", "Esquerdo") }
    var feedingRight: String  { s("Right",  "Правая",  "Rechts",  "Derecho",   "Droite", "Direito") }
    var feedingBottle: String { s("Bottle", "Бутылка", "Flasche", "Biberón",   "Biberon", "Biberão") }
    var typicalDuration: String { s("of ≈ 18 min typical", "из ≈ 18 мин обычно", "von ≈ 18 min üblich", "de ≈ 18 min típicos", "sur ≈ 18 min en moyenne", "de ≈ 18 min típicos") }
    var pause: String         { s("‖ Pause",     "‖ Пауза",      "‖ Pause",      "‖ Pausa",   "‖ Pause", "‖ Pausa") }
    var resume: String        { s("▶ Resume",    "▶ Продолжить", "▶ Fortsetzen", "▶ Reanudar","▶ Reprendre", "▶ Retomar") }
    var stopDone: String      { s("■ Done",      "■ Закончить",  "■ Fertig",     "■ Terminar","■ Terminer", "■ Concluir") }
    var feedings: String      { s("feedings",    "кормлений",    "Mahlzeiten",   "tomas",     "tétées", "mamadas") }
    var tapTagMood: String    { s("tap a tag to add a mood note", "нажмите тег для записи настроения", "Tag antippen für Stimmungsnotiz", "pulsa una etiqueta para añadir una nota de ánimo", "touchez une étiquette pour ajouter une note d’humeur", "toque numa etiqueta para adicionar uma nota de humor") }
    var moodCalm: String      { s("😊 calm",        "😊 спокоен",    "😊 ruhig",        "😊 tranquilo", "😊 calme", "😊 calmo") }
    var moodAsleep: String    { s("😴 fell asleep",  "😴 уснул",      "😴 eingeschlafen", "😴 se durmió", "😴 endormi", "😴 adormeceu") }
    var moodSpitUp: String    { s("🤢 spit up",      "🤢 срыгнул",    "🤢 gespuckt",     "🤢 regurgitó", "🤢 régurgité", "🤢 regurgitou") }
    var customTag: String     { s("+ custom",       "+ свой",        "+ eigenes",       "+ personalizado", "+ personnalisé", "+ personalizado") }
    var cancelTag: String     { s("✕ cancel",       "✕ отмена",      "✕ abbrechen",     "✕ cancelar", "✕ annuler", "✕ cancelar") }
    var customMoodPlaceholder: String { s("e.g. cried a bit, then calmed", "напр. немного поплакал, успокоился", "z.B. kurz geweint, dann ruhig", "p. ej. lloró un poco y se calmó", "p. ex. a un peu pleuré, puis s’est calmé", "ex.: chorou um pouco e acalmou") }
    var feedingsToday: String { s("feedings today", "кормлений сегодня", "Mahlzeiten heute", "tomas hoy", "tétées aujourd’hui", "mamadas hoje") }
    var mlUnit: String        { s("ml", "мл", "ml", "ml", "ml", "ml") }
    var bottleVolume: String  { s("VOLUME", "ОБЪЁМ", "MENGE", "VOLUMEN", "VOLUME", "VOLUME") }

    func feedingsCount(_ n: Int) -> String { s("\(n) feedings", "\(n) кормлений", "\(n) Mahlzeiten", "\(n) tomas", "\(n) tétées", "\(n) mamadas") }
    var addFeedingTitle: String      { s("Add Feeding",     "Добавить кормление",  "Fütterung eintragen", "Añadir toma", "Ajouter une tétée", "Adicionar mamada") }
    var feedingStartedLabel: String  { s("STARTED",        "НАЧАЛО",              "BEGINN",     "INICIO",  "DÉBUT", "INÍCIO") }
    var feedingEndedLabel: String    { s("ENDED",          "КОНЕЦ",               "ENDE",       "FIN",     "FIN", "FIM") }
    var feedingSideLabel: String     { s("SIDE",           "СТОРОНА",             "SEITE",      "LADO",    "CÔTÉ", "LADO") }
    var enterManuallyLabel: String   { s("enter manually", "ввести вручную",      "manuell eingeben", "introducir manual", "saisir manuellement", "introduzir manualmente") }
    var addPumpingTitle: String      { s("Add Pumping",    "Добавить сцеживание", "Pumpen eintragen", "Añadir extracción", "Ajouter un tirage", "Adicionar extração") }
    var pumpingTypicalDuration: String { s("of ≈ 20 min typical", "из ≈ 20 мин обычно", "von ≈ 20 min üblich", "de ≈ 20 min típicos", "sur ≈ 20 min en moyenne", "de ≈ 20 min típicos") }

    // MARK: — Sleep
    var sleepStart: String   { s("Start sleep",   "Начать сон",    "Schlaf starten", "Empezar sueño", "Démarrer le sommeil", "Iniciar sono") }
    var sleepStop: String    { s("Wake up",        "Проснулся",     "Aufwachen",     "Despertar",     "Réveil", "Acordar") }
    var stopSleep: String    { s("Stop Sleep",     "Остановить сон","Schlaf stoppen", "Parar sueño",  "Arrêter le sommeil", "Parar sono") }
    var sleepDuration: String { s("Duration",      "Длительность",  "Dauer",         "Duración",      "Durée", "Duração") }
    var asleep: String       { s("Asleep",         "Спит",          "Schläft",       "Dormido",       "Endormi", "A dormir") }
    var awake: String        { s("Awake",          "Проснулся",     "Wach",          "Despierto",     "Éveillé", "Acordado") }
    var sleepTracker: String { s("SLEEP TRACKER",  "ТРЕКЕР СНА",    "SCHLAFTRACKER", "REGISTRO DE SUEÑO", "SUIVI DU SOMMEIL", "REGISTO DO SONO") }
    var totalToday: String   { s("Total today",    "Всего сегодня", "Heute gesamt",  "Total hoy",     "Total aujourd’hui", "Total hoje") }
    var sessions: String     { s("Sessions",       "Сессий",        "Sitzungen",     "Sesiones",      "Sessions", "Sessões") }
    var sleepQuality: String { s("SLEEP QUALITY",  "КАЧЕСТВО СНА",  "SCHLAFQUALITÄT", "CALIDAD DEL SUEÑO", "QUALITÉ DU SOMMEIL", "QUALIDADE DO SONO") }
    var qualityGood: String    { s("😌 Good",      "😌 Хорошо",     "😌 Gut",        "😌 Bueno",   "😌 Bon", "😌 Bom") }
    var qualityNormal: String  { s("😐 Normal",    "😐 Нормально",  "😐 Normal",     "😐 Normal",  "😐 Normal", "😐 Normal") }
    var qualityRestless: String{ s("😣 Restless",  "😣 Беспокойно", "😣 Unruhig",    "😣 Inquieto","😣 Agité", "😣 Agitado") }

    // MARK: — Sleep forecast
    var sleepForecastNapTitle: String {
        s("Next sleep", "Следующий сон", "Nächster Schlaf", "Próximo sueño", "Prochain sommeil", "Próximo sono")
    }
    var sleepForecastBedtimeTitle: String {
        s("Time for bedtime", "Пора укладывать на ночь", "Zeit fürs Schlafengehen",
          "Hora de dormir", "L’heure du coucher", "Hora de deitar")
    }
    func sleepForecastRange(_ start: String, _ end: String) -> String {
        s("Window \(start)–\(end)", "Окно \(start)–\(end)", "Fenster \(start)–\(end)",
          "Ventana \(start)–\(end)", "Fenêtre \(start)–\(end)", "Janela \(start)–\(end)")
    }
    var sleepForecastConfidenceLow: String {
        s("Low confidence", "Низкая точность", "Geringe Sicherheit",
          "Confianza baja", "Confiance faible", "Confiança baixa")
    }
    var sleepForecastConfidenceMedium: String {
        s("Medium confidence", "Средняя точность", "Mittlere Sicherheit",
          "Confianza media", "Confiance moyenne", "Confiança média")
    }
    var sleepForecastConfidenceHigh: String {
        s("High confidence", "Высокая точность", "Hohe Sicherheit",
          "Confianza alta", "Confiance élevée", "Confiança alta")
    }
    var sleepForecastBasisAge: String {
        s("by age", "по возрасту", "nach Alter", "por edad", "selon l’âge", "por idade")
    }
    var sleepForecastBasisPersonalized: String {
        s("from your data", "по вашим данным", "aus deinen Daten",
          "según tus datos", "d’après vos données", "com base nos seus dados")
    }
    var sleepForecastOverdueTitle: String {
        s("Sleep overdue", "Окно сна пропущено", "Schlaf überfällig",
          "Sueño atrasado", "Sommeil en retard", "Sono atrasado")
    }
    var sleepForecastOverdueAction: String {
        s("Settle now", "Уложить сейчас", "Jetzt hinlegen",
          "Acostar ya", "Coucher maintenant", "Deitar agora")
    }
    func sleepForecastAwakeFor(_ dur: String) -> String {
        s("awake \(dur)", "бодрствует \(dur)", "wach seit \(dur)",
          "despierto \(dur)", "éveillé depuis \(dur)", "acordado há \(dur)")
    }
    var sleepForecastOverduePill: String {
        s("overdue", "просрочено", "überfällig", "atrasado", "en retard", "atrasado")
    }

    var feedingChartTitle: String  { s("Feeding",          "Кормление",             "Stillen",        "Tomas",   "Tétées", "Mamadas") }
    var feedingPeriodWeek: String  { s("7 days",           "7 дней",                "7 Tage",         "7 días",  "7 jours", "7 dias") }
    var feedingPeriodMonth: String { s("30 days",          "30 дней",               "30 Tage",        "30 días", "30 jours", "30 dias") }
    var feedingAvgPerDay: String   { s("avg/day",          "ср/день",               "Ø/Tag",          "med/día", "moy/jour", "méd/dia") }
    var feedingTotalSessions: String { s("total",          "всего",                 "gesamt",         "total",   "total", "total") }
    var feedingAvgDuration: String { s("avg dur.",         "ср. длит.",             "Ø Dauer",        "dur. med.", "durée moy.", "dur. méd.") }
    var feedingNoData: String      { s("No data for period", "Нет данных за период", "Keine Daten",   "Sin datos del periodo", "Aucune donnée pour la période", "Sem dados para o período") }

    var sleepChartTitle: String  { s("Sleep chart",   "График сна",    "Schlafdiagramm", "Gráfico de sueño", "Graphique du sommeil", "Gráfico do sono") }
    var sleepPeriodWeek: String  { s("7 days",        "7 дней",        "7 Tage",         "7 días",  "7 jours", "7 dias") }
    var sleepPeriodMonth: String { s("30 days",       "30 дней",       "30 Tage",        "30 días", "30 jours", "30 dias") }
    var sleepAverage: String     { s("Average",       "Среднее",       "Durchschn.",     "Media",   "Moyenne", "Média") }
    var sleepNormLabel: String   { s("Norm",          "Норма",         "Norm",           "Norma",   "Norme", "Norma") }
    var sleepInNorm: String      { s("In norm",       "В норме",       "In Norm",        "En la norma", "Dans la norme", "Dentro da norma") }
    var sleepBelowNorm: String   { s("Below norm",    "Ниже нормы",    "Unter Norm",     "Bajo la norma", "Sous la norme", "Abaixo da norma") }
    var sleepAboveNorm: String   { s("Above norm",    "Выше нормы",    "Über Norm",      "Sobre la norma", "Au-dessus de la norme", "Acima da norma") }
    var sleepNoData: String      { s("No sleep data yet", "Данных о сне пока нет", "Noch keine Schlafdaten", "Aún sin datos de sueño", "Pas encore de données de sommeil", "Ainda sem dados de sono") }
    var addSleepTitle: String    { s("Add Sleep",          "Добавить сон",           "Schlaf eintragen", "Añadir sueño", "Ajouter un sommeil", "Adicionar sono") }

    // MARK: — Diaper
    var diaperWet: String   { s("Wet",    "Мокрый",  "Nass",      "Mojado", "Mouillée", "Molhada") }
    var diaperDirty: String { s("Dirty",  "Грязный", "Schmutzig", "Sucio",  "Sale", "Suja") }
    var diaperChange: String{ s("Change", "Смена",   "Wechsel",   "Cambio", "Change", "Muda") }
    var diaperCount: String { s("changes today", "смен сегодня", "Wechsel heute", "cambios hoy", "changes aujourd’hui", "mudas hoje") }

    // MARK: — Diary
    var addNote: String     { s("Add note",      "Добавить заметку", "Notiz hinzufügen", "Añadir nota", "Ajouter une note", "Adicionar nota") }
    var addPhoto: String    { s("Add photo",     "Добавить фото",    "Foto hinzufügen",  "Añadir foto", "Ajouter une photo", "Adicionar foto") }
    var milestone: String   { s("Milestone",     "Веха",             "Meilenstein",      "Hito",   "Étape", "Marco") }
    var milestones: String  { s("Milestones",    "Вехи",             "Meilensteine",     "Hitos",  "Étapes", "Marcos") }
    var feed: String        { s("Feed",          "Лента",            "Feed",             "Muro",   "Fil", "Feed") }
    var empty: String       { s("Empty",         "Пусто",            "Leer",             "Vacío",  "Vide", "Vazio") }
    var diaryEmptyHint: String { s("Nothing in this category yet.\nAdd the first — tap +", "В этой категории пока нет записей.\nДобавьте первую — нажмите +", "Noch nichts hier.\nAuf + tippen", "Aún no hay nada en esta categoría.\nAñade la primera — pulsa +", "Rien dans cette catégorie pour l’instant.\nAjoutez la première — touchez +", "Ainda nada nesta categoria.\nAdicione a primeira — toque em +") }
    var filterPhoto: String { s("📷 Photo",      "📷 Фото",          "📷 Foto",          "📷 Foto", "📷 Photo", "📷 Foto") }
    var filterNotes: String { s("✎ Notes",       "✎ Заметки",        "✎ Notizen",        "✎ Notas", "✎ Notes", "✎ Notas") }
    var diaryQuote: String  { s("A year from now you'll open this and smile ✿", "через год вы откроете это и будете улыбаться ✿", "In einem Jahr wirst du das öffnen und lächeln ✿", "Dentro de un año abrirás esto y sonreirás ✿", "Dans un an, vous ouvrirez ceci et sourirez ✿", "Daqui a um ano vai abrir isto e sorrir ✿") }
    var babyPhotoLabel: String { s("baby's photo", "фото малыша",    "Babyfoto",         "foto del bebé", "photo du bébé", "foto do bebé") }
    var entryType: String   { s("Type",          "Тип",              "Typ",              "Tipo",   "Type", "Tipo") }
    var addToDiary: String  { s("Add to Diary",  "Добавить в дневник","Zum Tagebuch",    "Añadir al diario", "Ajouter au journal", "Adicionar ao diário") }
    var newEntry: String    { s("New Entry",     "Новая запись",     "Neuer Eintrag",    "Nueva entrada", "Nouvelle entrée", "Novo registo") }
    var whatToWrite: String { s("WHAT DO YOU WANT TO WRITE?", "ЧТО ХОТИТЕ ЗАПИСАТЬ?", "WAS MÖCHTEN SIE SCHREIBEN?", "¿QUÉ QUIERES ESCRIBIR?", "QUE VOULEZ-VOUS ÉCRIRE ?", "O QUE QUER ESCREVER?") }
    var noteExamplePlaceholder: String { s("E.g. Laughed out loud for the first time!", "Например: «Впервые засмеялся в голос!»", "Z.B. Zum ersten Mal laut gelacht!", "P. ej. ¡Se rió a carcajadas por primera vez!", "P. ex. A éclaté de rire pour la première fois !", "Ex.: Riu-se alto pela primeira vez!") }
    var chooseIcon: String  { s("CHOOSE ICON",   "ВЫБЕРИТЕ ИКОНКУ",  "SYMBOL WÄHLEN",    "ELIGE UN ICONO", "CHOISIR UNE ICÔNE", "ESCOLHER ÍCONE") }
    var orWriteYourOwn: String { s("OR WRITE YOUR OWN", "ИЛИ НАПИШИТЕ СВОЁ", "ODER EIGENES SCHREIBEN", "O ESCRIBE EL TUYO", "OU ÉCRIVEZ LE VÔTRE", "OU ESCREVA O SEU") }
    var milestoneExamplePlaceholder: String { s("E.g. First roll-over", "Например: «Первый переворот»", "Z.B. Erste Drehung", "P. ej. Primera vuelta", "P. ex. Premier retournement", "Ex.: Primeira vez que se virou") }
    var choosePhoto: String { s("CHOOSE PHOTO",  "ВЫБЕРИТЕ ФОТО",    "FOTO WÄHLEN",      "ELIGE UNA FOTO", "CHOISIR UNE PHOTO", "ESCOLHER FOTO") }
    var tapToChoose: String { s("Tap to choose", "Нажмите, чтобы выбрать", "Zum Auswählen tippen", "Pulsa para elegir", "Touchez pour choisir", "Toque para escolher") }
    var placeholderColor: String { s("Placeholder color:", "Цвет плейсхолдера:", "Platzhalterfarbe:", "Color del marcador:", "Couleur de l’espace réservé :", "Cor do marcador:") }
    var captionHandwriting: String { s("CAPTION (handwriting style)", "ПОДПИСЬ (рукописный стиль)", "BILDUNTERSCHRIFT (Handschrift)", "TEXTO (estilo manuscrito)", "LÉGENDE (style manuscrit)", "LEGENDA (estilo manuscrito)") }
    var captionExamplePlaceholder: String { s("E.g. first laugh", "Например: «первый смех»", "Z.B. erstes Lachen", "P. ej. primera risa", "P. ex. premier rire", "Ex.: primeiro riso") }
    var moment: String      { s("moment",        "момент",           "Moment",           "momento", "moment", "momento") }
    var toDiary: String     { s("To diary",      "В дневник",        "Zum Tagebuch",     "Al diario", "Au journal", "Ao diário") }

    func diaryTitle(name: String) -> String { s("\(name)'s Diary", "Дневник \(name)", "Tagebuch von \(name)", "Diario de \(name)", "Journal de \(name)", "Diário de \(name)") }

    // MARK: — Leaps
    var leaps: String           { s("Leaps",             "Скачки развития",  "Entwicklungsschübe", "Saltos", "Bonds", "Saltos") }
    var developmentalLeaps: String { s("Developmental Leaps", "Скачки развития", "Entwicklungsschübe", "Saltos del desarrollo", "Bonds de développement", "Saltos de desenvolvimento") }
    var leapWeeks: String       { s("weeks",             "недель",           "Wochen",          "semanas", "semaines", "semanas") }
    var leapCompleted: String   { s("Completed",         "Завершён",         "Abgeschlossen",   "Completado", "Terminé", "Concluído") }
    var leapInProgress: String  { s("In progress",       "В процессе",       "Im Gange",        "En curso", "En cours", "Em curso") }
    var leapUpcoming: String    { s("Upcoming",          "Предстоит",        "Bevorstehend",    "Próximo", "À venir", "A chegar") }
    var markDone: String        { s("Mark complete",     "Отметить",         "Abschließen",     "Marcar hecho", "Marquer terminé", "Marcar concluído") }
    var hangInThere: String     { s("hang in there, mama ✿", "держитесь, мама ✿", "Haltet durch, Mama ✿", "ánimo, mamá ✿", "courage, maman ✿", "força, mamã ✿") }
    var leapSettled: String     { s("calmer days now — new skills emerging ✿", "сейчас спокойнее — появляются новые навыки ✿", "ruhigere Tage — neue Fähigkeiten zeigen sich ✿", "días más tranquilos — surgen nuevas habilidades ✿", "des jours plus calmes — de nouvelles compétences apparaissent ✿", "dias mais calmos agora — surgem novas competências ✿") }
    var whatYouNotice: String   { s("WHAT YOU NOTICE",   "ЧТО ЗАМЕТНО",      "WAS SIE BEMERKEN", "LO QUE NOTAS", "CE QUE VOUS REMARQUEZ", "O QUE NOTA") }
    var comingSoon: String      { s("COMING SOON",       "СКОРО НАУЧИТСЯ",   "KOMMT BALD",      "PRONTO", "BIENTÔT", "EM BREVE") }
    /// Approximate duration in weeks, pluralized per language. `days` rounds to weeks (min 1).
    private func weeksApprox(days: Int) -> String {
        let w = max(1, Int((Double(days) / 7.0).rounded()))
        let ru: String = {
            let n = w % 100, d = w % 10
            let unit: String
            if n >= 11 && n <= 14 { unit = "недель" }
            else if d == 1        { unit = "неделю" }
            else if d >= 2 && d <= 4 { unit = "недели" }
            else                  { unit = "недель" }
            return "~\(w) \(unit)"
        }()
        return s(w == 1 ? "~1 week" : "~\(w) weeks",
                 ru,
                 w == 1 ? "~1 Woche" : "~\(w) Wochen",
                 w == 1 ? "~1 semana" : "~\(w) semanas",
                 w == 1 ? "~1 semaine" : "~\(w) semaines",
                 w == 1 ? "~1 semana" : "~\(w) semanas")
    }

    func leapWillPass(hardDays: Int) -> String {
        let dur = weeksApprox(days: hardDays)
        return s("✿ This will pass. Usually lasts \(dur). Hold them more — it doesn't spoil.",
                 "✿ Это пройдёт. Обычно длится \(dur). Чаще берите на руки — это не балует.",
                 "✿ Das geht vorüber. Dauert \(dur). Öfter auf den Arm nehmen.",
                 "✿ Esto pasará. Suele durar \(dur). Cógelo más en brazos — no lo malcría.",
                 "✿ Cela passera. Dure généralement \(dur). Prenez-le plus dans les bras — ça ne gâte pas.",
                 "✿ Isto vai passar. Costuma durar \(dur). Pegue-o mais ao colo — não o estraga.")
    }
    var leapCalendar: String    { s("Leap Calendar",     "Календарь скачков","Schub-Kalender",  "Calendario de saltos", "Calendrier des bonds", "Calendário de saltos") }
    var tipOfTheDay: String     { s("TIP OF THE DAY",    "СОВЕТ НА СЕГОДНЯ", "TIPP DES TAGES",  "CONSEJO DEL DÍA", "CONSEIL DU JOUR", "DICA DO DIA") }
    var leapInProgressStatus: String { s("in progress",  "идёт сейчас",      "im Gange",        "en curso", "en cours", "em curso") }
    var leapCompletedStatus: String  { s("completed",    "завершён",         "abgeschlossen",   "completado", "terminé", "concluído") }
    var notice: String          { s("notice",            "замечают",         "bemerken",        "notas", "à remarquer", "notar") }
    var willLearn: String       { s("will learn",        "научится",         "wird lernen",     "aprenderá", "va apprendre", "vai aprender") }

    func hardDaysProgress(day: Int, total: Int) -> String { s("Day \(day) of ~\(total) hard days.", "День \(day) из ~\(total) трудных.", "Tag \(day) von ~\(total) schweren.", "Día \(day) de ~\(total) días difíciles.", "Jour \(day) sur ~\(total) jours difficiles.", "Dia \(day) de ~\(total) dias difíceis.") }
    func currentLeapTitle(id: Int) -> String { s("Now — leap #\(id)", "Сейчас — скачок №\(id)", "Jetzt — Schub №\(id)", "Ahora — salto n.º \(id)", "Maintenant — bond n° \(id)", "Agora — salto n.º \(id)") }
    func weekPill(n: Int) -> String { s("week \(n)", "\(n)-я неделя", "Woche \(n)", "semana \(n)", "semaine \(n)", "semana \(n)") }
    func weekRow(n: Int) -> String  { s("\(n) wk",   "\(n) нед",     "\(n) W",      "\(n) sem", "\(n) sem", "\(n) sem") }
    func leapAhead(week: Int) -> String { s("ahead · week \(week)", "впереди · \(week)-я неделя", "bald · Woche \(week)", "próximo · semana \(week)", "à venir · semaine \(week)", "a chegar · semana \(week)") }
    func forLeapTip(name: String) -> String { s("For leap «\(name)»", "Для скачка «\(name)»", "Für Schub «\(name)»", "Para el salto «\(name)»", "Pour le bond «\(name)»", "Para o salto «\(name)»") }

    // MARK: — Tracking
    var weight: String          { s("Weight",        "Вес",           "Gewicht",       "Peso",   "Poids", "Peso") }
    var height: String          { s("Height",        "Рост",          "Größe",         "Altura", "Taille", "Altura") }
    var headCircumference: String { s("Head circ.",  "Окруж. головы", "Kopfumfang",    "Perím. cefálico", "Périm. crânien", "Perím. cefálico") }
    var temperature: String     { s("Temperature",   "Температура",   "Temperatur",    "Temperatura", "Température", "Temperatura") }
    var doctorVisit: String     { s("Doctor visit",  "Приём врача",   "Arztbesuch",    "Visita médica", "Visite médicale", "Consulta médica") }
    var addMeasurement: String  { s("Add measurement", "Добавить измерение", "Messung hinzufügen", "Añadir medida", "Ajouter une mesure", "Adicionar medição") }
    var logTemp: String         { s("Log temperature", "Записать температуру", "Temperatur erfassen", "Registrar temperatura", "Enregistrer la température", "Registar temperatura") }
    var percentile: String      { s("Percentile",    "Перцентиль",    "Perzentile",    "Percentil", "Percentile", "Percentil") }
    var normal: String          { s("Normal",        "Норма",         "Normal",        "Normal", "Normal", "Normal") }
    var elevated: String        { s("Elevated",      "Повышена",      "Erhöht",        "Elevada", "Élevée", "Elevada") }
    var high: String            { s("High",          "Высокая",       "Hoch",          "Alta",   "Forte", "Alta") }
    var health: String          { s("Health",        "Здоровье",      "Gesundheit",    "Salud",  "Santé", "Saúde") }
    var heightAndWeight: String { s("Height & Weight","Рост и вес",   "Größe & Gewicht", "Altura y peso", "Taille et poids", "Altura e peso") }
    var whoRange: String        { s("0–24 mo · WHO", "0–24 мес · ВОЗ","0–24 Mon. · WHO", "0–24 meses · OMS", "0–24 mois · OMS", "0–24 meses · OMS") }
    var median: String          { s("Median",        "Медиана",       "Median",        "Mediana", "Médiane", "Mediana") }
    var temperatureHistory: String { s("Temperature history", "История температуры", "Temperaturverlauf", "Historial de temperatura", "Historique de température", "Histórico de temperatura") }
    var recentMeasurements: String { s("Recent measurements", "Последние замеры", "Letzte Messungen", "Medidas recientes", "Mesures récentes", "Medições recentes") }
    var weightKg: String        { s("Weight, kg",    "Вес, кг",       "Gewicht, kg",   "Peso, kg", "Poids, kg", "Peso, kg") }
    var heightCm: String        { s("Height, cm",    "Рост, см",      "Größe, cm",     "Altura, cm", "Taille, cm", "Altura, cm") }
    var headCircCm: String      { s("Head circ., cm","Окруж. головы, см","Kopfumfang, cm", "Perím. cefálico, cm", "Périm. crânien, cm", "Perím. cefálico, cm") }
    var normalRange: String      { s("normal",        "в норме",        "normal",       "normal", "normal", "normal") }
    var subfebr: String         { s("subfebr.",      "субфебр.",       "subfebr.",     "subfebril", "fébricule", "subfebril") }
    var subfebrLabel: String    { s("Subfebr.",      "Субфебрильная", "Subfebril",     "Subfebril", "Fébricule", "Subfebril") }
    var highTemp: String        { s("High 🌡",       "Высокая 🌡",    "Hoch 🌡",       "Alta 🌡", "Forte 🌡", "Alta 🌡") }
    var normalOk: String        { s("Normal ✓",      "Норма ✓",       "Normal ✓",      "Normal ✓", "Normal ✓", "Normal ✓") }
    var addWeightHeight: String { s("+ Weight / Height", "+ Вес / рост", "+ Gewicht / Größe", "+ Peso / altura", "+ Poids / taille", "+ Peso / altura") }
    var addTemperature: String  { s("+ Temperature", "+ Температура", "+ Temperatur",  "+ Temperatura", "+ Température", "+ Temperatura") }
    var measurements: String    { s("Measurements",  "Замеры",        "Messungen",     "Medidas", "Mesures", "Medições") }
    var weightPlaceholder: String { s("kg (e.g. 6.4)", "кг (напр. 6.4)", "kg (z.B. 6.4)", "kg (p. ej. 6.4)", "kg (p. ex. 6.4)", "kg (ex.: 6,4)") }
    var heightPlaceholder: String { s("cm (e.g. 64)",  "см (напр. 64)",  "cm (z.B. 64)",  "cm (p. ej. 64)", "cm (p. ex. 64)", "cm (ex.: 64)") }
    var headCirc: String        { s("Head circ.",    "Окр. головы",   "Kopfumfang",    "Perím. cefálico", "Périm. crânien", "Perím. cefálico") }
    var headCircPlaceholder: String { s("cm (e.g. 42)", "см (напр. 42)", "cm (z.B. 42)", "cm (p. ej. 42)", "cm (p. ex. 42)", "cm (ex.: 42)") }
    var fillAtLeastOneField: String { s("Fill in at least one field.", "Заполните хотя бы одно поле.", "Mindestens ein Feld ausfüllen.", "Rellena al menos un campo.", "Remplissez au moins un champ.", "Preencha pelo menos um campo.") }
    var newMeasurement: String  { s("New measurement","Новый замер",   "Neue Messung",  "Nueva medida", "Nouvelle mesure", "Nova medição") }
    var tempPlaceholder: String { s("e.g. 37.2",     "напр. 37.2",    "z.B. 37.2",     "p. ej. 37.2", "p. ex. 37.2", "ex.: 37,2") }
    var noteSectionLabel: String { s("Note",         "Заметка",       "Notiz",         "Nota", "Note", "Nota") }
    var optionalNote: String    { s("Optional note…","Необязательная заметка…", "Optionale Notiz…", "Nota opcional…", "Note facultative…", "Nota opcional…") }
    var temperatureCelsius: String { s("Temperature, °C", "Температура, °C", "Temperatur, °C", "Temperatura, °C", "Température, °C", "Temperatura, °C") }
    var recentReadings: String  { s("recent readings", "последние замеры", "letzte Messungen", "últimas medidas", "dernières mesures", "últimas medições") }
    var noTemperatureData: String { s("No temperature data", "Нет данных о температуре", "Keine Temperaturdaten", "Sin datos de temperatura", "Aucune donnée de température", "Sem dados de temperatura") }
    var tempNormalRange: String { s("normal < 37.5°", "норма < 37.5°", "normal < 37.5°", "normal < 37.5°", "normal < 37,5°", "normal < 37,5°") }
    var tempSubfebrRange: String { s("subfebr. 37.5–38.4°", "субфебр. 37.5–38.4°", "subfebril. 37.5–38.4°", "subfebril 37.5–38.4°", "fébricule 37,5–38,4°", "subfebril 37,5–38,4°") }
    var tempHighRange: String   { s("high ≥ 38.5°", "высокая ≥ 38.5°", "hoch ≥ 38.5°", "alta ≥ 38.5°", "forte ≥ 38,5°", "alta ≥ 38,5°") }

    // MARK: — Sounds / Lullaby
    var sounds: String          { s("Sounds",        "Звуки",         "Klänge",        "Sonidos", "Sons", "Sons") }
    var lullaby: String         { s("Lullaby",       "Колыбельная",   "Schlaflied",    "Nana", "Berceuse", "Canção de embalar") }
    var nowPlaying: String      { s("NOW PLAYING",   "ИГРАЕТ",        "SPIELT",        "SONANDO", "EN LECTURE", "A TOCAR") }
    var nowPlayingFull: String  { s("NOW PLAYING",   "СЕЙЧАС ИГРАЕТ", "SPIELT GERADE", "SONANDO AHORA", "EN COURS DE LECTURE", "A TOCAR AGORA") }
    var tapToPlay: String       { s("Tap to play",   "Нажмите чтобы играть", "Zum Abspielen tippen", "Pulsa para reproducir", "Touchez pour lire", "Toque para reproduzir") }
    var sleepTight: String      { s("sleep tight",   "пусть спит крепко", "schlaf gut", "que duerma bien", "fais de beaux rêves", "dorme bem") }
    var playing: String         { s("playing",       "играет",        "spielt",        "sonando", "en lecture", "a tocar") }

    func forBabyName(_ name: String) -> String { s(" for \(name)", " для \(name)", " für \(name)", " para \(name)", " pour \(name)", " para \(name)") }

    // MARK: — Family / Sharing
    var family: String          { s("Family",        "Семья",         "Familie",       "Familia", "Famille", "Família") }
    var invite: String          { s("Invite",        "Пригласить",    "Einladen",      "Invitar", "Inviter", "Convidar") }
    var inviteSent: String      { s("Invite sent",   "Приглашение отправлено", "Einladung gesendet", "Invitación enviada", "Invitation envoyée", "Convite enviado") }
    var role: String            { s("Role",          "Роль",          "Rolle",         "Rol", "Rôle", "Função") }
    var roleMom: String         { s("Mom",           "Мама",          "Mama",          "Mamá", "Maman", "Mãe") }
    var roleDad: String         { s("Dad",           "Папа",          "Papa",          "Papá", "Papa", "Pai") }
    var roleGrandma: String     { s("Grandma",       "Бабушка",       "Oma",           "Abuela", "Grand-mère", "Avó") }
    var roleGrandpa: String     { s("Grandpa",       "Дедушка",       "Opa",           "Abuelo", "Grand-père", "Avô") }
    var roleNanny: String       { s("Nanny",         "Няня",          "Nanny",         "Niñera", "Nounou", "Ama") }
    var roleOther: String       { s("Other",         "Другой",        "Andere",        "Otro", "Autre", "Outro") }
    var familyRoleHint: String  { s("Everyone has a role — each with their own access level.", "У всех своя роль — у каждой свой уровень доступа.", "Jeder hat eine Rolle — mit eigenem Zugangslevel.", "Cada uno tiene un rol — con su propio nivel de acceso.", "Chacun a un rôle — chacun avec son niveau d’accès.", "Cada um tem uma função — cada uma com o seu nível de acesso.") }
    var inviteFamilyMember: String { s("Invite family member", "Пригласить члена семьи", "Familienmitglied einladen", "Invitar a un familiar", "Inviter un membre de la famille", "Convidar membro da família") }
    var inviteQrHint: String    { s("QR code or link · choose role", "QR-код или ссылка · выбор роли", "QR-Code oder Link · Rolle wählen", "Código QR o enlace · elige rol", "QR code ou lien · choisir le rôle", "Código QR ou ligação · escolher função") }
    var matrixFeedingSleep: String { s("Feedings & sleep", "Кормления и сон", "Fütterung & Schlaf", "Tomas y sueño", "Tétées et sommeil", "Mamadas e sono") }
    var matrixTempMedicine: String { s("Temp / medicine", "Температура / лекарства", "Temperatur / Medizin", "Temp. / medicina", "Temp. / médicaments", "Temp. / medicação") }
    var matrixPhotosDiary: String  { s("Photos & diary", "Фото и дневник", "Fotos & Tagebuch", "Fotos y diario", "Photos et journal", "Fotos e diário") }
    var matrixPaedsReport: String  { s("Paediatric report", "Отчёт педиатру", "Kinderbericht", "Informe pediátrico", "Rapport pédiatrique", "Relatório pediátrico") }
    var whatEachRoleSees: String{ s("What each role sees", "Что видит каждая роль", "Was jede Rolle sieht", "Qué ve cada rol", "Ce que voit chaque rôle", "O que cada função vê") }
    var joinFamilyTitle: String { s("Join a Family",    "Присоединиться к семье", "Familie beitreten", "Unirse a una familia", "Rejoindre une famille", "Juntar-se a uma família") }
    var joinAction: String      { s("Join",             "Войти",                  "Beitreten",     "Unirse", "Rejoindre", "Juntar-se") }
    var joinSuccessMessage: String { s("You joined the family!", "Вы присоединились к семье!", "Du bist der Familie beigetreten!", "¡Te uniste a la familia!", "Vous avez rejoint la famille !", "Juntou-se à família!") }
    var joinSuccessTitle: String { s("Joined the family", "Вы в семье", "Familie beigetreten", "Te uniste a la familia", "Famille rejointe", "Entrou na família") }
    var joinFailedTitle: String { s("Couldn’t join", "Не удалось присоединиться", "Beitritt fehlgeschlagen", "No se pudo unir", "Impossible de rejoindre", "Não foi possível entrar") }
    var joinFailedMessage: String { s("This invite code is invalid or has expired.", "Этот код приглашения недействителен или истёк.", "Dieser Einladungscode ist ungültig oder abgelaufen.", "Este código de invitación no es válido o ha caducado.", "Ce code d’invitation est invalide ou a expiré.", "Este código de convite é inválido ou expirou.") }
    var roleLabel: String       { s("ROLE",          "РОЛЬ",          "ROLLE",         "ROL", "RÔLE", "FUNÇÃO") }
    var saveRole: String        { s("Save role",     "Сохранить роль","Rolle speichern", "Guardar rol", "Enregistrer le rôle", "Guardar função") }
    var removeFromTeamAction: String { s("Remove from team", "Удалить из команды", "Aus Team entfernen", "Quitar del equipo", "Retirer de l’équipe", "Remover da equipa") }
    var editMember: String      { s("Edit",          "Редактировать", "Bearbeiten",    "Editar", "Modifier", "Editar") }
    var roleInTeam: String      { s("ROLE IN TEAM",  "РОЛЬ В КОМАНДЕ","ROLLE IM TEAM", "ROL EN EL EQUIPO", "RÔLE DANS L’ÉQUIPE", "FUNÇÃO NA EQUIPA") }
    var nameOptional: String    { s("NAME (optional)","ИМЯ (необязательно)","NAME (optional)", "NOMBRE (opcional)", "NOM (facultatif)", "NOME (opcional)") }
    var memberNamePlaceholder: String { s("E.g.: Mike, Grandma Olga…", "Например: Миша, Бабушка Оля…", "Z.B.: Mike, Oma Olga…", "P. ej.: Miguel, Abuela Olga…", "P. ex. : Marc, Grand-mère Olga…", "Ex.: Miguel, Avó Olga…") }
    var shareLink: String       { s("Share link",    "Поделиться ссылкой", "Link teilen", "Compartir enlace", "Partager le lien", "Partilhar ligação") }
    var invitationSent: String  { s("invitation sent","приглашение отправлено", "Einladung gesendet", "invitación enviada", "invitation envoyée", "convite enviado") }
    var addToTeam: String       { s("Add to team",   "Добавить в команду", "Zum Team hinzufügen", "Añadir al equipo", "Ajouter à l’équipe", "Adicionar à equipa") }
    var copyLink: String        { s("Copy link",     "Копировать",    "Link kopieren", "Copiar enlace", "Copier le lien", "Copiar ligação") }
    var newCode: String         { s("New code",      "Новый код",     "Neuer Code",    "Nuevo código", "Nouveau code", "Novo código") }

    func teamTitle(name: String) -> String { s("\(name)'s Team", "Команда \(name)", "Team von \(name)", "Equipo de \(name)", "Équipe de \(name)", "Equipa de \(name)") }
    func removeConfirm(name: String) -> String { s("Remove \(name) from team?", "Удалить \(name) из команды?", "\(name) aus Team entfernen?", "¿Quitar a \(name) del equipo?", "Retirer \(name) de l’équipe ?", "Remover \(name) da equipa?") }
    func expiryHoursLeft(hrs: Int, mins: Int) -> String { s("\(hrs)h \(mins)m left", "\(hrs)ч \(mins)м", "\(hrs)h \(mins)m übrig", "quedan \(hrs)h \(mins)m", "\(hrs)h \(mins)m restantes", "faltam \(hrs)h \(mins)m") }
    func expiryMinsLeft(_ mins: Int) -> String { s("\(mins)m left", "\(mins) мин", "\(mins)m übrig", "quedan \(mins)m", "\(mins)m restantes", "faltam \(mins)m") }

    // MARK: — Report
    var report: String          { s("Report",        "Отчёт",         "Bericht",       "Informe", "Rapport", "Relatório") }
    var weekly: String          { s("Weekly",        "Недельный",     "Wöchentlich",   "Semanal", "Hebdomadaire", "Semanal") }
    var daily: String           { s("Daily",         "Дневной",       "Täglich",       "Diario", "Quotidien", "Diário") }
    var exportPDF: String       { s("Export PDF",    "Экспорт PDF",   "PDF exportieren", "Exportar PDF", "Exporter en PDF", "Exportar PDF") }
    var shareReport: String     { s("Share",         "Поделиться",    "Teilen",        "Compartir", "Partager", "Partilhar") }
    var paediatricReport: String { s("Paediatric Report", "Отчёт для педиатра", "Kinderbericht", "Informe pediátrico", "Rapport pédiatrique", "Relatório pediátrico") }
    var prepareFor: String      { s("Prepare for",   "Подготовить за","Vorbereiten für", "Preparar para", "Préparer pour", "Preparar para") }
    var visitSummaryHint: String { s("Visit summary: sleep · food · weight · temp · stool", "Итог визита: сон · еда · вес · темп · стул", "Besuchszusammenfassung: Schlaf · Essen · Gewicht · Temp · Stuhl", "Resumen de visita: sueño · comida · peso · temp · deposiciones", "Résumé de visite : sommeil · repas · poids · temp · selles", "Resumo da consulta: sono · comida · peso · temp · fezes") }
    var includeInReport: String { s("INCLUDE IN REPORT", "ВКЛЮЧИТЬ В ОТЧЁТ", "IN BERICHT EINSCHLIESSEN", "INCLUIR EN EL INFORME", "INCLURE DANS LE RAPPORT", "INCLUIR NO RELATÓRIO") }
    var preparingPdf: String    { s("Preparing PDF…","Готовим PDF…",  "PDF vorbereiten…", "Preparando PDF…", "Préparation du PDF…", "A preparar PDF…") }
    var sharePdf: String        { s("Share PDF",     "Поделиться PDF","PDF teilen",     "Compartir PDF", "Partager le PDF", "Partilhar PDF") }
    var printAction: String     { s("Print",         "Распечатать",   "Drucken",       "Imprimir", "Imprimer", "Imprimir") }
    var reportJobName: String   { s("Momsy — report","Momsy — отчёт", "Momsy — Bericht", "Momsy — informe", "Momsy — rapport", "Momsy — relatório") }
    var reportPeriod3Days: String      { s("3 days",       "3 дня",                "3 Tage",        "3 días", "3 jours", "3 dias") }
    var reportPeriodWeek: String       { s("Week",          "Неделя",               "Woche",         "Semana", "Semaine", "Semana") }
    var reportPeriod2Weeks: String     { s("2 weeks",       "2 недели",             "2 Wochen",      "2 semanas", "2 semaines", "2 semanas") }
    var reportPeriodMonth: String      { s("Month",         "Месяц",                "Monat",         "Mes", "Mois", "Mês") }
    var reportPeriodSinceVisit: String { s("Since visit",   "С визита",             "Seit Besuch",   "Desde la visita", "Depuis la visite", "Desde a consulta") }
    var reportPeriodLabelWeek: String  { s("a week",        "неделю",               "eine Woche",    "una semana", "une semaine", "uma semana") }
    var reportPeriodLabelMonth: String { s("a month",       "месяц",                "einen Monat",   "un mes", "un mois", "um mês") }
    var reportPeriodLabelLastVisit: String { s("last visit","последний визит",       "letzten Besuch", "última visita", "dernière visite", "última consulta") }
    var noVisitRecorded: String        { s("No visit recorded",  "Визит не записан",  "Kein Besuch eingetragen", "Sin visita registrada", "Aucune visite enregistrée", "Nenhuma consulta registada") }
    var lastVisitDate: String          { s("Last visit date",    "Дата последнего визита", "Datum des letzten Besuchs", "Fecha de la última visita", "Date de la dernière visite", "Data da última consulta") }
    var setVisitDate: String           { s("Set visit date",     "Указать дату визита",    "Besuchsdatum setzen", "Fijar fecha de visita", "Définir la date de visite", "Definir data da consulta") }
    var reportSectionFeedings: String  { s("Feedings & spit-ups",  "Кормления и срыгивания",  "Mahlzeiten & Spucken", "Tomas y regurgitaciones", "Tétées et régurgitations", "Mamadas e regurgitações") }
    var reportSectionSleepByDay: String { s("Sleep by day",        "Сон по дням",             "Schlaf täglich", "Sueño por día", "Sommeil par jour", "Sono por dia") }
    var reportSectionDiapers: String   { s("Diapers & stool",      "Подгузники и стул",       "Windeln & Stuhl", "Pañales y deposiciones", "Couches et selles", "Fraldas e fezes") }
    var reportSectionTempSymptoms: String { s("Temp / symptoms",   "Температура / симптомы",  "Temp / Symptome", "Temp. / síntomas", "Temp. / symptômes", "Temp. / sintomas") }
    var reportSectionWeightHeight: String { s("Weight & height",   "Вес и рост (график)",     "Gewicht & Größe", "Peso y altura", "Poids et taille", "Peso e altura") }
    var reportSectionMedicine: String  { s("Medicine & vitamins",  "Лекарства и витамины",    "Medizin & Vitamine", "Medicina y vitaminas", "Médicaments et vitamines", "Medicação e vitaminas") }
    var reportSectionPhotosNotes: String { s("Photos & notes",     "Фото и заметки",          "Fotos & Notizen", "Fotos y notas", "Photos et notes", "Fotos e notas") }
    var reportStatFeedingsLabel: String { s("Feedings",    "Кормлений",               "Mahlzeiten",   "Tomas", "Tétées", "Mamadas") }
    func reportFeedAvgSub(avg: Double) -> String { s(String(format: "%.1f / day", avg), String(format: "%.1f / день", avg), String(format: "%.1f / Tag", avg), String(format: "%.1f / día", avg), String(format: "%.1f / jour", avg), String(format: "%.1f / dia", avg)) }
    var reportStatSleepLabel: String   { s("Sleep",        "Сон",                     "Schlaf",       "Sueño", "Sommeil", "Sono") }
    var reportStatSleepSub: String     { s("median / day", "медиана / сутки",          "Median / Tag", "mediana / día", "médiane / jour", "mediana / dia") }
    var reportStatDiapersLabel: String { s("Diapers",      "Подгузники",              "Windeln",      "Pañales", "Couches", "Fraldas") }
    var reportNotTracked: String       { s("not tracked",  "не отслеживается",         "nicht verfolgt", "no registrado", "non suivi", "não registado") }
    var reportStatTempLabel: String    { s("Temperature",  "Температура",             "Temperatur",   "Temperatura", "Température", "Temperatura") }
    func reportTempPeakSub(n: Int) -> String { s("peak · \(n)×", "пик · \(n)×",      "Peak · \(n)×",  "pico · \(n)×", "pic · \(n)×", "pico · \(n)×") }
    var reportTempNormal: String       { s("normal",       "норма",                   "normal",       "normal", "normal", "normal") }
    var reportStatWeightLabel: String  { s("Weight & Height", "Вес и рост",           "Gewicht & Größe", "Peso y altura", "Poids et taille", "Peso e altura") }
    var reportSparkWeightLabel: String { s("Weight, kg",      "Вес, кг",              "Gewicht, kg",  "Peso, kg", "Poids, kg", "Peso, kg") }
    func reportSparkWeightDynamicLabel(unit: String) -> String { s("Weight, \(unit)", "Вес, \(unit)", "Gewicht, \(unit)", "Peso, \(unit)", "Poids, \(unit)", "Peso, \(unit)") }
    var reportSparkFeedingsLabel: String { s("Feedings / day",  "Кормления / сут",    "Mahlzeiten / Tag", "Tomas / día", "Tétées / jour", "Mamadas / dia") }
    var reportSparkSleepLabel: String  { s("Sleep / day (h)",   "Сон / сут (ч)",      "Schlaf / Tag (h)", "Sueño / día (h)", "Sommeil / jour (h)", "Sono / dia (h)") }
    var reportSparkTempLabel: String   { s("Temperature °C",    "Температура °C",     "Temperatur °C", "Temperatura °C", "Température °C", "Temperatura °C") }
    func reportSparkTempDynamicLabel(unit: String) -> String { s("Temperature \(unit)", "Температура \(unit)", "Temperatur \(unit)", "Temperatura \(unit)", "Température \(unit)", "Temperatura \(unit)") }
    var reportSparkDiapersLabel: String { s("Diapers / day",   "Подгузники / сут",   "Windeln / Tag", "Pañales / día", "Couches / jour", "Fraldas / dia") }
    func reportPreviewPeriod(label: String) -> String { s("Period: \(label)", "Период: \(label)", "Zeitraum: \(label)", "Periodo: \(label)", "Période : \(label)", "Período: \(label)") }
    var reportPreviewNotes: String     { s("NOTES",         "ЗАМЕТКИ",                 "NOTIZEN",      "NOTAS", "NOTES", "NOTAS") }
    var reportPreviewDoctorNotes: String { s("DOCTOR'S NOTES", "ЗАМЕТКИ ВРАЧА",        "ARZTNOTIZEN",  "NOTAS DEL MÉDICO", "NOTES DU MÉDECIN", "NOTAS DO MÉDICO") }
    func reportSparkPeak(value: String) -> String { s("peak: \(value)", "пик: \(value)", "Peak: \(value)", "pico: \(value)", "pic : \(value)", "pico: \(value)") }

    // MARK: — Symptoms
    var symptomLabelTemperature: String  { s("Temperature",    "Температура",     "Temperatur",   "Temperatura", "Température", "Temperatura") }
    var symptomLabelRash: String         { s("Rash",           "Сыпь",            "Ausschlag",    "Sarpullido", "Éruption", "Erupção") }
    var symptomLabelVomiting: String     { s("Vomiting",       "Рвота",           "Erbrechen",    "Vómitos", "Vomissements", "Vómitos") }
    var symptomLabelLongCrying: String   { s("Long crying",    "Долгий плач",     "Langes Weinen", "Llanto prolongado", "Pleurs prolongés", "Choro prolongado") }
    var symptomLabelStool: String        { s("Stool",          "Стул",            "Stuhl",        "Deposición", "Selles", "Fezes") }
    var symptomLabelRefusingFood: String { s("Refusing food",  "Отказ от еды",    "Nahrungsverweigerung", "Rechazo de comida", "Refus de manger", "Recusa de comida") }
    var symptomLabelSleepIssues: String  { s("Sleep issues",   "Нарушение сна",   "Schlafprobleme", "Problemas de sueño", "Troubles du sommeil", "Problemas de sono") }
    var symptomLabelOther: String        { s("Other",          "Другое",          "Sonstiges",    "Otro", "Autre", "Outro") }
    var symptomSubChooseArea: String     { s("choose area",    "выберите место",   "Bereich wählen", "elige zona", "choisir la zone", "escolher zona") }
    var symptomSubNone: String           { s("none",           "нет",             "keine",        "ninguno", "aucun", "nenhum") }
    var symptomSubStoolNormal: String    { s("normal",         "обычный",         "normal",       "normal", "normal", "normal") }
    var symptomSubSelect: String         { s("select",         "выбрать",         "auswählen",    "seleccionar", "sélectionner", "selecionar") }
    var symptomSubShortPhases: String    { s("short phases",   "короткие фазы",   "kurze Phasen", "fases cortas", "phases courtes", "fases curtas") }
    var symptomSubDescribe: String       { s("describe",       "описать",         "beschreiben",  "describir", "décrire", "descrever") }
    var symptomUrgencyWatching: String   { s("Watching",       "Наблюдаем",       "Beobachten",   "Observando", "Surveillance", "A observar") }
    var symptomUrgencyLikely: String     { s("Likely",         "Скорее всего",    "Wahrscheinlich", "Probable", "Probable", "Provável") }
    var symptomUrgencySeeDoctor: String  { s("See Doctor",     "Нужен врач",      "Arzt aufsuchen", "Ver al médico", "Consulter un médecin", "Consultar médico") }
    var symptomResultNothingTitle: String  { s("Nothing marked",      "Ничего не отмечено",          "Nichts markiert", "Nada marcado", "Rien de marqué", "Nada marcado") }
    var symptomResultNothingDetail: String { s("Mark symptoms above — we'll suggest what might be happening.", "Отметьте симптомы выше — мы подскажем, что может происходить.", "Markieren Sie Symptome oben — wir schlagen vor, was passieren könnte.", "Marca los síntomas arriba — te sugeriremos qué puede estar pasando.", "Marquez les symptômes ci-dessus — nous suggérerons ce qui pourrait se passer.", "Marque os sintomas acima — vamos sugerir o que pode estar a acontecer.") }
    var symptomResultExamTitle: String   { s("Needs Examination",     "Требует осмотра",             "Untersuchung nötig", "Necesita revisión", "Nécessite un examen", "Requer observação") }
    var symptomResultExamDetail: String  { s("Fever combined with a rash needs a paediatrician's attention. Don't delay — call your doctor today.", "Сочетание температуры и сыпи требует внимания педиатра. Не откладывайте — позвоните врачу сегодня.", "Fieber mit Ausschlag erfordert einen Kinderarzt. Nicht verzögern — rufen Sie heute an.", "La fiebre junto con sarpullido requiere un pediatra. No lo demores — llama hoy al médico.", "La fièvre associée à une éruption nécessite l’attention d’un pédiatre. Ne tardez pas — appelez votre médecin aujourd’hui.", "Febre com erupção precisa da atenção de um pediatra. Não adie — ligue hoje ao médico.") }
    var symptomResultExamWarning: String { s("rash + fever · face or throat swelling · difficulty breathing", "сыпь + температура · отёк лица или горла · затруднённое дыхание", "Ausschlag + Fieber · Gesichts-/Halschwellung · Atembeschwerden", "sarpullido + fiebre · hinchazón de cara o garganta · dificultad para respirar", "éruption + fièvre · gonflement du visage ou de la gorge · difficulté à respirer", "erupção + febre · inchaço do rosto ou garganta · dificuldade em respirar") }
    var symptomResultGastroTitle: String   { s("Gastroenteritis",    "Гастроэнтерит",               "Gastroenteritis", "Gastroenteritis", "Gastro-entérite", "Gastroenterite") }
    var symptomResultGastroDetail: String  { s("Vomiting with fever may indicate a gut infection. Keep fluids up: offer breast and water more often.", "Рвота с температурой — возможна кишечная инфекция. Следите за водным балансом: грудь и вода чаще обычного.", "Erbrechen mit Fieber kann auf eine Darminfektion hinweisen. Mehr Flüssigkeit anbieten.", "Los vómitos con fiebre pueden indicar una infección intestinal. Mantén los líquidos: ofrece pecho y agua más a menudo.", "Des vomissements avec fièvre peuvent indiquer une infection intestinale. Maintenez l’hydratation : proposez le sein et de l’eau plus souvent.", "Vómitos com febre podem indicar uma infeção intestinal. Mantenha a hidratação: ofereça o peito e água com mais frequência.") }
    var symptomResultGastroWarning: String { s("refusing fluids 6+ hrs · sunken fontanelle · dry mouth · bloody vomit", "отказ от воды дольше 6 ч · запавший родничок · сухой рот · рвота с кровью", "Flüssigkeitsverweigerung 6+ Std. · eingesunkene Fontanelle · trockener Mund · blutiges Erbrechen", "rechazo de líquidos 6+ h · fontanela hundida · boca seca · vómito con sangre", "refus de boire 6 h+ · fontanelle creusée · bouche sèche · vomissements sanglants", "recusa de líquidos 6+ h · fontanela funda · boca seca · vómito com sangue") }
    var symptomResultDigestTitle: String   { s("Digestive Upset",    "Расстройство ЖКТ",            "Verdauungsstörung", "Malestar digestivo", "Trouble digestif", "Mal-estar digestivo") }
    var symptomResultDigestDetail: String  { s("Possible overfeeding, gas, or food reaction. Hold baby upright 20 min after feeding.", "Возможен перекорм, газы или реакция на питание. Держите малыша вертикально 20 мин после еды.", "Mögliche Überernährung, Blähungen oder Nahrungsreaktion. 20 Min. nach dem Füttern aufrichten.", "Posible sobrealimentación, gases o reacción a un alimento. Mantén al bebé erguido 20 min tras la toma.", "Possible suralimentation, gaz ou réaction alimentaire. Tenez le bébé droit 20 min après la tétée.", "Possível excesso de alimentação, gases ou reação a alimentos. Mantenha o bebé na vertical 20 min após a mamada.") }
    var symptomResultDigestWarning: String { s("projectile vomiting · vomiting 3+ times in 2 hrs · blood in vomit", "рвота фонтаном · рвота более 3 раз за 2 ч · кровь в рвоте", "Schwallartigem Erbrechen · 3+ Erbrechen in 2 Std. · Blut im Erbrechen", "vómito en escopetazo · vómitos 3+ veces en 2 h · sangre en el vómito", "vomissements en jet · vomissements 3 fois+ en 2 h · sang dans les vomissements", "vómito em jato · vómitos 3+ vezes em 2 h · sangue no vómito") }
    var symptomResultTeethTitle: String    { s("Teething",           "Прорезывание зубов",          "Zahnen", "Dentición", "Poussée dentaire", "Nascimento dos dentes") }
    var symptomResultTeethDetail: String   { s("Temp up to 38°, crying, disturbed sleep — classic signs. Try a cold teether, carry more.", "Температура до 38°, плач, нарушение сна — частые спутники. Попробуйте холодный прорезыватель, носите на руках.", "Temp bis 38°, Weinen, gestörter Schlaf — klassische Anzeichen. Kühler Beißring, mehr tragen.", "Temp. hasta 38°, llanto, sueño alterado — signos típicos. Prueba un mordedor frío y cárgalo más.", "Temp. jusqu’à 38°, pleurs, sommeil perturbé — signes classiques. Essayez un anneau de dentition froid, portez-le plus.", "Temp. até 38°, choro, sono perturbado — sinais clássicos. Experimente uma mordedeira fria e pegue-o mais ao colo.") }
    var symptomResultTeethWarning: String  { s("t° > 38.5° for more than a day · refusing fluids · lethargy · unusual rash", "t° > 38.5° дольше суток · отказ от воды · вялость · необычная сыпь", "t° > 38,5° mehr als einen Tag · Flüssigkeitsverweigerung · Lethargie · ungewöhnlicher Ausschlag", "t° > 38.5° más de un día · rechazo de líquidos · letargo · sarpullido inusual", "t° > 38,5° plus d’une journée · refus de boire · léthargie · éruption inhabituelle", "t° > 38,5° mais de um dia · recusa de líquidos · letargia · erupção invulgar") }
    var symptomResultArviTitle: String     { s("ARVI / Sore Throat", "ОРВИ / воспаление горла",     "Virusinfektion / Halsschmerzen", "Infección viral / dolor de garganta", "Infection virale / mal de gorge", "Infeção viral / dor de garganta") }
    var symptomResultArviDetail: String    { s("Refusing food with fever is a common sign of a viral infection. Offer fluids and breast more often.", "Отказ от еды при температуре — частый признак вирусной инфекции. Предлагайте воду и грудь чаще обычного.", "Nahrungsverweigerung mit Fieber ist häufig bei Virusinfektionen. Mehr Flüssigkeit anbieten.", "El rechazo de comida con fiebre es un signo común de infección viral. Ofrece líquidos y pecho más a menudo.", "Le refus de manger avec de la fièvre est un signe courant d’infection virale. Proposez des liquides et le sein plus souvent.", "A recusa de comida com febre é um sinal comum de infeção viral. Ofereça líquidos e o peito com mais frequência.") }
    var symptomResultArviWarning: String   { s("t° > 39° · difficulty breathing · lethargy · refusing all fluids", "t° > 39° · затруднённое дыхание · вялость · отказ от воды", "t° > 39° · Atembeschwerden · Lethargie · Flüssigkeitsverweigerung", "t° > 39° · dificultad para respirar · letargo · rechazo de todo líquido", "t° > 39° · difficulté à respirer · léthargie · refus de tout liquide", "t° > 39° · dificuldade em respirar · letargia · recusa de todos os líquidos") }
    var symptomResultViralTitle: String    { s("Viral Infection",    "Вирусная инфекция",           "Virale Infektion", "Infección viral", "Infection virale", "Infeção viral") }
    var symptomResultViralDetail: String   { s("Monitor closely. Use fever reducer at t° > 38.5°. Ensure adequate fluids.", "Следите за динамикой. Жаропонижающее при t° > 38.5°. Обеспечьте достаточное питьё.", "Genau beobachten. Fiebermittel bei t° > 38,5°. Ausreichend Flüssigkeit sicherstellen.", "Vigila de cerca. Usa antitérmico a t° > 38.5°. Asegura líquidos suficientes.", "Surveillez de près. Utilisez un antipyrétique à t° > 38,5°. Assurez une hydratation suffisante.", "Vigie de perto. Use antipirético a t° > 38,5°. Garanta líquidos suficientes.") }
    var symptomResultViralWarning: String  { s("t° > 38° in babies under 3 mo · t° > 39° in older babies · seizures · lethargy", "t° > 38° у детей до 3 мес · t° > 39° у старших · судороги · вялость", "t° > 38° bei Säuglingen unter 3 Mo · t° > 39° bei älteren · Krämpfe · Lethargie", "t° > 38° en bebés menores de 3 meses · t° > 39° en mayores · convulsiones · letargo", "t° > 38° chez les bébés de moins de 3 mois · t° > 39° chez les plus grands · convulsions · léthargie", "t° > 38° em bebés com menos de 3 meses · t° > 39° em bebés mais velhos · convulsões · letargia") }
    var symptomResultLeapTitle: String     { s("Leap or Colic",      "Скачок или колики",           "Entwicklungsschub oder Koliken", "Salto o cólico", "Bond ou coliques", "Salto ou cólicas") }
    var symptomResultLeapDetail: String    { s("Crying and disturbed sleep without fever are usually a developmental leap or colic. Try tummy massage and the 'tiger position'.", "Плач и нарушение сна без температуры чаще всего — скачок развития или колики. Попробуйте массаж животика и «позицию тигра».", "Weinen und gestörter Schlaf ohne Fieber sind meist ein Entwicklungsschub oder Koliken. Bauchmassage und 'Tigerposition' versuchen.", "El llanto y el sueño alterado sin fiebre suelen ser un salto del desarrollo o cólicos. Prueba masaje en la tripita y la 'posición del tigre'.", "Les pleurs et le sommeil perturbé sans fièvre sont souvent un bond de développement ou des coliques. Essayez le massage du ventre et la « position du tigre ».", "Choro e sono perturbado sem febre são normalmente um salto de desenvolvimento ou cólicas. Experimente massagem na barriga e a «posição do tigre».") }
    var symptomResultLeapWarning: String   { s("crying 3+ hrs non-stop · hard bloated belly", "плач дольше 3 часов без перерыва · живот твёрдый и вздутый", "Weinen 3+ Std. ohne Unterbrechung · harter aufgeblähter Bauch", "llanto 3+ h sin parar · tripita dura e hinchada", "pleurs 3 h+ sans arrêt · ventre dur et ballonné", "choro 3+ h sem parar · barriga dura e inchada") }
    var symptomResultCryingTitle: String   { s("Prolonged Crying",   "Долгий плач",                "Anhaltender Weinkrampf", "Llanto prolongado", "Pleurs prolongés", "Choro prolongado") }
    var symptomResultCryingDetail: String  { s("Check the basics: hunger, diaper, room temperature, tiredness. Peak colic age is 6 weeks.", "Проверьте основные причины: голод, подгузник, температура в комнате, усталость. Пик колик — 6 недель.", "Grundlegendes prüfen: Hunger, Windel, Raumtemperatur, Müdigkeit. Höhepunkt der Koliken: 6 Wochen.", "Revisa lo básico: hambre, pañal, temperatura del cuarto, cansancio. El pico de cólicos es a las 6 semanas.", "Vérifiez les bases : faim, couche, température de la pièce, fatigue. Le pic des coliques est à 6 semaines.", "Verifique o básico: fome, fralda, temperatura do quarto, cansaço. O pico das cólicas é às 6 semanas.") }
    var symptomResultCryingWarning: String { s("unusual tone of cry · arching back · no urination 8+ hrs", "плач необычного тона · выгибание спины · нет мочеиспускания 8+ ч", "Ungewöhnlicher Weinton · Rücken wölben · kein Wasserlassen 8+ Std.", "tono de llanto inusual · arquea la espalda · sin orinar 8+ h", "ton de pleurs inhabituel · dos cambré · pas de miction 8 h+", "tom de choro invulgar · arquear as costas · sem urinar 8+ h") }
    var symptomResultWatchingTitle: String   { s("Watching",         "Наблюдаем",                  "Beobachten", "Observando", "Surveillance", "A observar") }
    var symptomResultWatchingDetail: String  { s("The marked symptoms aren't alarming. Keep observing and log any changes.", "Отмеченные симптомы не вызывают тревоги. Продолжайте наблюдать и записывайте любые изменения.", "Die markierten Symptome sind nicht besorgniserregend. Weiter beobachten.", "Los síntomas marcados no son alarmantes. Sigue observando y registra cualquier cambio.", "Les symptômes marqués ne sont pas alarmants. Continuez à observer et notez tout changement.", "Os sintomas marcados não são alarmantes. Continue a observar e registe quaisquer alterações.") }
    var symptomResultWatchingWarning: String { s("any worsening · new symptoms · your gut — you know your baby best", "любое ухудшение · новые симптомы · ваша интуиция — вы лучше знаете малыша", "Jede Verschlechterung · neue Symptome · Ihr Instinkt — Sie kennen Ihr Baby am besten", "cualquier empeoramiento · síntomas nuevos · tu instinto — conoces mejor a tu bebé", "toute aggravation · nouveaux symptômes · votre instinct — vous connaissez mieux votre bébé", "qualquer agravamento · novos sintomas · o seu instinto — conhece melhor o seu bebé") }

    // MARK: — Navigation tabs
    var tabDoctor: String       { s("Doctor",        "Доктор",        "Arzt",          "Médico", "Médecin", "Médico") }
    var tabMe: String           { s("Me",            "Я",             "Ich",           "Yo", "Moi", "Eu") }
    var profile: String         { s("Profile",       "Профиль",       "Profil",        "Perfil", "Profil", "Perfil") }

    // MARK: — Splash
    var splashTagline: String   { s("Your baby's little diary", "Дневник вашего малыша", "Das Tagebuch deines Babys", "El pequeño diario de tu bebé", "Le petit journal de votre bébé", "O pequeno diário do seu bebé") }

    // MARK: — Settings
    var settings: String        { s("Settings",      "Настройки",     "Einstellungen", "Ajustes", "Réglages", "Definições") }
    var language: String        { s("Language",      "Язык",          "Sprache",       "Idioma", "Langue", "Idioma") }
    var theme: String           { s("Theme",         "Тема",          "Design",        "Tema", "Thème", "Tema") }
    var appTheme: String        { s("App Theme",     "Тема приложения","App-Design",    "Tema de la app", "Thème de l’app", "Tema da app") }
    var themeAuto: String       { s("Auto",          "Авто",          "Auto",          "Auto", "Auto", "Auto") }
    var autoThemeHint: String   { s("Auto follows the system appearance.", "Авто — следует системной теме устройства.", "Auto folgt der Systemdarstellung.", "Auto sigue la apariencia del sistema.", "Auto suit l’apparence du système.", "Auto segue a aparência do sistema.") }
    var appLanguage: String     { s("App Language",  "Язык приложения","App-Sprache",   "Idioma de la app", "Langue de l’app", "Idioma da app") }
    var languageComingSoon: String { s("More languages coming soon.", "Больше языков — скоро.", "Weitere Sprachen folgen bald.", "Pronto habrá más idiomas.", "D’autres langues bientôt.", "Mais idiomas em breve.") }
    var unitSystem: String      { s("Units",           "Единицы",       "Einheiten",     "Unidades", "Unités", "Unidades") }
    var unitMetric: String      { s("Metric",          "Метрическая",   "Metrisch",      "Métrico", "Métrique", "Métrico") }
    var unitImperial: String    { s("Imperial",        "Имперская",     "Imperial",      "Imperial", "Impérial", "Imperial") }
    var unitSystemHint: String  { s("Metric: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Метр.: кг, см, °C, мл · Импер.: lb, in, °F, oz",
                                     "Metrisch: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Métrico: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Métrique : kg, cm, °C, ml · Impérial : lb, in, °F, oz",
                                     "Métrico: kg, cm, °C, ml · Imperial: lb, in, °F, oz") }
    var about: String           { s("About",         "О приложении",  "Über",          "Acerca de", "À propos", "Acerca de") }
    var version: String         { s("Version",       "Версия",        "Version",       "Versión", "Version", "Versão") }
    var madeWithLove: String    { s("Made with love","Сделано с любовью","Mit Liebe gemacht", "Hecho con amor", "Fait avec amour", "Feito com amor") }
    var forMoms: String         { s("for moms",      "для мам",       "für Mütter",    "para mamás", "pour les mamans", "para as mamãs") }
    var privacy: String         { s("Privacy",       "Конфиденциальность","Datenschutz", "Privacidad", "Confidentialité", "Privacidade") }
    var feedback: String        { s("Feedback",      "Обратная связь", "Feedback",      "Comentarios", "Retour", "Comentários") }
    var icloudSyncTitle: String { s("Cloud Sync",    "Облачная синхронизация", "Cloud-Synchronisierung", "Sincronización en la nube", "Synchronisation cloud", "Sincronização na nuvem") }
    var icloudSyncDisclosure: String {
        s("Your baby's health records and your well-being entries (including the EPDS screening) are stored on this device and synced through your private Firebase account so they stay in sync across your devices. They are never shared with third parties or used for ads.",
          "Записи о здоровье малыша и ваши записи о самочувствии (включая скрининг EPDS) хранятся на этом устройстве и синхронизируются через ваш личный аккаунт Firebase, чтобы данные совпадали на всех ваших устройствах. Они никогда не передаются третьим лицам и не используются для рекламы.",
          "Die Gesundheitsdaten deines Babys und deine Wohlbefinden-Einträge (einschließlich des EPDS-Screenings) werden auf diesem Gerät gespeichert und über dein privates Firebase-Konto synchronisiert, damit sie auf deinen Geräten übereinstimmen. Sie werden nie an Dritte weitergegeben oder für Werbung verwendet.",
          "Los registros de salud de tu bebé y tus entradas de bienestar (incluido el cribado EPDS) se guardan en este dispositivo y se sincronizan a través de tu cuenta privada de Firebase para mantenerlos sincronizados entre tus dispositivos. Nunca se comparten con terceros ni se usan para publicidad.",
          "Les données de santé de votre bébé et vos entrées de bien-être (y compris le dépistage EPDS) sont stockées sur cet appareil et synchronisées via votre compte Firebase privé afin de rester synchronisées entre vos appareils. Elles ne sont jamais partagées avec des tiers ni utilisées à des fins publicitaires.",
          "Os registos de saúde do seu bebé e as suas entradas de bem-estar (incluindo o rastreio EPDS) são guardados neste dispositivo e sincronizados através da sua conta privada do Firebase para se manterem sincronizados entre os seus dispositivos. Nunca são partilhados com terceiros nem usados para publicidade.")
    }
    var dangerZone: String      { s("Data & Privacy", "Данные и конфиденциальность", "Daten & Datenschutz", "Datos y privacidad", "Données et confidentialité", "Dados e privacidade") }
    var deleteAllData: String   { s("Delete all data", "Удалить все данные", "Alle Daten löschen", "Eliminar todos los datos", "Supprimer toutes les données", "Eliminar todos os dados") }
    var deleteAllDataConfirm: String {
        s("This permanently deletes your account and every record — on this device and in the cloud — including health and well-being data and diary photos. This cannot be undone.",
          "Это навсегда удалит ваш аккаунт и все записи — на этом устройстве и в облаке — включая данные о здоровье и самочувствии и фото из дневника. Это действие необратимо.",
          "Dies löscht dauerhaft dein Konto und alle Einträge – auf diesem Gerät und in der Cloud – einschließlich Gesundheits- und Wohlbefindensdaten sowie Tagebuchfotos. Dies kann nicht rückgängig gemacht werden.",
          "Esto elimina permanentemente tu cuenta y todos los registros — en este dispositivo y en la nube — incluidos los datos de salud y bienestar y las fotos del diario. Esto no se puede deshacer.",
          "Ceci supprime définitivement votre compte et tous les enregistrements — sur cet appareil et dans le cloud — y compris les données de santé et de bien-être et les photos du journal. Cette action est irréversible.",
          "Isto elimina permanentemente a sua conta e todos os registos — neste dispositivo e na nuvem — incluindo dados de saúde e bem-estar e fotos do diário. Esta ação não pode ser anulada.")
    }
    var deleting: String        { s("Deleting…",     "Удаление…",     "Wird gelöscht…", "Eliminando…", "Suppression…", "A eliminar…") }
    var deleteFailed: String    { s("Couldn't delete your data. Please try again.", "Не удалось удалить данные. Попробуйте ещё раз.", "Daten konnten nicht gelöscht werden. Bitte versuche es erneut.", "No se pudieron eliminar los datos. Inténtalo de nuevo.", "Impossible de supprimer vos données. Veuillez réessayer.", "Não foi possível eliminar os seus dados. Tente novamente.") }
    var themeSystem: String     { s("System",        "Системная",     "System",        "Sistema", "Système", "Sistema") }
    var themeLight: String      { s("Light",         "Светлая",       "Hell",          "Claro", "Clair", "Claro") }
    var themeDark: String       { s("Dark",          "Тёмная",        "Dunkel",        "Oscuro", "Sombre", "Escuro") }
    var notifications: String   { s("Notifications", "Уведомления",   "Benachrichtigungen", "Notificaciones", "Notifications", "Notificações") }
    var babyProfile: String     { s("Baby profile",  "Профиль малыша","Baby-Profil",   "Perfil del bebé", "Profil du bébé", "Perfil do bebé") }
    var editProfile: String     { s("Edit Profile",  "Редактировать", "Bearbeiten",    "Editar perfil", "Modifier le profil", "Editar perfil") }
    var saveChanges: String     { s("Save changes",  "Сохранить",     "Speichern",     "Guardar cambios", "Enregistrer les modifications", "Guardar alterações") }
    var profileUpdated: String  { s("Profile saved", "Профиль сохранён","Profil gespeichert", "Perfil guardado", "Profil enregistré", "Perfil guardado") }
    var subscription: String    { s("Subscription",  "Подписка",      "Abonnement",    "Suscripción", "Abonnement", "Subscrição") }
    var privacyPolicy: String   { s("Privacy Policy","Политика конфид.", "Datenschutz", "Política de privacidad", "Politique de confidentialité", "Política de privacidade") }
    var termsOfUse: String      { s("Terms of Use",  "Условия использования", "Nutzungsbedingungen", "Términos de uso", "Conditions d’utilisation", "Termos de utilização") }

    // MARK: — Onboarding
    var onboardingWelcome: String { s("Welcome to Momsy", "Добро пожаловать в Momsy", "Willkommen bei Momsy", "Bienvenida a Momsy", "Bienvenue sur Momsy", "Bem-vinda à Momsy") }
    var onboardingSubtitle: String { s("Your smart baby tracker", "Умный трекер малыша", "Dein smarter Baby-Tracker", "Tu rastreador inteligente del bebé", "Votre suivi bébé intelligent", "O seu rastreador inteligente do bebé") }
    var babyName: String        { s("Baby's name",   "Имя малыша",    "Name des Babys", "Nombre del bebé", "Prénom du bébé", "Nome do bebé") }
    var birthDate: String       { s("Birth date",    "Дата рождения", "Geburtsdatum",  "Fecha de nacimiento", "Date de naissance", "Data de nascimento") }
    var getStarted: String      { s("Get started",   "Начать",        "Loslegen",      "Empezar", "Commencer", "Começar") }
    var continueLabel: String   { s("Continue",      "Продолжить",    "Weiter",        "Continuar", "Continuer", "Continuar") }
    var continueArrow: String   { s("Continue →",    "Продолжить →",  "Weiter →",      "Continuar →", "Continuer →", "Continuar →") }
    var skip: String            { s("Skip",          "Пропустить",    "Überspringen",  "Omitir", "Passer", "Ignorar") }
    var helloMama: String       { s("Hello, mama!",  "Привет, мама!", "Hallo, Mama!",  "¡Hola, mamá!", "Bonjour, maman !", "Olá, mamã!") }
    var howOldIsYourBaby: String { s("How old is your baby?\nWe'll tailor everything to their age.", "Сколько малышу?\nМы всё адаптируем под его возраст.", "Wie alt ist Ihr Baby?\nWir passen alles an.", "¿Cuántos meses tiene tu bebé?\nLo adaptaremos todo a su edad.", "Quel âge a votre bébé ?\nNous adapterons tout à son âge.", "Que idade tem o seu bebé?\nVamos adaptar tudo à idade dele.") }
    var ageChangeNote: String   { s("Age can be changed later. We'll highlight developmental leaps specifically for you.", "Возраст можно изменить позже. Мы выделим скачки развития специально для вас.", "Alter kann später geändert werden.", "La edad se puede cambiar después. Destacaremos los saltos del desarrollo especialmente para ti.", "L’âge peut être modifié plus tard. Nous mettrons en avant les bonds de développement spécialement pour vous.", "A idade pode ser alterada mais tarde. Vamos destacar os saltos de desenvolvimento especialmente para si.") }
    var whatsYourBabyName: String { s("What's your baby's name?", "Как зовут малыша?", "Wie heißt Ihr Baby?", "¿Cómo se llama tu bebé?", "Comment s’appelle votre bébé ?", "Como se chama o seu bebé?") }
    var nameBirthHelp: String   { s("Name and birth date help track\nleaps and development more accurately.", "Имя и дата рождения помогают точнее\nотслеживать скачки и развитие.", "Name und Geburtsdatum helfen genauer.", "El nombre y la fecha de nacimiento ayudan a seguir\nlos saltos y el desarrollo con más precisión.", "Le prénom et la date de naissance aident à suivre\nles bonds et le développement plus précisément.", "O nome e a data de nascimento ajudam a acompanhar\nos saltos e o desenvolvimento com mais precisão.") }
    var babyNameLabel: String   { s("BABY'S NAME",   "ИМЯ МАЛЫША",   "NAME DES BABYS", "NOMBRE DEL BEBÉ", "PRÉNOM DU BÉBÉ", "NOME DO BEBÉ") }
    var babyNamePlaceholder: String { s("E.g., Leo", "Например, Лёва","Z.B. Leon",     "P. ej., Leo", "P. ex., Léo", "Ex.: Leo") }
    var dateOfBirthLabel: String { s("DATE OF BIRTH","ДАТА РОЖДЕНИЯ", "GEBURTSDATUM",  "FECHA DE NACIMIENTO", "DATE DE NAISSANCE", "DATA DE NASCIMENTO") }
    var whoAreYou: String       { s("Who are you to the baby?", "Кто ты для малыша?", "Wer bist du für das Baby?", "¿Quién eres para el bebé?", "Qui êtes-vous pour le bébé ?", "Quem é para o bebé?") }
    var roleHelp: String        { s("This helps configure\nnotifications and access rights.", "Это помогает настроить\nуведомления и права доступа.", "Das hilft bei der Konfiguration.", "Esto ayuda a configurar\nnotificaciones y permisos de acceso.", "Cela aide à configurer\nles notifications et les droits d’accès.", "Isto ajuda a configurar\nnotificações e permissões de acesso.") }
    var yourNameOptional: String { s("YOUR NAME (optional)", "ВАШЕ ИМЯ (необязательно)", "IHR NAME (optional)", "TU NOMBRE (opcional)", "VOTRE NOM (facultatif)", "O SEU NOME (opcional)") }
    var yourNamePlaceholder: String { s("E.g., Anna", "Например, Аня","Z.B. Anna",     "P. ej., Ana", "P. ex., Anne", "Ex.: Ana") }
    var greetMom: String        { s("Mama!",         "Мама!",         "Mama!",         "¡Mamá!", "Maman !", "Mamã!") }
    var greetDad: String        { s("Papa!",         "Папа!",         "Papa!",         "¡Papá!", "Papa !", "Papá!") }
    var greetNanny: String      { s("Nanny!",        "Няня!",         "Nanny!",        "¡Niñera!", "Nounou !", "Ama!") }
    var greetDefault: String    { s("Hello!",        "Привет!",       "Hallo!",        "¡Hola!", "Bonjour !", "Olá!") }
    var allSet: String          { s("All set,",      "Всё готово,",   "Fertig,",       "Todo listo,", "Tout est prêt,", "Tudo pronto,") }
    var age: String             { s("Age",           "Возраст",       "Alter",         "Edad", "Âge", "Idade") }
    var caregiver: String       { s("Caregiver",     "Кто следит",    "Betreuer",      "Cuidador", "Personne en charge", "Cuidador") }
    var stage: String           { s("Stage",         "Стадия",        "Stufe",         "Etapa", "Étape", "Fase") }
    var dataStoredLocally: String { s("Data is stored only on your phone. Nothing extra.", "Данные хранятся только на вашем телефоне. Ничего лишнего.", "Daten werden nur auf Ihrem Telefon gespeichert.", "Los datos se guardan solo en tu teléfono. Nada más.", "Les données sont stockées uniquement sur votre téléphone. Rien de plus.", "Os dados são guardados apenas no seu telefone. Nada mais.") }
    var genderLabel: String      { s("GENDER",         "ПОЛ",           "GESCHLECHT",   "SEXO", "SEXE", "SEXO") }
    var genderBoy: String        { s("Boy",            "Мальчик",       "Junge",        "Niño", "Garçon", "Menino") }
    var genderGirl: String       { s("Girl",           "Девочка",       "Mädchen",      "Niña", "Fille", "Menina") }
    var genderUnknown: String    { s("Don't know yet", "Пока неизвестно","Noch unklar", "Aún no lo sé", "Je ne sais pas encore", "Ainda não sei") }

    func ageDescription(_ ageStr: String) -> String { s("Age: \(ageStr)", "Возраст: \(ageStr)", "Alter: \(ageStr)", "Edad: \(ageStr)", "Âge : \(ageStr)", "Idade: \(ageStr)") }

    // MARK: — Symptoms
    var symptoms: String        { s("Symptoms",      "Симптомы",      "Symptome",      "Síntomas", "Symptômes", "Sintomas") }
    var addSymptom: String      { s("Add symptom",   "Добавить симптом", "Symptom hinzufügen", "Añadir síntoma", "Ajouter un symptôme", "Adicionar sintoma") }
    var fever: String           { s("Fever",         "Температура",   "Fieber",        "Fiebre", "Fièvre", "Febre") }
    var cough: String           { s("Cough",         "Кашель",        "Husten",        "Tos", "Toux", "Tosse") }
    var runnyNose: String       { s("Runny nose",    "Насморк",       "Schnupfen",     "Mocos", "Nez qui coule", "Nariz a pingar") }
    var rash: String            { s("Rash",          "Сыпь",          "Ausschlag",     "Sarpullido", "Éruption", "Erupção") }
    var teething: String        { s("Teething",      "Зубы",          "Zahnen",        "Dentición", "Dentition", "Dentes") }
    var somethingWrong: String  { s("Something wrong?", "Что-то не так?", "Etwas nicht in Ordnung?", "¿Algo va mal?", "Quelque chose ne va pas ?", "Algo errado?") }
    var markItGuide: String     { s("Mark it — we'll guide you on what to do", "Отметьте — мы подскажем, что делать", "Markieren — wir führen Sie.", "Márcalo — te guiaremos sobre qué hacer", "Marquez-le — nous vous guiderons sur ce qu’il faut faire", "Marque — vamos orientá-la sobre o que fazer") }
    var notADiagnosis: String   { s("NOT A DIAGNOSIS","Это не диагноз","KEINE DIAGNOSE", "NO ES UN DIAGNÓSTICO", "PAS UN DIAGNOSTIC", "NÃO É UM DIAGNÓSTICO") }
    var symptomDisclaimer: String { s("We help you navigate. The decision is yours and your doctor's.", "Помогаем сориентироваться. Решение принимаете вы и врач.", "Wir helfen bei der Orientierung.", "Te ayudamos a orientarte. La decisión es tuya y de tu médico.", "Nous vous aidons à vous orienter. La décision vous revient, à vous et à votre médecin.", "Ajudamos a orientar. A decisão é sua e do seu médico.") }
    var seeDoctorUrgently: String { s("See doctor urgently if:", "Срочно к врачу, если:", "Arzt dringend aufsuchen wenn:", "Ve al médico con urgencia si:", "Consultez d’urgence un médecin si :", "Consulte o médico com urgência se:") }
    var symptomFooterDisclaimer: String { s("Symptom hints are navigation, not a diagnosis.\nWhen in doubt — always see your paediatrician.", "Подсказки на основе симптомов — это навигация, не диагноз.\nПри любых сомнениях — всегда к педиатру.", "Symptomhinweise sind Orientierung, keine Diagnose.\nIm Zweifel — immer zum Kinderarzt.", "Las pistas de síntomas son orientación, no un diagnóstico.\nAnte la duda — siempre acude a tu pediatra.", "Les indications de symptômes sont une orientation, pas un diagnostic.\nEn cas de doute — consultez toujours votre pédiatre.", "As dicas de sintomas são orientação, não um diagnóstico.\nEm caso de dúvida — consulte sempre o seu pediatra.") }
    var symptomsUpper: String   { s("SYMPTOMS",      "СИМПТОМЫ",      "SYMPTOME",      "SÍNTOMAS", "SYMPTÔMES", "SINTOMAS") }
    var noteSymptoms: String    { s("Note symptoms — get guidance. Not a diagnosis, just navigation.", "Отметьте симптомы — подскажем, что делать. Не диагноз, только навигация.", "Symptome notieren — Orientierung erhalten. Keine Diagnose.", "Anota los síntomas — recibe orientación. No es un diagnóstico, solo orientación.", "Notez les symptômes — recevez des conseils. Pas un diagnostic, juste une orientation.", "Anote os sintomas — receba orientação. Não é um diagnóstico, apenas orientação.") }

    // MARK: — Doctor Menu
    var pediatricianReport: String { s("Pediatrician Report","Отчёт для педиатра","Kinderarztbericht", "Informe para el pediatra", "Rapport pour le pédiatre", "Relatório para o pediatra") }
    var pdfForWeek: String      { s("PDF for the week — sleep, feeding, weight", "PDF за неделю — сон, кормление, вес", "PDF für die Woche — Schlaf, Ernährung, Gewicht", "PDF de la semana — sueño, tomas, peso", "PDF de la semaine — sommeil, tétées, poids", "PDF da semana — sono, mamadas, peso") }
    var whoPercentileChart: String { s("WHO percentile chart", "График по перцентилям ВОЗ", "WHO-Perzentilkurve", "Gráfico de percentiles OMS", "Courbe de percentiles OMS", "Gráfico de percentis OMS") }
    var vaccinations: String            { s("Vaccinations",          "Прививки",                     "Impfungen", "Vacunas", "Vaccins", "Vacinas") }
    var vaccinationCalendar: String     { s("Vaccination calendar",   "Календарь прививок",           "Impfkalender", "Calendario de vacunas", "Calendrier des vaccins", "Calendário de vacinas") }
    var vaccinationCalendarSub: String  { s("Schedule & reminders",   "Расписание и напоминания",     "Zeitplan & Erinnerungen", "Calendario y recordatorios", "Calendrier et rappels", "Calendário e lembretes") }
    var vaccinationSchedule: String     { s("Vaccination schedule",   "Календарь прививок",           "Impfkalender", "Calendario de vacunación", "Calendrier de vaccination", "Plano de vacinação") }
    var vaccinationScheduleHint: String { s("Based on your region. The WHO international schedule is used by default.", "На основе вашего региона. По умолчанию используется международный календарь ВОЗ.", "Basierend auf Ihrer Region. Standardmäßig wird der internationale WHO-Impfkalender verwendet.", "Según tu región. Se usa el calendario internacional de la OMS por defecto.", "Selon votre région. Le calendrier international de l’OMS est utilisé par défaut.", "Com base na sua região. Por predefinição, é usado o plano internacional da OMS.") }
    var vaccinationMarkDone: String     { s("Mark as done",           "Отметить выполненной",         "Als erledigt markieren", "Marcar como hecha", "Marquer comme fait", "Marcar como feita") }
    var vaccinationUndo: String         { s("Undo",                   "Отменить",                     "Rückgängig", "Deshacer", "Annuler", "Anular") }

    // MARK: — Food Diary
    var foodDiary: String           { s("Food Diary",          "Прикорм-дневник",        "Beikost-Tagebuch", "Diario de alimentación", "Journal alimentaire", "Diário alimentar") }
    var foodDiarySub: String        { s("New foods, reactions, allergies", "Новые продукты, реакции, аллергии", "Neue Lebensmittel, Reaktionen, Allergien", "Nuevos alimentos, reacciones, alergias", "Nouveaux aliments, réactions, allergies", "Novos alimentos, reações, alergias") }
    var addFood: String             { s("Add food",             "Добавить продукт",        "Lebensmittel hinzufügen", "Añadir alimento", "Ajouter un aliment", "Adicionar alimento") }
    var foodName: String            { s("Food name",            "Название продукта",       "Lebensmittelname", "Nombre del alimento", "Nom de l’aliment", "Nome do alimento") }
    var foodCategory: String        { s("Category",             "Категория",               "Kategorie", "Categoría", "Catégorie", "Categoria") }
    var foodReaction: String        { s("Reaction",             "Реакция",                 "Reaktion", "Reacción", "Réaction", "Reação") }
    var foodReactionNone: String    { s("No reaction",          "Без реакции",             "Keine Reaktion", "Sin reacción", "Aucune réaction", "Sem reação") }
    var foodReactionMild: String    { s("Mild",                 "Лёгкая",                  "Leicht", "Leve", "Légère", "Ligeira") }
    var foodReactionSevere: String  { s("Severe",               "Сильная",                 "Schwer", "Grave", "Sévère", "Grave") }
    var foodAllergen: String        { s("Allergen",             "Аллерген",                "Allergen", "Alérgeno", "Allergène", "Alérgeno") }
    var foodAllergens: String       { s("Allergens",            "Аллергены",               "Allergene", "Alérgenos", "Allergènes", "Alérgenos") }
    var foodAllergensNone: String   { s("No allergens logged",  "Аллергены не зафиксированы", "Keine Allergene erfasst", "Sin alérgenos registrados", "Aucun allergène enregistré", "Sem alérgenos registados") }
    var foodCatVegetable: String    { s("Vegetable",            "Овощ",                    "Gemüse", "Verdura", "Légume", "Legume") }
    var foodCatFruit: String        { s("Fruit",                "Фрукт",                   "Frucht", "Fruta", "Fruit", "Fruta") }
    var foodCatCereal: String       { s("Cereal",               "Каша",                    "Getreide", "Cereal", "Céréale", "Cereal") }
    var foodCatMeat: String         { s("Meat",                 "Мясо",                    "Fleisch", "Carne", "Viande", "Carne") }
    var foodCatDairy: String        { s("Dairy",                "Молочное",                "Milchprodukt", "Lácteo", "Produit laitier", "Lacticínio") }
    var foodCatFish: String         { s("Fish",                 "Рыба",                    "Fisch", "Pescado", "Poisson", "Peixe") }
    var foodCatEgg: String          { s("Egg",                  "Яйцо",                    "Ei", "Huevo", "Œuf", "Ovo") }
    var foodCatOther: String        { s("Other",                "Другое",                  "Sonstiges", "Otro", "Autre", "Outro") }
    var foodStartHint: String       { s("Log first solid foods for your baby", "Записывайте первые продукты прикорма", "Erste Beikost für Ihr Baby protokollieren", "Registra los primeros sólidos de tu bebé", "Enregistrez les premiers aliments solides de votre bébé", "Registe os primeiros alimentos sólidos do seu bebé") }

    // MARK: — Me / Profile
    var familyMembersHint: String { s("Mom, dad, nanny, grandma", "Мама, папа, няня, бабушка", "Mama, Papa, Nanny, Oma", "Mamá, papá, niñera, abuela", "Maman, papa, nounou, grand-mère", "Mãe, pai, ama, avó") }
    var lullabiesSounds: String { s("Lullabies & Sounds", "Колыбельные и шум", "Lieder & Klänge", "Nanas y sonidos", "Berceuses et sons", "Canções de embalar e sons") }
    var lullabiesHint: String   { s("White noise, melodies, timer", "Белый шум, мелодии, таймер", "Weißes Rauschen, Melodien, Timer", "Ruido blanco, melodías, temporizador", "Bruit blanc, mélodies, minuteur", "Ruído branco, melodias, temporizador") }
    var settingsHint: String    { s("Theme, language",  "Тема, язык",    "Design, Sprache", "Tema, idioma", "Thème, langue", "Tema, idioma") }

    // MARK: — Mom Mood Tracker
    var momMoodTitle: String          { s("My Wellbeing",            "Моё самочувствие",           "Mein Wohlbefinden", "Mi bienestar", "Mon bien-être", "O meu bem-estar") }
    var momMoodSub: String            { s("Mood & PPD screening",    "Настроение и PPD скрининг",  "Stimmung & PPD-Screening", "Ánimo y cribado de DPP", "Humeur et dépistage DPP", "Humor e rastreio de DPP") }
    var momMoodSectionLabel: String   { s("WELLBEING",               "САМОЧУВСТВИЕ",               "WOHLBEFINDEN", "BIENESTAR", "BIEN-ÊTRE", "BEM-ESTAR") }
    var momMoodTodayPrompt: String    { s("How are you feeling today?", "Как вы себя чувствуете сегодня?", "Wie geht es Ihnen heute?", "¿Cómo te sientes hoy?", "Comment vous sentez-vous aujourd’hui ?", "Como se sente hoje?") }
    var momMoodEnergyLabel: String    { s("Energy",                  "Энергия",                    "Energie", "Energía", "Énergie", "Energia") }
    var momMoodCheckin: String        { s("Daily Check-in",          "Ежедневная отметка",         "Tägliches Check-in", "Registro diario", "Suivi quotidien", "Registo diário") }
    var momMoodCheckinSub: String     { s("Rate your mood & energy", "Оцените настроение и силы",  "Stimmung & Energie bewerten", "Valora tu ánimo y energía", "Évaluez votre humeur et votre énergie", "Avalie o seu humor e energia") }
    var momMoodHistory: String        { s("30-day history",          "История за 30 дней",         "30-Tage-Verlauf", "Historial de 30 días", "Historique sur 30 jours", "Histórico de 30 dias") }
    var momMoodNoData: String         { s("No check-ins yet",        "Пока нет отметок",           "Noch keine Einträge", "Aún sin registros", "Aucun suivi pour l’instant", "Ainda sem registos") }
    var momSleepTitle: String         { s("Mom's Sleep",             "Сон мамы",                   "Schlaf der Mutter", "Sueño de mamá", "Sommeil de maman", "Sono da mãe") }
    var momSleepCardSub: String       { s("Track your rest",         "Отслеживайте свой отдых",    "Ihren Schlaf verfolgen", "Sigue tu descanso", "Suivez votre repos", "Acompanhe o seu descanso") }
    var momMoodNoteSub: String        { s("optional note",           "заметка (необязательно)",    "Notiz (optional)", "nota opcional", "note facultative", "nota opcional") }
    var epdsTitle: String             { s("EPDS Screening",          "Скрининг EPDS",              "EPDS-Screening", "Cribado EPDS", "Dépistage EPDS", "Rastreio EPDS") }
    var epdsSubtitle: String          { s("Edinburgh Postnatal Depression Scale", "Эдинбургская шкала послеродовой депрессии", "Edinburgher Wochenbettdepressionsskala", "Escala de Depresión Posnatal de Edimburgo", "Échelle de dépression postnatale d’Édimbourg", "Escala de Depressão Pós-natal de Edimburgo") }
    var epdsStartCTA: String          { s("Take Screening",          "Пройти скрининг",            "Screening starten", "Hacer el cribado", "Faire le dépistage", "Fazer o rastreio") }
    var epdsLastScore: String         { s("Last score",              "Последний результат",        "Letztes Ergebnis", "Última puntuación", "Dernier score", "Última pontuação") }
    var epdsProgress: String          { s("Question",                "Вопрос",                     "Frage", "Pregunta", "Question", "Pergunta") }
    var epdsOf: String                { s("of",                      "из",                         "von", "de", "sur", "de") }
    var epdsYourScore: String         { s("Your score",              "Ваш результат",              "Ihr Ergebnis", "Tu puntuación", "Votre score", "A sua pontuação") }
    var epdsLowRisk: String           { s("Low risk",                "Низкий риск",                "Geringes Risiko", "Riesgo bajo", "Faible risque", "Risco baixo") }
    var epdsMildRisk: String          { s("Possible mild depression","Возможная лёгкая депрессия", "Mögliche leichte Depression", "Posible depresión leve", "Possible dépression légère", "Possível depressão ligeira") }
    var epdsHighRisk: String          { s("Seek support",            "Обратитесь за помощью",      "Unterstützung suchen", "Busca apoyo", "Cherchez du soutien", "Procure apoio") }
    var epdsDisclaimer: String        { s("This tool is not a diagnosis. If your score is 10 or above, please consult your doctor.",
                                          "Этот инструмент не является диагнозом. При результате 10 и выше обратитесь к врачу.",
                                          "Dieses Tool ist keine Diagnose. Bei einem Score von 10 oder mehr wenden Sie sich an Ihren Arzt.",
                                          "Esta herramienta no es un diagnóstico. Si tu puntuación es 10 o más, consulta a tu médico.",
                                          "Cet outil n’est pas un diagnostic. Si votre score est de 10 ou plus, veuillez consulter votre médecin.",
                                          "Esta ferramenta não é um diagnóstico. Se a sua pontuação for 10 ou mais, consulte o seu médico.") }
    var epdsDoneButton: String        { s("Done",                    "Готово",                     "Fertig", "Hecho", "Terminé", "Concluído") }
    var epdsNextButton: String        { s("Next",                    "Далее",                      "Weiter", "Siguiente", "Suivant", "Seguinte") }
    var epdsQ1: String  { s("I have been able to laugh and see the funny side of things.",
                             "Я была способна смеяться и видеть смешную сторону вещей.",
                             "Ich konnte lachen und die lustige Seite der Dinge sehen.",
                             "He sido capaz de reír y ver el lado divertido de las cosas.",
                             "J’ai pu rire et voir le côté amusant des choses.",
                             "Consegui rir e ver o lado divertido das coisas.") }
    var epdsQ2: String  { s("I have looked forward with enjoyment to things.",
                             "Я с удовольствием ждала каких-то событий.",
                             "Ich habe mich auf kommende Dinge gefreut.",
                             "He esperado las cosas con ilusión.",
                             "J’ai attendu les choses avec plaisir.",
                             "Olhei para as coisas com prazer e expectativa.") }
    var epdsQ3: String  { s("I have blamed myself unnecessarily when things went wrong.",
                             "Я напрасно винила себя, когда что-то шло не так.",
                             "Ich habe mich unnötig beschuldigt, wenn etwas schief lief.",
                             "Me he culpado innecesariamente cuando las cosas salían mal.",
                             "Je me suis sentie coupable sans raison quand les choses allaient mal.",
                             "Culpei-me desnecessariamente quando as coisas corriam mal.") }
    var epdsQ4: String  { s("I have been anxious or worried for no good reason.",
                             "Я испытывала тревогу или беспокойство без видимой причины.",
                             "Ich war ängstlich oder besorgt ohne triftigen Grund.",
                             "He estado ansiosa o preocupada sin un buen motivo.",
                             "J’ai été anxieuse ou inquiète sans raison valable.",
                             "Senti-me ansiosa ou preocupada sem um bom motivo.") }
    var epdsQ5: String  { s("I have felt scared or panicky for no very good reason.",
                             "Я чувствовала страх или панику без особой причины.",
                             "Ich hatte Angst oder Panik ohne besonderen Grund.",
                             "He sentido miedo o pánico sin un buen motivo.",
                             "J’ai eu peur ou paniqué sans raison particulière.",
                             "Senti medo ou pânico sem qualquer motivo concreto.") }
    var epdsQ6: String  { s("Things have been getting on top of me.",
                             "Всё навалилось на меня.",
                             "Die Dinge häuften sich für mich.",
                             "Las cosas me han superado.",
                             "Les choses m’ont dépassée.",
                             "As coisas têm-me ultrapassado.") }
    var epdsQ7: String  { s("I have been so unhappy that I have had difficulty sleeping.",
                             "Мне было так плохо, что я с трудом засыпала.",
                             "Ich war so unglücklich, dass ich Schwierigkeiten beim Schlafen hatte.",
                             "He estado tan infeliz que me ha costado dormir.",
                             "J’ai été si malheureuse que j’ai eu du mal à dormir.",
                             "Tenho estado tão infeliz que tive dificuldade em dormir.") }
    var epdsQ8: String  { s("I have felt sad or miserable.",
                             "Я чувствовала себя грустной или несчастной.",
                             "Ich fühlte mich traurig oder elend.",
                             "Me he sentido triste o desdichada.",
                             "Je me suis sentie triste ou malheureuse.",
                             "Senti-me triste ou infeliz.") }
    var epdsQ9: String  { s("I have been so unhappy that I have been crying.",
                             "Мне было так плохо, что я плакала.",
                             "Ich war so unglücklich, dass ich geweint habe.",
                             "He estado tan infeliz que he llorado.",
                             "J’ai été si malheureuse que j’ai pleuré.",
                             "Tenho estado tão infeliz que tenho chorado.") }
    var epdsQ10: String { s("The thought of harming myself has occurred to me.",
                             "У меня возникали мысли о причинении себе вреда.",
                             "Der Gedanke, mir selbst Schaden zuzufügen, kam mir.",
                             "Se me ha pasado por la cabeza la idea de hacerme daño.",
                             "L’idée de me faire du mal m’est venue à l’esprit.",
                             "Ocorreu-me a ideia de me fazer mal.") }

    /// Answer options for each of the 10 EPDS questions (4 options each), in display order.
    var epdsOptions: [[String]] {
        [
            [s("As much as I always could", "Так же, как всегда", "So viel wie immer", "Tanto como siempre", "Autant que d’habitude", "Tanto como sempre"),
             s("Not quite so much now", "Немного меньше, чем обычно", "Etwas weniger als sonst", "Ahora no tanto", "Un peu moins que d’habitude", "Não tanto como antes"),
             s("Definitely not so much now", "Значительно меньше, чем обычно", "Deutlich weniger als sonst", "Claramente menos ahora", "Nettement moins que d’habitude", "Claramente menos agora"),
             s("Not at all", "Совсем нет", "Überhaupt nicht", "En absoluto", "Pas du tout", "De todo")],
            [s("As much as I ever did", "Так же, как и всегда", "So sehr wie immer", "Tanto como siempre", "Autant que d’habitude", "Tanto como sempre"),
             s("Rather less than I used to", "Меньше, чем прежде", "Etwas weniger als früher", "Algo menos que antes", "Plutôt moins qu’avant", "Um pouco menos do que antes"),
             s("Definitely less than I used to", "Намного меньше, чем прежде", "Deutlich weniger als früher", "Claramente menos que antes", "Nettement moins qu’avant", "Claramente menos do que antes"),
             s("Hardly at all", "Почти не ждала", "Kaum noch", "Casi nada", "Presque pas", "Quase nada")],
            [s("No, never", "Нет, никогда", "Nein, nie", "No, nunca", "Non, jamais", "Não, nunca"),
             s("Not very often", "Не очень часто", "Nicht sehr oft", "No muy a menudo", "Pas très souvent", "Não muito frequentemente"),
             s("Yes, some of the time", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes"),
             s("Yes, most of the time", "Да, большую часть времени", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, a maior parte do tempo")],
            [s("No, not at all", "Нет, совсем нет", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo"),
             s("Hardly ever", "Очень редко", "Fast nie", "Casi nunca", "Presque jamais", "Quase nunca"),
             s("Yes, sometimes", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes"),
             s("Yes, very often", "Да, очень часто", "Ja, sehr oft", "Sí, muy a menudo", "Oui, très souvent", "Sim, muito frequentemente")],
            [s("No, not at all", "Нет, совсем нет", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo"),
             s("No, not much", "Нет, не очень", "Nein, kaum", "No, no mucho", "Non, pas beaucoup", "Não, não muito"),
             s("Yes, sometimes", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes"),
             s("Yes, quite a lot", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante", "Oui, assez souvent", "Sim, bastante")],
            [s("No, I have been coping as well as ever", "Нет, я справлялась так же хорошо", "Nein, ich komme so gut zurecht wie immer", "No, me he desenvuelto tan bien como siempre", "Non, je gère aussi bien que d’habitude", "Não, tenho lidado tão bem como sempre"),
             s("No, most of the time I have coped quite well", "Нет, в основном справлялась", "Nein, meistens komme ich recht gut zurecht", "No, la mayor parte del tiempo me he desenvuelto bastante bien", "Non, la plupart du temps je gère plutôt bien", "Não, a maior parte do tempo tenho lidado muito bem"),
             s("Yes, sometimes I haven't been coping as well as usual", "Да, иногда хуже, чем обычно", "Ja, manchmal komme ich nicht so gut zurecht wie sonst", "Sí, a veces no me he desenvuelto tan bien como de costumbre", "Oui, parfois je gère moins bien que d’habitude", "Sim, às vezes não tenho lidado tão bem como o costume"),
             s("Yes, I have not been coping at all", "Да, совсем не справлялась", "Ja, ich komme überhaupt nicht zurecht", "Sí, no me he desenvuelto en absoluto", "Oui, je n’arrive plus du tout à gérer", "Sim, não tenho conseguido lidar de todo")],
            [s("No, not at all", "Нет, совсем", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo"),
             s("Not very often", "Не очень часто", "Nicht sehr oft", "No muy a menudo", "Pas très souvent", "Não muito frequentemente"),
             s("Yes, sometimes", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes"),
             s("Yes, most of the time", "Да, большую часть времени", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, a maior parte do tempo")],
            [s("No, not at all", "Нет, совсем", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo"),
             s("Not very often", "Не очень часто", "Nicht sehr oft", "No muy a menudo", "Pas très souvent", "Não muito frequentemente"),
             s("Yes, quite often", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante a menudo", "Oui, assez souvent", "Sim, bastante vezes"),
             s("Yes, most of the time", "Да, почти всё время", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, quase sempre")],
            [s("No, never", "Нет, никогда", "Nein, nie", "No, nunca", "Non, jamais", "Não, nunca"),
             s("Only occasionally", "Лишь иногда", "Nur gelegentlich", "Solo de vez en cuando", "Seulement de temps en temps", "Apenas ocasionalmente"),
             s("Yes, quite often", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante a menudo", "Oui, assez souvent", "Sim, bastante vezes"),
             s("Yes, most of the time", "Да, большую часть времени", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, a maior parte do tempo")],
            [s("Never", "Никогда", "Nie", "Nunca", "Jamais", "Nunca"),
             s("Hardly ever", "Почти никогда", "Fast nie", "Casi nunca", "Presque jamais", "Quase nunca"),
             s("Sometimes", "Иногда", "Manchmal", "A veces", "Parfois", "Às vezes"),
             s("Yes, quite often", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante a menudo", "Oui, assez souvent", "Sim, bastante vezes")],
        ]
    }

    // MARK: — Unit abbreviations (charts, age labels)
    var unitHourShort: String  { s("h",   "ч",   "Std", "h",   "h",    "h") }
    var unitMinShort: String   { s("min", "мин", "Min", "min", "min",  "min") }
    var ageMonthShort: String  { s("mo",  "мес", "Mon", "m",   "mois", "m") }
    var ageDayShort: String    { s("d",   "дн",  "T",   "d",   "j",    "d") }

    // MARK: — Water Intake
    var waterIntakeTitle: String       { s("Water Intake",               "Жидкость мамы",                "Flüssigkeit", "Hidratación", "Hydratation", "Hidratação") }
    var waterIntakeLabel: String       { s("HYDRATION",                  "ГИДРАТАЦИЯ",                   "HYDRATION", "HIDRATACIÓN", "HYDRATATION", "HIDRATAÇÃO") }
    var waterIntakeSub: String         { s("Daily hydration",            "Суточное потребление жидкости", "Tagesflüssigkeit", "Hidratación diaria", "Hydratation quotidienne", "Hidratação diária") }
    var waterGoalLabel: String         { s("Goal",                       "Цель",                          "Ziel", "Objetivo", "Objectif", "Objetivo") }
    var waterTodayLabel: String        { s("today",                      "сегодня",                       "heute", "hoy", "aujourd’hui", "hoje") }
    var waterAdd150: String            { s("+150 ml",                    "+150 мл",                       "+150 ml", "+150 ml", "+150 ml", "+150 ml") }
    var waterAdd250: String            { s("+250 ml",                    "+250 мл",                       "+250 ml", "+250 ml", "+250 ml", "+250 ml") }
    var waterAdd500: String            { s("+500 ml",                    "+500 мл",                       "+500 ml", "+500 ml", "+500 ml", "+500 ml") }
    var waterNoEntries: String         { s("No logs today",              "Записей нет",                   "Keine Einträge", "Sin registros hoy", "Aucun enregistrement aujourd’hui", "Sem registos hoje") }
    var waterWeekLabel: String         { s("LAST 7 DAYS",                "ПОСЛЕДНИЕ 7 ДНЕЙ",              "LETZTE 7 TAGE", "ÚLTIMOS 7 DÍAS", "7 DERNIERS JOURS", "ÚLTIMOS 7 DIAS") }
    var waterTodayEntriesLabel: String { s("TODAY",                      "СЕГОДНЯ",                       "HEUTE", "HOY", "AUJOURD’HUI", "HOJE") }

    // MARK: — Auth / Sign-In
    var authStepTitle: String      { s("Create Account",                   "Создай аккаунт",                    "Konto erstellen", "Crear cuenta", "Créer un compte", "Criar conta") }
    var authStepSubtitle: String   { s("Back up your data & restore it\non any device",
                                       "Сохрани данные и восстанови\nна любом устройстве",
                                       "Daten sichern & auf jedem\nGerät wiederherstellen",
                                       "Respalda tus datos y restáuralos\nen cualquier dispositivo",
                                       "Sauvegardez vos données et restaurez-les\nsur n’importe quel appareil",
                                       "Faça uma cópia dos seus dados e restaure-os\nem qualquer dispositivo") }
    var signInWithApple: String    { s("Sign in with Apple",               "Войти через Apple",                 "Mit Apple anmelden", "Iniciar sesión con Apple", "Se connecter avec Apple", "Iniciar sessão com a Apple") }
    var signInWithGoogle: String   { s("Sign in with Google",              "Войти через Google",                "Mit Google anmelden", "Iniciar sesión con Google", "Se connecter avec Google", "Iniciar sessão com o Google") }
    var mayBeLater: String         { s("Maybe Later",                      "Позже",                             "Vielleicht später", "Quizá más tarde", "Plus tard", "Talvez mais tarde") }

    // MARK: — Paywall
    var trialBadge: String         { s("7 days free",
                                       "7 дней бесплатно",
                                       "7 Tage gratis",
                                       "7 días gratis",
                                       "7 jours gratuits",
                                       "7 dias grátis") }
    var startTrial: String         { s("Start Free Trial",
                                       "Начать бесплатно на 7 дней",
                                       "7 Tage gratis starten",
                                       "Empezar prueba gratis",
                                       "Commencer l’essai gratuit",
                                       "Iniciar avaliação gratuita") }
    var paywallPriceNote: String   { s("Then $4.99/month · Cancel anytime",
                                       "Затем 299 ₽/мес · Отменить в любое время",
                                       "Dann 4,99 €/Monat · Jederzeit kündbar",
                                       "Luego 4,99 $/mes · Cancela cuando quieras",
                                       "Puis 4,99 €/mois · Annulable à tout moment",
                                       "Depois 4,99 €/mês · Cancele quando quiser") }
    var restorePurchases: String   { s("Restore Purchases",
                                       "Восстановить покупки",
                                       "Käufe wiederherstellen",
                                       "Restaurar compras",
                                       "Restaurer les achats",
                                       "Restaurar compras") }
    var featureAll: String         { s("All features, no limits",
                                       "Все функции без ограничений",
                                       "Alle Funktionen ohne Limits",
                                       "Todas las funciones, sin límites",
                                       "Toutes les fonctions, sans limites",
                                       "Todas as funcionalidades, sem limites") }
    var featureSync: String        { s("Family sync across devices",
                                       "Синхронизация и семейный доступ",
                                       "Familiensync über Geräte hinweg",
                                       "Sincronización familiar entre dispositivos",
                                       "Synchronisation familiale entre appareils",
                                       "Sincronização familiar entre dispositivos") }
    var featureDiary: String       { s("Unlimited diary & statistics",
                                       "Журнал и статистика без лимитов",
                                       "Unbegrenzte Statistiken",
                                       "Diario y estadísticas sin límites",
                                       "Journal et statistiques illimités",
                                       "Diário e estatísticas ilimitados") }
    var authSignedIn: String       { s("Signed in ✓",                      "Вы вошли ✓",                        "Angemeldet ✓", "Sesión iniciada ✓", "Connecté ✓", "Sessão iniciada ✓") }
    var signInFailed: String       { s("Sign in failed. Please try again.",
                                       "Не удалось войти. Попробуйте ещё раз.",
                                       "Anmeldung fehlgeschlagen. Bitte erneut versuchen.",
                                       "Error al iniciar sesión. Inténtalo de nuevo.",
                                       "Échec de la connexion. Veuillez réessayer.",
                                       "Falha ao iniciar sessão. Tente novamente.") }
    var googleComingSoon: String   { s("Google Sign-In is coming soon.",    "Вход через Google скоро появится.", "Google-Anmeldung kommt bald.", "El inicio de sesión con Google llegará pronto.", "La connexion Google arrive bientôt.", "O início de sessão com o Google chega em breve.") }
    var appleSignInHint: String    { s("Please sign in with your Apple ID in Settings → [Your Name] to use Sign in with Apple.",
                                       "Войдите в Apple ID в Настройках → [Ваше имя], чтобы использовать Sign in with Apple.",
                                       "Bitte melde dich in Einstellungen → [Dein Name] mit deiner Apple ID an.",
                                       "Inicia sesión con tu Apple ID en Ajustes → [Tu nombre] para usar Iniciar sesión con Apple.",
                                       "Veuillez vous connecter avec votre identifiant Apple dans Réglages → [Votre nom] pour utiliser Se connecter avec Apple.",
                                       "Inicie sessão com o seu ID Apple em Definições → [O seu nome] para usar Iniciar sessão com a Apple.") }

    // MARK: — Notifications
    var notifFeedingTitle: String  { s("Feeding reminder", "Напоминание о кормлении", "Fütterungserinnerung", "Recordatorio de toma", "Rappel de tétée", "Lembrete de mamada") }
    func notifFeedingBody(hours: Int) -> String { s("Baby hasn't eaten in \(hours)+ hours. Time to feed?", "Малыш не ел уже \(hours)+ ч. Пора покормить?", "Baby hat seit \(hours)+ Stunden nicht gegessen. Zeit zu füttern?", "El bebé no ha comido en \(hours)+ horas. ¿Hora de la toma?", "Bébé n’a pas mangé depuis \(hours)+ heures. Il est temps de le nourrir ?", "O bebé não come há \(hours)+ horas. Hora de alimentar?") }
    var notifDiaryTitle: String    { s("Daily diary", "Дневник малыша", "Tägliches Tagebuch", "Diario diario", "Journal quotidien", "Diário diário") }
    var notifDiaryBody: String     { s("Write down today's special moments", "Запишите сегодняшние моменты в дневник малыша", "Halte die besonderen Momente von heute fest", "Anota los momentos especiales de hoy", "Notez les moments spéciaux d’aujourd’hui", "Registe os momentos especiais de hoje") }
    var notifLeapTitle: String     { s("Development leap", "Скачок развития", "Entwicklungsschub", "Salto del desarrollo", "Bond de développement", "Salto de desenvolvimento") }
    func notifLeapBody(name: String) -> String { s("«\(name)» leap begins — your baby is reaching a new stage", "Начинается «\(name)» — малыш переходит на новый этап", "Der Schub «\(name)» beginnt — dein Baby erreicht eine neue Phase", "Comienza el salto «\(name)» — tu bebé alcanza una nueva etapa", "Le bond «\(name)» commence — votre bébé atteint une nouvelle étape", "O salto «\(name)» começa — o seu bebé atinge uma nova fase") }
    var notifVaccinationTitle: String { s("Vaccination reminder", "Напоминание о прививке", "Impferinnerung", "Recordatorio de vacuna", "Rappel de vaccin", "Lembrete de vacina") }
    func notifVaccinationBody(name: String) -> String { s("\(name) — in 7 days", "\(name) — через 7 дней", "\(name) — in 7 Tagen", "\(name) — en 7 días", "\(name) — dans 7 jours", "\(name) — em 7 dias") }
}
