import SwiftUI
import WidgetKit

struct MomsyFeedingWidgetView: View {
    let entry: MomsyWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .widgetURL(URL(string: "momsy://feeding"))
    }

    @ViewBuilder private var content: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - System Small

private struct SmallWidgetView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch entry.feedingState {
            case .running(let start, let side):
                FeedingTimerView(effectiveStart: start, side: side, paused: false, pausedSecs: 0)
            case .paused(let secs, let side):
                FeedingTimerView(effectiveStart: .now, side: side, paused: true, pausedSecs: secs)
            case .idle:
                switch entry.sleepState {
                case .active(let start):
                    SleepTimerView(startDate: start)
                case .idle:
                    IdleSummaryView(entry: entry)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .colorScheme(.light)
        .containerBackground(Color(red: 1.0, green: 0.965, blue: 0.925), for: .widget)
    }
}

// MARK: - System Medium

private struct MediumWidgetView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            FeedingColumn(state: entry.feedingState)
                .frame(maxWidth: .infinity)
            Divider().padding(.vertical, 8)
            SleepColumn(state: entry.sleepState)
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .colorScheme(.light)
        .containerBackground(Color(red: 1.0, green: 0.965, blue: 0.925), for: .widget)
    }
}

private let bbCoral   = Color(red: 0.941, green: 0.541, blue: 0.431)
private let bbLilac   = Color(red: 0.624, green: 0.510, blue: 0.847)
private let bbInk     = Color(red: 0.239, green: 0.165, blue: 0.125)
private let bbInkSoft = Color(red: 0.420, green: 0.329, blue: 0.275)

private enum WidgetLocalizationDefaults {
    static let appLanguageKey = "appLanguage"
    static let appGroupSuiteName = "group.RuslanAbd.Momsy"

    static var selectedLanguageCode: String? {
        UserDefaults(suiteName: appGroupSuiteName)?.string(forKey: appLanguageKey)
            ?? UserDefaults.standard.string(forKey: appLanguageKey)
    }
}

struct WidgetL10n {
    static var current: WidgetL10n {
        let code = WidgetLocalizationDefaults.selectedLanguageCode
            ?? Locale.preferredLanguages.first
            ?? "en"
        return WidgetL10n(lang: normalizedLanguageCode(from: code))
    }

    let lang: String

    private static func normalizedLanguageCode(from code: String) -> String {
        let languageCode = code.split(separator: "-").first.map(String.init) ?? code
        switch languageCode {
        case "ru", "de", "es", "fr", "pt", "zh":
            return languageCode
        default:
            return "en"
        }
    }

