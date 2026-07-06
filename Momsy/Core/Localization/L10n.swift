import Foundation

struct L10n {
    private let lang: Language

    init(_ lang: Language) { self.lang = lang }

    private func s(_ en: String, _ ru: String, _ de: String, _ es: String, _ fr: String, _ pt: String, _ zh: String) -> String {
        switch lang {
        case .english:    return en
        case .russian:    return ru
        case .german:     return de
        case .spanish:    return es
        case .french:     return fr
        case .portuguese: return pt
        case .chinese:    return zh
        }
    }

    // MARK: — General
    var done: String        { s("Done",         "Готово",       "Fertig",       "Hecho",        "Terminé",      "Concluído", "完成") }
    var cancel: String      { s("Cancel",        "Отмена",       "Abbrechen",    "Cancelar",     "Annuler",      "Cancelar", "取消") }
    var edit: String        { s("Edit",          "Правка",       "Bearbeiten",   "Editar",       "Modifier",     "Editar", "编辑") }
    var save: String        { s("Save",          "Сохранить",    "Speichern",    "Guardar",      "Enregistrer",  "Guardar", "保存") }
    var today: String       { s("Today",         "Сегодня",      "Heute",        "Hoy",          "Aujourd’hui",  "Hoje", "今天") }
    var yesterday: String   { s("Yesterday",     "Вчера",        "Gestern",      "Ayer",         "Hier",         "Ontem", "昨天") }
    var now: String         { s("Now",           "Сейчас",       "Jetzt",        "Ahora",        "Maintenant",   "Agora", "现在") }
    var active: String      { s("ACTIVE",        "ИДЁТ",         "AKTIV",        "ACTIVO",       "EN COURS",     "A DECORRER", "进行中") }
    var paused: String      { s("PAUSED",        "ПАУЗА",        "PAUSE",        "EN PAUSA",     "EN PAUSE",     "EM PAUSA", "已暂停") }
    var add: String         { s("Add",           "Добавить",     "Hinzufügen",   "Añadir",       "Ajouter",      "Adicionar", "添加") }
    var close: String       { s("Close",         "Закрыть",      "Schließen",    "Cerrar",       "Fermer",       "Fechar", "关闭") }
    var confirm: String     { s("Confirm",       "Подтвердить",  "Bestätigen",   "Confirmar",    "Confirmer",    "Confirmar", "确认") }
    var name: String        { s("Name",          "Имя",          "Name",         "Nombre",       "Nom",          "Nome", "姓名") }
    var gender: String      { s("Gender",        "Пол",          "Geschlecht",   "Sexo",         "Sexe",         "Sexo", "性别") }
    var genderUnspecified: String { s("Unspecified", "Не указан", "Nicht angegeben", "Sin especificar", "Non précisé", "Não especificado", "未指定") }
    var couldntComplete: String { s("Couldn’t complete", "Не удалось", "Konnte nicht abgeschlossen werden", "No se pudo completar", "Impossible de terminer", "Não foi possível concluir", "无法完成") }
    var persistenceRecoveryTitle: String {
        s("Local data couldn't be opened",
          "Не удалось открыть локальные данные",
          "Lokale Daten konnten nicht geöffnet werden",
          "No se pudieron abrir los datos locales",
          "Impossible d’ouvrir les données locales",
          "Não foi possível abrir os dados locais",
          "无法打开本地数据")
    }
    var persistenceRecoveryMessage: String {
        s("Momsy couldn't start its on-device database. The app did not crash, and your previous store was backed up before a fresh store was attempted.",
          "Momsy не смогла запустить базу данных на устройстве. Приложение не закрылось аварийно, а предыдущая store была сохранена в backup перед попыткой создать новую.",
          "Momsy konnte die Datenbank auf diesem Gerät nicht starten. Die App ist nicht abgestürzt; der vorherige Store wurde gesichert, bevor ein neuer Store versucht wurde.",
          "Momsy no pudo iniciar la base de datos del dispositivo. La app no se cerró inesperadamente; la base anterior se respaldó antes de intentar crear una nueva.",
          "Momsy n’a pas pu démarrer la base de données de l’appareil. L’app ne s’est pas fermée brutalement; l’ancien store a été sauvegardé avant la tentative de création d’un nouveau store.",
          "A Momsy não conseguiu iniciar a base de dados no dispositivo. A app não encerrou de forma inesperada; a store anterior foi guardada antes de tentar criar uma nova.",
          "Momsy 无法启动设备上的数据库。应用没有崩溃；在尝试创建新 store 前，旧 store 已备份。")
    }
    var persistenceRecoverySuggestion: String {
        s("Free up device storage if needed, then try again. If this keeps happening, send the technical details to support.",
          "Если нужно, освободите место на устройстве и попробуйте снова. Если ошибка повторяется, отправьте технические детали в поддержку.",
          "Gib bei Bedarf Speicherplatz frei und versuche es erneut. Wenn das Problem weiter besteht, sende die technischen Details an den Support.",
          "Libera espacio en el dispositivo si hace falta y vuelve a intentarlo. Si sigue ocurriendo, envía los detalles técnicos a soporte.",
          "Libérez de l’espace sur l’appareil si nécessaire, puis réessayez. Si le problème persiste, envoyez les détails techniques au support.",
          "Liberte espaço no dispositivo, se necessário, e tente novamente. Se continuar a acontecer, envie os detalhes técnicos para o suporte.",
          "如有需要，请释放设备存储空间后重试。如果问题持续发生，请将技术详情发送给支持团队。")
    }
    var persistenceRecoveryRetry: String {
        s("Try Again", "Попробовать снова", "Erneut versuchen", "Intentarlo de nuevo", "Réessayer", "Tentar novamente", "重试")
    }
    var persistenceRecoveryDetails: String {
        s("Technical Details", "Технические детали", "Technische Details", "Detalles técnicos", "Détails techniques", "Detalhes técnicos", "技术详情")
    }

    // MARK: — Weekly Insights (AI weekly report)
    var weeklyInsightTitle: String {
        s("Weekly Report", "Отчёт за неделю", "Wochenbericht", "Informe semanal", "Rapport hebdomadaire", "Relatório semanal", "周报")
    }
    var weeklyInsightSub: String {
        s("AI summary of sleep & feeding", "AI-сводка сна и кормления",
          "KI-Zusammenfassung Schlaf & Ernährung", "Resumen IA de sueño y alimentación",
          "Résumé IA du sommeil et de l’alimentation",
          "Resumo de IA do sono e da alimentação",
          "AI 睡眠与喂养摘要")
    }
    var weeklyInsightSleepHeader: String {
        s("Sleep", "Сон", "Schlaf", "Sueño", "Sommeil", "Sono", "睡眠")
    }
    var weeklyInsightFeedingHeader: String {
        s("Feeding & solids", "Кормление и прикорм", "Ernährung & Beikost", "Alimentación y sólidos",
          "Alimentation et diversification", "Alimentação e sólidos", "喂养与辅食")
    }
    var weeklyInsightEmpty: String {
        s("Your first weekly report will appear here after a full week of tracking.",
          "Ваш первый недельный отчёт появится здесь после недели записей.",
          "Dein erster Wochenbericht erscheint hier nach einer Woche mit Einträgen.",
          "Tu primer informe semanal aparecerá aquí tras una semana de registros.",
          "Votre premier rapport hebdomadaire apparaîtra ici après une semaine de suivi.",
          "O seu primeiro relatório semanal aparecerá aqui após uma semana de registos.",
          "记录满一周后，您的第一份周报将在这里显示。")
    }
    var weeklyInsightNoData: String {
        s("No activity was logged this week, so there's nothing to summarize. Track sleep, feeding, and diapers to get an AI report next week.",
          "На этой неделе не было записей, поэтому обобщать нечего. Записывайте сон, кормления и подгузники, чтобы получить AI-отчёт на следующей неделе.",
          "Diese Woche wurden keine Einträge erfasst, daher gibt es nichts zusammenzufassen. Erfasse Schlaf, Mahlzeiten und Windeln, um nächste Woche einen KI-Bericht zu erhalten.",
          "Esta semana no se registró ninguna actividad, así que no hay nada que resumir. Registra el sueño, las tomas y los pañales para obtener un informe con IA la próxima semana.",
          "Aucune activité n’a été enregistrée cette semaine, il n’y a donc rien à résumer. Enregistrez le sommeil, les repas et les couches pour obtenir un rapport IA la semaine prochaine.",
          "Esta semana não foram registadas atividades, por isso não há nada a resumir. Registe o sono, as mamadas e as fraldas para receber um relatório de IA na próxima semana.",
          "本周没有任何记录，因此暂无可总结的内容。记录睡眠、喂养和尿布，下周即可获得 AI 报告。")
    }
    var weeklyInsightLocked: String {
        s("Weekly AI reports are a Premium feature.",
          "Недельные AI-отчёты доступны в Premium.",
          "Wöchentliche KI-Berichte sind eine Premium-Funktion.",
          "Los informes semanales con IA son una función Premium.",
          "Les rapports IA hebdomadaires sont une fonction Premium.",
          "Os relatórios semanais com IA são uma funcionalidade Premium.",
          "每周 AI 报告是高级版功能。")
    }
    var weeklyInsightError: String {
        s("Couldn't load the report. Please try again.",
          "Не удалось загрузить отчёт. Попробуйте ещё раз.",
          "Bericht konnte nicht geladen werden. Bitte erneut versuchen.",
          "No se pudo cargar el informe. Inténtalo de nuevo.",
          "Impossible de charger le rapport. Veuillez réessayer.",
          "Não foi possível carregar o relatório. Tente novamente.",
          "无法加载报告，请重试。")
    }
    var unlockPremium: String {
        s("Unlock Premium", "Открыть Premium", "Premium freischalten", "Desbloquear Premium",
          "Débloquer Premium", "Desbloquear Premium", "解锁高级版")
    }
    var weeklyReportNotificationTitle: String {
        s("Your weekly report is ready", "Ваш недельный отчёт готов",
          "Dein Wochenbericht ist fertig", "Tu informe semanal está listo",
          "Votre rapport hebdomadaire est prêt", "O seu relatório semanal está pronto",
          "您的周报已生成")
    }
    var weeklyReportNotificationBody: String {
        s("See how your baby slept and ate this week",
          "Посмотрите, как малыш спал и ел на этой неделе",
          "Sieh, wie dein Baby diese Woche geschlafen und gegessen hat",
          "Mira cómo durmió y comió tu bebé esta semana",
          "Découvrez comment votre bébé a dormi et mangé cette semaine",
          "Veja como o seu bebé dormiu e comeu esta semana",
          "看看宝宝这周睡得怎么样、吃得怎么样")
    }
    var note: String        { s("NOTE",          "ЗАМЕТКА",      "NOTIZ",        "NOTA",         "NOTE",         "NOTA", "备注") }
    var history: String     { s("History",       "История",      "Verlauf",      "Historial",    "Historique",   "Histórico", "历史") }
    var remove: String      { s("Remove",        "Удалить",      "Entfernen",    "Quitar",       "Retirer",      "Remover", "移除") }
    var clear: String       { s("Clear",         "Очистить",     "Löschen",      "Borrar",       "Effacer",      "Limpar", "清除") }
    var saved: String       { s("Saved",         "Записано",     "Gespeichert",  "Guardado",     "Enregistré",   "Guardado", "已保存") }
    var start: String       { s("Start",         "Начать",       "Starten",      "Empezar",      "Démarrer",     "Iniciar", "开始") }
    var all: String         { s("All",           "Всё",          "Alle",         "Todo",         "Tout",         "Tudo", "全部") }
    var you: String         { s("you",           "вы",           "du",           "tú",           "vous",         "você", "您") }
    var expired: String     { s("expired",       "истёк",        "abgelaufen",   "caducado",     "expiré",       "expirado", "已过期") }
    var copied: String      { s("Copied!",       "Скопировано!", "Kopiert!",     "¡Copiado!",    "Copié !",      "Copiado!", "已复制！") }
    var reset: String       { s("reset",         "сбросить",     "zurücksetzen", "reiniciar",    "réinitialiser","repor", "重置") }
    var call: String        { s("Call",          "Позвонить",    "Anrufen",      "Llamar",       "Appeler",      "Ligar", "拨打") }
    var days: String        { s("days",          "дней",         "Tage",         "días",         "jours",        "dias", "天") }
    var editSmall: String   { s("edit",          "правка",       "bearbeiten",   "editar",       "modifier",     "editar", "编辑") }
    var delete: String     { s("Delete",        "Удалить",      "Löschen",      "Eliminar",     "Supprimer",    "Eliminar", "删除") }
    var notes: String      { s("Notes",         "Заметки",      "Notizen",      "Notas",        "Notes",        "Notas", "备注") }
    var optional: String   { s("optional",      "необязательно","optional",     "opcional",     "facultatif",   "opcional", "可选") }
    var photo: String      { s("Photo",         "Фото",         "Foto",         "Foto",         "Photo",        "Foto", "照片") }

    // MARK: — Time units
    var unitDay: String     { s("d",    "дн",   "T",   "d",    "j",    "d", "天") }
    var unitMonth: String   { s("mo",   "мес",  "M",   "mes",  "mois", "mês", "月") }
    var unitYear: String    { s("yr",   "лет",  "J",   "año",  "an",   "ano", "岁") }
    var unitHour: String    { s("h",    "ч",    "h",   "h",    "h",    "h", "时") }
    var unitMin: String     { s("min",  "мин",  "min", "min",  "min",  "min", "分") }
    var unitSec: String     { s("sec",  "сек",  "s",   "s",    "s",    "s", "秒") }
    var unitHr: String      { s("hr",   "ч",    "h",   "h",    "h",    "h", "时") }
    var unitKg: String      { s("kg",   "кг",   "kg",  "kg",   "kg",   "kg", "kg") }
    var unitCm: String      { s("cm",   "см",   "cm",  "cm",   "cm",   "cm", "cm") }
    var justNow: String     { s("just now",    "только что",   "gerade eben",          "justo ahora",  "à l’instant",  "agora mesmo", "刚刚") }
    var noSleepYet: String  { s("no sleep yet","не спал",      "noch nicht geschlafen","aún no durmió", "pas encore de sommeil", "ainda sem sono", "还没睡") }
    var noData: String      { s("no data",     "нет данных",   "keine Daten",          "sin datos",    "aucune donnée", "sem dados", "暂无数据") }
    var playingContinuously: String { s("playing continuously","играет непрерывно","spielt kontinuierlich","sonando sin parar","lecture en continu","a tocar continuamente", "持续播放中") }
    var sleepStarted: String { s("Sleep · started", "Сон · начало", "Schlaf · begonnen", "Sueño · iniciado", "Sommeil · commencé", "Sono · iniciado", "睡眠 · 开始") }
    var symptomRecorded: String { s("Symptom · recorded","Симптом · записан","Symptom · erfasst","Síntoma · registrado","Symptôme · enregistré","Sintoma · registado", "症状 · 已记录") }
    var belowP3: String     { s("below P3",  "ниже P3",   "unter P3", "bajo P3",  "sous P3",  "abaixo de P3", "低于 P3") }
    var aboveP97: String    { s("above P97", "выше P97",  "über P97", "sobre P97","au-dessus de P97","acima de P97", "高于 P97") }
    var headShort: String   { s("Head",      "Голова",    "Kopf",     "Cabeza",   "Tête",     "Cabeça", "头围") }
    var hrToStop: String    { s("hr to stop",  "ч до выкл.",  "h bis Stopp",   "h para parar", "h avant l’arrêt", "h até parar", "小时后停止") }
    var minToStop: String   { s("min to stop", "мин до выкл.","min bis Stopp", "min para parar","min avant l’arrêt", "min até parar", "分钟后停止") }
    var secToStop: String   { s("sec to stop", "с до выкл.",  "s bis Stopp",   "s para parar", "s avant l’arrêt", "s até parar", "秒后停止") }
    func minsAgo(_ n: Int) -> String { s("\(n) min ago", "\(n) мин назад", "vor \(n) Min.", "hace \(n) min", "il y a \(n) min", "há \(n) min", "\(n) 分钟前") }
    func hrsAgo(h: Int, m: Int) -> String { s("\(h) hr \(m) min ago", "\(h) ч \(m) мин назад", "vor \(h) h \(m) min", "hace \(h) h \(m) min", "il y a \(h) h \(m) min", "há \(h) h \(m) min", "\(h) 小时 \(m) 分钟前") }
    func hrsAgoFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h ago", "\(h) ч назад", "vor \(h)h", "hace \(h)h", "il y a \(h)h", "há \(h)h", "\(h) 小时前") : s("\(h)h \(m)m ago", "\(h) ч \(m) мин назад", "vor \(h)h \(m)m", "hace \(h)h \(m)m", "il y a \(h)h \(m)m", "há \(h)h \(m)m", "\(h) 小时 \(m) 分前") }
    func hrAgo(_ h: Int) -> String { s("\(h)h ago", "\(h) ч назад", "vor \(h)h", "hace \(h)h", "il y a \(h)h", "há \(h)h", "\(h) 小时前") }
    func sleepDurationFormatted(h: Int, m: Int) -> String { m == 0 ? s("\(h)h", "\(h) ч", "\(h)h", "\(h)h", "\(h)h", "\(h)h", "\(h) 小时") : s("\(h)h \(m)m", "\(h) ч \(m) м", "\(h)h \(m)m", "\(h)h \(m)m", "\(h)h \(m)m", "\(h)h \(m)m", "\(h) 小时 \(m) 分") }
    /// Formats a duration in minutes into a localized string (e.g. "45 min" or "2h 30m").
    func durationFormatted(_ mins: Int) -> String {
        guard mins >= 60 else { return "\(mins) \(unitMin)" }
        let h = mins / 60, m = mins % 60
        return sleepDurationFormatted(h: h, m: m)
    }
    func diaperLogEntry(count: Int) -> String { s("Diaper #\(count) · wet", "Подгузник #\(count) · мокрый", "Windel #\(count) · nass", "Pañal #\(count) · mojado", "Couche #\(count) · mouillée", "Fralda #\(count) · molhada", "尿布 #\(count) · 湿") }
    func feedingLogEntry(dur: Int, side: String) -> String { s("Feeding · \(dur) min · \(side)", "Кормление · \(dur) мин · \(side)", "Fütterung · \(dur) min · \(side)", "Toma · \(dur) min · \(side)", "Tétée · \(dur) min · \(side)", "Mamada · \(dur) min · \(side)", "喂养 · \(dur) 分钟 · \(side)") }
    func sleepLogEntry(dur: String) -> String { s("Sleep · \(dur)", "Сон · \(dur)", "Schlaf · \(dur)", "Sueño · \(dur)", "Sommeil · \(dur)", "Sono · \(dur)", "睡眠 · \(dur)") }
    func todayEntry(_ date: String) -> String { s("Today · \(date)", "Сегодня · \(date)", "Heute · \(date)", "Hoy · \(date)", "Aujourd’hui · \(date)", "Hoje · \(date)", "今天 · \(date)") }
    func yesterdayEntry(_ date: String) -> String { s("Yesterday · \(date)", "Вчера · \(date)", "Gestern · \(date)", "Ayer · \(date)", "Hier · \(date)", "Ontem · \(date)", "昨天 · \(date)") }

    // MARK: — Tabs / Sections
    var tabHome: String     { s("Home",     "Главная",   "Startseite", "Inicio", "Accueil", "Início", "首页") }
    var tabSleep: String    { s("Sleep",    "Сон",       "Schlaf",     "Sueño",  "Sommeil", "Sono", "睡眠") }
    var tabFeeding: String  { s("Feeding",  "Кормление", "Füttern",    "Tomas",  "Tétées",  "Mamadas", "喂养") }
    var tabSounds: String   { s("Sounds",   "Звуки",     "Töne",       "Sonidos","Sons",    "Sons", "声音") }
    var tabDiary: String    { s("Diary",    "Дневник",   "Tagebuch",   "Diario", "Journal", "Diário", "日记") }
    var tabLeaps: String    { s("Leaps",    "Скачки",    "Schübe",     "Saltos", "Bonds",   "Saltos", "飞跃期") }
    var tabReport: String   { s("Report",   "Отчёт",     "Bericht",    "Informe","Rapport", "Relatório", "报告") }
    var tabTracking: String { s("Tracking", "Показатели","Messung",    "Medidas","Mesures", "Medições", "指标") }
    var tabSharing: String  { s("Family",   "Семья",     "Familie",    "Familia","Famille", "Família", "家庭") }

    // MARK: — Greetings
    var goodNight: String       { s("Good night,",     "Доброй ночи,",  "Gute Nacht,",  "Buenas noches,", "Bonne nuit,", "Boa noite,", "晚安，") }
    var goodMorning: String     { s("Good morning",    "Доброе утро",   "Guten Morgen", "Buenos días",    "Bonjour", "Bom dia", "早上好") }
    var goodAfternoon: String   { s("Good afternoon",  "Добрый день",   "Guten Tag",    "Buenas tardes",  "Bon après-midi", "Boa tarde", "下午好") }
    var goodEvening: String     { s("Good evening",    "Добрый вечер",  "Guten Abend",  "Buenas tardes",  "Bonsoir", "Boa noite", "晚上好") }
    var goodMorningGreeting: String   { s("Good morning,",   "Доброе утро,",   "Guten Morgen,", "Buenos días,",   "Bonjour,", "Bom dia,", "早上好，") }
    var goodAfternoonGreeting: String { s("Good afternoon,", "Добрый день,",   "Guten Tag,",    "Buenas tardes,", "Bon après-midi,", "Boa tarde,", "下午好，") }
    var goodEveningGreeting: String   { s("Good evening,",   "Добрый вечер,",  "Guten Abend,",  "Buenas noches,", "Bonsoir,", "Boa noite,", "晚上好，") }

    // MARK: — Today / Home
    var baby: String         { s("Baby",         "Малыш",        "Baby",         "Bebé",     "Bébé", "Bebé", "宝宝") }
    var logEntry: String     { s("Log",          "Журнал",       "Tagebuch",     "Registro", "Journal", "Registo", "记录") }
    var quickLog: String     { s("Quick Log",    "Быстрый лог",  "Schnellnotiz", "Registro rápido", "Saisie rapide", "Registo rápido", "快速记录") }
    var quickLogLabel: String{ s("Quick log",    "Быстро записать", "Schnell erfassen", "Registrar rápido", "Saisie rapide", "Registar rápido", "快速记录") }
    var feeding: String      { s("Feeding",      "Кормление",    "Fütterung",    "Toma",     "Tétée", "Mamada", "喂养") }
    var sleep: String        { s("Sleep",        "Сон",          "Schlaf",       "Sueño",    "Sommeil", "Sono", "睡眠") }
    var diaper: String       { s("Diaper",       "Подгузник",    "Windel",       "Pañal",    "Couche", "Fralda", "尿布") }
    var diaperQuick: String  { s("Diaper",       "Памп",         "Windel",       "Pañal",    "Couche", "Fralda", "尿布") }
    var diapers: String      { s("Diapers",      "Подгузники",   "Windeln",      "Pañales",  "Couches", "Fraldas", "尿布") }
    var diary: String        { s("Diary",        "Дневник",      "Tagebuch",     "Diario",   "Journal", "Diário", "日记") }
    var symptom: String      { s("Symptom",      "Симптом",      "Symptom",      "Síntoma",  "Symptôme", "Sintoma", "症状") }
    var walk: String         { s("Walk",         "Прогулка",     "Spaziergang",  "Paseo",    "Promenade", "Passeio", "散步") }
    var bath: String         { s("Bath",         "Купание",      "Bad",          "Baño",     "Bain", "Banho", "洗澡") }
    var vitamins: String     { s("Vitamins",     "Витамины",     "Vitamine",     "Vitaminas","Vitamines", "Vitaminas", "维生素") }
    var stoolLabel: String     { s("Stool",           "Стул",                  "Stuhlgang",        "Deposición", "Selles", "Fezes", "大便") }
    var stoolLogged: String    { s("Stool · logged",  "Стул · записан",        "Stuhlgang · notiert", "Deposición · registrada", "Selles · enregistrées", "Fezes · registadas", "大便 · 已记录") }
    var addStoolTitle: String  { s("Add Entry",       "Новая запись",          "Eintrag",          "Nueva entrada", "Nouvelle entrée", "Novo registo", "新增记录") }
    var stoolTimeLabel: String { s("Time",            "Время",                 "Zeit",             "Hora",       "Heure", "Hora", "时间") }
    var walkLogged: String   { s("Walk · logged",    "Прогулка · записана",   "Spaziergang · erfasst", "Paseo · registrado", "Promenade · enregistrée", "Passeio · registado", "散步 · 已记录") }
    var bathLogged: String   { s("Bath · logged",    "Купание · записано",    "Bad · erfasst",    "Baño · registrado", "Bain · enregistré", "Banho · registado", "洗澡 · 已记录") }
    var vitaminsGiven: String { s("Vitamins · given","Витамины · приняты",    "Vitamine · gegeben","Vitaminas · dadas", "Vitamines · données", "Vitaminas · dadas", "维生素 · 已服用") }
    var vitaminNamePlaceholder: String { s("e.g. Vitamin D", "напр. Витамин D",     "z.B. Vitamin D",   "p. ej. Vitamina D", "p. ex. Vitamine D", "ex.: Vitamina D", "例如：维生素 D") }
    var todaysVitamins: String         { s("Today's vitamins","Витамины сегодня",    "Vitamine heute",   "Vitaminas de hoy", "Vitamines du jour", "Vitaminas de hoje", "今日维生素") }
    var noVitaminsYet: String          { s("No vitamins added yet","Витамины ещё не добавлены","Noch keine Vitamine","Aún sin vitaminas", "Aucune vitamine ajoutée", "Ainda sem vitaminas", "尚未添加维生素") }
    var vitaminNameLabel: String       { s("VITAMIN NAME", "НАЗВАНИЕ ВИТАМИНА",    "VITAMINNAME",      "NOMBRE DE LA VITAMINA", "NOM DE LA VITAMINE", "NOME DA VITAMINA", "维生素名称") }
    func vitaminAdded(name: String) -> String { s("Vitamins · \(name)", "Витамины · \(name)", "Vitamine · \(name)", "Vitaminas · \(name)", "Vitamines · \(name)", "Vitaminas · \(name)", "维生素 · \(name)") }
    var walkTracker: String  { s("WALK TRACKER",    "ТРЕКЕР ПРОГУЛКИ",       "GEHTRACKER",       "REGISTRO DE PASEO", "SUIVI DE PROMENADE", "REGISTO DE PASSEIO", "散步记录") }
    var walking: String      { s("walking…",        "гуляем…",               "gehen…",           "paseando…", "en promenade…", "a passear…", "散步中…") }
    var startWalk: String    { s("Start Walk",      "Начать прогулку",       "Spaziergang starten", "Empezar paseo", "Démarrer la promenade", "Iniciar passeio", "开始散步") }
    var stopWalk: String     { s("Stop Walk",       "Закончить прогулку",    "Spaziergang stoppen", "Terminar paseo", "Terminer la promenade", "Terminar passeio", "结束散步") }
    var addWalkTitle: String { s("Add Walk",        "Добавить прогулку",     "Spaziergang erfassen", "Añadir paseo", "Ajouter une promenade", "Adicionar passeio", "添加散步") }
    var noWalkYet: String    { s("no walk yet",     "ещё не гуляли",         "noch nicht spaziert", "aún sin paseo", "pas encore de promenade", "ainda sem passeio", "还没散步") }
    func walkLogEntry(dur: Int) -> String { s("Walk · \(dur) min", "Прогулка · \(dur) мин", "Spaziergang · \(dur) min", "Paseo · \(dur) min", "Promenade · \(dur) min", "Passeio · \(dur) min", "散步 · \(dur) 分钟") }
    var bathTracker: String  { s("BATH TRACKER",     "ТРЕКЕР КУПАНИЯ",        "BADTRACKER",       "REGISTRO DE BAÑO", "SUIVI DU BAIN", "REGISTO DE BANHO", "洗澡记录") }
    var bathing: String      { s("bathing…",         "купаемся…",             "Baden…",           "bañando…", "au bain…", "a tomar banho…", "洗澡中…") }
    var startBath: String    { s("Start Bath",       "Начать купание",        "Bad starten",      "Empezar baño", "Démarrer le bain", "Iniciar banho", "开始洗澡") }
    var stopBath: String     { s("Stop Bath",        "Закончить купание",     "Bad stoppen",      "Terminar baño", "Terminer le bain", "Terminar banho", "结束洗澡") }
    var noBathYet: String    { s("no bath yet",      "ещё не купались",       "noch nicht gebadet", "aún sin baño", "pas encore de bain", "ainda sem banho", "还没洗澡") }
    var addBathTitle: String { s("Add Bath",         "Добавить купание",      "Bad erfassen",     "Añadir baño", "Ajouter un bain", "Adicionar banho", "添加洗澡") }
    func bathLogEntry(dur: Int) -> String { s("Bath · \(dur) min", "Купание · \(dur) мин", "Bad · \(dur) min", "Baño · \(dur) min", "Bain · \(dur) min", "Banho · \(dur) min", "洗澡 · \(dur) 分钟") }

