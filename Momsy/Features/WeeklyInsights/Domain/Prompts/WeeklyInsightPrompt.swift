import Foundation

/// Centralised prompts for the Weekly Insight feature.
/// System + user prompts live here — never in ViewModel or View.
/// The model receives ONLY pre-aggregated stats (never raw rows) and must reply in JSON.
enum WeeklyInsightPrompt {

    static let jsonKeys = "sleepSummary, sleepRecommendation, feedingSummary, feedingRecommendation, overallSummary"

    static func system(for language: Language) -> String {
        switch language {
        case .english:
            return """
            You are a warm, caring pediatric assistant for mothers. Analyze a baby's weekly stats.
            Compare to WHO age norms. Be encouraging, never give medical diagnoses, and NEVER recommend
            re-introducing a food that is flagged as an allergen or caused a reaction.
            Reply ONLY with a JSON object with exactly these keys: \(jsonKeys).
            Each value is 1–2 warm sentences in English. No markdown, no extra keys, no text outside the JSON.
            """
        case .spanish:
            return """
            Eres una asistente pediátrica cálida y cercana para madres. Analiza las estadísticas semanales de un bebé.
            Compáralas con las normas de la OMS para su edad. Sé alentadora, no des diagnósticos médicos y NUNCA recomiendes
            reintroducir un alimento marcado como alérgeno o que haya causado una reacción.
            Responde SOLO con un objeto JSON con exactamente estas claves: \(jsonKeys).
            Cada valor debe tener 1–2 frases cálidas en español. Sin markdown, sin claves extra, sin texto fuera del JSON.
            """
        case .portuguese:
            return """
            És uma assistente pediátrica meiga e carinhosa para mães. Analisa as estatísticas semanais de um bebé.
            Compara com as normas da OMS para a idade. Sê encorajadora, nunca dês diagnósticos médicos e NUNCA recomendes
            reintroduzir um alimento assinalado como alergénio ou que tenha causado uma reação.
            Responde APENAS com um objeto JSON com exatamente estas chaves: \(jsonKeys).
            Cada valor são 1–2 frases calorosas em português. Sem markdown, sem chaves extra, sem texto fora do JSON.
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
        case .french:
            return """
            Tu es une assistante pédiatrique chaleureuse et bienveillante pour les mamans. Analyse les statistiques hebdomadaires d’un bébé.
            Compare aux normes de l’OMS selon l’âge. Sois encourageante, ne pose jamais de diagnostic médical et ne recommande JAMAIS
            de réintroduire un aliment signalé comme allergène ou ayant provoqué une réaction.
            Réponds UNIQUEMENT par un objet JSON contenant exactement ces clés : \(jsonKeys).
            Chaque valeur est composée de 1 à 2 phrases chaleureuses en français. Pas de markdown, pas de clés supplémentaires, aucun texte hors du JSON.
            """
        case .chinese:
            return """
            你是一位温暖体贴的儿科助手，专为妈妈们服务。请分析宝宝的每周统计数据。
            与世卫组织的年龄标准对比。多给鼓励，绝不做医学诊断，并且绝不建议
            重新引入已被标记为过敏原或曾引起反应的食物。
            只回复一个 JSON 对象，且恰好包含这些键：\(jsonKeys)。
            每个值为 1–2 句温暖的中文。不要 markdown，不要多余的键，JSON 之外不要有任何文字。
            """
        }
    }

    static func user(ctx: WeeklyInsightContext) -> String {
        switch ctx.language {
        case .english: return build(ctx: ctx, l: .en)
        case .spanish: return build(ctx: ctx, l: .es)
        case .russian: return build(ctx: ctx, l: .ru)
        case .german:  return build(ctx: ctx, l: .de)
        case .french:  return build(ctx: ctx, l: .fr)
        case .portuguese: return build(ctx: ctx, l: .pt)
        case .chinese: return build(ctx: ctx, l: .zh)
        }
    }

    // MARK: - Builder

    private enum Loc { case en, ru, de, es, fr, pt, zh }

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
        case .es:
            lines.append("Edad del bebé: \(s.ageMonths) meses (\(s.ageWeeks) semanas).")
            if let leap { lines.append("Salto de desarrollo: \(leap).") }
            lines.append("OMS: objetivo de sueño total ≥ \(whoH)/día; ventana máxima de vigilia ~\(s.whoAwakeWindowMax) min.")
            lines.append("Sueño esta semana: media \(sleepH)/día (noche \(nightH), día \(dayH), \(naps) siestas/día), \(trend).")
            lines.append("Tomas esta semana: \(feeds)/día, \(s.totalFeedings) en total. Cambios de pañal: \(s.totalDiapers).")
            lines.append("Nuevos alimentos introducidos: \(foods). Alérgeno/reacción marcada: \(allergens).")
            lines.append("Devuelve JSON {\(jsonKeys)} comparando con las normas de la OMS, con una recomendación práctica en cada campo.")
        case .fr:
            lines.append("Âge du bébé : \(s.ageMonths) mois (\(s.ageWeeks) semaines).")
            if let leap { lines.append("Bond de développement : \(leap).") }
            lines.append("OMS : objectif de sommeil total ≥ \(whoH)/jour ; fenêtre d’éveil max. ~\(s.whoAwakeWindowMax) min.")
            lines.append("Sommeil cette semaine : moy. \(sleepH)/jour (nuit \(nightH), jour \(dayH), \(naps) siestes/jour), \(trend).")
            lines.append("Tétées cette semaine : \(feeds)/jour, \(s.totalFeedings) au total. Changes de couche : \(s.totalDiapers).")
            lines.append("Nouveaux aliments introduits : \(foods). Allergène/réaction signalé : \(allergens).")
            lines.append("Renvoie un JSON {\(jsonKeys)} comparant aux normes de l’OMS, avec une recommandation pratique pour chaque champ.")
        case .pt:
            lines.append("Idade do bebé: \(s.ageMonths) meses (\(s.ageWeeks) semanas).")
            if let leap { lines.append("Salto de desenvolvimento: \(leap).") }
            lines.append("OMS: objetivo de sono total ≥ \(whoH)/dia; janela máxima de vigília ~\(s.whoAwakeWindowMax) min.")
            lines.append("Sono esta semana: média \(sleepH)/dia (noite \(nightH), dia \(dayH), \(naps) sestas/dia), \(trend).")
            lines.append("Mamadas esta semana: \(feeds)/dia, \(s.totalFeedings) no total. Mudas de fralda: \(s.totalDiapers).")
            lines.append("Alimentos novos introduzidos: \(foods). Alergénio/reação assinalado: \(allergens).")
            lines.append("Devolve um JSON {\(jsonKeys)} comparando com as normas da OMS, com uma recomendação prática em cada campo.")
        case .zh:
            lines.append("宝宝年龄：\(s.ageMonths) 个月（\(s.ageWeeks) 周）。")
            if let leap { lines.append("发育猛长期：\(leap)。") }
            lines.append("世卫组织：每日总睡眠目标 ≥ \(whoH)；最长清醒时长约 \(s.whoAwakeWindowMax) 分钟。")
            lines.append("本周睡眠：平均 \(sleepH)/天（夜间 \(nightH)，白天 \(dayH)，每天 \(naps) 次小睡），\(trend)。")
            lines.append("本周喂养：\(feeds)/天，共 \(s.totalFeedings) 次。换尿布：\(s.totalDiapers) 次。")
            lines.append("引入的新食物：\(foods)。已标记过敏原/反应：\(allergens)。")
            lines.append("返回 JSON {\(jsonKeys)}，与世卫组织标准对比，每个字段给一条实用建议。")
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
        case .es:
            if absMin < 10 { return "aproximadamente igual que la semana pasada" }
            return delta > 0 ? "+\(absMin) min/día frente a la semana pasada" : "-\(absMin) min/día frente a la semana pasada"
        case .fr:
            if absMin < 10 { return "à peu près comme la semaine dernière" }
            return delta > 0 ? "+\(absMin) min/jour vs. semaine dernière" : "-\(absMin) min/jour vs. semaine dernière"
        case .pt:
            if absMin < 10 { return "praticamente igual à semana passada" }
            return delta > 0 ? "+\(absMin) min/dia vs. semana passada" : "-\(absMin) min/dia vs. semana passada"
        case .zh:
            if absMin < 10 { return "与上周大致相同" }
            return delta > 0 ? "比上周每天多 \(absMin) 分钟" : "比上周每天少 \(absMin) 分钟"
        }
    }
}
