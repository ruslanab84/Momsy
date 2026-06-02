import Foundation

/// Centralised prompts for the Weekly Insight feature.
/// System + user prompts live here — never in ViewModel or View.
/// The model receives ONLY pre-aggregated stats (never raw rows) and must reply in JSON.
enum WeeklyInsightPrompt {

    static let jsonKeys = "sleepSummary, sleepRecommendation, feedingSummary, feedingRecommendation, overallSummary"

    static func system(for language: Language) -> String {
        switch language {
        case .english, .spanish, .portuguese:
            return """
            You are a warm, caring pediatric assistant for mothers. Analyze a baby's weekly stats.
            Compare to WHO age norms. Be encouraging, never give medical diagnoses, and NEVER recommend
            re-introducing a food that is flagged as an allergen or caused a reaction.
            Reply ONLY with a JSON object with exactly these keys: \(jsonKeys).
            Each value is 1–2 warm sentences in English. No markdown, no extra keys, no text outside the JSON.
            """
        case .russian:
            return """
            Ты — тёплый и заботливый помощник по уходу за малышом. Проанализируй недельную статистику ребёнка.
            Сравни с возрастными нормами ВОЗ. Подбадривай, не ставь медицинских диагнозов и НИКОГДА не предлагай
            повторно вводить продукт, помеченный как аллерген или вызвавший реакцию.
            Ответь ТОЛЬКО JSON-объектом ровно с этими ключами: \(jsonKeys).
            Каждое значение — 1–2 тёплых предложения на русском языке. Без markdown, без лишних ключей, без текста вне JSON.
            """
        case .german:
            return """
            Du bist ein einfühlsamer Assistent für die Babypflege. Analysiere die Wochenstatistik des Babys.
            Vergleiche mit den WHO-Altersnormen. Sei ermutigend, stelle keine medizinischen Diagnosen und empfehle NIEMALS,
            ein als Allergen markiertes oder reaktionsauslösendes Lebensmittel erneut einzuführen.
            Antworte NUR mit einem JSON-Objekt mit genau diesen Schlüsseln: \(jsonKeys).
            Jeder Wert sind 1–2 warme Sätze auf Deutsch. Kein Markdown, keine zusätzlichen Schlüssel, kein Text außerhalb des JSON.
            """
        }
    }

    static func user(ctx: WeeklyInsightContext) -> String {
        switch ctx.language {
        case .english, .spanish, .portuguese: return build(ctx: ctx, l: .en)
        case .russian: return build(ctx: ctx, l: .ru)
        case .german:  return build(ctx: ctx, l: .de)
        }
    }

    // MARK: - Builder

    private enum Loc { case en, ru, de }

    private static func build(ctx: WeeklyInsightContext, l: Loc) -> String {
        let s = ctx.stats
        let sleepH = hours(s.avgSleepMinutesPerDay)
        let nightH = hours(s.avgNightSleepMinutes)
        let dayH = hours(s.avgDaySleepMinutes)
        let whoH = hours(s.whoMinSleepMinutes)
        let naps = String(format: "%.1f", s.avgNapsPerDay)
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let trend = trendString(s.sleepTrendVsPrevWeekMinutes, l: l)
        let foods = s.newFoodsIntroduced.isEmpty ? "—" : s.newFoodsIntroduced.joined(separator: ", ")
        let allergens = s.allergensFlagged.isEmpty ? "—" : s.allergensFlagged.joined(separator: ", ")
        let leap = s.currentLeapName

        var lines: [String] = []
        switch l {
        case .en:
            lines.append("Baby age: \(s.ageMonths) mo (\(s.ageWeeks) weeks).")
            if let leap { lines.append("Developmental leap: \(leap).") }
            lines.append("WHO: total sleep target ≥ \(whoH)/day; max awake window ~\(s.whoAwakeWindowMax) min.")
            lines.append("Sleep this week: avg \(sleepH)/day (night \(nightH), day \(dayH), \(naps) naps/day), \(trend).")
            lines.append("Feeding this week: \(feeds)/day, \(s.totalFeedings) total. Diaper changes: \(s.totalDiapers).")
            lines.append("New foods introduced: \(foods). Allergen/reaction flagged: \(allergens).")
            lines.append("Return JSON {\(jsonKeys)} comparing to WHO norms with one practical recommendation each.")
        case .ru:
            lines.append("Возраст малыша: \(s.ageMonths) мес (\(s.ageWeeks) нед).")
            if let leap { lines.append("Скачок развития: \(leap).") }
            lines.append("ВОЗ: суммарный сон ≥ \(whoH)/сутки; макс. время бодрствования ~\(s.whoAwakeWindowMax) мин.")
            lines.append("Сон за неделю: в среднем \(sleepH)/сутки (ночь \(nightH), день \(dayH), \(naps) дневных снов/сутки), \(trend).")
            lines.append("Кормления за неделю: \(feeds)/сутки, всего \(s.totalFeedings). Смен подгузников: \(s.totalDiapers).")
            lines.append("Новые продукты: \(foods). Аллерген/реакция: \(allergens).")
            lines.append("Верни JSON {\(jsonKeys)}, сравнивая с нормами ВОЗ, с одной практичной рекомендацией в каждом поле.")
        case .de:
            lines.append("Babyalter: \(s.ageMonths) Mon. (\(s.ageWeeks) Wochen).")
            if let leap { lines.append("Entwicklungsschub: \(leap).") }
            lines.append("WHO: Gesamtschlaf ≥ \(whoH)/Tag; max. Wachfenster ~\(s.whoAwakeWindowMax) Min.")
            lines.append("Schlaf diese Woche: Ø \(sleepH)/Tag (Nacht \(nightH), Tag \(dayH), \(naps) Schläfchen/Tag), \(trend).")
            lines.append("Mahlzeiten diese Woche: \(feeds)/Tag, gesamt \(s.totalFeedings). Windelwechsel: \(s.totalDiapers).")
            lines.append("Neue Lebensmittel: \(foods). Allergen/Reaktion: \(allergens).")
            lines.append("Gib JSON {\(jsonKeys)} zurück, vergleiche mit WHO-Normen, je eine praktische Empfehlung.")
        }
        return lines.joined(separator: "\n")
    }

    private static func hours(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }

    private static func trendString(_ delta: Int, l: Loc) -> String {
        let absMin = abs(delta)
        switch l {
        case .en:
            if absMin < 10 { return "about the same as last week" }
            return delta > 0 ? "+\(absMin) min/day vs last week" : "-\(absMin) min/day vs last week"
        case .ru:
            if absMin < 10 { return "примерно как на прошлой неделе" }
            return delta > 0 ? "+\(absMin) мин/сутки к прошлой неделе" : "-\(absMin) мин/сутки к прошлой неделе"
        case .de:
            if absMin < 10 { return "etwa wie letzte Woche" }
            return delta > 0 ? "+\(absMin) Min/Tag vs. letzte Woche" : "-\(absMin) Min/Tag vs. letzte Woche"
        }
    }
}