    var pumping: String         { s("Pumping",          "Сцеживание",          "Pumpen",      "Extracción", "Tire-lait", "Extração", "吸奶") }
    var pumpingSideLabel: String { s("SIDE",            "СТОРОНА",             "SEITE",       "LADO",       "CÔTÉ", "LADO", "侧别") }
    var pumpingLeft: String     { s("Left",             "Левая",               "Links",       "Izquierdo",  "Gauche", "Esquerdo", "左侧") }
    var pumpingRight: String    { s("Right",            "Правая",              "Rechts",      "Derecho",    "Droite", "Direito", "右侧") }
    var pumpingBoth: String     { s("Both",             "Обе",                 "Beide",       "Ambos",      "Les deux", "Ambos", "双侧") }
    var pumpingVolume: String   { s("VOLUME (ML)",      "ОБЪЁМ (МЛ)",          "MENGE (ML)",  "VOLUMEN (ML)","VOLUME (ML)", "VOLUME (ML)", "容量（毫升）") }
    var pumpingStart: String    { s("Start",            "Начать",              "Starten",     "Empezar",    "Démarrer", "Iniciar", "开始") }
    var pumpingStop: String     { s("Done",             "Готово",              "Fertig",      "Hecho",      "Terminé", "Concluído", "完成") }
    var noPumpingYet: String    { s("No pumping today", "Сцеживаний ещё нет",  "Noch kein Pumpen", "Sin extracción hoy", "Aucun tirage aujourd’hui", "Sem extração hoje", "今天还没吸奶") }
    var pumpingTracker: String  { s("PUMPING TRACKER",  "ТРЕКЕР СЦЕЖИВАНИЯ",   "PUMPEN-TRACKER", "REGISTRO DE EXTRACCIÓN", "SUIVI DU TIRE-LAIT", "REGISTO DE EXTRAÇÃO", "吸奶记录") }
    func pumpingLogEntry(dur: Int, ml: Int) -> String {
        ml > 0
            ? s("Pumping · \(dur) min · \(ml) ml",   "Сцеживание · \(dur) мин · \(ml) мл",   "Pumpen · \(dur) min · \(ml) ml",   "Extracción · \(dur) min · \(ml) ml",   "Tire-lait · \(dur) min · \(ml) ml",   "Extração · \(dur) min · \(ml) ml",   "吸奶 · \(dur) 分钟 · \(ml) 毫升")
            : s("Pumping · \(dur) min",               "Сцеживание · \(dur) мин",               "Pumpen · \(dur) min",              "Extracción · \(dur) min",              "Tire-lait · \(dur) min",              "Extração · \(dur) min",              "吸奶 · \(dur) 分钟")
    }

    var mood: String         { s("Mood",         "Настроение",   "Stimmung",     "Ánimo",   "Humeur", "Humor", "心情") }
    var feedLabel: String    { s("Feed",         "Еда",          "Essen",        "Comida",  "Repas", "Refeição", "喂食") }
    var sleeping: String     { s("sleeping…",    "спит…",        "schläft…",     "durmiendo…", "dort…", "a dormir…", "睡觉中…") }
    var feedingLabel: String { s("FEEDING",      "КОРМЛЕНИЕ",    "FÜTTERUNG",    "TOMA",    "TÉTÉE", "MAMADA", "喂养") }
    var typicalLengthHint: String { s("Typical length — 18 min. Tap pause or stop.", "Обычная длина — 18 мин. Нажмите паузу или стоп.", "Typische Länge — 18 Min. Pause oder Stop tippen.", "Duración típica — 18 min. Pulsa pausa o parar.", "Durée typique — 18 min. Touchez pause ou stop.", "Duração típica — 18 min. Toque em pausa ou parar.", "通常时长 18 分钟。点击暂停或停止。") }
    var usuallyAroundThisTime: String { s("Usually around this time — tap to start.", "Обычно в это время — нажмите для старта.", "Normalerweise um diese Zeit — zum Starten tippen.", "Suele ser a esta hora — pulsa para empezar.", "Habituellement à cette heure — touchez pour démarrer.", "Normalmente a esta hora — toque para iniciar.", "通常在这个时间——点击开始。") }
    var tipOfDay: String     { s("Tip of the day",   "Подсказка дня",      "Tipp des Tages", "Consejo del día", "Conseil du jour", "Dica do dia", "每日小贴士") }
    var todaySoFar: String   { s("Today so far",     "Сегодня уже было",   "Heute bisher",   "Hoy hasta ahora", "Aujourd’hui jusqu’ici", "Hoje até agora", "今天到目前") }
    var todayUpper: String   { s("TODAY",            "СЕГОДНЯ",            "HEUTE",          "HOY",     "AUJOURD’HUI", "HOJE", "今天") }
    func leapPill(_ n: Int) -> String { s("Leap #\(n)", "Скачок №\(n)", "Schub #\(n)", "Salto n.º \(n)", "Bond n° \(n)", "Salto n.º \(n)", "飞跃期 #\(n)") }
    func leapDayCard(n: Int, day: Int, total: Int) -> String { s("LEAP #\(n) · DAY \(day) OF ~\(total)", "СКАЧОК №\(n) · ДЕНЬ \(day) ИЗ ~\(total)", "SCHUB #\(n) · TAG \(day) VON ~\(total)", "SALTO N.º \(n) · DÍA \(day) DE ~\(total)", "BOND N° \(n) · JOUR \(day) SUR ~\(total)", "SALTO N.º \(n) · DIA \(day) DE ~\(total)", "飞跃期 #\(n) · 第 \(day) 天 / 约 \(total) 天") }
    func leapNumberCard(_ n: Int) -> String { s("LEAP #\(n)", "СКАЧОК №\(n)", "SCHUB #\(n)", "SALTO N.º \(n)", "BOND N° \(n)", "SALTO N.º \(n)", "飞跃期 #\(n)") }
    func leapNormalLabel(name: String) -> String { s("«\(name)» — this is normal", "«\(name)» — это нормально", "«\(name)» — das ist normal", "«\(name)» — es normal", "«\(name)» — c’est normal", "«\(name)» — é normal", "「\(name)」——这是正常的") }
    var leapCryingNote: String { s("Crying, poor sleep, wants to be held. Not sick — growing.", "Плачет, плохо спит, просит руки. Он не болен — он растёт.", "Weint, schläft schlecht, will gehalten werden. Nicht krank — wächst.", "Llora, duerme mal, quiere brazos. No está enfermo — está creciendo.", "Pleure, dort mal, réclame les bras. Pas malade — il grandit.", "Chora, dorme mal, quer colo. Não está doente — está a crescer.", "哭闹、睡不好、想要抱抱。不是生病——是在成长。") }
    var leapSettledNote: String { s("The hard part has passed — practicing new skills.", "Самое сложное позади — осваивает новые навыки.", "Das Schwerste ist vorbei — übt neue Fähigkeiten.", "Lo más difícil ya pasó — practica nuevas habilidades.", "Le plus dur est passé — il s’exerce à de nouvelles compétences.", "A parte mais difícil passou — está a praticar novas competências.", "最难的阶段已经过去——正在练习新技能。") }

    func howDidSleep(name: String) -> String { s("how did \(name) sleep?", "как \(name) спал?", "wie hat \(name) geschlafen?", "¿cómo durmió \(name)?", "comment \(name) a-t-il dormi ?", "como dormiu \(name)?", "\(name) 睡得怎么样？") }
    func feedingActiveLabel(side: String) -> String { s("active · \(side)", "идёт · \(side)", "aktiv · \(side)", "activo · \(side)", "en cours · \(side)", "a decorrer · \(side)", "进行中 · \(side)") }
    func feedingDuration(_ time: String) -> String { s("Feeding has been going for \(time). Typical length is 18 min.", "Кормление идёт уже \(time). Обычная длина — 18 мин.", "Fütterung dauert seit \(time). Typische Länge 18 Min.", "La toma lleva \(time). La duración típica es 18 min.", "La tétée dure depuis \(time). La durée typique est de 18 min.", "A mamada já dura \(time). A duração típica é de 18 min.", "喂养已进行 \(time)。通常时长为 18 分钟。") }
    func feedingTip(ago: String, name: String) -> String { s("\(ago) since last feeding — \(name) usually eats now. If crying — try breast first.", "Прошло \(ago) с прошлого кормления — обычно \(name) ест в это время. Если плачет — попробуйте сначала грудь.", "\(ago) seit der letzten Fütterung — \(name) isst normalerweise jetzt.", "\(ago) desde la última toma — \(name) suele comer ahora. Si llora, prueba primero el pecho.", "\(ago) depuis la dernière tétée — \(name) mange habituellement maintenant. S’il pleure, proposez d’abord le sein.", "\(ago) desde a última mamada — \(name) costuma comer agora. Se chorar, ofereça primeiro o peito.", "距上次喂养已 \(ago)——\(name) 通常这时候要吃。如果哭闹，先试试母乳。") }
    func leapContrastsTip(name: String) -> String { s("During this leap \(name) is especially drawn to contrasts — show a black-and-white book.", "В этот скачок \(name) особенно интересны контрасты — покажите чёрно-белую книжку.", "In diesem Schub ist \(name) besonders von Kontrasten angezogen.", "Durante este salto a \(name) le atraen los contrastes — muéstrale un libro en blanco y negro.", "Pendant ce bond, \(name) est particulièrement attiré par les contrastes — montrez-lui un livre en noir et blanc.", "Durante este salto, \(name) sente-se especialmente atraído por contrastes — mostre um livro a preto e branco.", "在这次飞跃期，\(name) 对黑白对比特别感兴趣——给他看一本黑白图画书。") }
    func diaperCountDay(_ n: Int) -> String { s("\(n) / day", "\(n) / день", "\(n) / Tag", "\(n) / día", "\(n) / jour", "\(n) / dia", "\(n) / 天") }
    func entriesCount(_ n: Int) -> String { s("\(n) entries", "\(n) записей", "\(n) Einträge", "\(n) entradas", "\(n) entrées", "\(n) registos", "\(n) 条记录") }
    var noEntriesYet: String { s("Nothing logged yet today", "Ещё ничего не записано", "Noch nichts eingetragen", "Nada registrado hoy aún", "Rien d’enregistré aujourd’hui", "Ainda nada registado hoje", "今天还没有任何记录") }

    // MARK: — Feeding
    var feedingLeft: String   { s("Left",   "Левая",   "Links",   "Izquierdo", "Gauche", "Esquerdo", "左侧") }
    var feedingRight: String  { s("Right",  "Правая",  "Rechts",  "Derecho",   "Droite", "Direito", "右侧") }
    var feedingBottle: String { s("Bottle", "Бутылка", "Flasche", "Biberón",   "Biberon", "Biberão", "奶瓶") }
    var typicalDuration: String { s("of ≈ 18 min typical", "из ≈ 18 мин обычно", "von ≈ 18 min üblich", "de ≈ 18 min típicos", "sur ≈ 18 min en moyenne", "de ≈ 18 min típicos", "约 18 分钟（通常）") }
    var pause: String         { s("‖ Pause",     "‖ Пауза",      "‖ Pause",      "‖ Pausa",   "‖ Pause", "‖ Pausa", "‖ 暂停") }
    var resume: String        { s("▶ Resume",    "▶ Продолжить", "▶ Fortsetzen", "▶ Reanudar","▶ Reprendre", "▶ Retomar", "▶ 继续") }
    var stopDone: String      { s("■ Done",      "■ Закончить",  "■ Fertig",     "■ Terminar","■ Terminer", "■ Concluir", "■ 完成") }
    var feedings: String      { s("feedings",    "кормлений",    "Mahlzeiten",   "tomas",     "tétées", "mamadas", "次喂养") }
    var tapTagMood: String    { s("tap a tag to add a mood note", "нажмите тег для записи настроения", "Tag antippen für Stimmungsnotiz", "pulsa una etiqueta para añadir una nota de ánimo", "touchez une étiquette pour ajouter une note d’humeur", "toque numa etiqueta para adicionar uma nota de humor", "点击标签添加心情记录") }
    var moodCalm: String      { s("😊 calm",        "😊 спокоен",    "😊 ruhig",        "😊 tranquilo", "😊 calme", "😊 calmo", "😊 平静") }
    var moodAsleep: String    { s("😴 fell asleep",  "😴 уснул",      "😴 eingeschlafen", "😴 se durmió", "😴 endormi", "😴 adormeceu", "😴 睡着了") }
    var moodSpitUp: String    { s("🤢 spit up",      "🤢 срыгнул",    "🤢 gespuckt",     "🤢 regurgitó", "🤢 régurgité", "🤢 regurgitou", "🤢 吐奶") }
    var customTag: String     { s("+ custom",       "+ свой",        "+ eigenes",       "+ personalizado", "+ personnalisé", "+ personalizado", "+ 自定义") }
    var cancelTag: String     { s("✕ cancel",       "✕ отмена",      "✕ abbrechen",     "✕ cancelar", "✕ annuler", "✕ cancelar", "✕ 取消") }
    var customMoodPlaceholder: String { s("e.g. cried a bit, then calmed", "напр. немного поплакал, успокоился", "z.B. kurz geweint, dann ruhig", "p. ej. lloró un poco y se calmó", "p. ex. a un peu pleuré, puis s’est calmé", "ex.: chorou um pouco e acalmou", "例如：哭了一会儿，然后平静下来") }
    var feedingsToday: String { s("feedings today", "кормлений сегодня", "Mahlzeiten heute", "tomas hoy", "tétées aujourd’hui", "mamadas hoje", "今日喂养次数") }
    var mlUnit: String        { s("ml", "мл", "ml", "ml", "ml", "ml", "毫升") }
    var bottleVolume: String  { s("VOLUME", "ОБЪЁМ", "MENGE", "VOLUMEN", "VOLUME", "VOLUME", "容量") }

    func feedingsCount(_ n: Int) -> String { s("\(n) feedings", "\(n) кормлений", "\(n) Mahlzeiten", "\(n) tomas", "\(n) tétées", "\(n) mamadas", "\(n) 次喂养") }
    var addFeedingTitle: String      { s("Add Feeding",     "Добавить кормление",  "Fütterung eintragen", "Añadir toma", "Ajouter une tétée", "Adicionar mamada", "添加喂养") }
    var feedingStartedLabel: String  { s("STARTED",        "НАЧАЛО",              "BEGINN",     "INICIO",  "DÉBUT", "INÍCIO", "开始") }
    var feedingEndedLabel: String    { s("ENDED",          "КОНЕЦ",               "ENDE",       "FIN",     "FIN", "FIM", "结束") }
    var feedingSideLabel: String     { s("SIDE",           "СТОРОНА",             "SEITE",      "LADO",    "CÔTÉ", "LADO", "侧别") }
    var enterManuallyLabel: String   { s("enter manually", "ввести вручную",      "manuell eingeben", "introducir manual", "saisir manuellement", "introduzir manualmente", "手动输入") }
    var addPumpingTitle: String      { s("Add Pumping",    "Добавить сцеживание", "Pumpen eintragen", "Añadir extracción", "Ajouter un tirage", "Adicionar extração", "添加吸奶") }
    var pumpingTypicalDuration: String { s("of ≈ 20 min typical", "из ≈ 20 мин обычно", "von ≈ 20 min üblich", "de ≈ 20 min típicos", "sur ≈ 20 min en moyenne", "de ≈ 20 min típicos", "约 20 分钟（通常）") }

    // MARK: — Sleep
    var sleepStart: String   { s("Start sleep",   "Начать сон",    "Schlaf starten", "Empezar sueño", "Démarrer le sommeil", "Iniciar sono", "开始睡眠") }
    var sleepStop: String    { s("Wake up",        "Проснулся",     "Aufwachen",     "Despertar",     "Réveil", "Acordar", "醒来") }
    var stopSleep: String    { s("Stop Sleep",     "Остановить сон","Schlaf stoppen", "Parar sueño",  "Arrêter le sommeil", "Parar sono", "结束睡眠") }
    var sleepDuration: String { s("Duration",      "Длительность",  "Dauer",         "Duración",      "Durée", "Duração", "时长") }
    var asleep: String       { s("Asleep",         "Спит",          "Schläft",       "Dormido",       "Endormi", "A dormir", "睡着") }
    var awake: String        { s("Awake",          "Проснулся",     "Wach",          "Despierto",     "Éveillé", "Acordado", "醒着") }
    var sleepTracker: String { s("SLEEP TRACKER",  "ТРЕКЕР СНА",    "SCHLAFTRACKER", "REGISTRO DE SUEÑO", "SUIVI DU SOMMEIL", "REGISTO DO SONO", "睡眠记录") }
    var totalToday: String   { s("Total today",    "Всего сегодня", "Heute gesamt",  "Total hoy",     "Total aujourd’hui", "Total hoje", "今日总计") }
    var sessions: String     { s("Sessions",       "Сессий",        "Sitzungen",     "Sesiones",      "Sessions", "Sessões", "次数") }
    var sleepQuality: String { s("SLEEP QUALITY",  "КАЧЕСТВО СНА",  "SCHLAFQUALITÄT", "CALIDAD DEL SUEÑO", "QUALITÉ DU SOMMEIL", "QUALIDADE DO SONO", "睡眠质量") }
    var qualityGood: String    { s("😌 Good",      "😌 Хорошо",     "😌 Gut",        "😌 Bueno",   "😌 Bon", "😌 Bom", "😌 好") }
    var qualityNormal: String  { s("😐 Normal",    "😐 Нормально",  "😐 Normal",     "😐 Normal",  "😐 Normal", "😐 Normal", "😐 一般") }
    var qualityRestless: String{ s("😣 Restless",  "😣 Беспокойно", "😣 Unruhig",    "😣 Inquieto","😣 Agité", "😣 Agitado", "😣 不安") }

    // MARK: — Sleep forecast
    var sleepForecastNapTitle: String {
        s("Next sleep", "Следующий сон", "Nächster Schlaf", "Próximo sueño", "Prochain sommeil", "Próximo sono", "下次睡眠")
    }
    var sleepForecastBedtimeTitle: String {
        s("Time for bedtime", "Пора укладывать на ночь", "Zeit fürs Schlafengehen",
          "Hora de dormir", "L’heure du coucher", "Hora de deitar", "该睡觉了")
    }
    func sleepForecastRange(_ start: String, _ end: String) -> String {
        s("Window \(start)–\(end)", "Окно \(start)–\(end)", "Fenster \(start)–\(end)",
          "Ventana \(start)–\(end)", "Fenêtre \(start)–\(end)", "Janela \(start)–\(end)", "时段 \(start)–\(end)")
    }
    var sleepForecastConfidenceLow: String {
        s("Low confidence", "Низкая точность", "Geringe Sicherheit",
          "Confianza baja", "Confiance faible", "Confiança baixa", "可信度低")
    }
    var sleepForecastConfidenceMedium: String {
        s("Medium confidence", "Средняя точность", "Mittlere Sicherheit",
          "Confianza media", "Confiance moyenne", "Confiança média", "可信度中")
    }
    var sleepForecastConfidenceHigh: String {
        s("High confidence", "Высокая точность", "Hohe Sicherheit",
          "Confianza alta", "Confiance élevée", "Confiança alta", "可信度高")
    }
    var sleepForecastBasisAge: String {
        s("by age", "по возрасту", "nach Alter", "por edad", "selon l’âge", "por idade", "按年龄")
    }
    var sleepForecastBasisPersonalized: String {
        s("from your data", "по вашим данным", "aus deinen Daten",
          "según tus datos", "d’après vos données", "com base nos seus dados", "根据您的数据")
    }
    var sleepForecastOverdueTitle: String {
        s("Sleep overdue", "Окно сна пропущено", "Schlaf überfällig",
          "Sueño atrasado", "Sommeil en retard", "Sono atrasado", "睡眠已超时")
    }
    var sleepForecastOverdueAction: String {
        s("Settle now", "Уложить сейчас", "Jetzt hinlegen",
          "Acostar ya", "Coucher maintenant", "Deitar agora", "现在哄睡")
    }
    func sleepForecastAwakeFor(_ dur: String) -> String {
        s("awake \(dur)", "бодрствует \(dur)", "wach seit \(dur)",
          "despierto \(dur)", "éveillé depuis \(dur)", "acordado há \(dur)", "已清醒 \(dur)")
    }
    var sleepForecastOverduePill: String {
        s("overdue", "просрочено", "überfällig", "atrasado", "en retard", "atrasado", "已超时")
    }

    var feedingChartTitle: String  { s("Feeding",          "Кормление",             "Stillen",        "Tomas",   "Tétées", "Mamadas", "喂养") }
    var feedingPeriodWeek: String  { s("7 days",           "7 дней",                "7 Tage",         "7 días",  "7 jours", "7 dias", "7 天") }
    var feedingPeriodMonth: String { s("30 days",          "30 дней",               "30 Tage",        "30 días", "30 jours", "30 dias", "30 天") }
    var feedingAvgPerDay: String   { s("avg/day",          "ср/день",               "Ø/Tag",          "med/día", "moy/jour", "méd/dia", "日均") }
    var feedingTotalSessions: String { s("total",          "всего",                 "gesamt",         "total",   "total", "total", "总计") }
    var feedingAvgDuration: String { s("avg dur.",         "ср. длит.",             "Ø Dauer",        "dur. med.", "durée moy.", "dur. méd.", "平均时长") }
    var feedingNoData: String      { s("No data for period", "Нет данных за период", "Keine Daten",   "Sin datos del periodo", "Aucune donnée pour la période", "Sem dados para o período", "该时段无数据") }

    var sleepChartTitle: String  { s("Sleep chart",   "График сна",    "Schlafdiagramm", "Gráfico de sueño", "Graphique du sommeil", "Gráfico do sono", "睡眠图表") }
    var sleepPeriodWeek: String  { s("7 days",        "7 дней",        "7 Tage",         "7 días",  "7 jours", "7 dias", "7 天") }
    var sleepPeriodMonth: String { s("30 days",       "30 дней",       "30 Tage",        "30 días", "30 jours", "30 dias", "30 天") }
    var sleepAverage: String     { s("Average",       "Среднее",       "Durchschn.",     "Media",   "Moyenne", "Média", "平均") }
    var sleepNormLabel: String   { s("Norm",          "Норма",         "Norm",           "Norma",   "Norme", "Norma", "标准") }
    var sleepInNorm: String      { s("In norm",       "В норме",       "In Norm",        "En la norma", "Dans la norme", "Dentro da norma", "达标") }
    var sleepBelowNorm: String   { s("Below norm",    "Ниже нормы",    "Unter Norm",     "Bajo la norma", "Sous la norme", "Abaixo da norma", "低于标准") }
    var sleepAboveNorm: String   { s("Above norm",    "Выше нормы",    "Über Norm",      "Sobre la norma", "Au-dessus de la norme", "Acima da norma", "高于标准") }
    var sleepNoData: String      { s("No sleep data yet", "Данных о сне пока нет", "Noch keine Schlafdaten", "Aún sin datos de sueño", "Pas encore de données de sommeil", "Ainda sem dados de sono", "暂无睡眠数据") }
    var addSleepTitle: String    { s("Add Sleep",          "Добавить сон",           "Schlaf eintragen", "Añadir sueño", "Ajouter un sommeil", "Adicionar sono", "添加睡眠") }

