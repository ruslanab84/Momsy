import Foundation

/// Centralised prompts for the Daily AI Tip feature.
/// System + user prompts live here — never in ViewModel or View.
enum DailyTipPrompt {

    static func system(for language: Language) -> String {
        switch language {
        case .english, .spanish:
            return """
            You are a warm and caring assistant for mothers. ONLY answer questions about baby care.
            Response: 1–2 sentences, warm tone, no medical diagnoses, in English.
            Do not mention that you are AI. No bullet points, headings, or lists.
            Use the baby's name if provided.
            """
        case .portuguese:
            return """
            És uma assistente meiga e carinhosa para mães. Responde APENAS a temas de cuidados com o bebé.
            Resposta: 1–2 frases, tom caloroso, sem diagnósticos médicos, em português.
            Não menciones que és uma IA. Sem tópicos, títulos ou listas.
            Usa o nome do bebé, se for indicado.
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
        case .chinese:
            return """
            你是一位温柔体贴、专为妈妈们服务的助手。只回答与宝宝护理相关的问题。
            回答：1–2 句话，语气温暖，不做医学诊断，用中文回答。
            不要提及你是 AI。不要使用项目符号、标题或列表。
            如果提供了宝宝的名字，请使用它。
            """
        }
    }

    static func user(ctx: DailyContext) -> String {
        switch ctx.language {
        case .english, .spanish: return buildEN(ctx: ctx)
        case .russian: return buildRU(ctx: ctx)
        case .german:  return buildDE(ctx: ctx)
        case .french:  return buildFR(ctx: ctx)
        case .portuguese: return buildPT(ctx: ctx)
        case .chinese: return buildZH(ctx: ctx)
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

    private static func buildPT(ctx: DailyContext) -> String {
        var lines: [String] = ["Bebé: \(ctx.babyName), \(ctx.ageMonths) meses \(ctx.ageDays) dias."]
        if let leap = ctx.currentLeapName { lines.append("Salto de desenvolvimento: \(leap).") }
        lines.append("Período do dia: \(ctx.timeOfDay.displayName(for: .portuguese)).")
        lines.append("")
        lines.append("Hoje:")
        var feedLine = "- Mamadas: \(ctx.feedingCount)"
        if ctx.totalFeedingMinutes > 0 { feedLine += ", total \(ctx.totalFeedingMinutes) min" }
        if let m = ctx.minutesSinceLastFeed { feedLine += ", última há \(m) min" }
        lines.append(feedLine)
        if let side = ctx.lastFeedSide, !side.isEmpty { lines.append("  Lado: \(side)") }
        var sleepLine = "- Sono: \(ctx.sleepCount) vezes"
        if ctx.totalSleepMinutes > 0 {
            let h = ctx.totalSleepMinutes / 60
            let m = ctx.totalSleepMinutes % 60
            sleepLine += ", total \(h > 0 ? "\(h)h " : "")\(m > 0 ? "\(m)min" : "")".trimmingCharacters(in: .whitespaces)
        }
        lines.append(sleepLine)
        lines.append("- Fraldas: \(ctx.diaperCount)")
        lines.append("")
        lines.append("Dá um conselho prático para agora. No máximo 2 frases.")
        return lines.joined(separator: "\n")
    }

    private static func buildZH(ctx: DailyContext) -> String {
        var lines: [String] = ["宝宝：\(ctx.babyName)，\(ctx.ageMonths) 个月 \(ctx.ageDays) 天。"]
        if let leap = ctx.currentLeapName { lines.append("发育猛长期：\(leap)。") }
        lines.append("时段：\(ctx.timeOfDay.displayName(for: .chinese))。")
        lines.append("")
        lines.append("今天：")
        var feedLine = "- 喂养：\(ctx.feedingCount) 次"
        if ctx.totalFeedingMinutes > 0 { feedLine += "，共 \(ctx.totalFeedingMinutes) 分钟" }
        if let m = ctx.minutesSinceLastFeed { feedLine += "，上次在 \(m) 分钟前" }
        lines.append(feedLine)
        if let side = ctx.lastFeedSide, !side.isEmpty { lines.append("  侧别：\(side)") }
        var sleepLine = "- 睡眠：\(ctx.sleepCount) 次"
        if ctx.totalSleepMinutes > 0 {
            let h = ctx.totalSleepMinutes / 60
            let m = ctx.totalSleepMinutes % 60
            sleepLine += "，共 \(h > 0 ? "\(h) 小时 " : "")\(m > 0 ? "\(m) 分钟" : "")".trimmingCharacters(in: .whitespaces)
        }
        lines.append(sleepLine)
        lines.append("- 尿布：\(ctx.diaperCount)")
        lines.append("")
        lines.append("请给出一条现在就能用的实用建议。最多 2 句话。")
        return lines.joined(separator: "\n")
    }
}
