import Foundation

/// Centralised prompts for the Daily AI Tip feature.
/// System + user prompts live here — never in ViewModel or View.
enum DailyTipPrompt {

    static let system = """
    Ты — мягкий и заботливый помощник для мам. Отвечай ТОЛЬКО на темы ухода за ребёнком.
    Ответ: 1–2 предложения, тёплый тон, без медицинских диагнозов, на русском языке.
    Не упоминай что ты AI. Без bullet points, заголовков и списков.
    Используй имя ребёнка, если оно есть.
    """

    static func user(ctx: DailyContext) -> String {
        var lines: [String] = []

        lines.append("Ребёнок: \(ctx.babyName), \(ctx.ageMonths) мес. \(ctx.ageDays) дн.")

        if let leap = ctx.currentLeapName {
            lines.append("Скачок развития: \(leap).")
        }

        lines.append("Время суток: \(ctx.timeOfDay.displayName).")
        lines.append("")
        lines.append("Сегодня:")

        var feedLine = "- Кормлений: \(ctx.feedingCount)"
        if ctx.totalFeedingMinutes > 0 { feedLine += ", суммарно \(ctx.totalFeedingMinutes) мин" }
        if let mins = ctx.minutesSinceLastFeed { feedLine += ", последнее \(mins) мин назад" }
        lines.append(feedLine)

        if let side = ctx.lastFeedSide, !side.isEmpty {
            lines.append("  Сторона: \(side)")
        }

        var sleepLine = "- Сон: \(ctx.sleepCount) раз"
        if ctx.totalSleepMinutes > 0 {
            let h = ctx.totalSleepMinutes / 60
            let m = ctx.totalSleepMinutes % 60
            sleepLine += ", суммарно \(h > 0 ? "\(h) ч " : "")\(m > 0 ? "\(m) мин" : "")".trimmingCharacters(in: .whitespaces)
        }
        lines.append(sleepLine)

        lines.append("- Подгузников: \(ctx.diaperCount)")
        lines.append("")
        lines.append("Дай один практичный совет на сейчас. Максимум 2 предложения.")

        return lines.joined(separator: "\n")
    }
}