    // MARK: — Diaper
    var diaperWet: String   { s("Wet",    "Мокрый",  "Nass",      "Mojado", "Mouillée", "Molhada", "湿") }
    var diaperDirty: String { s("Dirty",  "Грязный", "Schmutzig", "Sucio",  "Sale", "Suja", "脏") }
    var diaperChange: String{ s("Change", "Смена",   "Wechsel",   "Cambio", "Change", "Muda", "更换") }
    var diaperCount: String { s("changes today", "смен сегодня", "Wechsel heute", "cambios hoy", "changes aujourd’hui", "mudas hoje", "今日更换") }

    // MARK: — Diary
    var addNote: String     { s("Add note",      "Добавить заметку", "Notiz hinzufügen", "Añadir nota", "Ajouter une note", "Adicionar nota", "添加备注") }
    var addPhoto: String    { s("Add photo",     "Добавить фото",    "Foto hinzufügen",  "Añadir foto", "Ajouter une photo", "Adicionar foto", "添加照片") }
    var milestone: String   { s("Milestone",     "Веха",             "Meilenstein",      "Hito",   "Étape", "Marco", "里程碑") }
    var milestones: String  { s("Milestones",    "Вехи",             "Meilensteine",     "Hitos",  "Étapes", "Marcos", "里程碑") }
    var milestoneFirstSmile: String { s("First smile", "Первая улыбка", "Erstes Lächeln", "Primera sonrisa", "Premier sourire", "Primeiro sorriso", "第一次微笑") }
    var milestoneRolledOver: String { s("Rolled over", "Перевернулся", "Umdrehen", "Se dio la vuelta", "S’est retourné", "Virou-se", "会翻身了") }
    var milestoneSatUpAlone: String { s("Sat up alone", "Сел сам", "Alleine hingesetzt", "Se sentó solo", "S’est assis seul", "Sentou-se sem ajuda", "能独自坐起") }
    var milestoneFirstTooth: String { s("First tooth", "Первый зуб", "Erster Zahn", "Primer diente", "Première dent", "Primeiro dente", "第一颗牙") }
    var milestoneTriedSolids: String { s("Tried solids", "Попробовал прикорм", "Beikost probiert", "Probó sólidos", "A goûté les solides", "Experimentou sólidos", "尝试了辅食") }
    var milestoneFirstWord: String { s("First word", "Первое слово", "Erstes Wort", "Primera palabra", "Premier mot", "Primeira palavra", "第一个词") }
    var feed: String        { s("Feed",          "Лента",            "Feed",             "Muro",   "Fil", "Feed", "动态") }
    var empty: String       { s("Empty",         "Пусто",            "Leer",             "Vacío",  "Vide", "Vazio", "空") }
    var diaryEmptyHint: String { s("Nothing in this category yet.\nAdd the first — tap +", "В этой категории пока нет записей.\nДобавьте первую — нажмите +", "Noch nichts hier.\nAuf + tippen", "Aún no hay nada en esta categoría.\nAñade la primera — pulsa +", "Rien dans cette catégorie pour l’instant.\nAjoutez la première — touchez +", "Ainda nada nesta categoria.\nAdicione a primeira — toque em +", "这个分类还没有内容。\n添加第一条——点击 +") }
    var filterPhoto: String { s("📷 Photo",      "📷 Фото",          "📷 Foto",          "📷 Foto", "📷 Photo", "📷 Foto", "📷 照片") }
    var filterNotes: String { s("✎ Notes",       "✎ Заметки",        "✎ Notizen",        "✎ Notas", "✎ Notes", "✎ Notas", "✎ 备注") }
    var diaryQuote: String  { s("A year from now you'll open this and smile ✿", "через год вы откроете это и будете улыбаться ✿", "In einem Jahr wirst du das öffnen und lächeln ✿", "Dentro de un año abrirás esto y sonreirás ✿", "Dans un an, vous ouvrirez ceci et sourirez ✿", "Daqui a um ano vai abrir isto e sorrir ✿", "一年后再打开这里，你会会心一笑 ✿") }
    var babyPhotoLabel: String { s("baby's photo", "фото малыша",    "Babyfoto",         "foto del bebé", "photo du bébé", "foto do bebé", "宝宝的照片") }
    var entryType: String   { s("Type",          "Тип",              "Typ",              "Tipo",   "Type", "Tipo", "类型") }
    var addToDiary: String  { s("Add to Diary",  "Добавить в дневник","Zum Tagebuch",    "Añadir al diario", "Ajouter au journal", "Adicionar ao diário", "添加到日记") }
    var newEntry: String    { s("New Entry",     "Новая запись",     "Neuer Eintrag",    "Nueva entrada", "Nouvelle entrée", "Novo registo", "新建记录") }
    var whatToWrite: String { s("WHAT DO YOU WANT TO WRITE?", "ЧТО ХОТИТЕ ЗАПИСАТЬ?", "WAS MÖCHTEN SIE SCHREIBEN?", "¿QUÉ QUIERES ESCRIBIR?", "QUE VOULEZ-VOUS ÉCRIRE ?", "O QUE QUER ESCREVER?", "想写点什么？") }
    var noteExamplePlaceholder: String { s("E.g. Laughed out loud for the first time!", "Например: «Впервые засмеялся в голос!»", "Z.B. Zum ersten Mal laut gelacht!", "P. ej. ¡Se rió a carcajadas por primera vez!", "P. ex. A éclaté de rire pour la première fois !", "Ex.: Riu-se alto pela primeira vez!", "例如：第一次放声大笑！") }
    var chooseIcon: String  { s("CHOOSE ICON",   "ВЫБЕРИТЕ ИКОНКУ",  "SYMBOL WÄHLEN",    "ELIGE UN ICONO", "CHOISIR UNE ICÔNE", "ESCOLHER ÍCONE", "选择图标") }
    var orWriteYourOwn: String { s("OR WRITE YOUR OWN", "ИЛИ НАПИШИТЕ СВОЁ", "ODER EIGENES SCHREIBEN", "O ESCRIBE EL TUYO", "OU ÉCRIVEZ LE VÔTRE", "OU ESCREVA O SEU", "或自己输入") }
    var milestoneExamplePlaceholder: String { s("E.g. First roll-over", "Например: «Первый переворот»", "Z.B. Erste Drehung", "P. ej. Primera vuelta", "P. ex. Premier retournement", "Ex.: Primeira vez que se virou", "例如：第一次翻身") }
    var choosePhoto: String { s("CHOOSE PHOTO",  "ВЫБЕРИТЕ ФОТО",    "FOTO WÄHLEN",      "ELIGE UNA FOTO", "CHOISIR UNE PHOTO", "ESCOLHER FOTO", "选择照片") }
    var tapToChoose: String { s("Tap to choose", "Нажмите, чтобы выбрать", "Zum Auswählen tippen", "Pulsa para elegir", "Touchez pour choisir", "Toque para escolher", "点击选择") }
    var placeholderColor: String { s("Placeholder color:", "Цвет плейсхолдера:", "Platzhalterfarbe:", "Color del marcador:", "Couleur de l’espace réservé :", "Cor do marcador:", "占位图颜色：") }
    var captionHandwriting: String { s("CAPTION (handwriting style)", "ПОДПИСЬ (рукописный стиль)", "BILDUNTERSCHRIFT (Handschrift)", "TEXTO (estilo manuscrito)", "LÉGENDE (style manuscrit)", "LEGENDA (estilo manuscrito)", "说明文字（手写体）") }
    var captionExamplePlaceholder: String { s("E.g. first laugh", "Например: «первый смех»", "Z.B. erstes Lachen", "P. ej. primera risa", "P. ex. premier rire", "Ex.: primeiro riso", "例如：第一次笑") }
    var moment: String      { s("moment",        "момент",           "Moment",           "momento", "moment", "momento", "时刻") }
    var toDiary: String     { s("To diary",      "В дневник",        "Zum Tagebuch",     "Al diario", "Au journal", "Ao diário", "加入日记") }

    func diaryTitle(name: String) -> String { s("\(name)'s Diary", "Дневник \(name)", "Tagebuch von \(name)", "Diario de \(name)", "Journal de \(name)", "Diário de \(name)", "\(name) 的日记") }

