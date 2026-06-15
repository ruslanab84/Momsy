import Foundation

/// Centralised prompts for the Daily AI Tip feature.
/// System + user prompts live here — never in ViewModel or View.
enum DailyTipPrompt {

    static func system(for language: Language) -> String {
        switch language {
        case .english, .spanish, .portuguese:
            return """
            You are a warm and caring assistant for mothers. ONLY answer questions about baby care.
            Response: 1–2 sentences, warm tone, no medical diagnoses, in English.
            Do not mention that you are AI. No bullet points, headings, or lists.
            Use the baby's name if provided.
            """
        case .russian:
            return """
            Ты — мягкий и заботливый помощник для мам. Отвечай ТОЛЬКО на темы ухода за ребёнком.
            Ответ: 1–2 предложения, тёплый тон, без медицинских диагнозов, на русском языке.
            Не упоминай что ты AI. Без bullet points, заголовков и списков.
            Используй имя ребёнка, если оно есть.
            """
        case .german:
            return """
            Du bist ein einfühlsamer Assistent für Mütter. Antworte NUR zu Themen der Babypflege.
            Antwort: 1–2 Sätze, warmer Ton, keine medizinischen Diagnosen, auf Deutsch.
            Erwähne nicht, dass du eine KI bist. Keine Aufzählungen, Überschriften oder Listen.
            Verwende den Namen des Babys, wenn er angegeben ist.
            """
        case .french:
            return """
            Tu es une assistante douce et bienveillante pour les mamans. Réponds UNIQUEMENT aux sujets sur les soins du bébé.
            Réponse : 1 à 2 phrases, ton chaleureux, pas de diagnostic médical, en français.
            Ne mentionne pas que tu es une IA. Pas de puces, de titres ni de listes.
            Utilise le prénom du bébé s’il est indiqué.
            """
        }
    }

    static func user(ctx: DailyContext) -> String {
        switch ctx.language {
        case .english, .spanish, .portuguese: return buildEN(ctx: ctx)
        case .russian: return buildRU(ctx: ctx)
        case .german:  return buildDE(ctx: ctx)
        case .french:  return buildFR(ctx: ctx)
        }
    }

    // MARK: - Language builders

    private static func buildEN(ctx: DailyContext) -> String {
        var lines: [String] = ["Baby: \(ctx.babyName), \(ctx.ageMonths) mo. \(ctx.ageDays) d."]
        if let leap = ctx.currentLeapName { lines.append("Developmental leap: \(leap).") }
        lines.append("Time of day: \(ctx.timeOfDay.displayName(for: .english)).")
        lines.append("")
        lines.append("Today:")
        var feedLine = "- Feedings: \(ctx.feedingCount)"
        if ctx.totalFeedingMinutes > 0 { feedLine += ", total \(ctx.totalFeedingMinutes) min" }
        if let m = ctx.minutesSinceLastFeed { feedLine += ", last \(m) min ago" }
        lines.append(feedLine)
        if let side = ctx.lastFeedSide, !side.isEmpty { lines.append("  Side: \(side)") }
        var sleepLine = "- Sleep: \(ctx.sleepCount) times"
        if ctx.totalSleepMinutes > 0 {
            let h = ctx.totalSleepMinutes / 60
            let m = ctx.totalSleepMinutes % 60
            sleepLine += ", total \(h > 0 ? "\(h)h " : "")\(m > 0 ? "\(m)min" : "")".trimmingCharacters(in: .whitespaces)
        }
        lines.append(sleepLine)
        lines.append("- Diapers: \(ctx.diaperCount)")
        lines.append("")
        lines.append("Give one practical tip for right now. Maximum 2 sentences.")
        return lines.joined(separator: "\n")
    }