    private func t(_ en: String, _ ru: String, _ de: String, _ es: String, _ fr: String, _ pt: String, _ zh: String) -> String {
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

    var baby: String { t("Baby", "Малыш", "Baby", "Bebé", "Bébé", "Bebé", "宝宝") }
    var today: String { t("Today", "Сегодня", "Heute", "Hoy", "Aujourd’hui", "Hoje", "今天") }
    var ago: String { t("ago", "назад", "her", "atrás", "avant", "atrás", "前") }
    var active: String { t("active", "активен", "aktiv", "activo", "en cours", "ativo", "进行中") }
    var last: String { t("last", "последний", "letzter", "último", "dernier", "último", "上次") }
    var duration: String { t("duration", "продолжительность", "Dauer", "duración", "durée", "duração", "时长") }
    var inProgress: String { t("in progress", "идёт сейчас", "läuft gerade", "en curso", "en cours", "em curso", "进行中") }
    var noData: String { t("No data", "Нет данных", "Keine Daten", "Sin datos", "Aucune donnée", "Sem dados", "暂无数据") }
    var feeding: String { t("Feeding", "Кормление", "Füttern", "Toma", "Tétée", "Mamada", "喂养") }
    var feedingActive: String { t("Feeding…", "Кормление…", "Füttern…", "Tomando…", "Tétée…", "Mamada…", "喂养中…") }
    var paused: String { t("Paused", "Пауза", "Pause", "En pausa", "En pause", "Em pausa", "已暂停") }
    var sleep: String { t("Sleep", "Сон", "Schlaf", "Sueño", "Sommeil", "Sono", "睡眠") }
    var sleeping: String { t("sleeping", "спит", "schläft", "durmiendo", "dort", "a dormir", "睡觉中") }
    var sleepingNow: String { t("sleeping now", "спит сейчас", "schläft jetzt", "duerme ahora", "dort maintenant", "a dormir agora", "正在睡觉") }
    var wokeUp: String { t("woke up", "проснулся", "aufgewacht", "se despertó", "réveillé", "acordou", "醒来") }
    var leap: String { t("Leap", "Скачок", "Schub", "Salto", "Bond", "Salto", "飞跃期") }
    var walk: String { t("Walk", "Прогулка", "Spaziergang", "Paseo", "Promenade", "Passeio", "散步") }
    var walking: String { t("Walking…", "Прогулка…", "Spaziergang…", "Paseando…", "En promenade…", "A passear…", "散步中…") }
    var bath: String { t("Bath", "Купание", "Bad", "Baño", "Bain", "Banho", "洗澡") }
    var bathing: String { t("Bathing…", "Купание…", "Baden…", "Bañando…", "Au bain…", "A tomar banho…", "洗澡中…") }
    var pumping: String { t("Pumping", "Сцеживание", "Pumpen", "Extracción", "Tire-lait", "Extração", "吸奶") }
    var pumpingActive: String { t("Pumping…", "Сцеживание…", "Pumpen…", "Extrayendo…", "Tire-lait…", "Extração…", "吸奶中…") }
    var updating: String { t("Updating…", "Обновление…", "Aktualisiert…", "Actualizando…", "Mise à jour…", "A atualizar…", "更新中…") }

    var widgetFeedingDescription: String { t("Feeding timer", "Таймер кормления", "Fütterungs-Timer", "Temporizador de tomas", "Minuteur de tétée", "Temporizador de mamadas", "喂养计时器") }
    var widgetSleepDescription: String { t("Sleep tracker", "Трекер сна", "Schlaf-Tracker", "Registro de sueño", "Suivi du sommeil", "Registo de sono", "睡眠记录") }
    var widgetSummaryName: String { t("Daily summary", "Сводка дня", "Tagesübersicht", "Resumen del día", "Résumé du jour", "Resumo do dia", "每日概览") }
    var widgetSummaryDescription: String { t("Feeding, sleep and diapers", "Кормление, сон и подгузники", "Füttern, Schlaf und Windeln", "Tomas, sueño y pañales", "Tétées, sommeil et couches", "Mamadas, sono e fraldas", "喂养、睡眠和尿布") }
    var widgetStandByName: String { t("Night mode", "Ночной режим", "Nachtmodus", "Modo noche", "Mode nuit", "Modo noturno", "夜间模式") }
    var widgetStandByDescription: String { t("Last feeding and sleep for StandBy", "Последнее кормление и сон для StandBy", "Letzte Fütterung und Schlaf für StandBy", "Última toma y sueño para StandBy", "Dernière tétée et sommeil pour StandBy", "Última mamada e sono para StandBy", "StandBy 上的最近喂养与睡眠") }

    func openMomsyFor(_ name: String) -> String {
        t("Open Momsy\nfor \(name)", "Открой Momsy\nдля \(name)", "Öffne Momsy\nfür \(name)", "Abre Momsy\npara \(name)", "Ouvrez Momsy\npour \(name)", "Abra o Momsy\npara \(name)", "打开 Momsy\n查看 \(name)")
    }

    func ageMonths(_ months: Int) -> String {
        t("\(months) mo", "\(months) мес", "\(months) Mon", "\(months) m", "\(months) mois", "\(months) m", "\(months) 个月")
    }

    func duration(seconds total: Int) -> String {
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 {
            return t("\(h)h \(m)m", "\(h) ч \(m) мин", "\(h)h \(m)m", "\(h)h \(m)m", "\(h)h \(m)m", "\(h)h \(m)m", "\(h) 小时 \(m) 分钟")
        }
        return t("\(m)m", "\(m) мин", "\(m)m", "\(m) min", "\(m) min", "\(m) min", "\(m) 分钟")
    }

    func sleepingDuration(seconds total: Int) -> String {
        t("Sleeping \(duration(seconds: total))", "Спит \(duration(seconds: total))", "Schläft \(duration(seconds: total))", "Duerme \(duration(seconds: total))", "Dort \(duration(seconds: total))", "A dormir \(duration(seconds: total))", "已睡 \(duration(seconds: total))")
    }

    func feedingSideLabel(_ side: String) -> String {
        switch side {
        case "left", "Левая": return t("Left", "Левая", "Links", "Izquierdo", "Gauche", "Esquerdo", "左侧")
        case "right", "Правая": return t("Right", "Правая", "Rechts", "Derecho", "Droite", "Direito", "右侧")
        default: return t("Bottle", "Бутылка", "Flasche", "Biberón", "Biberon", "Biberão", "奶瓶")
        }
    }

    func pumpingSideLabel(_ side: String) -> String {
        switch side {
        case "left": return t("Left", "Левая", "Links", "Izquierdo", "Gauche", "Esquerdo", "左侧")
        case "right": return t("Right", "Правая", "Rechts", "Derecho", "Droite", "Direito", "右侧")
        default: return t("Both", "Обе", "Beide", "Ambos", "Les deux", "Ambos", "双侧")
        }
    }
}

private struct FeedingColumn: View {
    let state: FeedingWidgetState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(WidgetL10n.current.feeding, systemImage: "drop.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(bbCoral)
            switch state {
            case .running(let start, let side):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .minimumScaleFactor(0.7)
                Text(sideLabel(side)).font(.caption).foregroundStyle(.secondary)
            case .paused(let secs, let side):
                Text(formatSeconds(secs))
                    .font(.title2.monospacedDigit().weight(.semibold))
                HStack(spacing: 2) {
                    Image(systemName: "pause.fill").font(.caption2)
                    Text(sideLabel(side)).font(.caption)
                }
                .foregroundStyle(.secondary)
            case .idle(let lastDate):
                if let date = lastDate {
                    Text(date, style: .relative)
                        .font(.subheadline.monospacedDigit())
                    Text(WidgetL10n.current.ago).font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("—").font(.title2).foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

private struct SleepColumn: View {
    let state: SleepWidgetState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(WidgetL10n.current.sleep, systemImage: "moon.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(bbLilac)
            switch state {
            case .active(let start):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .minimumScaleFactor(0.7)
                Text(WidgetL10n.current.active).font(.caption).foregroundStyle(.green)
            case .idle(let dur):
                if let secs = dur {
                    Text(formatSeconds(secs))
                        .font(.subheadline.monospacedDigit())
                    Text(WidgetL10n.current.last).font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("—").font(.title2).foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

// MARK: - Accessory Rectangular (Lock Screen)

private struct AccessoryRectangularView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            feedingRow
            sleepRow
        }
        .containerBackground(.clear, for: .widget)
    }

    @ViewBuilder private var feedingRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "drop.fill").frame(width: 12)
            switch entry.feedingState {
            case .running(let start, let side):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                Text(sideLabel(side))
            case .paused(let secs, let side):
                Text(formatSeconds(secs)).monospacedDigit()
                Image(systemName: "pause.fill").font(.caption2)
                Text(sideLabel(side))
            case .idle(let date):
                if let d = date {
                    Text(d, style: .relative).monospacedDigit()
                } else {
                    Text("—")
                }
            }
        }
        .font(.caption2)
    }

    @ViewBuilder private var sleepRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.fill").frame(width: 12)
            switch entry.sleepState {
            case .active(let start):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
            case .idle(let dur):
                if let secs = dur {
                    Text(formatSeconds(secs)).monospacedDigit()
                } else {
                    Text("—")
                }
            }
        }
        .font(.caption2)
    }
}

// MARK: - Subviews

private struct FeedingTimerView: View {
    let effectiveStart: Date
    let side: String
    let paused: Bool
    let pausedSecs: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(WidgetL10n.current.feeding, systemImage: "drop.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(bbCoral)
            if paused {
                Text(formatSeconds(pausedSecs))
                    .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                HStack(spacing: 4) {
                    Image(systemName: "pause.fill").font(.caption)
                    Text(sideLabel(side)).font(.caption)
                }
                .foregroundStyle(.secondary)
            } else {
                Text(timerInterval: effectiveStart...Date.distantFuture, countsDown: false)
                    .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                    .minimumScaleFactor(0.6)
                Text(sideLabel(side)).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private struct SleepTimerView: View {
    let startDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(WidgetL10n.current.sleep, systemImage: "moon.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(bbLilac)
            Text(timerInterval: startDate...Date.distantFuture, countsDown: false)
                .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                .minimumScaleFactor(0.6)
        }
    }
}

private struct IdleSummaryView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            feedingRow
            sleepRow
        }
    }