    // MARK: — Leaps
    var leaps: String           { s("Leaps",             "Скачки развития",  "Entwicklungsschübe", "Saltos", "Bonds", "Saltos", "飞跃期") }
    var developmentalLeaps: String { s("Developmental Leaps", "Скачки развития", "Entwicklungsschübe", "Saltos del desarrollo", "Bonds de développement", "Saltos de desenvolvimento", "发展飞跃期") }
    var leapWeeks: String       { s("weeks",             "недель",           "Wochen",          "semanas", "semaines", "semanas", "周") }
    var leapCompleted: String   { s("Completed",         "Завершён",         "Abgeschlossen",   "Completado", "Terminé", "Concluído", "已完成") }
    var leapInProgress: String  { s("In progress",       "В процессе",       "Im Gange",        "En curso", "En cours", "Em curso", "进行中") }
    var leapUpcoming: String    { s("Upcoming",          "Предстоит",        "Bevorstehend",    "Próximo", "À venir", "A chegar", "即将到来") }
    var markDone: String        { s("Mark complete",     "Отметить",         "Abschließen",     "Marcar hecho", "Marquer terminé", "Marcar concluído", "标记完成") }
    var hangInThere: String     { s("hang in there, mama ✿", "держитесь, мама ✿", "Haltet durch, Mama ✿", "ánimo, mamá ✿", "courage, maman ✿", "força, mamã ✿", "坚持住，妈妈 ✿") }
    var leapSettled: String     { s("calmer days now — new skills emerging ✿", "сейчас спокойнее — появляются новые навыки ✿", "ruhigere Tage — neue Fähigkeiten zeigen sich ✿", "días más tranquilos — surgen nuevas habilidades ✿", "des jours plus calmes — de nouvelles compétences apparaissent ✿", "dias mais calmos agora — surgem novas competências ✿", "现在平静些了——新技能正在显现 ✿") }
    var whatYouNotice: String   { s("WHAT YOU NOTICE",   "ЧТО ЗАМЕТНО",      "WAS SIE BEMERKEN", "LO QUE NOTAS", "CE QUE VOUS REMARQUEZ", "O QUE NOTA", "你会注意到") }
    var comingSoon: String      { s("COMING SOON",       "СКОРО НАУЧИТСЯ",   "KOMMT BALD",      "PRONTO", "BIENTÔT", "EM BREVE", "即将学会") }
    var leapPhaseSoon: String { s("soon", "скоро", "bald", "pronto", "bientôt", "em breve", "即将开始") }
    var leapPhaseHardDays: String { s("hard days", "сложные дни", "schwere Tage", "días difíciles", "jours difficiles", "dias difíceis", "难熬阶段") }
    var leapPhaseConsolidation: String { s("consolidation", "закрепление", "Festigung", "consolidación", "consolidation", "consolidação", "巩固期") }
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
                 w == 1 ? "~1 semana" : "~\(w) semanas",
                 "约 \(w) 周")
    }

    func leapWillPass(hardDays: Int) -> String {
        let dur = weeksApprox(days: hardDays)
        return s("✿ This will pass. Usually lasts \(dur). Hold them more — it doesn't spoil.",
                 "✿ Это пройдёт. Обычно длится \(dur). Чаще берите на руки — это не балует.",
                 "✿ Das geht vorüber. Dauert \(dur). Öfter auf den Arm nehmen.",
                 "✿ Esto pasará. Suele durar \(dur). Cógelo más en brazos — no lo malcría.",
                 "✿ Cela passera. Dure généralement \(dur). Prenez-le plus dans les bras — ça ne gâte pas.",
                 "✿ Isto vai passar. Costuma durar \(dur). Pegue-o mais ao colo — não o estraga.",
                 "✿ 这会过去的。通常持续 \(dur)。多抱抱他——不会惯坏。")
    }
    var leapCalendar: String    { s("Leap Calendar",     "Календарь скачков","Schub-Kalender",  "Calendario de saltos", "Calendrier des bonds", "Calendário de saltos", "飞跃期日历") }
    var tipOfTheDay: String     { s("TIP OF THE DAY",    "СОВЕТ НА СЕГОДНЯ", "TIPP DES TAGES",  "CONSEJO DEL DÍA", "CONSEIL DU JOUR", "DICA DO DIA", "今日提示") }
    var leapInProgressStatus: String { s("in progress",  "идёт сейчас",      "im Gange",        "en curso", "en cours", "em curso", "进行中") }
    var leapCompletedStatus: String  { s("completed",    "завершён",         "abgeschlossen",   "completado", "terminé", "concluído", "已完成") }
    var notice: String          { s("notice",            "замечают",         "bemerken",        "notas", "à remarquer", "notar", "注意") }
    var willLearn: String       { s("will learn",        "научится",         "wird lernen",     "aprenderá", "va apprendre", "vai aprender", "将学会") }

    func hardDaysProgress(day: Int, total: Int) -> String { s("Day \(day) of ~\(total) hard days.", "День \(day) из ~\(total) трудных.", "Tag \(day) von ~\(total) schweren.", "Día \(day) de ~\(total) días difíciles.", "Jour \(day) sur ~\(total) jours difficiles.", "Dia \(day) de ~\(total) dias difíceis.", "第 \(day) 天 / 约 \(total) 个难熬的日子。") }
    func currentLeapTitle(id: Int) -> String { s("Now — leap #\(id)", "Сейчас — скачок №\(id)", "Jetzt — Schub №\(id)", "Ahora — salto n.º \(id)", "Maintenant — bond n° \(id)", "Agora — salto n.º \(id)", "现在——飞跃期 #\(id)") }
    func nextLeapTitle(id: Int) -> String { s("Next — leap #\(id)", "Дальше — скачок №\(id)", "Als Nächstes — Schub №\(id)", "Siguiente — salto n.º \(id)", "Ensuite — bond n° \(id)", "A seguir — salto n.º \(id)", "下一个——飞跃期 #\(id)") }
    func weekPill(n: Int) -> String { s("week \(n)", "\(n)-я неделя", "Woche \(n)", "semana \(n)", "semaine \(n)", "semana \(n)", "第 \(n) 周") }
    func weekRow(n: Int) -> String  { s("\(n) wk",   "\(n) нед",     "\(n) W",      "\(n) sem", "\(n) sem", "\(n) sem", "\(n) 周") }
    func leapAhead(week: Int) -> String { s("ahead · week \(week)", "впереди · \(week)-я неделя", "bald · Woche \(week)", "próximo · semana \(week)", "à venir · semaine \(week)", "a chegar · semana \(week)", "即将 · 第 \(week) 周") }
    func forLeapTip(name: String) -> String { s("For leap «\(name)»", "Для скачка «\(name)»", "Für Schub «\(name)»", "Para el salto «\(name)»", "Pour le bond «\(name)»", "Para o salto «\(name)»", "针对飞跃期「\(name)」") }
    func leapStartsOn(_ date: String) -> String {
        s("starts \(date)", "начнётся \(date)", "startet \(date)", "empieza \(date)", "commence \(date)", "começa \(date)", "\(date) 开始")
    }
    func leapStartsIn(days: Int, date: String) -> String {
        s("starts \(date) · in \(days)d", "начнётся \(date) · через \(days) дн.", "startet \(date) · in \(days) T.", "empieza \(date) · en \(days) d", "commence \(date) · dans \(days) j", "começa \(date) · em \(days) d", "\(date) 开始 · 还有 \(days) 天")
    }
    var leapPeakToday: String {
        s("peak today", "пик сегодня", "Höhepunkt heute", "pico hoy", "pic aujourd’hui", "pico hoje", "今天是高峰")
    }
    func leapPeakIn(days: Int) -> String {
        s("peak in \(days)d", "пик через \(days) дн.", "Höhepunkt in \(days) T.", "pico en \(days) d", "pic dans \(days) j", "pico em \(days) d", "高峰还有 \(days) 天")
    }
    func leapHardDaysLeft(days: Int) -> String {
        s("about \(days)d left", "осталось примерно \(days) дн.", "noch etwa \(days) T.", "quedan unos \(days) d", "encore environ \(days) j", "faltam cerca de \(days) d", "大约还剩 \(days) 天")
    }
    var leapConsolidationDetail: String {
        s("hard part passed · practicing skills", "сложная часть позади · закрепляет навыки", "das Schwere ist vorbei · übt Fähigkeiten", "lo difícil pasó · practica habilidades", "le plus dur est passé · les compétences se fixent", "a parte difícil passou · pratica competências", "最难的部分过去了 · 正在练习技能")
    }
    var leapCompletedDetail: String {
        s("completed", "завершён", "abgeschlossen", "completado", "terminé", "concluído", "已完成")
    }
    var leapCalendarWeekMode: String {
        s("Week", "Неделя", "Woche", "Semana", "Semaine", "Semana", "周")
    }
    var leapCalendarMonthMode: String {
        s("Month", "Месяц", "Monat", "Mes", "Mois", "Mês", "月")
    }
    var leapCalmDay: String {
        s("Calm", "Спокойно", "Ruhig", "Calma", "Calme", "Calmo", "平静")
    }
    var leapHardDay: String {
        s("Hard", "Сложно", "Schwer", "Difícil", "Difficile", "Difícil", "困难")
    }
    var leapPeakDay: String {
        s("Peak", "Пик", "Höhepunkt", "Pico", "Pic", "Pico", "高峰")
    }
    var leapRecoveryDay: String {
        s("Recovery", "Восстановление", "Erholung", "Recuperación", "Récupération", "Recuperação", "恢复")
    }
    var leapCheckInTitle: String {
        s("Daily check-in", "Дневной чек-ин", "Täglicher Check-in", "Registro diario", "Point du jour", "Check-in diário", "每日记录")
    }
    var leapCheckInSubtitle: String {
        s("Mark what you noticed today.", "Отметьте, что заметили сегодня.", "Markiere, was du heute bemerkt hast.", "Marca lo que notaste hoy.", "Notez ce que vous avez remarqué aujourd’hui.", "Marque o que notou hoje.", "记录今天观察到的情况。")
    }
    var leapTodayActionsTitle: String {
        s("What to do today", "Что делать сегодня", "Was heute hilft", "Qué hacer hoy", "Que faire aujourd’hui", "O que fazer hoje", "今天可以做什么")
    }
    var leapActionPlayTitle: String {
        s("Play", "Игра", "Spiel", "Juego", "Jeu", "Brincar", "游戏")
    }
    var leapActionSleepTitle: String {
        s("Sleep", "Сон", "Schlaf", "Sueño", "Sommeil", "Sono", "睡眠")
    }
    var leapActionContactTitle: String {
        s("Contact", "Контакт", "Nähe", "Contacto", "Contact", "Contacto", "亲密接触")
    }
    var leapActionFeedingTitle: String {
        s("Feeding", "Кормление", "Füttern", "Toma", "Tétée", "Mamada", "喂养")
    }
    var leapActionSleepHard: String {
        s("Shorten wake windows by 10-15 min and keep the room quieter.", "Сократите окна бодрствования на 10-15 мин и сделайте комнату тише.", "Verkürze Wachfenster um 10-15 Min. und halte den Raum ruhiger.", "Acorta las ventanas de vigilia 10-15 min y baja estímulos.", "Réduisez les temps d’éveil de 10-15 min et gardez la pièce plus calme.", "Reduza as janelas acordado em 10-15 min e deixe o quarto mais calmo.", "清醒时间缩短 10-15 分钟，房间保持更安静。")
    }
    var leapActionSleepCalm: String {
        s("Keep the bedtime sequence steady: same order, same cues.", "Держите ритуал сна стабильным: тот же порядок и сигналы.", "Halte die Schlafroutine stabil: gleiche Reihenfolge, gleiche Signale.", "Mantén la rutina de dormir estable: mismo orden, mismas señales.", "Gardez le rituel du coucher stable : même ordre, mêmes repères.", "Mantenha a rotina de sono estável: mesma ordem, mesmos sinais.", "保持睡前流程稳定：同样顺序、同样提示。")
    }
    var leapActionContact: String {
        s("Offer more carrying and eye contact; it does not spoil during a leap.", "Чаще берите на руки и ловите взгляд — во время скачка это не балует.", "Biete mehr Tragen und Blickkontakt an; das verwöhnt in einem Schub nicht.", "Ofrece más brazos y contacto visual; en un salto no malcría.", "Proposez plus de portage et de regard; pendant un bond, cela ne gâte pas.", "Ofereça mais colo e contacto visual; durante um salto não estraga.", "多抱抱、多眼神交流；飞跃期这样不会惯坏。")
    }
    var leapActionFeeding: String {
        s("Offer smaller calm feeds and do not force volume when appetite shifts.", "Предлагайте меньше и спокойнее; не давите на объём, если аппетит скачет.", "Biete kleinere ruhige Mahlzeiten an und erzwinge keine Menge.", "Ofrece tomas pequeñas y tranquilas; no fuerces cantidad si cambia el apetito.", "Proposez de petites tétées calmes sans forcer les quantités.", "Ofereça mamadas menores e calmas; não force quantidade se o apetite mudar.", "少量、安静地喂；食欲变化时不要强迫量。")
    }
    var leapRecordSkillButton: String {
        s("Record new skill", "Записать новый навык", "Neue Fähigkeit notieren", "Registrar nueva habilidad", "Noter une nouvelle compétence", "Registar nova competência", "记录新技能")
    }
    var leapRecordSkillTitle: String {
        s("New skill", "Новый навык", "Neue Fähigkeit", "Nueva habilidad", "Nouvelle compétence", "Nova competência", "新技能")
    }
    var leapRecordSkillSubtitle: String {
        s("Pick a skill from this leap or write your own milestone for the diary.",
          "Выберите навык из этого скачка или запишите свою веху в дневник.",
          "Wähle eine Fähigkeit aus diesem Schub oder schreibe einen eigenen Meilenstein ins Tagebuch.",
          "Elige una habilidad de este salto o escribe tu propio hito en el diario.",
          "Choisissez une compétence de ce bond ou écrivez votre propre étape dans le journal.",
          "Escolha uma competência deste salto ou escreva o seu próprio marco no diário.",
          "选择本次飞跃期的技能，或为日记写下自己的里程碑。")
    }
    var leapRecordSkillPlaceholder: String {
        s("What appeared today?", "Что появилось сегодня?", "Was ist heute neu?", "¿Qué apareció hoy?", "Qu’est-ce qui est apparu aujourd’hui ?", "O que apareceu hoje?", "今天出现了什么新变化？")
    }
    var leapSkillSaved: String {
        s("Saved to diary", "Сохранено в дневник", "Im Tagebuch gespeichert", "Guardado en el diario", "Enregistré dans le journal", "Guardado no diário", "已保存到日记")
    }
    var leapSkillSaveError: String {
        s("Couldn't save the skill. Try again.", "Не удалось сохранить навык. Попробуйте ещё раз.", "Fähigkeit konnte nicht gespeichert werden. Bitte erneut versuchen.", "No se pudo guardar la habilidad. Inténtalo de nuevo.", "Impossible d’enregistrer la compétence. Réessayez.", "Não foi possível guardar a competência. Tente novamente.", "无法保存技能，请重试。")
    }
    var leapHistoryTitle: String {
        s("Child's leap history", "История скачков ребёнка", "Schubverlauf des Kindes", "Historial de saltos del bebé", "Historique des bonds de l’enfant", "Histórico de saltos do bebé", "宝宝飞跃期历史")
    }
    var leapHistorySubtitle: String {
        s("Based on completed leaps and daily check-ins for this child.",
          "По завершённым скачкам и дневным чек-инам этого ребёнка.",
          "Basierend auf abgeschlossenen Schüben und täglichen Check-ins dieses Kindes.",
          "Según los saltos completados y los registros diarios de este bebé.",
          "D’après les bonds terminés et les pointages quotidiens de cet enfant.",
          "Com base nos saltos concluídos e check-ins diários deste bebé.",
          "基于这个宝宝已完成的飞跃期和每日记录。")
    }
    var leapHistoryEmpty: String {
        s("History will appear after you mark symptoms or complete a leap.",
          "История появится после отметок симптомов или завершения скачка.",
          "Der Verlauf erscheint, sobald du Symptome markierst oder einen Schub abschließt.",
          "El historial aparecerá cuando marques señales o completes un salto.",
          "L’historique apparaîtra après avoir noté des signes ou terminé un bond.",
          "O histórico aparece depois de marcar sinais ou concluir um salto.",
          "标记迹象或完成飞跃期后，这里会显示历史。")
    }
    var leapHistoryLight: String {
        s("lighter", "легче", "leichter", "más fácil", "plus facile", "mais leve", "较轻松")
    }
    var leapHistoryModerate: String {
        s("moderate", "средне", "mittel", "moderado", "modéré", "moderado", "中等")
    }
    var leapHistoryHard: String {
        s("harder", "тяжелее", "schwerer", "más difícil", "plus difficile", "mais difícil", "较困难")
    }
    func leapHistoryDuration(days: Int) -> String {
        s("Lasted about \(days)d",
          "Длился фактически около \(days) дн.",
          "Dauerte etwa \(days) T.",
          "Duró aprox. \(days) d",
          "A duré environ \(days) j",
          "Durou cerca de \(days) d",
          "实际持续约 \(days) 天")
    }
    var leapHistoryNoSymptoms: String {
        s("No symptom check-ins", "Нет чек-инов симптомов", "Keine Symptom-Check-ins", "Sin registros de señales", "Aucun pointage de signe", "Sem check-ins de sinais", "没有迹象记录")
    }
    var leapInsightTitle: String {
        s("From your logs", "По вашим записям", "Aus deinen Daten", "Según tus registros", "D’après vos notes", "Pelos seus registos", "根据记录")
    }
    var leapSleepInsight: String {
        s("Sleep looks shorter during this leap. That can happen; protect an earlier, calmer wind-down today.", "Сон стал короче во время скачка. Так бывает; сегодня лучше начать спокойное укладывание раньше.", "Der Schlaf wirkt in diesem Schub kürzer. Das kann passieren; beginne heute früher und ruhiger.", "El sueño parece más corto en este salto. Puede pasar; hoy conviene una bajada más temprana y tranquila.", "Le sommeil semble plus court pendant ce bond. Cela arrive; commencez l’apaisement plus tôt aujourd’hui.", "O sono parece mais curto neste salto. Pode acontecer; hoje comece a acalmar mais cedo.", "这次飞跃期睡眠看起来变短了。这可能发生；今天早点安静进入睡眠流程。")
    }
    var leapFeedingInsight: String {
        s("Feeding rhythm shifted during the leap. Offer calmly and follow cues instead of pushing a fixed amount.", "Ритм кормлений изменился во время скачка. Предлагайте спокойно и идите по сигналам, не по фиксированному объёму.", "Der Fütterrhythmus hat sich im Schub verändert. Biete ruhig an und folge den Signalen statt festen Mengen.", "El ritmo de tomas cambió durante el salto. Ofrece con calma y sigue sus señales.", "Le rythme des tétées a changé pendant le bond. Proposez calmement et suivez les signaux.", "O ritmo das mamadas mudou durante o salto. Ofereça com calma e siga os sinais.", "飞跃期喂养节奏有变化。安静提供，跟随信号，不强求固定量。")
    }
    var leapNormalDoctorTitle: String {
        s("Normal or doctor?", "Это нормально / когда к врачу", "Normal oder Arzt?", "Normal o médico", "Normal ou médecin ?", "Normal ou médico?", "正常还是就医？")
    }
    var leapNormalText: String {
        s("More fussiness, clinginess, short naps, and uneven appetite can be normal during a leap.", "Больше капризов, просьб на руки, короткие сны и неровный аппетит во время скачка часто нормальны.", "Mehr Quengeln, Nähebedürfnis, kurze Nickerchen und wechselnder Appetit können normal sein.", "Más irritabilidad, brazos, siestas cortas y apetito irregular pueden ser normales.", "Plus d’agitation, de besoin des bras, de siestes courtes et d’appétit irrégulier peut être normal.", "Mais irritação, colo, sestas curtas e apetite irregular podem ser normais.", "更烦躁、更黏人、小睡变短、食欲不稳在飞跃期可能是正常的。")
    }
    var leapDoctorText: String {
        s("Call a clinician for fever, dehydration signs, breathing trouble, unusual lethargy, persistent vomiting, or crying that feels different.", "Обратитесь к врачу при температуре, признаках обезвоживания, проблемах с дыханием, необычной вялости, постоянной рвоте или непривычном плаче.", "Wende dich an eine Praxis bei Fieber, Dehydrierungszeichen, Atemproblemen, ungewöhnlicher Schläfrigkeit, anhaltendem Erbrechen oder anderem Schreien.", "Consulta por fiebre, signos de deshidratación, dificultad respiratoria, letargo inusual, vómitos persistentes o llanto diferente.", "Appelez un soignant en cas de fièvre, signes de déshydratation, gêne respiratoire, grande somnolence, vomissements persistants ou pleurs inhabituels.", "Contacte um profissional se houver febre, sinais de desidratação, dificuldade respiratória, letargia invulgar, vómitos persistentes ou choro diferente.", "如有发热、脱水迹象、呼吸困难、异常嗜睡、持续呕吐或哭声明显不同，请联系医生。")
    }

    // MARK: — Tracking
    var weight: String          { s("Weight",        "Вес",           "Gewicht",       "Peso",   "Poids", "Peso", "体重") }
    var height: String          { s("Height",        "Рост",          "Größe",         "Altura", "Taille", "Altura", "身高") }
    var headCircumference: String { s("Head circ.",  "Окруж. головы", "Kopfumfang",    "Perím. cefálico", "Périm. crânien", "Perím. cefálico", "头围") }
    var temperature: String     { s("Temperature",   "Температура",   "Temperatur",    "Temperatura", "Température", "Temperatura", "体温") }
    var doctorVisit: String     { s("Doctor visit",  "Приём врача",   "Arztbesuch",    "Visita médica", "Visite médicale", "Consulta médica", "就诊") }
    var addMeasurement: String  { s("Add measurement", "Добавить измерение", "Messung hinzufügen", "Añadir medida", "Ajouter une mesure", "Adicionar medição", "添加测量") }
    var logTemp: String         { s("Log temperature", "Записать температуру", "Temperatur erfassen", "Registrar temperatura", "Enregistrer la température", "Registar temperatura", "记录体温") }
    var percentile: String      { s("Percentile",    "Перцентиль",    "Perzentile",    "Percentil", "Percentile", "Percentil", "百分位") }
    var normal: String          { s("Normal",        "Норма",         "Normal",        "Normal", "Normal", "Normal", "正常") }
    var elevated: String        { s("Elevated",      "Повышена",      "Erhöht",        "Elevada", "Élevée", "Elevada", "偏高") }
    var high: String            { s("High",          "Высокая",       "Hoch",          "Alta",   "Forte", "Alta", "高") }
    var health: String          { s("Health",        "Здоровье",      "Gesundheit",    "Salud",  "Santé", "Saúde", "健康") }
    var heightAndWeight: String { s("Height & Weight","Рост и вес",   "Größe & Gewicht", "Altura y peso", "Taille et poids", "Altura e peso", "身高与体重") }
    var whoRange: String        { s("0–24 mo · WHO", "0–24 мес · ВОЗ","0–24 Mon. · WHO", "0–24 meses · OMS", "0–24 mois · OMS", "0–24 meses · OMS", "0–24 月 · WHO") }
    var median: String          { s("Median",        "Медиана",       "Median",        "Mediana", "Médiane", "Mediana", "中位数") }
    var temperatureHistory: String { s("Temperature history", "История температуры", "Temperaturverlauf", "Historial de temperatura", "Historique de température", "Histórico de temperatura", "体温历史") }
    var recentMeasurements: String { s("Recent measurements", "Последние замеры", "Letzte Messungen", "Medidas recientes", "Mesures récentes", "Medições recentes", "近期测量") }
    var weightKg: String        { s("Weight, kg",    "Вес, кг",       "Gewicht, kg",   "Peso, kg", "Poids, kg", "Peso, kg", "体重，kg") }
    var heightCm: String        { s("Height, cm",    "Рост, см",      "Größe, cm",     "Altura, cm", "Taille, cm", "Altura, cm", "身高，cm") }
    var headCircCm: String      { s("Head circ., cm","Окруж. головы, см","Kopfumfang, cm", "Perím. cefálico, cm", "Périm. crânien, cm", "Perím. cefálico, cm", "头围，cm") }
    var normalRange: String      { s("normal",        "в норме",        "normal",       "normal", "normal", "normal", "正常") }
    var subfebr: String         { s("subfebr.",      "субфебр.",       "subfebr.",     "subfebril", "fébricule", "subfebril", "低热") }
    var subfebrLabel: String    { s("Subfebr.",      "Субфебрильная", "Subfebril",     "Subfebril", "Fébricule", "Subfebril", "低热") }
    var highTemp: String        { s("High 🌡",       "Высокая 🌡",    "Hoch 🌡",       "Alta 🌡", "Forte 🌡", "Alta 🌡", "高 🌡") }
    var normalOk: String        { s("Normal ✓",      "Норма ✓",       "Normal ✓",      "Normal ✓", "Normal ✓", "Normal ✓", "正常 ✓") }
    var addWeightHeight: String { s("+ Weight / Height", "+ Вес / рост", "+ Gewicht / Größe", "+ Peso / altura", "+ Poids / taille", "+ Peso / altura", "+ 体重 / 身高") }
    var addTemperature: String  { s("+ Temperature", "+ Температура", "+ Temperatur",  "+ Temperatura", "+ Température", "+ Temperatura", "+ 体温") }
    var measurements: String    { s("Measurements",  "Замеры",        "Messungen",     "Medidas", "Mesures", "Medições", "测量") }
    var weightPlaceholder: String { s("kg (e.g. 6.4)", "кг (напр. 6.4)", "kg (z.B. 6.4)", "kg (p. ej. 6.4)", "kg (p. ex. 6.4)", "kg (ex.: 6,4)", "kg（例如 6.4）") }
    var heightPlaceholder: String { s("cm (e.g. 64)",  "см (напр. 64)",  "cm (z.B. 64)",  "cm (p. ej. 64)", "cm (p. ex. 64)", "cm (ex.: 64)", "cm（例如 64）") }
    var headCirc: String        { s("Head circ.",    "Окр. головы",   "Kopfumfang",    "Perím. cefálico", "Périm. crânien", "Perím. cefálico", "头围") }
    var headCircPlaceholder: String { s("cm (e.g. 42)", "см (напр. 42)", "cm (z.B. 42)", "cm (p. ej. 42)", "cm (p. ex. 42)", "cm (ex.: 42)", "cm（例如 42）") }
    var fillAtLeastOneField: String { s("Fill in at least one field.", "Заполните хотя бы одно поле.", "Mindestens ein Feld ausfüllen.", "Rellena al menos un campo.", "Remplissez au moins un champ.", "Preencha pelo menos um campo.", "请至少填写一项。") }
    var newMeasurement: String  { s("New measurement","Новый замер",   "Neue Messung",  "Nueva medida", "Nouvelle mesure", "Nova medição", "新测量") }
    var tempPlaceholder: String { s("e.g. 37.2",     "напр. 37.2",    "z.B. 37.2",     "p. ej. 37.2", "p. ex. 37.2", "ex.: 37,2", "例如 37.2") }
    var noteSectionLabel: String { s("Note",         "Заметка",       "Notiz",         "Nota", "Note", "Nota", "备注") }
    var optionalNote: String    { s("Optional note…","Необязательная заметка…", "Optionale Notiz…", "Nota opcional…", "Note facultative…", "Nota opcional…", "可选备注…") }
    var temperatureCelsius: String { s("Temperature, °C", "Температура, °C", "Temperatur, °C", "Temperatura, °C", "Température, °C", "Temperatura, °C", "体温，°C") }
    var recentReadings: String  { s("recent readings", "последние замеры", "letzte Messungen", "últimas medidas", "dernières mesures", "últimas medições", "近期读数") }
    var noTemperatureData: String { s("No temperature data", "Нет данных о температуре", "Keine Temperaturdaten", "Sin datos de temperatura", "Aucune donnée de température", "Sem dados de temperatura", "暂无体温数据") }
    var tempNormalRange: String { s("normal < 37.5°", "норма < 37.5°", "normal < 37.5°", "normal < 37.5°", "normal < 37,5°", "normal < 37,5°", "正常 < 37.5°") }
    var tempSubfebrRange: String { s("subfebr. 37.5–38.4°", "субфебр. 37.5–38.4°", "subfebril. 37.5–38.4°", "subfebril 37.5–38.4°", "fébricule 37,5–38,4°", "subfebril 37,5–38,4°", "低热 37.5–38.4°") }
    var tempHighRange: String   { s("high ≥ 38.5°", "высокая ≥ 38.5°", "hoch ≥ 38.5°", "alta ≥ 38.5°", "forte ≥ 38,5°", "alta ≥ 38,5°", "高 ≥ 38.5°") }

    // MARK: — Sounds / Lullaby
    var sounds: String          { s("Sounds",        "Звуки",         "Klänge",        "Sonidos", "Sons", "Sons", "声音") }
    var lullaby: String         { s("Lullaby",       "Колыбельная",   "Schlaflied",    "Nana", "Berceuse", "Canção de embalar", "摇篮曲") }
    var nowPlaying: String      { s("NOW PLAYING",   "ИГРАЕТ",        "SPIELT",        "SONANDO", "EN LECTURE", "A TOCAR", "正在播放") }
    var nowPlayingFull: String  { s("NOW PLAYING",   "СЕЙЧАС ИГРАЕТ", "SPIELT GERADE", "SONANDO AHORA", "EN COURS DE LECTURE", "A TOCAR AGORA", "正在播放") }
    var tapToPlay: String       { s("Tap to play",   "Нажмите чтобы играть", "Zum Abspielen tippen", "Pulsa para reproducir", "Touchez pour lire", "Toque para reproduzir", "点按播放") }
    var sleepTight: String      { s("sleep tight",   "пусть спит крепко", "schlaf gut", "que duerma bien", "fais de beaux rêves", "dorme bem", "睡个好觉") }
    var playing: String         { s("playing",       "играет",        "spielt",        "sonando", "en lecture", "a tocar", "播放中") }
    var soundWomb: String       { s("Womb", "Утроба", "Mutterleib", "Útero", "Ventre maternel", "Útero", "子宫声") }
    var soundRain: String       { s("Rain", "Дождь", "Regen", "Lluvia", "Pluie", "Chuva", "雨声") }
    var soundHairDryer: String  { s("Hair dryer", "Фен", "Föhn", "Secador", "Sèche-cheveux", "Secador", "吹风机") }
    var soundLullaby: String    { s("Lullaby", "Колыбельная", "Schlaflied", "Nana", "Berceuse", "Canção de embalar", "摇篮曲") }
    var soundHeartbeat: String  { s("Heartbeat", "Сердцебиение", "Herzschlag", "Latido", "Battement de cœur", "Batimento cardíaco", "心跳声") }
    var soundOcean: String      { s("Ocean", "Океан", "Ozean", "Océano", "Océan", "Oceano", "海浪声") }
    var soundForest: String     { s("Forest", "Лес", "Wald", "Bosque", "Forêt", "Floresta", "森林") }
    var soundBrook: String      { s("Brook", "Ручей", "Bach", "Arroyo", "Ruisseau", "Ribeiro", "溪流") }
    var soundCategoryWhiteNoise: String { s("white noise", "белый шум", "weißes Rauschen", "ruido blanco", "bruit blanc", "ruído branco", "白噪音") }
    var soundCategoryNature: String     { s("nature", "природа", "Natur", "naturaleza", "nature", "natureza", "自然") }
    var soundCategoryPinkNoise: String  { s("pink noise", "розовый шум", "rosa Rauschen", "ruido rosa", "bruit rose", "ruído rosa", "粉红噪音") }
    var soundCategoryMelody: String     { s("melody", "мелодия", "Melodie", "melodía", "mélodie", "melodia", "旋律") }
    var soundCategoryNewborns: String   { s("for newborns", "для новорождённых", "für Neugeborene", "para recién nacidos", "pour nouveau-nés", "para recém-nascidos", "适合新生儿") }

    func forBabyName(_ name: String) -> String { s(" for \(name)", " для \(name)", " für \(name)", " para \(name)", " pour \(name)", " para \(name)", "（\(name)）") }

    // MARK: — Family / Sharing
    var family: String          { s("Family",        "Семья",         "Familie",       "Familia", "Famille", "Família", "家庭") }
    var invite: String          { s("Invite",        "Пригласить",    "Einladen",      "Invitar", "Inviter", "Convidar", "邀请") }
    var inviteSent: String      { s("Invite sent",   "Приглашение отправлено", "Einladung gesendet", "Invitación enviada", "Invitation envoyée", "Convite enviado", "邀请已发送") }
    var role: String            { s("Role",          "Роль",          "Rolle",         "Rol", "Rôle", "Função", "角色") }
    var roleMom: String         { s("Mom",           "Мама",          "Mama",          "Mamá", "Maman", "Mãe", "妈妈") }
    var roleDad: String         { s("Dad",           "Папа",          "Papa",          "Papá", "Papa", "Pai", "爸爸") }
    var roleGrandma: String     { s("Grandma",       "Бабушка",       "Oma",           "Abuela", "Grand-mère", "Avó", "奶奶") }
    var roleGrandpa: String     { s("Grandpa",       "Дедушка",       "Opa",           "Abuelo", "Grand-père", "Avô", "爷爷") }
    var roleNanny: String       { s("Nanny",         "Няня",          "Nanny",         "Niñera", "Nounou", "Ama", "保姆") }
    var roleOther: String       { s("Other",         "Другой",        "Andere",        "Otro", "Autre", "Outro", "其他") }
    var roleFullAccess: String  { s("full access",   "полный доступ", "voller Zugriff", "acceso completo", "accès complet", "acesso total", "完整访问权限") }
    var roleTrackingNoMedical: String { s("tracking · no medical", "трекинг · без медицины", "Tracking · keine Medizin", "seguimiento · sin medicina", "suivi · sans médical", "registo · sem saúde", "记录 · 无医疗权限") }
    var rolePhotosStatusOnly: String { s("photos and status only", "только фото и статус", "nur Fotos und Status", "solo fotos y estado", "photos et statut uniquement", "apenas fotos e estado", "仅照片和状态") }
    var familyRoleHint: String  { s("Everyone has a role — each with their own access level.", "У всех своя роль — у каждой свой уровень доступа.", "Jeder hat eine Rolle — mit eigenem Zugangslevel.", "Cada uno tiene un rol — con su propio nivel de acceso.", "Chacun a un rôle — chacun avec son niveau d’accès.", "Cada um tem uma função — cada uma com o seu nível de acesso.", "每个人都有自己的角色——各有不同的访问权限。") }
    var inviteFamilyMember: String { s("Invite family member", "Пригласить члена семьи", "Familienmitglied einladen", "Invitar a un familiar", "Inviter un membre de la famille", "Convidar membro da família", "邀请家庭成员") }
    var inviteQrHint: String    { s("QR code or link · choose role", "QR-код или ссылка · выбор роли", "QR-Code oder Link · Rolle wählen", "Código QR o enlace · elige rol", "QR code ou lien · choisir le rôle", "Código QR ou ligação · escolher função", "二维码或链接 · 选择角色") }
    var matrixFeedingSleep: String { s("Feedings & sleep", "Кормления и сон", "Fütterung & Schlaf", "Tomas y sueño", "Tétées et sommeil", "Mamadas e sono", "喂养与睡眠") }
    var matrixTempMedicine: String { s("Temp / medicine", "Температура / лекарства", "Temperatur / Medizin", "Temp. / medicina", "Temp. / médicaments", "Temp. / medicação", "体温 / 用药") }
    var matrixPhotosDiary: String  { s("Photos & diary", "Фото и дневник", "Fotos & Tagebuch", "Fotos y diario", "Photos et journal", "Fotos e diário", "照片与日记") }
    var matrixPaedsReport: String  { s("Paediatric report", "Отчёт педиатру", "Kinderbericht", "Informe pediátrico", "Rapport pédiatrique", "Relatório pediátrico", "儿科报告") }
    var whatEachRoleSees: String{ s("What each role sees", "Что видит каждая роль", "Was jede Rolle sieht", "Qué ve cada rol", "Ce que voit chaque rôle", "O que cada função vê", "每个角色可见的内容") }
    var joinFamilyTitle: String { s("Join a Family",    "Присоединиться к семье", "Familie beitreten", "Unirse a una familia", "Rejoindre une famille", "Juntar-se a uma família", "加入家庭") }
    var joinAction: String      { s("Join",             "Войти",                  "Beitreten",     "Unirse", "Rejoindre", "Juntar-se", "加入") }
    var joinSuccessMessage: String { s("You joined the family!", "Вы присоединились к семье!", "Du bist der Familie beigetreten!", "¡Te uniste a la familia!", "Vous avez rejoint la famille !", "Juntou-se à família!", "您已加入家庭！") }
    var joinReplaceTitle: String   { s("Join this family?", "Присоединиться к этой семье?", "Dieser Familie beitreten?", "¿Unirse a esta familia?", "Rejoindre cette famille ?", "Juntar-se a esta família?", "加入这个家庭？") }
    var joinReplaceMessage: String { s("You already have a child set up. Joining a new family won't move your current data over — it will stay only on this device. Continue?", "У вас уже добавлен ребёнок. При входе в новую семью текущие данные не перенесутся и останутся только на этом устройстве. Продолжить?", "Du hast bereits ein Kind eingerichtet. Beim Beitritt zu einer neuen Familie werden deine aktuellen Daten nicht übertragen und bleiben nur auf diesem Gerät. Fortfahren?", "Ya tienes un bebé configurado. Al unirte a una familia nueva, tus datos actuales no se transferirán y quedarán solo en este dispositivo. ¿Continuar?", "Vous avez déjà un enfant configuré. En rejoignant une nouvelle famille, vos données actuelles ne seront pas transférées et resteront uniquement sur cet appareil. Continuer ?", "Já tens um bebé configurado. Ao juntar-te a uma nova família, os teus dados atuais não serão transferidos e ficarão apenas neste dispositivo. Continuar?", "您已经设置了一个宝宝。加入新家庭不会转移您当前的数据——这些数据将只保留在本设备上。是否继续？") }
    var joinReplaceConfirm: String { s("Join anyway", "Всё равно войти", "Trotzdem beitreten", "Unirse igualmente", "Rejoindre quand même", "Juntar mesmo assim", "仍然加入") }
    var joinSuccessTitle: String { s("Joined the family", "Вы в семье", "Familie beigetreten", "Te uniste a la familia", "Famille rejointe", "Entrou na família", "已加入家庭") }
    var joinFailedTitle: String { s("Couldn’t join", "Не удалось присоединиться", "Beitritt fehlgeschlagen", "No se pudo unir", "Impossible de rejoindre", "Não foi possível entrar", "无法加入") }
    var joinFailedMessage: String { s("This invite code is invalid or has expired.", "Этот код приглашения недействителен или истёк.", "Dieser Einladungscode ist ungültig oder abgelaufen.", "Este código de invitación no es válido o ha caducado.", "Ce code d’invitation est invalide ou a expiré.", "Este código de convite é inválido ou expirou.", "此邀请码无效或已过期。") }
    var roleLabel: String       { s("ROLE",          "РОЛЬ",          "ROLLE",         "ROL", "RÔLE", "FUNÇÃO", "角色") }
    var saveRole: String        { s("Save role",     "Сохранить роль","Rolle speichern", "Guardar rol", "Enregistrer le rôle", "Guardar função", "保存角色") }
    var removeFromTeamAction: String { s("Remove from team", "Удалить из команды", "Aus Team entfernen", "Quitar del equipo", "Retirer de l’équipe", "Remover da equipa", "移出团队") }
    var editMember: String      { s("Edit",          "Редактировать", "Bearbeiten",    "Editar", "Modifier", "Editar", "编辑") }
    var roleInTeam: String      { s("ROLE IN TEAM",  "РОЛЬ В КОМАНДЕ","ROLLE IM TEAM", "ROL EN EL EQUIPO", "RÔLE DANS L’ÉQUIPE", "FUNÇÃO NA EQUIPA", "团队中的角色") }
    var nameOptional: String    { s("NAME (optional)","ИМЯ (необязательно)","NAME (optional)", "NOMBRE (opcional)", "NOM (facultatif)", "NOME (opcional)", "姓名（可选）") }
    var memberNamePlaceholder: String { s("E.g.: Mike, Grandma Olga…", "Например: Миша, Бабушка Оля…", "Z.B.: Mike, Oma Olga…", "P. ej.: Miguel, Abuela Olga…", "P. ex. : Marc, Grand-mère Olga…", "Ex.: Miguel, Avó Olga…", "例如：小明、奥尔加奶奶…") }
    var shareLink: String       { s("Share link",    "Поделиться ссылкой", "Link teilen", "Compartir enlace", "Partager le lien", "Partilhar ligação", "分享链接") }
    var invitationSent: String  { s("invitation sent","приглашение отправлено", "Einladung gesendet", "invitación enviada", "invitation envoyée", "convite enviado", "邀请已发送") }
    var addToTeam: String       { s("Add to team",   "Добавить в команду", "Zum Team hinzufügen", "Añadir al equipo", "Ajouter à l’équipe", "Adicionar à equipa", "加入团队") }
    var copyLink: String        { s("Copy link",     "Копировать",    "Link kopieren", "Copiar enlace", "Copier le lien", "Copiar ligação", "复制链接") }
    var newCode: String         { s("New code",      "Новый код",     "Neuer Code",    "Nuevo código", "Nouveau code", "Novo código", "新的邀请码") }

    func teamTitle(name: String) -> String { s("\(name)'s Team", "Команда \(name)", "Team von \(name)", "Equipo de \(name)", "Équipe de \(name)", "Equipa de \(name)", "\(name)的团队") }
    func removeConfirm(name: String) -> String { s("Remove \(name) from team?", "Удалить \(name) из команды?", "\(name) aus Team entfernen?", "¿Quitar a \(name) del equipo?", "Retirer \(name) de l’équipe ?", "Remover \(name) da equipa?", "将\(name)移出团队？") }
    func expiryHoursLeft(hrs: Int, mins: Int) -> String { s("\(hrs)h \(mins)m left", "\(hrs)ч \(mins)м", "\(hrs)h \(mins)m übrig", "quedan \(hrs)h \(mins)m", "\(hrs)h \(mins)m restantes", "faltam \(hrs)h \(mins)m", "剩余\(hrs)时\(mins)分") }
    func expiryMinsLeft(_ mins: Int) -> String { s("\(mins)m left", "\(mins) мин", "\(mins)m übrig", "quedan \(mins)m", "\(mins)m restantes", "faltam \(mins)m", "剩余\(mins)分") }

    // MARK: — Report
    var report: String          { s("Report",        "Отчёт",         "Bericht",       "Informe", "Rapport", "Relatório", "报告") }
    var weekly: String          { s("Weekly",        "Недельный",     "Wöchentlich",   "Semanal", "Hebdomadaire", "Semanal", "每周") }
    var daily: String           { s("Daily",         "Дневной",       "Täglich",       "Diario", "Quotidien", "Diário", "每日") }
    var exportPDF: String       { s("Export PDF",    "Экспорт PDF",   "PDF exportieren", "Exportar PDF", "Exporter en PDF", "Exportar PDF", "导出 PDF") }
    var shareReport: String     { s("Share",         "Поделиться",    "Teilen",        "Compartir", "Partager", "Partilhar", "分享") }
    var paediatricReport: String { s("Paediatric Report", "Отчёт для педиатра", "Kinderbericht", "Informe pediátrico", "Rapport pédiatrique", "Relatório pediátrico", "儿科报告") }
    var prepareFor: String      { s("Prepare for",   "Подготовить за","Vorbereiten für", "Preparar para", "Préparer pour", "Preparar para", "准备就诊") }
    var visitSummaryHint: String { s("Visit summary: sleep · food · weight · temp · stool", "Итог визита: сон · еда · вес · темп · стул", "Besuchszusammenfassung: Schlaf · Essen · Gewicht · Temp · Stuhl", "Resumen de visita: sueño · comida · peso · temp · deposiciones", "Résumé de visite : sommeil · repas · poids · temp · selles", "Resumo da consulta: sono · comida · peso · temp · fezes", "就诊摘要：睡眠 · 饮食 · 体重 · 体温 · 大便") }
    var includeInReport: String { s("INCLUDE IN REPORT", "ВКЛЮЧИТЬ В ОТЧЁТ", "IN BERICHT EINSCHLIESSEN", "INCLUIR EN EL INFORME", "INCLURE DANS LE RAPPORT", "INCLUIR NO RELATÓRIO", "纳入报告") }
    var preparingPdf: String    { s("Preparing PDF…","Готовим PDF…",  "PDF vorbereiten…", "Preparando PDF…", "Préparation du PDF…", "A preparar PDF…", "正在生成 PDF…") }
    var sharePdf: String        { s("Share PDF",     "Поделиться PDF","PDF teilen",     "Compartir PDF", "Partager le PDF", "Partilhar PDF", "分享 PDF") }
    var printAction: String     { s("Print",         "Распечатать",   "Drucken",       "Imprimir", "Imprimer", "Imprimir", "打印") }
    var reportJobName: String   { s("Momsy — report","Momsy — отчёт", "Momsy — Bericht", "Momsy — informe", "Momsy — rapport", "Momsy — relatório", "Momsy — 报告") }
    var reportPeriod3Days: String      { s("3 days",       "3 дня",                "3 Tage",        "3 días", "3 jours", "3 dias", "3 天") }
    var reportPeriodWeek: String       { s("Week",          "Неделя",               "Woche",         "Semana", "Semaine", "Semana", "一周") }
    var reportPeriod2Weeks: String     { s("2 weeks",       "2 недели",             "2 Wochen",      "2 semanas", "2 semaines", "2 semanas", "2 周") }
    var reportPeriodMonth: String      { s("Month",         "Месяц",                "Monat",         "Mes", "Mois", "Mês", "一个月") }
    var reportPeriodSinceVisit: String { s("Since visit",   "С визита",             "Seit Besuch",   "Desde la visita", "Depuis la visite", "Desde a consulta", "自上次就诊") }
    var reportPeriodLabelWeek: String  { s("a week",        "неделю",               "eine Woche",    "una semana", "une semaine", "uma semana", "一周") }
    var reportPeriodLabelMonth: String { s("a month",       "месяц",                "einen Monat",   "un mes", "un mois", "um mês", "一个月") }
    var reportPeriodLabelLastVisit: String { s("last visit","последний визит",       "letzten Besuch", "última visita", "dernière visite", "última consulta", "上次就诊") }
    var noVisitRecorded: String        { s("No visit recorded",  "Визит не записан",  "Kein Besuch eingetragen", "Sin visita registrada", "Aucune visite enregistrée", "Nenhuma consulta registada", "未记录就诊") }
    var lastVisitDate: String          { s("Last visit date",    "Дата последнего визита", "Datum des letzten Besuchs", "Fecha de la última visita", "Date de la dernière visite", "Data da última consulta", "上次就诊日期") }
    var setVisitDate: String           { s("Set visit date",     "Указать дату визита",    "Besuchsdatum setzen", "Fijar fecha de visita", "Définir la date de visite", "Definir data da consulta", "设置就诊日期") }
    var reportSectionFeedings: String  { s("Feedings & spit-ups",  "Кормления и срыгивания",  "Mahlzeiten & Spucken", "Tomas y regurgitaciones", "Tétées et régurgitations", "Mamadas e regurgitações", "喂养与吐奶") }
    var reportSectionSleepByDay: String { s("Sleep by day",        "Сон по дням",             "Schlaf täglich", "Sueño por día", "Sommeil par jour", "Sono por dia", "每日睡眠") }
    var reportSectionDiapers: String   { s("Diapers & stool",      "Подгузники и стул",       "Windeln & Stuhl", "Pañales y deposiciones", "Couches et selles", "Fraldas e fezes", "尿布与大便") }
    var reportSectionTempSymptoms: String { s("Temp / symptoms",   "Температура / симптомы",  "Temp / Symptome", "Temp. / síntomas", "Temp. / symptômes", "Temp. / sintomas", "体温 / 症状") }
    var reportSectionWeightHeight: String { s("Weight & height",   "Вес и рост (график)",     "Gewicht & Größe", "Peso y altura", "Poids et taille", "Peso e altura", "体重与身高") }
    var reportSectionMedicine: String  { s("Medicine & vitamins",  "Лекарства и витамины",    "Medizin & Vitamine", "Medicina y vitaminas", "Médicaments et vitamines", "Medicação e vitaminas", "用药与维生素") }
    var reportSectionPhotosNotes: String { s("Photos & notes",     "Фото и заметки",          "Fotos & Notizen", "Fotos y notas", "Photos et notes", "Fotos e notas", "照片与备注") }
    var reportStatFeedingsLabel: String { s("Feedings",    "Кормлений",               "Mahlzeiten",   "Tomas", "Tétées", "Mamadas", "喂养") }
    func reportFeedAvgSub(avg: Double) -> String { s(String(format: "%.1f / day", avg), String(format: "%.1f / день", avg), String(format: "%.1f / Tag", avg), String(format: "%.1f / día", avg), String(format: "%.1f / jour", avg), String(format: "%.1f / dia", avg), String(format: "%.1f / 天", avg)) }
    var reportStatSleepLabel: String   { s("Sleep",        "Сон",                     "Schlaf",       "Sueño", "Sommeil", "Sono", "睡眠") }
    var reportStatSleepSub: String     { s("median / day", "медиана / сутки",          "Median / Tag", "mediana / día", "médiane / jour", "mediana / dia", "中位数 / 天") }
    var reportStatDiapersLabel: String { s("Diapers",      "Подгузники",              "Windeln",      "Pañales", "Couches", "Fraldas", "尿布") }
    var reportNotTracked: String       { s("not tracked",  "не отслеживается",         "nicht verfolgt", "no registrado", "non suivi", "não registado", "未记录") }
    var reportStatTempLabel: String    { s("Temperature",  "Температура",             "Temperatur",   "Temperatura", "Température", "Temperatura", "体温") }
    func reportTempPeakSub(n: Int) -> String { s("peak · \(n)×", "пик · \(n)×",      "Peak · \(n)×",  "pico · \(n)×", "pic · \(n)×", "pico · \(n)×", "峰值 · \(n)次") }
    var reportTempNormal: String       { s("normal",       "норма",                   "normal",       "normal", "normal", "normal", "正常") }
    var reportStatWeightLabel: String  { s("Weight & Height", "Вес и рост",           "Gewicht & Größe", "Peso y altura", "Poids et taille", "Peso e altura", "体重与身高") }
    var reportSparkWeightLabel: String { s("Weight, kg",      "Вес, кг",              "Gewicht, kg",  "Peso, kg", "Poids, kg", "Peso, kg", "体重，kg") }
    func reportSparkWeightDynamicLabel(unit: String) -> String { s("Weight, \(unit)", "Вес, \(unit)", "Gewicht, \(unit)", "Peso, \(unit)", "Poids, \(unit)", "Peso, \(unit)", "体重，\(unit)") }
    var reportSparkFeedingsLabel: String { s("Feedings / day",  "Кормления / сут",    "Mahlzeiten / Tag", "Tomas / día", "Tétées / jour", "Mamadas / dia", "喂养 / 天") }
    var reportSparkSleepLabel: String  { s("Sleep / day (h)",   "Сон / сут (ч)",      "Schlaf / Tag (h)", "Sueño / día (h)", "Sommeil / jour (h)", "Sono / dia (h)", "睡眠 / 天（时）") }
    var reportSparkTempLabel: String   { s("Temperature °C",    "Температура °C",     "Temperatur °C", "Temperatura °C", "Température °C", "Temperatura °C", "体温 °C") }
    func reportSparkTempDynamicLabel(unit: String) -> String { s("Temperature \(unit)", "Температура \(unit)", "Temperatur \(unit)", "Temperatura \(unit)", "Température \(unit)", "Temperatura \(unit)", "体温 \(unit)") }
    var reportSparkDiapersLabel: String { s("Diapers / day",   "Подгузники / сут",   "Windeln / Tag", "Pañales / día", "Couches / jour", "Fraldas / dia", "尿布 / 天") }
    func reportPreviewPeriod(label: String) -> String { s("Period: \(label)", "Период: \(label)", "Zeitraum: \(label)", "Periodo: \(label)", "Période : \(label)", "Período: \(label)", "时间段：\(label)") }
    var reportPreviewDoctorNotes: String { s("DOCTOR'S NOTES", "ЗАМЕТКИ ВРАЧА",        "ARZTNOTIZEN",  "NOTAS DEL MÉDICO", "NOTES DU MÉDECIN", "NOTAS DO MÉDICO", "医生备注") }
    func reportSparkPeak(value: String) -> String { s("peak: \(value)", "пик: \(value)", "Peak: \(value)", "pico: \(value)", "pic : \(value)", "pico: \(value)", "峰值：\(value)") }

    // MARK: — Symptoms
    var symptomLabelTemperature: String  { s("Temperature",    "Температура",     "Temperatur",   "Temperatura", "Température", "Temperatura", "体温") }
    var symptomLabelRash: String         { s("Rash",           "Сыпь",            "Ausschlag",    "Sarpullido", "Éruption", "Erupção", "皮疹") }
    var symptomLabelVomiting: String     { s("Vomiting",       "Рвота",           "Erbrechen",    "Vómitos", "Vomissements", "Vómitos", "呕吐") }
    var symptomLabelLongCrying: String   { s("Long crying",    "Долгий плач",     "Langes Weinen", "Llanto prolongado", "Pleurs prolongés", "Choro prolongado", "长时间哭闹") }
    var symptomLabelStool: String        { s("Stool",          "Стул",            "Stuhl",        "Deposición", "Selles", "Fezes", "大便") }
    var symptomLabelRefusingFood: String { s("Refusing food",  "Отказ от еды",    "Nahrungsverweigerung", "Rechazo de comida", "Refus de manger", "Recusa de comida", "拒食") }
    var symptomLabelSleepIssues: String  { s("Sleep issues",   "Нарушение сна",   "Schlafprobleme", "Problemas de sueño", "Troubles du sommeil", "Problemas de sono", "睡眠问题") }
    var symptomLabelOther: String        { s("Other",          "Другое",          "Sonstiges",    "Otro", "Autre", "Outro", "其他") }
    var symptomSubChooseArea: String     { s("choose area",    "выберите место",   "Bereich wählen", "elige zona", "choisir la zone", "escolher zona", "选择部位") }
    var symptomSubNone: String           { s("none",           "нет",             "keine",        "ninguno", "aucun", "nenhum", "无") }
    var symptomSubStoolNormal: String    { s("normal",         "обычный",         "normal",       "normal", "normal", "normal", "正常") }
    var symptomSubSelect: String         { s("select",         "выбрать",         "auswählen",    "seleccionar", "sélectionner", "selecionar", "选择") }
    var symptomSubShortPhases: String    { s("short phases",   "короткие фазы",   "kurze Phasen", "fases cortas", "phases courtes", "fases curtas", "短暂阶段") }
    var symptomSubDescribe: String       { s("describe",       "описать",         "beschreiben",  "describir", "décrire", "descrever", "描述") }
    var symptomUrgencyWatching: String   { s("Watching",       "Наблюдаем",       "Beobachten",   "Observando", "Surveillance", "A observar", "观察中") }
    var symptomUrgencyLikely: String     { s("Likely",         "Скорее всего",    "Wahrscheinlich", "Probable", "Probable", "Provável", "可能") }
    var symptomUrgencySeeDoctor: String  { s("See Doctor",     "Нужен врач",      "Arzt aufsuchen", "Ver al médico", "Consulter un médecin", "Consultar médico", "就医") }
    var symptomResultNothingTitle: String  { s("Nothing marked",      "Ничего не отмечено",          "Nichts markiert", "Nada marcado", "Rien de marqué", "Nada marcado", "未标记任何症状") }
    var symptomResultNothingDetail: String { s("Mark symptoms above — we'll suggest what might be happening.", "Отметьте симптомы выше — мы подскажем, что может происходить.", "Markieren Sie Symptome oben — wir schlagen vor, was passieren könnte.", "Marca los síntomas arriba — te sugeriremos qué puede estar pasando.", "Marquez les symptômes ci-dessus — nous suggérerons ce qui pourrait se passer.", "Marque os sintomas acima — vamos sugerir o que pode estar a acontecer.", "在上方标记症状——我们会提示可能的情况。") }
    var symptomResultExamTitle: String   { s("Needs Examination",     "Требует осмотра",             "Untersuchung nötig", "Necesita revisión", "Nécessite un examen", "Requer observação", "需要就诊检查") }
    var symptomResultExamDetail: String  { s("Fever combined with a rash needs a paediatrician's attention. Don't delay — call your doctor today.", "Сочетание температуры и сыпи требует внимания педиатра. Не откладывайте — позвоните врачу сегодня.", "Fieber mit Ausschlag erfordert einen Kinderarzt. Nicht verzögern — rufen Sie heute an.", "La fiebre junto con sarpullido requiere un pediatra. No lo demores — llama hoy al médico.", "La fièvre associée à une éruption nécessite l’attention d’un pédiatre. Ne tardez pas — appelez votre médecin aujourd’hui.", "Febre com erupção precisa da atenção de um pediatra. Não adie — ligue hoje ao médico.", "发热伴皮疹需要儿科医生关注。请勿拖延——今天就联系医生。") }
    var symptomResultExamWarning: String { s("rash + fever · face or throat swelling · difficulty breathing", "сыпь + температура · отёк лица или горла · затруднённое дыхание", "Ausschlag + Fieber · Gesichts-/Halschwellung · Atembeschwerden", "sarpullido + fiebre · hinchazón de cara o garganta · dificultad para respirar", "éruption + fièvre · gonflement du visage ou de la gorge · difficulté à respirer", "erupção + febre · inchaço do rosto ou garganta · dificuldade em respirar", "皮疹 + 发热 · 面部或咽喉肿胀 · 呼吸困难") }
    var symptomResultGastroTitle: String   { s("Gastroenteritis",    "Гастроэнтерит",               "Gastroenteritis", "Gastroenteritis", "Gastro-entérite", "Gastroenterite", "肠胃炎") }
    var symptomResultGastroDetail: String  { s("Vomiting with fever may indicate a gut infection. Keep fluids up: offer breast and water more often.", "Рвота с температурой — возможна кишечная инфекция. Следите за водным балансом: грудь и вода чаще обычного.", "Erbrechen mit Fieber kann auf eine Darminfektion hinweisen. Mehr Flüssigkeit anbieten.", "Los vómitos con fiebre pueden indicar una infección intestinal. Mantén los líquidos: ofrece pecho y agua más a menudo.", "Des vomissements avec fièvre peuvent indiquer une infection intestinale. Maintenez l’hydratation : proposez le sein et de l’eau plus souvent.", "Vómitos com febre podem indicar uma infeção intestinal. Mantenha a hidratação: ofereça o peito e água com mais frequência.", "呕吐伴发热可能提示肠道感染。注意补液：更频繁地哺乳和喂水。") }
    var symptomResultGastroWarning: String { s("refusing fluids 6+ hrs · sunken fontanelle · dry mouth · bloody vomit", "отказ от воды дольше 6 ч · запавший родничок · сухой рот · рвота с кровью", "Flüssigkeitsverweigerung 6+ Std. · eingesunkene Fontanelle · trockener Mund · blutiges Erbrechen", "rechazo de líquidos 6+ h · fontanela hundida · boca seca · vómito con sangre", "refus de boire 6 h+ · fontanelle creusée · bouche sèche · vomissements sanglants", "recusa de líquidos 6+ h · fontanela funda · boca seca · vómito com sangue", "拒绝饮水超过 6 小时 · 囟门凹陷 · 口干 · 呕血") }
    var symptomResultDigestTitle: String   { s("Digestive Upset",    "Расстройство ЖКТ",            "Verdauungsstörung", "Malestar digestivo", "Trouble digestif", "Mal-estar digestivo", "消化不适") }
    var symptomResultDigestDetail: String  { s("Possible overfeeding, gas, or food reaction. Hold baby upright 20 min after feeding.", "Возможен перекорм, газы или реакция на питание. Держите малыша вертикально 20 мин после еды.", "Mögliche Überernährung, Blähungen oder Nahrungsreaktion. 20 Min. nach dem Füttern aufrichten.", "Posible sobrealimentación, gases o reacción a un alimento. Mantén al bebé erguido 20 min tras la toma.", "Possible suralimentation, gaz ou réaction alimentaire. Tenez le bébé droit 20 min après la tétée.", "Possível excesso de alimentação, gases ou reação a alimentos. Mantenha o bebé na vertical 20 min após a mamada.", "可能是喂养过量、胀气或食物反应。喂奶后让宝宝竖抱 20 分钟。") }
    var symptomResultDigestWarning: String { s("projectile vomiting · vomiting 3+ times in 2 hrs · blood in vomit", "рвота фонтаном · рвота более 3 раз за 2 ч · кровь в рвоте", "Schwallartigem Erbrechen · 3+ Erbrechen in 2 Std. · Blut im Erbrechen", "vómito en escopetazo · vómitos 3+ veces en 2 h · sangre en el vómito", "vomissements en jet · vomissements 3 fois+ en 2 h · sang dans les vomissements", "vómito em jato · vómitos 3+ vezes em 2 h · sangue no vómito", "喷射性呕吐 · 2 小时内呕吐 3 次以上 · 呕吐物带血") }
    var symptomResultTeethTitle: String    { s("Teething",           "Прорезывание зубов",          "Zahnen", "Dentición", "Poussée dentaire", "Nascimento dos dentes", "出牙") }
    var symptomResultTeethDetail: String   { s("Temp up to 38°, crying, disturbed sleep — classic signs. Try a cold teether, carry more.", "Температура до 38°, плач, нарушение сна — частые спутники. Попробуйте холодный прорезыватель, носите на руках.", "Temp bis 38°, Weinen, gestörter Schlaf — klassische Anzeichen. Kühler Beißring, mehr tragen.", "Temp. hasta 38°, llanto, sueño alterado — signos típicos. Prueba un mordedor frío y cárgalo más.", "Temp. jusqu’à 38°, pleurs, sommeil perturbé — signes classiques. Essayez un anneau de dentition froid, portez-le plus.", "Temp. até 38°, choro, sono perturbado — sinais clássicos. Experimente uma mordedeira fria e pegue-o mais ao colo.", "体温至多 38°、哭闹、睡眠不安——典型表现。试试冰凉的牙胶，多抱抱。") }
    var symptomResultTeethWarning: String  { s("t° > 38.5° for more than a day · refusing fluids · lethargy · unusual rash", "t° > 38.5° дольше суток · отказ от воды · вялость · необычная сыпь", "t° > 38,5° mehr als einen Tag · Flüssigkeitsverweigerung · Lethargie · ungewöhnlicher Ausschlag", "t° > 38.5° más de un día · rechazo de líquidos · letargo · sarpullido inusual", "t° > 38,5° plus d’une journée · refus de boire · léthargie · éruption inhabituelle", "t° > 38,5° mais de um dia · recusa de líquidos · letargia · erupção invulgar", "体温 > 38.5° 持续超过一天 · 拒绝饮水 · 嗜睡 · 异常皮疹") }
    var symptomResultArviTitle: String     { s("ARVI / Sore Throat", "ОРВИ / воспаление горла",     "Virusinfektion / Halsschmerzen", "Infección viral / dolor de garganta", "Infection virale / mal de gorge", "Infeção viral / dor de garganta", "病毒感染 / 咽痛") }
    var symptomResultArviDetail: String    { s("Refusing food with fever is a common sign of a viral infection. Offer fluids and breast more often.", "Отказ от еды при температуре — частый признак вирусной инфекции. Предлагайте воду и грудь чаще обычного.", "Nahrungsverweigerung mit Fieber ist häufig bei Virusinfektionen. Mehr Flüssigkeit anbieten.", "El rechazo de comida con fiebre es un signo común de infección viral. Ofrece líquidos y pecho más a menudo.", "Le refus de manger avec de la fièvre est un signe courant d’infection virale. Proposez des liquides et le sein plus souvent.", "A recusa de comida com febre é um sinal comum de infeção viral. Ofereça líquidos e o peito com mais frequência.", "发热伴拒食是病毒感染的常见表现。更频繁地喂水和哺乳。") }
    var symptomResultArviWarning: String   { s("t° > 39° · difficulty breathing · lethargy · refusing all fluids", "t° > 39° · затруднённое дыхание · вялость · отказ от воды", "t° > 39° · Atembeschwerden · Lethargie · Flüssigkeitsverweigerung", "t° > 39° · dificultad para respirar · letargo · rechazo de todo líquido", "t° > 39° · difficulté à respirer · léthargie · refus de tout liquide", "t° > 39° · dificuldade em respirar · letargia · recusa de todos os líquidos", "体温 > 39° · 呼吸困难 · 嗜睡 · 拒绝一切液体") }
    var symptomResultViralTitle: String    { s("Viral Infection",    "Вирусная инфекция",           "Virale Infektion", "Infección viral", "Infection virale", "Infeção viral", "病毒感染") }
    var symptomResultViralDetail: String   { s("Monitor closely. Use fever reducer at t° > 38.5°. Ensure adequate fluids.", "Следите за динамикой. Жаропонижающее при t° > 38.5°. Обеспечьте достаточное питьё.", "Genau beobachten. Fiebermittel bei t° > 38,5°. Ausreichend Flüssigkeit sicherstellen.", "Vigila de cerca. Usa antitérmico a t° > 38.5°. Asegura líquidos suficientes.", "Surveillez de près. Utilisez un antipyrétique à t° > 38,5°. Assurez une hydratation suffisante.", "Vigie de perto. Use antipirético a t° > 38,5°. Garanta líquidos suficientes.", "密切观察。体温 > 38.5° 时使用退烧药。确保充足补液。") }
    var symptomResultViralWarning: String  { s("t° > 38° in babies under 3 mo · t° > 39° in older babies · seizures · lethargy", "t° > 38° у детей до 3 мес · t° > 39° у старших · судороги · вялость", "t° > 38° bei Säuglingen unter 3 Mo · t° > 39° bei älteren · Krämpfe · Lethargie", "t° > 38° en bebés menores de 3 meses · t° > 39° en mayores · convulsiones · letargo", "t° > 38° chez les bébés de moins de 3 mois · t° > 39° chez les plus grands · convulsions · léthargie", "t° > 38° em bebés com menos de 3 meses · t° > 39° em bebés mais velhos · convulsões · letargia", "3 个月以下宝宝体温 > 38° · 较大宝宝体温 > 39° · 抽搐 · 嗜睡") }
    var symptomResultLeapTitle: String     { s("Leap or Colic",      "Скачок или колики",           "Entwicklungsschub oder Koliken", "Salto o cólico", "Bond ou coliques", "Salto ou cólicas", "猛长期或肠绞痛") }
    var symptomResultLeapDetail: String    { s("Crying and disturbed sleep without fever are usually a developmental leap or colic. Try tummy massage and the 'tiger position'.", "Плач и нарушение сна без температуры чаще всего — скачок развития или колики. Попробуйте массаж животика и «позицию тигра».", "Weinen und gestörter Schlaf ohne Fieber sind meist ein Entwicklungsschub oder Koliken. Bauchmassage und 'Tigerposition' versuchen.", "El llanto y el sueño alterado sin fiebre suelen ser un salto del desarrollo o cólicos. Prueba masaje en la tripita y la 'posición del tigre'.", "Les pleurs et le sommeil perturbé sans fièvre sont souvent un bond de développement ou des coliques. Essayez le massage du ventre et la « position du tigre ».", "Choro e sono perturbado sem febre são normalmente um salto de desenvolvimento ou cólicas. Experimente massagem na barriga e a «posição do tigre».", "无发热的哭闹和睡眠不安通常是发育猛长期或肠绞痛。试试腹部按摩和「飞机抱」。") }
    var symptomResultLeapWarning: String   { s("crying 3+ hrs non-stop · hard bloated belly", "плач дольше 3 часов без перерыва · живот твёрдый и вздутый", "Weinen 3+ Std. ohne Unterbrechung · harter aufgeblähter Bauch", "llanto 3+ h sin parar · tripita dura e hinchada", "pleurs 3 h+ sans arrêt · ventre dur et ballonné", "choro 3+ h sem parar · barriga dura e inchada", "持续哭闹 3 小时以上 · 腹部硬胀") }
    var symptomResultCryingTitle: String   { s("Prolonged Crying",   "Долгий плач",                "Anhaltender Weinkrampf", "Llanto prolongado", "Pleurs prolongés", "Choro prolongado", "持续哭闹") }
    var symptomResultCryingDetail: String  { s("Check the basics: hunger, diaper, room temperature, tiredness. Peak colic age is 6 weeks.", "Проверьте основные причины: голод, подгузник, температура в комнате, усталость. Пик колик — 6 недель.", "Grundlegendes prüfen: Hunger, Windel, Raumtemperatur, Müdigkeit. Höhepunkt der Koliken: 6 Wochen.", "Revisa lo básico: hambre, pañal, temperatura del cuarto, cansancio. El pico de cólicos es a las 6 semanas.", "Vérifiez les bases : faim, couche, température de la pièce, fatigue. Le pic des coliques est à 6 semaines.", "Verifique o básico: fome, fralda, temperatura do quarto, cansaço. O pico das cólicas é às 6 semanas.", "检查基本情况：饥饿、尿布、室温、疲倦。肠绞痛高峰在 6 周龄。") }
    var symptomResultCryingWarning: String { s("unusual tone of cry · arching back · no urination 8+ hrs", "плач необычного тона · выгибание спины · нет мочеиспускания 8+ ч", "Ungewöhnlicher Weinton · Rücken wölben · kein Wasserlassen 8+ Std.", "tono de llanto inusual · arquea la espalda · sin orinar 8+ h", "ton de pleurs inhabituel · dos cambré · pas de miction 8 h+", "tom de choro invulgar · arquear as costas · sem urinar 8+ h", "哭声异常 · 身体后弓 · 超过 8 小时未排尿") }
    var symptomResultWatchingTitle: String   { s("Watching",         "Наблюдаем",                  "Beobachten", "Observando", "Surveillance", "A observar", "观察中") }
    var symptomResultWatchingDetail: String  { s("The marked symptoms aren't alarming. Keep observing and log any changes.", "Отмеченные симптомы не вызывают тревоги. Продолжайте наблюдать и записывайте любые изменения.", "Die markierten Symptome sind nicht besorgniserregend. Weiter beobachten.", "Los síntomas marcados no son alarmantes. Sigue observando y registra cualquier cambio.", "Les symptômes marqués ne sont pas alarmants. Continuez à observer et notez tout changement.", "Os sintomas marcados não são alarmantes. Continue a observar e registe quaisquer alterações.", "所标记的症状并不令人担忧。继续观察并记录任何变化。") }
    var symptomResultWatchingWarning: String { s("any worsening · new symptoms · your gut — you know your baby best", "любое ухудшение · новые симптомы · ваша интуиция — вы лучше знаете малыша", "Jede Verschlechterung · neue Symptome · Ihr Instinkt — Sie kennen Ihr Baby am besten", "cualquier empeoramiento · síntomas nuevos · tu instinto — conoces mejor a tu bebé", "toute aggravation · nouveaux symptômes · votre instinct — vous connaissez mieux votre bébé", "qualquer agravamento · novos sintomas · o seu instinto — conhece melhor o seu bebé", "任何恶化 · 新症状 · 您的直觉——您最了解自己的宝宝") }

    // MARK: — Navigation tabs
    var tabDoctor: String       { s("Doctor",        "Доктор",        "Arzt",          "Médico", "Médecin", "Médico", "医生") }
    var tabMe: String           { s("Me",            "Я",             "Ich",           "Yo", "Moi", "Eu", "我") }
    var profile: String         { s("Profile",       "Профиль",       "Profil",        "Perfil", "Profil", "Perfil", "资料") }

    // MARK: — Splash
    var splashTagline: String   { s("Your baby's little diary", "Дневник вашего малыша", "Das Tagebuch deines Babys", "El pequeño diario de tu bebé", "Le petit journal de votre bébé", "O pequeno diário do seu bebé", "您宝宝的小日记") }

    // MARK: — Settings
    var settings: String        { s("Settings",      "Настройки",     "Einstellungen", "Ajustes", "Réglages", "Definições", "设置") }
    var language: String        { s("Language",      "Язык",          "Sprache",       "Idioma", "Langue", "Idioma", "语言") }
    var theme: String           { s("Theme",         "Тема",          "Design",        "Tema", "Thème", "Tema", "主题") }
    var appTheme: String        { s("App Theme",     "Тема приложения","App-Design",    "Tema de la app", "Thème de l’app", "Tema da app", "应用主题") }
    var themeAuto: String       { s("Auto",          "Авто",          "Auto",          "Auto", "Auto", "Auto", "自动") }
    var autoThemeHint: String   { s("Auto follows the system appearance.", "Авто — следует системной теме устройства.", "Auto folgt der Systemdarstellung.", "Auto sigue la apariencia del sistema.", "Auto suit l’apparence du système.", "Auto segue a aparência do sistema.", "自动跟随系统外观。") }
    var appLanguage: String     { s("App Language",  "Язык приложения","App-Sprache",   "Idioma de la app", "Langue de l’app", "Idioma da app", "应用语言") }
    var languageComingSoon: String { s("More languages coming soon.", "Больше языков — скоро.", "Weitere Sprachen folgen bald.", "Pronto habrá más idiomas.", "D’autres langues bientôt.", "Mais idiomas em breve.", "更多语言即将推出。") }
    var unitSystem: String      { s("Units",           "Единицы",       "Einheiten",     "Unidades", "Unités", "Unidades", "单位") }
    var unitMetric: String      { s("Metric",          "Метрическая",   "Metrisch",      "Métrico", "Métrique", "Métrico", "公制") }
    var unitImperial: String    { s("Imperial",        "Имперская",     "Imperial",      "Imperial", "Impérial", "Imperial", "英制") }
    var unitSystemHint: String  { s("Metric: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Метр.: кг, см, °C, мл · Импер.: lb, in, °F, oz",
                                     "Metrisch: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Métrico: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "Métrique : kg, cm, °C, ml · Impérial : lb, in, °F, oz",
                                     "Métrico: kg, cm, °C, ml · Imperial: lb, in, °F, oz",
                                     "公制：kg、cm、°C、ml · 英制：lb、in、°F、oz") }
    var about: String           { s("About",         "О приложении",  "Über",          "Acerca de", "À propos", "Acerca de", "关于") }
    var version: String         { s("Version",       "Версия",        "Version",       "Versión", "Version", "Versão", "版本") }
    var madeWithLove: String    { s("Made with love","Сделано с любовью","Mit Liebe gemacht", "Hecho con amor", "Fait avec amour", "Feito com amor", "用心打造") }
    var forMoms: String         { s("for moms",      "для мам",       "für Mütter",    "para mamás", "pour les mamans", "para as mamãs", "献给妈妈们") }
    var privacy: String         { s("Privacy",       "Конфиденциальность","Datenschutz", "Privacidad", "Confidentialité", "Privacidade", "隐私") }
    var feedback: String        { s("Feedback",      "Обратная связь", "Feedback",      "Comentarios", "Retour", "Comentários", "反馈") }
    var icloudSyncTitle: String { s("Cloud Sync",    "Облачная синхронизация", "Cloud-Synchronisierung", "Sincronización en la nube", "Synchronisation cloud", "Sincronização na nuvem", "云同步") }
    var icloudSyncDisclosure: String {
        s("Your baby's health records and your well-being entries (including the EPDS screening) are stored on this device and synced through your private Firebase account so they stay in sync across your devices. They are never shared with third parties or used for ads.",
          "Записи о здоровье малыша и ваши записи о самочувствии (включая скрининг EPDS) хранятся на этом устройстве и синхронизируются через ваш личный аккаунт Firebase, чтобы данные совпадали на всех ваших устройствах. Они никогда не передаются третьим лицам и не используются для рекламы.",
          "Die Gesundheitsdaten deines Babys und deine Wohlbefinden-Einträge (einschließlich des EPDS-Screenings) werden auf diesem Gerät gespeichert und über dein privates Firebase-Konto synchronisiert, damit sie auf deinen Geräten übereinstimmen. Sie werden nie an Dritte weitergegeben oder für Werbung verwendet.",
          "Los registros de salud de tu bebé y tus entradas de bienestar (incluido el cribado EPDS) se guardan en este dispositivo y se sincronizan a través de tu cuenta privada de Firebase para mantenerlos sincronizados entre tus dispositivos. Nunca se comparten con terceros ni se usan para publicidad.",
          "Les données de santé de votre bébé et vos entrées de bien-être (y compris le dépistage EPDS) sont stockées sur cet appareil et synchronisées via votre compte Firebase privé afin de rester synchronisées entre vos appareils. Elles ne sont jamais partagées avec des tiers ni utilisées à des fins publicitaires.",
          "Os registos de saúde do seu bebé e as suas entradas de bem-estar (incluindo o rastreio EPDS) são guardados neste dispositivo e sincronizados através da sua conta privada do Firebase para se manterem sincronizados entre os seus dispositivos. Nunca são partilhados com terceiros nem usados para publicidade.",
          "您宝宝的健康记录和您的身心状态记录（包括 EPDS 筛查）保存在本设备上，并通过您的私人 Firebase 账户同步，以便在您的各设备间保持一致。它们绝不会与第三方共享或用于广告。")
    }
    var dangerZone: String      { s("Data & Privacy", "Данные и конфиденциальность", "Daten & Datenschutz", "Datos y privacidad", "Données et confidentialité", "Dados e privacidade", "数据与隐私") }
    var deleteAllData: String   { s("Delete all data", "Удалить все данные", "Alle Daten löschen", "Eliminar todos los datos", "Supprimer toutes les données", "Eliminar todos os dados", "删除所有数据") }
    var deleteAllDataConfirm: String {
        s("This permanently deletes your account and every record — on this device and in the cloud — including health and well-being data and diary photos. This cannot be undone.",
          "Это навсегда удалит ваш аккаунт и все записи — на этом устройстве и в облаке — включая данные о здоровье и самочувствии и фото из дневника. Это действие необратимо.",
          "Dies löscht dauerhaft dein Konto und alle Einträge – auf diesem Gerät und in der Cloud – einschließlich Gesundheits- und Wohlbefindensdaten sowie Tagebuchfotos. Dies kann nicht rückgängig gemacht werden.",
          "Esto elimina permanentemente tu cuenta y todos los registros — en este dispositivo y en la nube — incluidos los datos de salud y bienestar y las fotos del diario. Esto no se puede deshacer.",
          "Ceci supprime définitivement votre compte et tous les enregistrements — sur cet appareil et dans le cloud — y compris les données de santé et de bien-être et les photos du journal. Cette action est irréversible.",
          "Isto elimina permanentemente a sua conta e todos os registos — neste dispositivo e na nuvem — incluindo dados de saúde e bem-estar e fotos do diário. Esta ação não pode ser anulada.",
          "这将永久删除您的账户和所有记录——包括本设备和云端——其中包括健康和身心状态数据以及日记照片。此操作无法撤销。")
    }
    var deleting: String        { s("Deleting…",     "Удаление…",     "Wird gelöscht…", "Eliminando…", "Suppression…", "A eliminar…", "正在删除…") }
    var deleteFailed: String    { s("Couldn't delete your data. Please try again.", "Не удалось удалить данные. Попробуйте ещё раз.", "Daten konnten nicht gelöscht werden. Bitte versuche es erneut.", "No se pudieron eliminar los datos. Inténtalo de nuevo.", "Impossible de supprimer vos données. Veuillez réessayer.", "Não foi possível eliminar os seus dados. Tente novamente.", "无法删除您的数据。请重试。") }
    var themeSystem: String     { s("System",        "Системная",     "System",        "Sistema", "Système", "Sistema", "系统") }
    var themeLight: String      { s("Light",         "Светлая",       "Hell",          "Claro", "Clair", "Claro", "浅色") }
    var themeDark: String       { s("Dark",          "Тёмная",        "Dunkel",        "Oscuro", "Sombre", "Escuro", "深色") }
    var notifications: String   { s("Notifications", "Уведомления",   "Benachrichtigungen", "Notificaciones", "Notifications", "Notificações", "通知") }
    var babyProfile: String     { s("Baby profile",  "Профиль малыша","Baby-Profil",   "Perfil del bebé", "Profil du bébé", "Perfil do bebé", "宝宝资料") }
    var children: String        { s("Children",      "Дети",          "Kinder",        "Niños", "Enfants", "Crianças", "孩子") }
    var addChild: String        { s("Add child",     "Добавить ребёнка", "Kind hinzufügen", "Añadir niño", "Ajouter un enfant", "Adicionar criança", "添加孩子") }
    var newChild: String        { s("New child",     "Новый ребёнок", "Neues Kind",    "Nuevo niño", "Nouvel enfant", "Nova criança", "新孩子") }
    var childrenProfiles: String { s("Children’s profiles", "Профили детей", "Kinderprofile", "Perfiles de niños", "Profils des enfants", "Perfis das crianças", "孩子资料") }
    var childrenSettingsHint: String {
        s("Add, switch, or remove child profiles.",
          "Добавляйте, переключайте или удаляйте профили детей.",
          "Kinderprofile hinzufügen, wechseln oder entfernen.",
          "Añade, cambia o elimina perfiles de niños.",
          "Ajoutez, changez ou supprimez les profils des enfants.",
          "Adicione, alterne ou remova perfis de crianças.",
          "添加、切换或移除孩子资料。")
    }
    func maxChildrenHint(_ count: Int) -> String {
        s("Up to \(count) children.",
          "До \(count) детей.",
          "Bis zu \(count) Kinder.",
          "Hasta \(count) niños.",
          "Jusqu’à \(count) enfants.",
          "Até \(count) crianças.",
          "最多 \(count) 个孩子。")
    }
    func deleteChildTitle(_ name: String) -> String {
        s("Delete \(name)?",
          "Удалить \(name)?",
          "\(name) löschen?",
          "¿Eliminar \(name)?",
          "Supprimer \(name) ?",
          "Eliminar \(name)?",
          "删除 \(name)？")
    }
    func deleteChildMessage(_ name: String) -> String {
        s("This permanently removes \(name)'s profile and records from this device and the cloud. This cannot be undone.",
          "Профиль \(name) и все записи будут навсегда удалены с этого устройства и из облака. Это действие необратимо.",
          "Das Profil und alle Einträge von \(name) werden dauerhaft von diesem Gerät und aus der Cloud gelöscht. Dies kann nicht rückgängig gemacht werden.",
          "Esto elimina permanentemente el perfil y los registros de \(name) de este dispositivo y de la nube. No se puede deshacer.",
          "Le profil et les enregistrements de \(name) seront définitivement supprimés de cet appareil et du cloud. Cette action est irréversible.",
          "Isto remove permanentemente o perfil e os registos de \(name) deste dispositivo e da nuvem. Não pode ser desfeito.",
          "这会从本设备和云端永久删除 \(name) 的资料和记录。此操作无法撤销。")
    }
    var cannotDeleteLastChild: String {
        s("At least one child profile must remain.",
          "Должен остаться хотя бы один профиль ребёнка.",
          "Mindestens ein Kinderprofil muss erhalten bleiben.",
          "Debe quedar al menos un perfil de niño.",
          "Au moins un profil d’enfant doit rester.",
          "Deve permanecer pelo menos um perfil de criança.",
          "至少需要保留一个孩子资料。")
    }
    var editProfile: String     { s("Edit Profile",  "Редактировать", "Bearbeiten",    "Editar perfil", "Modifier le profil", "Editar perfil", "编辑资料") }
    var saveChanges: String     { s("Save changes",  "Сохранить",     "Speichern",     "Guardar cambios", "Enregistrer les modifications", "Guardar alterações", "保存更改") }
    var profileUpdated: String  { s("Profile saved", "Профиль сохранён","Profil gespeichert", "Perfil guardado", "Profil enregistré", "Perfil guardado", "资料已保存") }
    var subscription: String    { s("Subscription",  "Подписка",      "Abonnement",    "Suscripción", "Abonnement", "Subscrição", "订阅") }
    var privacyPolicy: String   { s("Privacy Policy","Политика конфид.", "Datenschutz", "Política de privacidad", "Politique de confidentialité", "Política de privacidade", "隐私政策") }
    var termsOfUse: String      { s("Terms of Use",  "Условия использования", "Nutzungsbedingungen", "Términos de uso", "Conditions d’utilisation", "Termos de utilização", "使用条款") }
    var termsOfUseEULA: String  { s("Terms of Use (EULA)", "Условия использования (EULA)", "Nutzungsbedingungen (EULA)", "Términos de uso (EULA)", "Conditions d’utilisation (EULA)", "Termos de utilização (EULA)", "使用条款 (EULA)") }

    // MARK: — Onboarding
    var onboardingWelcome: String { s("Welcome to Momsy", "Добро пожаловать в Momsy", "Willkommen bei Momsy", "Bienvenida a Momsy", "Bienvenue sur Momsy", "Bem-vinda à Momsy", "欢迎使用 Momsy") }
    var onboardingSubtitle: String { s("Your smart baby tracker", "Умный трекер малыша", "Dein smarter Baby-Tracker", "Tu rastreador inteligente del bebé", "Votre suivi bébé intelligent", "O seu rastreador inteligente do bebé", "您的智能宝宝记录助手") }
    var babyName: String        { s("Baby's name",   "Имя малыша",    "Name des Babys", "Nombre del bebé", "Prénom du bébé", "Nome do bebé", "宝宝的名字") }
    var birthDate: String       { s("Birth date",    "Дата рождения", "Geburtsdatum",  "Fecha de nacimiento", "Date de naissance", "Data de nascimento", "出生日期") }
    var getStarted: String      { s("Get started",   "Начать",        "Loslegen",      "Empezar", "Commencer", "Começar", "开始使用") }
    var continueLabel: String   { s("Continue",      "Продолжить",    "Weiter",        "Continuar", "Continuer", "Continuar", "继续") }
    var continueArrow: String   { s("Continue →",    "Продолжить →",  "Weiter →",      "Continuar →", "Continuer →", "Continuar →", "继续 →") }
    var skip: String            { s("Skip",          "Пропустить",    "Überspringen",  "Omitir", "Passer", "Ignorar", "跳过") }
    var helloMama: String       { s("Hello, mama!",  "Привет, мама!", "Hallo, Mama!",  "¡Hola, mamá!", "Bonjour, maman !", "Olá, mamã!", "你好，妈妈！") }
    var howOldIsYourBaby: String { s("How old is your baby?\nWe'll tailor everything to their age.", "Сколько малышу?\nМы всё адаптируем под его возраст.", "Wie alt ist Ihr Baby?\nWir passen alles an.", "¿Cuántos meses tiene tu bebé?\nLo adaptaremos todo a su edad.", "Quel âge a votre bébé ?\nNous adapterons tout à son âge.", "Que idade tem o seu bebé?\nVamos adaptar tudo à idade dele.", "宝宝多大了？\n我们会根据他的年龄量身定制一切。") }
    var ageChangeNote: String   { s("Age can be changed later. We'll highlight developmental leaps specifically for you.", "Возраст можно изменить позже. Мы выделим скачки развития специально для вас.", "Alter kann später geändert werden.", "La edad se puede cambiar después. Destacaremos los saltos del desarrollo especialmente para ti.", "L’âge peut être modifié plus tard. Nous mettrons en avant les bonds de développement spécialement pour vous.", "A idade pode ser alterada mais tarde. Vamos destacar os saltos de desenvolvimento especialmente para si.", "年龄之后可以修改。我们会专门为您标出发育猛长期。") }
    var ageStageNewbornLabel: String { s("0–3 mo", "0–3 мес", "0–3 Mon", "0–3 m", "0–3 mois", "0–3 m", "0–3 个月") }
    var ageStageBabyLabel: String    { s("3–6 mo", "3–6 мес", "3–6 Mon", "3–6 m", "3–6 mois", "3–6 m", "3–6 个月") }
    var ageStageEatLabel: String     { s("6–12 mo", "6–12 мес", "6–12 Mon", "6–12 m", "6–12 mois", "6–12 m", "6–12 个月") }
    var ageStageToddlerLabel: String { s("1–2 yr", "1–2 года", "1–2 J", "1–2 años", "1–2 ans", "1–2 anos", "1–2 岁") }
    var ageStageKidLabel: String     { s("2+", "2+", "2+", "2+", "2+", "2+", "2+") }
    var ageStageNewbornSubtitle: String { s("Newborn", "Новорождённый", "Neugeborenes", "Recién nacido", "Nouveau-né", "Recém-nascido", "新生儿") }
    var ageStageBabySubtitle: String    { s("Baby", "Малыш", "Baby", "Bebé", "Bébé", "Bebé", "宝宝") }
    var ageStageEatSubtitle: String     { s("Solids", "Прикорм", "Beikost", "Sólidos", "Diversification", "Sólidos", "辅食") }
    var ageStageToddlerSubtitle: String { s("Toddler", "Карапуз", "Kleinkind", "Niño pequeño", "Tout-petit", "Criança pequena", "幼儿") }
    var ageStageKidSubtitle: String     { s("Little one", "Маленький человек", "Kleines Kind", "Peque", "Petit enfant", "Pequenino", "小朋友") }
    var ageStageNewbornFocus: String { s("Feeding, sleep, diapers", "Кормление, сон, подгузники", "Füttern, Schlaf, Windeln", "Tomas, sueño, pañales", "Tétées, sommeil, couches", "Mamadas, sono, fraldas", "喂养、睡眠、尿布") }
    var ageStageBabyFocus: String    { s("Leaps, routine, development", "Скачки, режим, развитие", "Schübe, Rhythmus, Entwicklung", "Saltos, rutina, desarrollo", "Bonds, rythme, développement", "Saltos, rotina, desenvolvimento", "猛长期、作息、发育") }
    var ageStageEatFocus: String     { s("+ Solid foods & food diary", "+ Прикорм и пищевой дневник", "+ Beikost & Ernährungstagebuch", "+ Sólidos y diario de comida", "+ Aliments solides et journal", "+ Sólidos e diário alimentar", "+ 辅食与食物日记") }
    var ageStageToddlerFocus: String { s("+ Daily routine, activities", "+ Режим дня, активности", "+ Tagesrhythmus, Aktivitäten", "+ Rutina diaria, actividades", "+ Routine quotidienne, activités", "+ Rotina diária, atividades", "+ 日常作息、活动") }
    var ageStageKidFocus: String     { s("Flexible routine, health", "Гибкий режим, здоровье", "Flexibler Rhythmus, Gesundheit", "Rutina flexible, salud", "Rythme flexible, santé", "Rotina flexível, saúde", "灵活作息、健康") }
    var haveInviteLink: String  { s("I have a family invite link", "У меня есть семейная ссылка", "Ich habe einen Familienlink", "Tengo un enlace familiar", "J’ai un lien familial", "Tenho uma ligação familiar", "我有家庭邀请链接") }
    var joinOnboardingTitle: String { s("Join your family", "Войти в семью", "Familie beitreten", "Unirse a tu familia", "Rejoindre votre famille", "Entrar na sua família", "加入您的家庭") }
    var joinOnboardingSubtitle: String { s("Paste the Momsy invite code or continue with the link you opened.", "Вставьте код Momsy или продолжите со ссылкой, которую открыли.", "Füge den Momsy-Code ein oder fahre mit dem geöffneten Link fort.", "Pega el código de Momsy o continúa con el enlace que abriste.", "Collez le code Momsy ou continuez avec le lien ouvert.", "Cole o código Momsy ou continue com a ligação aberta.", "粘贴 Momsy 邀请码，或继续使用刚打开的链接。") }
    var inviteCodeLabel: String { s("INVITE CODE OR LINK", "КОД ИЛИ ССЫЛКА", "CODE ODER LINK", "CÓDIGO O ENLACE", "CODE OU LIEN", "CÓDIGO OU LIGAÇÃO", "邀请码或链接") }
    var createNewBabyProfile: String { s("Set up a new baby profile", "Создать новый профиль малыша", "Neues Baby-Profil einrichten", "Crear un nuevo perfil del bebé", "Créer un nouveau profil bébé", "Criar um novo perfil do bebé", "创建新的宝宝资料") }
    var inviteOnboardingTitle: String { s("Invite your family", "Пригласите семью", "Familie einladen", "Invita a tu familia", "Invitez votre famille", "Convide a família", "邀请家人") }
    var inviteOnboardingSubtitle: String { s("Create a private link for another caregiver. You can skip this and invite them later.", "Создайте приватную ссылку для второго взрослого. Можно пропустить и пригласить позже.", "Erstelle einen privaten Link für eine weitere Betreuungsperson. Du kannst das überspringen.", "Crea un enlace privado para otro cuidador. Puedes omitirlo e invitarlo después.", "Créez un lien privé pour une autre personne. Vous pouvez passer cette étape.", "Crie uma ligação privada para outro cuidador. Pode ignorar e convidar depois.", "为另一位照护者创建私人链接。也可以稍后再邀请。") }
    var generateInviteLink: String { s("Generate link", "Создать ссылку", "Link erstellen", "Generar enlace", "Générer le lien", "Gerar ligação", "生成链接") }
    var inviteLinkNotGenerated: String { s("No invite link yet", "Ссылка ещё не создана", "Noch kein Einladungslink", "Aún no hay enlace", "Aucun lien pour l’instant", "Ainda sem ligação", "尚未生成邀请链接") }
    var skipInviteForNow: String { s("Skip for now", "Пока пропустить", "Vorerst überspringen", "Omitir por ahora", "Passer pour l’instant", "Ignorar por agora", "暂时跳过") }
    var whatsYourBabyName: String { s("What's your baby's name?", "Как зовут малыша?", "Wie heißt Ihr Baby?", "¿Cómo se llama tu bebé?", "Comment s’appelle votre bébé ?", "Como se chama o seu bebé?", "宝宝叫什么名字？") }
    var nameBirthHelp: String   { s("Name and birth date help track\nleaps and development more accurately.", "Имя и дата рождения помогают точнее\nотслеживать скачки и развитие.", "Name und Geburtsdatum helfen genauer.", "El nombre y la fecha de nacimiento ayudan a seguir\nlos saltos y el desarrollo con más precisión.", "Le prénom et la date de naissance aident à suivre\nles bonds et le développement plus précisément.", "O nome e a data de nascimento ajudam a acompanhar\nos saltos e o desenvolvimento com mais precisão.", "姓名和出生日期有助于更准确地\n追踪猛长期和发育。") }
    var babyNameLabel: String   { s("BABY'S NAME",   "ИМЯ МАЛЫША",   "NAME DES BABYS", "NOMBRE DEL BEBÉ", "PRÉNOM DU BÉBÉ", "NOME DO BEBÉ", "宝宝的名字") }
    var babyNamePlaceholder: String { s("E.g., Leo", "Например, Лёва","Z.B. Leon",     "P. ej., Leo", "P. ex., Léo", "Ex.: Leo", "例如：乐乐") }
    var dateOfBirthLabel: String { s("DATE OF BIRTH","ДАТА РОЖДЕНИЯ", "GEBURTSDATUM",  "FECHA DE NACIMIENTO", "DATE DE NAISSANCE", "DATA DE NASCIMENTO", "出生日期") }
    var whoAreYou: String       { s("Who are you to the baby?", "Кто ты для малыша?", "Wer bist du für das Baby?", "¿Quién eres para el bebé?", "Qui êtes-vous pour le bébé ?", "Quem é para o bebé?", "您是宝宝的谁？") }
    var roleHelp: String        { s("This helps configure\nnotifications and access rights.", "Это помогает настроить\nуведомления и права доступа.", "Das hilft bei der Konfiguration.", "Esto ayuda a configurar\nnotificaciones y permisos de acceso.", "Cela aide à configurer\nles notifications et les droits d’accès.", "Isto ajuda a configurar\nnotificações e permissões de acesso.", "这有助于配置\n通知和访问权限。") }
    var yourNameOptional: String { s("YOUR NAME (optional)", "ВАШЕ ИМЯ (необязательно)", "IHR NAME (optional)", "TU NOMBRE (opcional)", "VOTRE NOM (facultatif)", "O SEU NOME (opcional)", "您的名字（可选）") }
    var yourNamePlaceholder: String { s("E.g., Anna", "Например, Аня","Z.B. Anna",     "P. ej., Ana", "P. ex., Anne", "Ex.: Ana", "例如：安娜") }
    var greetMom: String        { s("Mama!",         "Мама!",         "Mama!",         "¡Mamá!", "Maman !", "Mamã!", "妈妈！") }
    var greetDad: String        { s("Papa!",         "Папа!",         "Papa!",         "¡Papá!", "Papa !", "Papá!", "爸爸！") }
    var greetNanny: String      { s("Nanny!",        "Няня!",         "Nanny!",        "¡Niñera!", "Nounou !", "Ama!", "保姆！") }
    var greetDefault: String    { s("Hello!",        "Привет!",       "Hallo!",        "¡Hola!", "Bonjour !", "Olá!", "你好！") }
    var allSet: String          { s("All set,",      "Всё готово,",   "Fertig,",       "Todo listo,", "Tout est prêt,", "Tudo pronto,", "一切就绪，") }
    var familyJoinedReadyTitle: String { s("You're in,", "Вы в семье,", "Du bist drin,", "Ya estás dentro,", "Vous êtes dedans,", "Entrou,", "您已加入，") }
    var familyJoinedReadySubtitle: String { s("family is ready", "семья готова", "Familie bereit", "familia lista", "famille prête", "família pronta", "家庭已准备好") }
    var familyJoinedReadyFootnote: String { s("Family data is synced from the shared Momsy workspace.", "Данные семьи синхронизированы из общего пространства Momsy.", "Familiendaten werden aus dem gemeinsamen Momsy-Bereich synchronisiert.", "Los datos familiares se sincronizan desde el espacio compartido de Momsy.", "Les données familiales sont synchronisées depuis l’espace partagé Momsy.", "Os dados da família são sincronizados a partir do espaço partilhado Momsy.", "家庭数据已从共享的 Momsy 空间同步。") }
    var age: String             { s("Age",           "Возраст",       "Alter",         "Edad", "Âge", "Idade", "年龄") }
    var caregiver: String       { s("Caregiver",     "Кто следит",    "Betreuer",      "Cuidador", "Personne en charge", "Cuidador", "照护者") }
    var stage: String           { s("Stage",         "Стадия",        "Stufe",         "Etapa", "Étape", "Fase", "阶段") }
    var dataStoredLocally: String { s("Data is stored only on your phone. Nothing extra.", "Данные хранятся только на вашем телефоне. Ничего лишнего.", "Daten werden nur auf Ihrem Telefon gespeichert.", "Los datos se guardan solo en tu teléfono. Nada más.", "Les données sont stockées uniquement sur votre téléphone. Rien de plus.", "Os dados são guardados apenas no seu telefone. Nada mais.", "数据仅保存在您的手机上。别无其他。") }
    var genderLabel: String      { s("GENDER",         "ПОЛ",           "GESCHLECHT",   "SEXO", "SEXE", "SEXO", "性别") }
    var genderBoy: String        { s("Boy",            "Мальчик",       "Junge",        "Niño", "Garçon", "Menino", "男孩") }
    var genderGirl: String       { s("Girl",           "Девочка",       "Mädchen",      "Niña", "Fille", "Menina", "女孩") }
    var genderUnknown: String    { s("Don't know yet", "Пока неизвестно","Noch unklar", "Aún no lo sé", "Je ne sais pas encore", "Ainda não sei", "暂时不知道") }

    func ageDescription(_ ageStr: String) -> String { s("Age: \(ageStr)", "Возраст: \(ageStr)", "Alter: \(ageStr)", "Edad: \(ageStr)", "Âge : \(ageStr)", "Idade: \(ageStr)", "年龄：\(ageStr)") }

    // MARK: — Symptoms
    var symptoms: String        { s("Symptoms",      "Симптомы",      "Symptome",      "Síntomas", "Symptômes", "Sintomas", "症状") }
    var addSymptom: String      { s("Add symptom",   "Добавить симптом", "Symptom hinzufügen", "Añadir síntoma", "Ajouter un symptôme", "Adicionar sintoma", "添加症状") }
    var fever: String           { s("Fever",         "Температура",   "Fieber",        "Fiebre", "Fièvre", "Febre", "发热") }
    var cough: String           { s("Cough",         "Кашель",        "Husten",        "Tos", "Toux", "Tosse", "咳嗽") }
    var runnyNose: String       { s("Runny nose",    "Насморк",       "Schnupfen",     "Mocos", "Nez qui coule", "Nariz a pingar", "流鼻涕") }
    var rash: String            { s("Rash",          "Сыпь",          "Ausschlag",     "Sarpullido", "Éruption", "Erupção", "皮疹") }
    var teething: String        { s("Teething",      "Зубы",          "Zahnen",        "Dentición", "Dentition", "Dentes", "出牙") }
    var somethingWrong: String  { s("Something wrong?", "Что-то не так?", "Etwas nicht in Ordnung?", "¿Algo va mal?", "Quelque chose ne va pas ?", "Algo errado?", "有什么不对劲吗？") }
    var markItGuide: String     { s("Mark it — we'll guide you on what to do", "Отметьте — мы подскажем, что делать", "Markieren — wir führen Sie.", "Márcalo — te guiaremos sobre qué hacer", "Marquez-le — nous vous guiderons sur ce qu’il faut faire", "Marque — vamos orientá-la sobre o que fazer", "标记一下——我们会指导您该怎么做") }
    var notADiagnosis: String   { s("NOT A DIAGNOSIS","Это не диагноз","KEINE DIAGNOSE", "NO ES UN DIAGNÓSTICO", "PAS UN DIAGNOSTIC", "NÃO É UM DIAGNÓSTICO", "这不是诊断") }
    var symptomDisclaimer: String { s("We help you navigate. The decision is yours and your doctor's.", "Помогаем сориентироваться. Решение принимаете вы и врач.", "Wir helfen bei der Orientierung.", "Te ayudamos a orientarte. La decisión es tuya y de tu médico.", "Nous vous aidons à vous orienter. La décision vous revient, à vous et à votre médecin.", "Ajudamos a orientar. A decisão é sua e do seu médico.", "我们帮助您理清思路。决定权在您和您的医生。") }
    var seeDoctorUrgently: String { s("See doctor urgently if:", "Срочно к врачу, если:", "Arzt dringend aufsuchen wenn:", "Ve al médico con urgencia si:", "Consultez d’urgence un médecin si :", "Consulte o médico com urgência se:", "出现以下情况请立即就医：") }
    var symptomFooterDisclaimer: String { s("Symptom hints are navigation, not a diagnosis.\nWhen in doubt — always see your paediatrician.", "Подсказки на основе симптомов — это навигация, не диагноз.\nПри любых сомнениях — всегда к педиатру.", "Symptomhinweise sind Orientierung, keine Diagnose.\nIm Zweifel — immer zum Kinderarzt.", "Las pistas de síntomas son orientación, no un diagnóstico.\nAnte la duda — siempre acude a tu pediatra.", "Les indications de symptômes sont une orientation, pas un diagnostic.\nEn cas de doute — consultez toujours votre pédiatre.", "As dicas de sintomas são orientação, não um diagnóstico.\nEm caso de dúvida — consulte sempre o seu pediatra.", "症状提示只是参考，并非诊断。\n如有疑问——请务必就诊儿科医生。") }
    var symptomsUpper: String   { s("SYMPTOMS",      "СИМПТОМЫ",      "SYMPTOME",      "SÍNTOMAS", "SYMPTÔMES", "SINTOMAS", "症状") }
    var noteSymptoms: String    { s("Note symptoms — get guidance. Not a diagnosis, just navigation.", "Отметьте симптомы — подскажем, что делать. Не диагноз, только навигация.", "Symptome notieren — Orientierung erhalten. Keine Diagnose.", "Anota los síntomas — recibe orientación. No es un diagnóstico, solo orientación.", "Notez les symptômes — recevez des conseils. Pas un diagnostic, juste une orientation.", "Anote os sintomas — receba orientação. Não é um diagnóstico, apenas orientação.", "记录症状——获得指引。并非诊断，只是参考。") }

    // MARK: — Doctor Menu
    var pediatricianReport: String { s("Pediatrician Report","Отчёт для педиатра","Kinderarztbericht", "Informe para el pediatra", "Rapport pour le pédiatre", "Relatório para o pediatra", "儿科医生报告") }
    var pdfForWeek: String      { s("PDF for the week — sleep, feeding, weight", "PDF за неделю — сон, кормление, вес", "PDF für die Woche — Schlaf, Ernährung, Gewicht", "PDF de la semana — sueño, tomas, peso", "PDF de la semaine — sommeil, tétées, poids", "PDF da semana — sono, mamadas, peso", "一周 PDF——睡眠、喂养、体重") }
    var whoPercentileChart: String { s("WHO percentile chart", "График по перцентилям ВОЗ", "WHO-Perzentilkurve", "Gráfico de percentiles OMS", "Courbe de percentiles OMS", "Gráfico de percentis OMS", "WHO 百分位曲线图") }
    var vaccinations: String            { s("Vaccinations",          "Прививки",                     "Impfungen", "Vacunas", "Vaccins", "Vacinas", "疫苗接种") }
    var vaccinationCalendar: String     { s("Vaccination calendar",   "Календарь прививок",           "Impfkalender", "Calendario de vacunas", "Calendrier des vaccins", "Calendário de vacinas", "疫苗接种日历") }
    var vaccinationCalendarSub: String  { s("Schedule & reminders",   "Расписание и напоминания",     "Zeitplan & Erinnerungen", "Calendario y recordatorios", "Calendrier et rappels", "Calendário e lembretes", "计划与提醒") }
    var vaccinationSchedule: String     { s("Vaccination schedule",   "Календарь прививок",           "Impfkalender", "Calendario de vacunación", "Calendrier de vaccination", "Plano de vacinação", "疫苗接种计划") }
    var vaccinationScheduleHint: String { s("Based on your region. The WHO international schedule is used by default.", "На основе вашего региона. По умолчанию используется международный календарь ВОЗ.", "Basierend auf Ihrer Region. Standardmäßig wird der internationale WHO-Impfkalender verwendet.", "Según tu región. Se usa el calendario internacional de la OMS por defecto.", "Selon votre région. Le calendrier international de l’OMS est utilisé par défaut.", "Com base na sua região. Por predefinição, é usado o plano internacional da OMS.", "根据您所在地区。默认使用 WHO 国际接种计划。") }
    var vaccinationMarkDone: String     { s("Mark as done",           "Отметить выполненной",         "Als erledigt markieren", "Marcar como hecha", "Marquer comme fait", "Marcar como feita", "标记为已完成") }
    var vaccinationUndo: String         { s("Undo",                   "Отменить",                     "Rückgängig", "Deshacer", "Annuler", "Anular", "撤销") }
    var vaccinationAddCustom: String    { s("Add vaccine",            "Добавить прививку",            "Impfung hinzufügen", "Añadir vacuna", "Ajouter un vaccin", "Adicionar vacina", "添加疫苗") }
    var vaccinationNamePlaceholder: String { s("Vaccine name",         "Название прививки",            "Name der Impfung", "Nombre de la vacuna", "Nom du vaccin", "Nome da vacina", "疫苗名称") }

    // MARK: — Food Diary
    var foodDiary: String           { s("Food Diary",          "Прикорм-дневник",        "Beikost-Tagebuch", "Diario de alimentación", "Journal alimentaire", "Diário alimentar", "辅食日记") }
    var foodDiarySub: String        { s("New foods, reactions, allergies", "Новые продукты, реакции, аллергии", "Neue Lebensmittel, Reaktionen, Allergien", "Nuevos alimentos, reacciones, alergias", "Nouveaux aliments, réactions, allergies", "Novos alimentos, reações, alergias", "新食物、反应、过敏") }
    var addFood: String             { s("Add food",             "Добавить продукт",        "Lebensmittel hinzufügen", "Añadir alimento", "Ajouter un aliment", "Adicionar alimento", "添加食物") }
    var foodName: String            { s("Food name",            "Название продукта",       "Lebensmittelname", "Nombre del alimento", "Nom de l’aliment", "Nome do alimento", "食物名称") }
    var foodCategory: String        { s("Category",             "Категория",               "Kategorie", "Categoría", "Catégorie", "Categoria", "类别") }
    var foodReaction: String        { s("Reaction",             "Реакция",                 "Reaktion", "Reacción", "Réaction", "Reação", "反应") }
    var foodReactionNone: String    { s("No reaction",          "Без реакции",             "Keine Reaktion", "Sin reacción", "Aucune réaction", "Sem reação", "无反应") }
    var foodReactionMild: String    { s("Mild",                 "Лёгкая",                  "Leicht", "Leve", "Légère", "Ligeira", "轻微") }
    var foodReactionSevere: String  { s("Severe",               "Сильная",                 "Schwer", "Grave", "Sévère", "Grave", "严重") }
    var foodAllergen: String        { s("Allergen",             "Аллерген",                "Allergen", "Alérgeno", "Allergène", "Alérgeno", "过敏原") }
    var foodAllergens: String       { s("Allergens",            "Аллергены",               "Allergene", "Alérgenos", "Allergènes", "Alérgenos", "过敏原") }
    var foodAllergensNone: String   { s("No allergens logged",  "Аллергены не зафиксированы", "Keine Allergene erfasst", "Sin alérgenos registrados", "Aucun allergène enregistré", "Sem alérgenos registados", "未记录过敏原") }
    var foodCatVegetable: String    { s("Vegetable",            "Овощ",                    "Gemüse", "Verdura", "Légume", "Legume", "蔬菜") }
    var foodCatFruit: String        { s("Fruit",                "Фрукт",                   "Frucht", "Fruta", "Fruit", "Fruta", "水果") }
    var foodCatCereal: String       { s("Cereal",               "Каша",                    "Getreide", "Cereal", "Céréale", "Cereal", "米糊") }
    var foodCatMeat: String         { s("Meat",                 "Мясо",                    "Fleisch", "Carne", "Viande", "Carne", "肉类") }
    var foodCatDairy: String        { s("Dairy",                "Молочное",                "Milchprodukt", "Lácteo", "Produit laitier", "Lacticínio", "乳制品") }
    var foodCatFish: String         { s("Fish",                 "Рыба",                    "Fisch", "Pescado", "Poisson", "Peixe", "鱼类") }
    var foodCatEgg: String          { s("Egg",                  "Яйцо",                    "Ei", "Huevo", "Œuf", "Ovo", "蛋类") }
    var foodCatOther: String        { s("Other",                "Другое",                  "Sonstiges", "Otro", "Autre", "Outro", "其他") }
    var foodStartHint: String       { s("Log first solid foods for your baby", "Записывайте первые продукты прикорма", "Erste Beikost für Ihr Baby protokollieren", "Registra los primeros sólidos de tu bebé", "Enregistrez les premiers aliments solides de votre bébé", "Registe os primeiros alimentos sólidos do seu bebé", "记录宝宝的第一口辅食") }

    // MARK: — Me / Profile
    var familyMembersHint: String { s("Mom, dad, nanny, grandma", "Мама, папа, няня, бабушка", "Mama, Papa, Nanny, Oma", "Mamá, papá, niñera, abuela", "Maman, papa, nounou, grand-mère", "Mãe, pai, ama, avó", "妈妈、爸爸、保姆、奶奶") }
    var lullabiesSounds: String { s("Lullabies & Sounds", "Колыбельные и шум", "Lieder & Klänge", "Nanas y sonidos", "Berceuses et sons", "Canções de embalar e sons", "摇篮曲与声音") }
    var lullabiesHint: String   { s("White noise, melodies, timer", "Белый шум, мелодии, таймер", "Weißes Rauschen, Melodien, Timer", "Ruido blanco, melodías, temporizador", "Bruit blanc, mélodies, minuteur", "Ruído branco, melodias, temporizador", "白噪音、旋律、定时器") }
    var settingsHint: String    { s("Theme, language",  "Тема, язык",    "Design, Sprache", "Tema, idioma", "Thème, langue", "Tema, idioma", "主题、语言") }

    // MARK: — Mom Mood Tracker
    var momMoodTitle: String          { s("My Wellbeing",            "Моё самочувствие",           "Mein Wohlbefinden", "Mi bienestar", "Mon bien-être", "O meu bem-estar", "我的身心状态") }
    var momMoodSub: String            { s("Mood & PPD screening",    "Настроение и PPD скрининг",  "Stimmung & PPD-Screening", "Ánimo y cribado de DPP", "Humeur et dépistage DPP", "Humor e rastreio de DPP", "情绪与产后抑郁筛查") }
    var momMoodSectionLabel: String   { s("WELLBEING",               "САМОЧУВСТВИЕ",               "WOHLBEFINDEN", "BIENESTAR", "BIEN-ÊTRE", "BEM-ESTAR", "身心状态") }
    var momMoodTodayPrompt: String    { s("How are you feeling today?", "Как вы себя чувствуете сегодня?", "Wie geht es Ihnen heute?", "¿Cómo te sientes hoy?", "Comment vous sentez-vous aujourd’hui ?", "Como se sente hoje?", "您今天感觉如何？") }
    var momMoodEnergyLabel: String    { s("Energy",                  "Энергия",                    "Energie", "Energía", "Énergie", "Energia", "精力") }
    var momMoodCheckin: String        { s("Daily Check-in",          "Ежедневная отметка",         "Tägliches Check-in", "Registro diario", "Suivi quotidien", "Registo diário", "每日打卡") }
    var momMoodCheckinSub: String     { s("Rate your mood & energy", "Оцените настроение и силы",  "Stimmung & Energie bewerten", "Valora tu ánimo y energía", "Évaluez votre humeur et votre énergie", "Avalie o seu humor e energia", "评估您的情绪与精力") }
    var momMoodHistory: String        { s("30-day history",          "История за 30 дней",         "30-Tage-Verlauf", "Historial de 30 días", "Historique sur 30 jours", "Histórico de 30 dias", "30 天记录") }
    var momMoodNoData: String         { s("No check-ins yet",        "Пока нет отметок",           "Noch keine Einträge", "Aún sin registros", "Aucun suivi pour l’instant", "Ainda sem registos", "暂无打卡记录") }
    var momSleepTitle: String         { s("Mom's Sleep",             "Сон мамы",                   "Schlaf der Mutter", "Sueño de mamá", "Sommeil de maman", "Sono da mãe", "妈妈的睡眠") }
    var momSleepCardSub: String       { s("Track your rest",         "Отслеживайте свой отдых",    "Ihren Schlaf verfolgen", "Sigue tu descanso", "Suivez votre repos", "Acompanhe o seu descanso", "记录您的休息") }
    var momMoodNoteSub: String        { s("optional note",           "заметка (необязательно)",    "Notiz (optional)", "nota opcional", "note facultative", "nota opcional", "备注（可选）") }
    var epdsTitle: String             { s("EPDS Screening",          "Скрининг EPDS",              "EPDS-Screening", "Cribado EPDS", "Dépistage EPDS", "Rastreio EPDS", "EPDS 筛查") }
    var epdsSubtitle: String          { s("Edinburgh Postnatal Depression Scale", "Эдинбургская шкала послеродовой депрессии", "Edinburgher Wochenbettdepressionsskala", "Escala de Depresión Posnatal de Edimburgo", "Échelle de dépression postnatale d’Édimbourg", "Escala de Depressão Pós-natal de Edimburgo", "爱丁堡产后抑郁量表") }
    var epdsStartCTA: String          { s("Take Screening",          "Пройти скрининг",            "Screening starten", "Hacer el cribado", "Faire le dépistage", "Fazer o rastreio", "开始筛查") }
    var epdsLastScore: String         { s("Last score",              "Последний результат",        "Letztes Ergebnis", "Última puntuación", "Dernier score", "Última pontuação", "上次得分") }
    var epdsProgress: String          { s("Question",                "Вопрос",                     "Frage", "Pregunta", "Question", "Pergunta", "问题") }
    var epdsOf: String                { s("of",                      "из",                         "von", "de", "sur", "de", "/") }
    var epdsYourScore: String         { s("Your score",              "Ваш результат",              "Ihr Ergebnis", "Tu puntuación", "Votre score", "A sua pontuação", "您的得分") }
    var epdsLowRisk: String           { s("Low risk",                "Низкий риск",                "Geringes Risiko", "Riesgo bajo", "Faible risque", "Risco baixo", "低风险") }
    var epdsMildRisk: String          { s("Possible mild depression","Возможная лёгкая депрессия", "Mögliche leichte Depression", "Posible depresión leve", "Possible dépression légère", "Possível depressão ligeira", "可能为轻度抑郁") }
    var epdsHighRisk: String          { s("Seek support",            "Обратитесь за помощью",      "Unterstützung suchen", "Busca apoyo", "Cherchez du soutien", "Procure apoio", "寻求帮助") }
    var epdsDisclaimer: String        { s("This tool is not a diagnosis. If your score is 10 or above, please consult your doctor.",
                                          "Этот инструмент не является диагнозом. При результате 10 и выше обратитесь к врачу.",
                                          "Dieses Tool ist keine Diagnose. Bei einem Score von 10 oder mehr wenden Sie sich an Ihren Arzt.",
                                          "Esta herramienta no es un diagnóstico. Si tu puntuación es 10 o más, consulta a tu médico.",
                                          "Cet outil n’est pas un diagnostic. Si votre score est de 10 ou plus, veuillez consulter votre médecin.",
                                          "Esta ferramenta não é um diagnóstico. Se a sua pontuação for 10 ou mais, consulte o seu médico.",
                                          "此工具不构成诊断。如果您的得分为 10 分或以上，请咨询您的医生。") }
    var epdsDoneButton: String        { s("Done",                    "Готово",                     "Fertig", "Hecho", "Terminé", "Concluído", "完成") }
    var epdsNextButton: String        { s("Next",                    "Далее",                      "Weiter", "Siguiente", "Suivant", "Seguinte", "下一步") }
    var epdsQ1: String  { s("I have been able to laugh and see the funny side of things.",
                             "Я была способна смеяться и видеть смешную сторону вещей.",
                             "Ich konnte lachen und die lustige Seite der Dinge sehen.",
                             "He sido capaz de reír y ver el lado divertido de las cosas.",
                             "J’ai pu rire et voir le côté amusant des choses.",
                             "Consegui rir e ver o lado divertido das coisas.",
                             "我能够开怀大笑，看到事物有趣的一面。") }
    var epdsQ2: String  { s("I have looked forward with enjoyment to things.",
                             "Я с удовольствием ждала каких-то событий.",
                             "Ich habe mich auf kommende Dinge gefreut.",
                             "He esperado las cosas con ilusión.",
                             "J’ai attendu les choses avec plaisir.",
                             "Olhei para as coisas com prazer e expectativa.",
                             "我对一些事情怀着愉快的期待。") }
    var epdsQ3: String  { s("I have blamed myself unnecessarily when things went wrong.",
                             "Я напрасно винила себя, когда что-то шло не так.",
                             "Ich habe mich unnötig beschuldigt, wenn etwas schief lief.",
                             "Me he culpado innecesariamente cuando las cosas salían mal.",
                             "Je me suis sentie coupable sans raison quand les choses allaient mal.",
                             "Culpei-me desnecessariamente quando as coisas corriam mal.",
                             "当事情出错时，我会不必要地责怪自己。") }
    var epdsQ4: String  { s("I have been anxious or worried for no good reason.",
                             "Я испытывала тревогу или беспокойство без видимой причины.",
                             "Ich war ängstlich oder besorgt ohne triftigen Grund.",
                             "He estado ansiosa o preocupada sin un buen motivo.",
                             "J’ai été anxieuse ou inquiète sans raison valable.",
                             "Senti-me ansiosa ou preocupada sem um bom motivo.",
                             "我会无缘无故地感到焦虑或担心。") }
    var epdsQ5: String  { s("I have felt scared or panicky for no very good reason.",
                             "Я чувствовала страх или панику без особой причины.",
                             "Ich hatte Angst oder Panik ohne besonderen Grund.",
                             "He sentido miedo o pánico sin un buen motivo.",
                             "J’ai eu peur ou paniqué sans raison particulière.",
                             "Senti medo ou pânico sem qualquer motivo concreto.",
                             "我会无缘无故地感到害怕或恐慌。") }
    var epdsQ6: String  { s("Things have been getting on top of me.",
                             "Всё навалилось на меня.",
                             "Die Dinge häuften sich für mich.",
                             "Las cosas me han superado.",
                             "Les choses m’ont dépassée.",
                             "As coisas têm-me ultrapassado.",
                             "事情让我应接不暇。") }
    var epdsQ7: String  { s("I have been so unhappy that I have had difficulty sleeping.",
                             "Мне было так плохо, что я с трудом засыпала.",
                             "Ich war so unglücklich, dass ich Schwierigkeiten beim Schlafen hatte.",
                             "He estado tan infeliz que me ha costado dormir.",
                             "J’ai été si malheureuse que j’ai eu du mal à dormir.",
                             "Tenho estado tão infeliz que tive dificuldade em dormir.",
                             "我如此不开心，以至于难以入睡。") }
    var epdsQ8: String  { s("I have felt sad or miserable.",
                             "Я чувствовала себя грустной или несчастной.",
                             "Ich fühlte mich traurig oder elend.",
                             "Me he sentido triste o desdichada.",
                             "Je me suis sentie triste ou malheureuse.",
                             "Senti-me triste ou infeliz.",
                             "我感到悲伤或痛苦。") }
    var epdsQ9: String  { s("I have been so unhappy that I have been crying.",
                             "Мне было так плохо, что я плакала.",
                             "Ich war so unglücklich, dass ich geweint habe.",
                             "He estado tan infeliz que he llorado.",
                             "J’ai été si malheureuse que j’ai pleuré.",
                             "Tenho estado tão infeliz que tenho chorado.",
                             "我如此不开心，以至于一直在哭。") }
    var epdsQ10: String { s("The thought of harming myself has occurred to me.",
                             "У меня возникали мысли о причинении себе вреда.",
                             "Der Gedanke, mir selbst Schaden zuzufügen, kam mir.",
                             "Se me ha pasado por la cabeza la idea de hacerme daño.",
                             "L’idée de me faire du mal m’est venue à l’esprit.",
                             "Ocorreu-me a ideia de me fazer mal.",
                             "我曾产生过伤害自己的念头。") }

    /// Answer options for each of the 10 EPDS questions (4 options each), in display order.
    var epdsOptions: [[String]] {
        [
            [s("As much as I always could", "Так же, как всегда", "So viel wie immer", "Tanto como siempre", "Autant que d’habitude", "Tanto como sempre", "和以往一样多"),
             s("Not quite so much now", "Немного меньше, чем обычно", "Etwas weniger als sonst", "Ahora no tanto", "Un peu moins que d’habitude", "Não tanto como antes", "现在没那么多了"),
             s("Definitely not so much now", "Значительно меньше, чем обычно", "Deutlich weniger als sonst", "Claramente menos ahora", "Nettement moins que d’habitude", "Claramente menos agora", "现在明显少了很多"),
             s("Not at all", "Совсем нет", "Überhaupt nicht", "En absoluto", "Pas du tout", "De todo", "完全没有")],
            [s("As much as I ever did", "Так же, как и всегда", "So sehr wie immer", "Tanto como siempre", "Autant que d’habitude", "Tanto como sempre", "和以往一样"),
             s("Rather less than I used to", "Меньше, чем прежде", "Etwas weniger als früher", "Algo menos que antes", "Plutôt moins qu’avant", "Um pouco menos do que antes", "比以前少一些"),
             s("Definitely less than I used to", "Намного меньше, чем прежде", "Deutlich weniger als früher", "Claramente menos que antes", "Nettement moins qu’avant", "Claramente menos do que antes", "明显比以前少"),
             s("Hardly at all", "Почти не ждала", "Kaum noch", "Casi nada", "Presque pas", "Quase nada", "几乎没有")],
            [s("No, never", "Нет, никогда", "Nein, nie", "No, nunca", "Non, jamais", "Não, nunca", "不，从不"),
             s("Not very often", "Не очень часто", "Nicht sehr oft", "No muy a menudo", "Pas très souvent", "Não muito frequentemente", "不太经常"),
             s("Yes, some of the time", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes", "是的，有时"),
             s("Yes, most of the time", "Да, большую часть времени", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, a maior parte do tempo", "是的，大部分时间")],
            [s("No, not at all", "Нет, совсем нет", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo", "不，完全没有"),
             s("Hardly ever", "Очень редко", "Fast nie", "Casi nunca", "Presque jamais", "Quase nunca", "几乎没有"),
             s("Yes, sometimes", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes", "是的，有时"),
             s("Yes, very often", "Да, очень часто", "Ja, sehr oft", "Sí, muy a menudo", "Oui, très souvent", "Sim, muito frequentemente", "是的，非常频繁")],
            [s("No, not at all", "Нет, совсем нет", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo", "不，完全没有"),
             s("No, not much", "Нет, не очень", "Nein, kaum", "No, no mucho", "Non, pas beaucoup", "Não, não muito", "不，不太多"),
             s("Yes, sometimes", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes", "是的，有时"),
             s("Yes, quite a lot", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante", "Oui, assez souvent", "Sim, bastante", "是的，相当多")],
            [s("No, I have been coping as well as ever", "Нет, я справлялась так же хорошо", "Nein, ich komme so gut zurecht wie immer", "No, me he desenvuelto tan bien como siempre", "Non, je gère aussi bien que d’habitude", "Não, tenho lidado tão bem como sempre", "不，我应对得和往常一样好"),
             s("No, most of the time I have coped quite well", "Нет, в основном справлялась", "Nein, meistens komme ich recht gut zurecht", "No, la mayor parte del tiempo me he desenvuelto bastante bien", "Non, la plupart du temps je gère plutôt bien", "Não, a maior parte do tempo tenho lidado muito bem", "不，大部分时间我都应对得不错"),
             s("Yes, sometimes I haven't been coping as well as usual", "Да, иногда хуже, чем обычно", "Ja, manchmal komme ich nicht so gut zurecht wie sonst", "Sí, a veces no me he desenvuelto tan bien como de costumbre", "Oui, parfois je gère moins bien que d’habitude", "Sim, às vezes não tenho lidado tão bem como o costume", "是的，有时我应对得不如往常"),
             s("Yes, I have not been coping at all", "Да, совсем не справлялась", "Ja, ich komme überhaupt nicht zurecht", "Sí, no me he desenvuelto en absoluto", "Oui, je n’arrive plus du tout à gérer", "Sim, não tenho conseguido lidar de todo", "是的，我完全无法应对")],
            [s("No, not at all", "Нет, совсем", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo", "不，完全没有"),
             s("Not very often", "Не очень часто", "Nicht sehr oft", "No muy a menudo", "Pas très souvent", "Não muito frequentemente", "不太经常"),
             s("Yes, sometimes", "Да, иногда", "Ja, manchmal", "Sí, a veces", "Oui, parfois", "Sim, às vezes", "是的，有时"),
             s("Yes, most of the time", "Да, большую часть времени", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, a maior parte do tempo", "是的，大部分时间")],
            [s("No, not at all", "Нет, совсем", "Nein, überhaupt nicht", "No, en absoluto", "Non, pas du tout", "Não, de todo", "不，完全没有"),
             s("Not very often", "Не очень часто", "Nicht sehr oft", "No muy a menudo", "Pas très souvent", "Não muito frequentemente", "不太经常"),
             s("Yes, quite often", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante a menudo", "Oui, assez souvent", "Sim, bastante vezes", "是的，相当频繁"),
             s("Yes, most of the time", "Да, почти всё время", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, quase sempre", "是的，大部分时间")],
            [s("No, never", "Нет, никогда", "Nein, nie", "No, nunca", "Non, jamais", "Não, nunca", "不，从不"),
             s("Only occasionally", "Лишь иногда", "Nur gelegentlich", "Solo de vez en cuando", "Seulement de temps en temps", "Apenas ocasionalmente", "只是偶尔"),
             s("Yes, quite often", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante a menudo", "Oui, assez souvent", "Sim, bastante vezes", "是的，相当频繁"),
             s("Yes, most of the time", "Да, большую часть времени", "Ja, meistens", "Sí, la mayor parte del tiempo", "Oui, la plupart du temps", "Sim, a maior parte do tempo", "是的，大部分时间")],
            [s("Never", "Никогда", "Nie", "Nunca", "Jamais", "Nunca", "从不"),
             s("Hardly ever", "Почти никогда", "Fast nie", "Casi nunca", "Presque jamais", "Quase nunca", "几乎没有"),
             s("Sometimes", "Иногда", "Manchmal", "A veces", "Parfois", "Às vezes", "有时"),
             s("Yes, quite often", "Да, довольно часто", "Ja, ziemlich oft", "Sí, bastante a menudo", "Oui, assez souvent", "Sim, bastante vezes", "是的，相当频繁")],
        ]
    }

    // MARK: — Unit abbreviations (charts, age labels)
    var unitHourShort: String  { s("h",   "ч",   "Std", "h",   "h",    "h", "时") }
    var unitMinShort: String   { s("min", "мин", "Min", "min", "min",  "min", "分") }
    var ageMonthShort: String  { s("mo",  "мес", "Mon", "m",   "mois", "m", "月") }
    var ageDayShort: String    { s("d",   "дн",  "T",   "d",   "j",    "d", "天") }

    // MARK: — Water Intake
    var waterIntakeTitle: String       { s("Water Intake",               "Жидкость мамы",                "Flüssigkeit", "Hidratación", "Hydratation", "Hidratação", "饮水量") }
    var waterIntakeLabel: String       { s("HYDRATION",                  "ГИДРАТАЦИЯ",                   "HYDRATION", "HIDRATACIÓN", "HYDRATATION", "HIDRATAÇÃO", "补水") }
    var waterIntakeSub: String         { s("Daily hydration",            "Суточное потребление жидкости", "Tagesflüssigkeit", "Hidratación diaria", "Hydratation quotidienne", "Hidratação diária", "每日补水") }
    var waterGoalLabel: String         { s("Goal",                       "Цель",                          "Ziel", "Objetivo", "Objectif", "Objetivo", "目标") }
    var waterTodayLabel: String        { s("today",                      "сегодня",                       "heute", "hoy", "aujourd’hui", "hoje", "今天") }
    var waterAdd150: String            { s("+150 ml",                    "+150 мл",                       "+150 ml", "+150 ml", "+150 ml", "+150 ml", "+150 ml") }
    var waterAdd250: String            { s("+250 ml",                    "+250 мл",                       "+250 ml", "+250 ml", "+250 ml", "+250 ml", "+250 ml") }
    var waterAdd500: String            { s("+500 ml",                    "+500 мл",                       "+500 ml", "+500 ml", "+500 ml", "+500 ml", "+500 ml") }
    var waterNoEntries: String         { s("No logs today",              "Записей нет",                   "Keine Einträge", "Sin registros hoy", "Aucun enregistrement aujourd’hui", "Sem registos hoje", "今天没有记录") }
    var waterWeekLabel: String         { s("LAST 7 DAYS",                "ПОСЛЕДНИЕ 7 ДНЕЙ",              "LETZTE 7 TAGE", "ÚLTIMOS 7 DÍAS", "7 DERNIERS JOURS", "ÚLTIMOS 7 DIAS", "最近 7 天") }
    var waterTodayEntriesLabel: String { s("TODAY",                      "СЕГОДНЯ",                       "HEUTE", "HOY", "AUJOURD’HUI", "HOJE", "今天") }

    // MARK: — Auth / Sign-In
    var authStepTitle: String      { s("Create Account",                   "Создай аккаунт",                    "Konto erstellen", "Crear cuenta", "Créer un compte", "Criar conta", "创建账户") }
    var authStepSubtitle: String   { s("Back up your data & restore it\non any device",
                                       "Сохрани данные и восстанови\nна любом устройстве",
                                       "Daten sichern & auf jedem\nGerät wiederherstellen",
                                       "Respalda tus datos y restáuralos\nen cualquier dispositivo",
                                       "Sauvegardez vos données et restaurez-les\nsur n’importe quel appareil",
                                       "Faça uma cópia dos seus dados e restaure-os\nem qualquer dispositivo",
                                       "备份您的数据，并在\n任何设备上恢复") }
    var signInWithApple: String    { s("Sign in with Apple",               "Войти через Apple",                 "Mit Apple anmelden", "Iniciar sesión con Apple", "Se connecter avec Apple", "Iniciar sessão com a Apple", "通过 Apple 登录") }
    var signInWithGoogle: String   { s("Sign in with Google",              "Войти через Google",                "Mit Google anmelden", "Iniciar sesión con Google", "Se connecter avec Google", "Iniciar sessão com o Google", "通过 Google 登录") }
    var mayBeLater: String         { s("Maybe Later",                      "Позже",                             "Vielleicht später", "Quizá más tarde", "Plus tard", "Talvez mais tarde", "稍后再说") }
    var joinAuthTitle: String      { s("Sign in to join",                  "Войдите, чтобы присоединиться",     "Zum Beitreten anmelden", "Inicia sesión para unirte", "Connectez-vous pour rejoindre", "Inicie sessão para entrar", "登录以加入") }
    var joinAuthSubtitle: String   { s("Apple or Google keeps your family access safe across devices.",
                                       "Apple или Google сохранят доступ к семье на ваших устройствах.",
                                       "Apple oder Google schützt den Familienzugang geräteübergreifend.",
                                       "Apple o Google mantiene seguro el acceso familiar en tus dispositivos.",
                                       "Apple ou Google sécurise l’accès familial sur vos appareils.",
                                       "Apple ou Google mantém o acesso familiar seguro nos seus dispositivos.",
                                       "Apple 或 Google 可在多设备上安全保存家庭访问权限。") }
    var settingsAccount: String        { s("Account", "Аккаунт", "Konto", "Cuenta", "Compte", "Conta", "账户") }
    var settingsSignIn: String         { s("Sign in", "Войти", "Anmelden", "Iniciar sesión", "Se connecter", "Iniciar sessão", "登录") }
    var settingsSignInHint: String     { s("Back up your data and sync with your family", "Сохраните данные и синхронизируйтесь с семьёй", "Sichern Sie Ihre Daten und synchronisieren Sie mit Ihrer Familie", "Guarda tus datos y sincroniza con tu familia", "Sauvegardez vos données et synchronisez avec votre famille", "Faça backup dos seus dados e sincronize com a família", "备份数据并与家人同步") }
    var settingsSignedIn: String       { s("Signed in", "Вы вошли", "Angemeldet", "Sesión iniciada", "Connecté", "Sessão iniciada", "已登录") }
    var settingsAuthSheetTitle: String { s("Sign in to Momsy", "Войдите в Momsy", "Bei Momsy anmelden", "Inicia sesión en Momsy", "Connectez-vous à Momsy", "Inicie sessão no Momsy", "登录 Momsy") }
    var settingsAuthSheetSubtitle: String { s("Your entries will be linked to your account and synced across devices", "Записи будут привязаны к аккаунту и синхронизированы между устройствами", "Ihre Einträge werden mit Ihrem Konto verknüpft und geräteübergreifend synchronisiert", "Tus registros se vincularán a tu cuenta y se sincronizarán entre dispositivos", "Vos entrées seront liées à votre compte et synchronisées entre vos appareils", "Os seus registos serão associados à sua conta e sincronizados entre dispositivos", "记录将关联到您的账户并在设备间同步") }
    var joinAuthUnavailable: String    { s("Couldn't connect. Check your internet connection and try again.", "Не удалось подключиться. Проверьте интернет и попробуйте снова.", "Verbindung fehlgeschlagen. Prüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.", "No se pudo conectar. Comprueba tu conexión e inténtalo de nuevo.", "Connexion impossible. Vérifiez votre connexion Internet et réessayez.", "Não foi possível conectar. Verifique a sua ligação e tente novamente.", "无法连接。请检查网络后重试。") }

    // MARK: — Paywall
    var paywallPlanFallbackName: String { s("Momsy Premium",
                                            "Momsy Premium",
                                            "Momsy Premium",
                                            "Momsy Premium",
                                            "Momsy Premium",
                                            "Momsy Premium",
                                            "Momsy Premium") }
    var paywallSubscriptionNameLabel: String { s("Subscription",
                                                 "Подписка",
                                                 "Abo",
                                                 "Suscripción",
                                                 "Abonnement",
                                                 "Subscrição",
                                                 "订阅") }
    var paywallSubscriptionPeriodLabel: String { s("Period",
                                                   "Период",
                                                   "Zeitraum",
                                                   "Periodo",
                                                   "Période",
                                                   "Período",
                                                   "周期") }
    var paywallSubscriptionPriceLabel: String { s("Price",
                                                  "Цена",
                                                  "Preis",
                                                  "Precio",
                                                  "Prix",
                                                  "Preço",
                                                  "价格") }
    var paywallMonthlyPeriod: String { s("1 month",
                                         "1 месяц",
                                         "1 Monat",
                                         "1 mes",
                                         "1 mois",
                                         "1 mês",
                                         "1个月") }
    var trialBadge: String         { s("7 days free",
                                       "7 дней бесплатно",
                                       "7 Tage gratis",
                                       "7 días gratis",
                                       "7 jours gratuits",
                                       "7 dias grátis",
                                       "7 天免费") }
    var startTrial: String         { s("Start Free Trial",
                                       "Начать бесплатно на 7 дней",
                                       "7 Tage gratis starten",
                                       "Empezar prueba gratis",
                                       "Commencer l’essai gratuit",
                                       "Iniciar avaliação gratuita",
                                       "开始免费试用") }
    var paywallPriceLoadingDisclosure: String {
        s("Loading subscription price...",
          "Загружаем цену подписки...",
          "Abo-Preis wird geladen...",
          "Cargando precio de la suscripción...",
          "Chargement du prix de l'abonnement...",
          "A carregar o preço da subscrição...",
          "正在加载订阅价格...")
    }
    func paywallRenewalDisclosure(price: String) -> String {
        s("7 days free, then \(price)/month. Subscription renews automatically every month unless canceled at least 24 hours before the period ends.",
          "7 дней бесплатно, затем \(price)/мес. Подписка автоматически продлевается каждый месяц, если не отменить её минимум за 24 часа до конца периода.",
          "7 Tage gratis, danach \(price)/Monat. Das Abo verlängert sich jeden Monat automatisch, sofern es nicht mindestens 24 Stunden vor Periodenende gekündigt wird.",
          "7 días gratis, luego \(price)/mes. La suscripción se renueva automáticamente cada mes salvo que se cancele al menos 24 horas antes de que termine el periodo.",
          "7 jours gratuits, puis \(price)/mois. L'abonnement se renouvelle automatiquement chaque mois sauf annulation au moins 24 heures avant la fin de la période.",
          "7 dias grátis, depois \(price)/mês. A subscrição renova automaticamente todos os meses, salvo cancelamento pelo menos 24 horas antes do fim do período.",
          "7 天免费，之后 \(price)/月。订阅每月自动续订，除非在当前周期结束前至少 24 小时取消。")
    }
    var purchaseErrorTitle: String { s("Purchase Error",
                                       "Ошибка покупки",
                                       "Kauffehler",
                                       "Error de compra",
                                       "Erreur d’achat",
                                       "Erro na compra",
                                       "购买错误") }
    var purchaseVerificationFailed: String {
        s("Couldn’t verify the purchase. Please try again.",
          "Не удалось подтвердить покупку. Попробуйте ещё раз.",
          "Kauf konnte nicht verifiziert werden. Bitte erneut versuchen.",
          "No se pudo verificar la compra. Inténtalo de nuevo.",
          "Impossible de vérifier l’achat. Veuillez réessayer.",
          "Não foi possível verificar a compra. Tente novamente.",
          "无法验证购买，请重试。")
    }
    var purchaseProductUnavailable: String {
        s("Subscription isn’t available right now. Check your connection and try again.",
          "Подписка сейчас недоступна. Проверьте соединение и попробуйте ещё раз.",
          "Abo derzeit nicht verfügbar. Prüfe deine Verbindung und versuche es erneut.",
          "La suscripción no está disponible ahora. Revisa tu conexión e inténtalo de nuevo.",
          "L’abonnement n’est pas disponible pour le moment. Vérifiez votre connexion et réessayez.",
          "A subscrição não está disponível de momento. Verifique a ligação e tente novamente.",
          "订阅当前不可用，请检查网络后重试。")
    }
    var restorePurchases: String   { s("Restore Purchases",
                                       "Восстановить покупки",
                                       "Käufe wiederherstellen",
                                       "Restaurar compras",
                                       "Restaurer les achats",
                                       "Restaurar compras",
                                       "恢复购买") }
    var featureAll: String         { s("All features, no limits",
                                       "Все функции без ограничений",
                                       "Alle Funktionen ohne Limits",
                                       "Todas las funciones, sin límites",
                                       "Toutes les fonctions, sans limites",
                                       "Todas as funcionalidades, sem limites",
                                       "所有功能，无限制") }
    var featureSync: String        { s("Family sync across devices",
                                       "Синхронизация и семейный доступ",
                                       "Familiensync über Geräte hinweg",
                                       "Sincronización familiar entre dispositivos",
                                       "Synchronisation familiale entre appareils",
                                       "Sincronização familiar entre dispositivos",
                                       "家庭多设备同步") }
    var featureDiary: String       { s("Unlimited diary & statistics",
                                       "Журнал и статистика без лимитов",
                                       "Unbegrenzte Statistiken",
                                       "Diario y estadísticas sin límites",
                                       "Journal et statistiques illimités",
                                       "Diário e estatísticas ilimitados",
                                       "无限日记与统计") }
    var authSignedIn: String       { s("Signed in ✓",                      "Вы вошли ✓",                        "Angemeldet ✓", "Sesión iniciada ✓", "Connecté ✓", "Sessão iniciada ✓", "已登录 ✓") }
    var signInFailed: String       { s("Sign in failed. Please try again.",
                                       "Не удалось войти. Попробуйте ещё раз.",
                                       "Anmeldung fehlgeschlagen. Bitte erneut versuchen.",
                                       "Error al iniciar sesión. Inténtalo de nuevo.",
                                       "Échec de la connexion. Veuillez réessayer.",
                                       "Falha ao iniciar sessão. Tente novamente.",
                                       "登录失败。请重试。") }
    var googleComingSoon: String   { s("Google Sign-In is coming soon.",    "Вход через Google скоро появится.", "Google-Anmeldung kommt bald.", "El inicio de sesión con Google llegará pronto.", "La connexion Google arrive bientôt.", "O início de sessão com o Google chega em breve.", "Google 登录即将推出。") }
    var appleSignInHint: String    { s("Please sign in with your Apple ID in Settings → [Your Name] to use Sign in with Apple.",
                                       "Войдите в Apple ID в Настройках → [Ваше имя], чтобы использовать Sign in with Apple.",
                                       "Bitte melde dich in Einstellungen → [Dein Name] mit deiner Apple ID an.",
                                       "Inicia sesión con tu Apple ID en Ajustes → [Tu nombre] para usar Iniciar sesión con Apple.",
                                       "Veuillez vous connecter avec votre identifiant Apple dans Réglages → [Votre nom] pour utiliser Se connecter avec Apple.",
                                       "Inicie sessão com o seu ID Apple em Definições → [O seu nome] para usar Iniciar sessão com a Apple.",
                                       "请在 设置 →[您的姓名] 中登录您的 Apple ID，以使用通过 Apple 登录。") }

    // MARK: — Notifications
    var notifFeedingTitle: String  { s("Feeding reminder", "Напоминание о кормлении", "Fütterungserinnerung", "Recordatorio de toma", "Rappel de tétée", "Lembrete de mamada", "喂养提醒") }
    func notifFeedingBody(hours: Int) -> String { s("Baby hasn't eaten in \(hours)+ hours. Time to feed?", "Малыш не ел уже \(hours)+ ч. Пора покормить?", "Baby hat seit \(hours)+ Stunden nicht gegessen. Zeit zu füttern?", "El bebé no ha comido en \(hours)+ horas. ¿Hora de la toma?", "Bébé n’a pas mangé depuis \(hours)+ heures. Il est temps de le nourrir ?", "O bebé não come há \(hours)+ horas. Hora de alimentar?", "宝宝已经 \(hours)+ 小时没吃了。该喂奶了吗？") }
    var notifDiaryTitle: String    { s("Daily diary", "Дневник малыша", "Tägliches Tagebuch", "Diario diario", "Journal quotidien", "Diário diário", "每日日记") }
    var notifDiaryBody: String     { s("Write down today's special moments", "Запишите сегодняшние моменты в дневник малыша", "Halte die besonderen Momente von heute fest", "Anota los momentos especiales de hoy", "Notez les moments spéciaux d’aujourd’hui", "Registe os momentos especiais de hoje", "记下今天的特别时刻") }
    var notifLeapTitle: String     { s("Development leap", "Скачок развития", "Entwicklungsschub", "Salto del desarrollo", "Bond de développement", "Salto de desenvolvimento", "发育猛长期") }
    func notifLeapBody(name: String) -> String { s("«\(name)» leap begins — your baby is reaching a new stage", "Начинается «\(name)» — малыш переходит на новый этап", "Der Schub «\(name)» beginnt — dein Baby erreicht eine neue Phase", "Comienza el salto «\(name)» — tu bebé alcanza una nueva etapa", "Le bond «\(name)» commence — votre bébé atteint une nouvelle étape", "O salto «\(name)» começa — o seu bebé atinge uma nova fase", "「\(name)」猛长期开始了——您的宝宝正迈入新阶段") }
    var notifLeapSoonTitle: String { s("Leap may start soon", "Скоро возможен скачок", "Schub bald möglich", "Puede empezar un salto", "Un bond peut commencer bientôt", "Salto pode começar em breve", "飞跃期可能快开始了") }
    func notifLeapSoonBody(name: String) -> String { s("In 3 days «\(name)» may begin. Keep routines a little calmer.", "Через 3 дня возможен «\(name)». Сделайте режим чуть спокойнее.", "In 3 Tagen kann «\(name)» beginnen. Halte Routinen etwas ruhiger.", "En 3 días puede empezar «\(name)». Mantén las rutinas un poco más tranquilas.", "Dans 3 jours, «\(name)» peut commencer. Gardez des routines un peu plus calmes.", "Em 3 dias pode começar «\(name)». Mantenha as rotinas um pouco mais calmas.", "3 天后可能进入「\(name)」。让日常节奏稍微更安静。") }
    var notifLeapPeakTitle: String { s("Peak of the hard phase", "Пик сложной фазы", "Höhepunkt der schweren Phase", "Pico de la fase difícil", "Pic de la phase difficile", "Pico da fase difícil", "困难阶段高峰") }
    func notifLeapPeakBody(name: String) -> String { s("Today may be the peak of «\(name)». Shorter wake windows can help.", "Сегодня может быть пик «\(name)». Помогут более короткие окна бодрствования.", "Heute kann der Höhepunkt von «\(name)» sein. Kürzere Wachfenster können helfen.", "Hoy puede ser el pico de «\(name)». Ventanas de vigilia más cortas pueden ayudar.", "Aujourd’hui peut être le pic de «\(name)». Des temps d’éveil plus courts peuvent aider.", "Hoje pode ser o pico de «\(name)». Janelas acordado mais curtas podem ajudar.", "今天可能是「\(name)」的高峰。缩短清醒时间可能有帮助。") }
    var notifLeapSkillsTitle: String { s("Time to mark new skills", "Пора отметить новые навыки", "Zeit für neue Fähigkeiten", "Hora de marcar nuevas habilidades", "Il est temps de noter les nouvelles compétences", "Hora de marcar novas competências", "该记录新技能了") }
    func notifLeapSkillsBody(name: String) -> String { s("The hard stretch of «\(name)» is easing. Record what your baby learned.", "Сложная часть «\(name)» стихает. Запишите, чему малыш научился.", "Die schwere Phase von «\(name)» lässt nach. Notiere, was dein Baby gelernt hat.", "La parte difícil de «\(name)» se calma. Registra lo que aprendió tu bebé.", "La phase difficile de «\(name)» s’apaise. Notez ce que bébé a appris.", "A parte difícil de «\(name)» está a acalmar. Registe o que o bebé aprendeu.", "「\(name)」的困难阶段正在缓和。记录宝宝学会了什么。") }
    var notifVaccinationTitle: String { s("Vaccination reminder", "Напоминание о прививке", "Impferinnerung", "Recordatorio de vacuna", "Rappel de vaccin", "Lembrete de vacina", "疫苗接种提醒") }
    func notifVaccinationBody(name: String) -> String { s("\(name) — in 7 days", "\(name) — через 7 дней", "\(name) — in 7 Tagen", "\(name) — en 7 días", "\(name) — dans 7 jours", "\(name) — em 7 dias", "\(name) — 7 天后") }
}