    private static func buildRU(ctx: DailyContext) -> String {
        var lines: [String] = ["Ребёнок: \(ctx.babyName), \(ctx.ageMonths) мес. \(ctx.ageDays) дн."]
        if let leap = ctx.currentLeapName { lines.append("Скачок развития: \(leap).") }
        lines.append("Время суток: \(ctx.timeOfDay.displayName(for: .russian)).")
        lines.append("")
        lines.append("Сегодня:")
        var feedLine = "- Кормлений: \(ctx.feedingCount)"
        if ctx.totalFeedingMinutes > 0 { feedLine += ", суммарно \(ctx.totalFeedingMinutes) мин" }
        if let m = ctx.minutesSinceLastFeed { feedLine += ", последнее \(m) мин назад" }
        lines.append(feedLine)
        if let side = ctx.lastFeedSide, !side.isEmpty { lines.append("  Сторона: \(side)") }
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

    private static func buildDE(ctx: DailyContext) -> String {
        var lines: [String] = ["Baby: \(ctx.babyName), \(ctx.ageMonths) Mon. \(ctx.ageDays) T."]
        if let leap = ctx.currentLeapName { lines.append("Entwicklungsschub: \(leap).") }
        lines.append("Tageszeit: \(ctx.timeOfDay.displayName(for: .german)).")
        lines.append("")
        lines.append("Heute:")
        var feedLine = "- Mahlzeiten: \(ctx.feedingCount)"
        if ctx.totalFeedingMinutes > 0 { feedLine += ", gesamt \(ctx.totalFeedingMinutes) min" }
        if let m = ctx.minutesSinceLastFeed { feedLine += ", letzte vor \(m) min" }
        lines.append(feedLine)
        if let side = ctx.lastFeedSide, !side.isEmpty { lines.append("  Seite: \(side)") }
        var sleepLine = "- Schlaf: \(ctx.sleepCount)-mal"
        if ctx.totalSleepMinutes > 0 {
            let h = ctx.totalSleepMinutes / 60
            let m = ctx.totalSleepMinutes % 60
            sleepLine += ", gesamt \(h > 0 ? "\(h)h " : "")\(m > 0 ? "\(m)min" : "")".trimmingCharacters(in: .whitespaces)
        }
        lines.append(sleepLine)
        lines.append("- Windeln: \(ctx.diaperCount)")
        lines.append("")
        lines.append("Gib einen praktischen Tipp für jetzt. Maximal 2 Sätze.")
        return lines.joined(separator: "\n")
    }

    private static func buildFR(ctx: DailyContext) -> String {
        var lines: [String] = ["Bébé : \(ctx.babyName), \(ctx.ageMonths) mois \(ctx.ageDays) j."]
        if let leap = ctx.currentLeapName { lines.append("Bond de développement : \(leap).") }
        lines.append("Moment de la journée : \(ctx.timeOfDay.displayName(for: .french)).")
        lines.append("")
        lines.append("Aujourd’hui :")
        var feedLine = "- Tétées : \(ctx.feedingCount)"
        if ctx.totalFeedingMinutes > 0 { feedLine += ", total \(ctx.totalFeedingMinutes) min" }
        if let m = ctx.minutesSinceLastFeed { feedLine += ", dernière il y a \(m) min" }
        lines.append(feedLine)
        if let side = ctx.lastFeedSide, !side.isEmpty { lines.append("  Côté : \(side)") }
        var sleepLine = "- Sommeil : \(ctx.sleepCount) fois"
        if ctx.totalSleepMinutes > 0 {
            let h = ctx.totalSleepMinutes / 60
            let m = ctx.totalSleepMinutes % 60
            sleepLine += ", total \(h > 0 ? "\(h)h " : "")\(m > 0 ? "\(m)min" : "")".trimmingCharacters(in: .whitespaces)
        }
        lines.append(sleepLine)
        lines.append("- Couches : \(ctx.diaperCount)")
        lines.append("")
        lines.append("Donne un conseil pratique pour maintenant. Maximum 2 phrases.")
        return lines.joined(separator: "\n")
    }
}