    @ViewBuilder private var feedingRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(WidgetL10n.current.feeding, systemImage: "drop.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(bbCoral)
            if case .idle(let date) = entry.feedingState, let d = date {
                VStack(alignment: .leading, spacing: 0) {
                    Text(d, style: .relative)
                        .font(.subheadline.monospacedDigit().weight(.medium))
                    Text(WidgetL10n.current.ago).font(.caption).foregroundStyle(.secondary)
                }
            } else {
                Text("—").foregroundStyle(.tertiary)
            }
        }
    }

    @ViewBuilder private var sleepRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(WidgetL10n.current.sleep, systemImage: "moon.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(bbLilac)
            if case .idle(let dur) = entry.sleepState, let secs = dur {
                Text(formatSeconds(secs))
                    .font(.subheadline.monospacedDigit().weight(.medium))
            } else {
                Text("—").foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Accessory Circular (Lock Screen)

private struct AccessoryCircularView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "drop.fill")
                    .font(.caption2.weight(.semibold))
                Group {
                    switch entry.feedingState {
                    case .running(let start, _):
                        Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    case .paused(let secs, _):
                        Text(formatSeconds(secs))
                    case .idle(let date):
                        if let d = date {
                            Text(d, style: .relative)
                        } else {
                            Text("—")
                        }
                    }
                }
                .font(.caption2.monospacedDigit())
                .minimumScaleFactor(0.6)
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Helpers

private func sideLabel(_ side: String) -> String {
    switch side {
    case "left", "Левая":   return "←"
    case "right", "Правая":  return "→"
    case "bottle", "Бутылка": return "🍼"
    default:        return side
    }
}

private func formatSeconds(_ total: Int) -> String {
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
    return String(format: "%02d:%02d", m, s)
}
