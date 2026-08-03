import Foundation

/// Deterministic offline fallback. Builds a warm narrative purely from
/// `WeeklyStats` + the app's own age thresholds (`WhoNorms`), so a report is
/// always available without network. Those thresholds are in-house heuristics,
/// not WHO publications — never attribute them to WHO in user-facing copy.
final class StaticWeeklyInsightService: WeeklyInsightService {

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        let s = context.stats
        switch context.language {
        case .russian: return ru(s)
        case .german:  return de(s)
        case .spanish: return es(s)
        case .french:  return fr(s)
        case .portuguese: return pt(s)
        case .chinese: return zh(s)
        default:       return en(s)
        }
    }

    private func h(_ minutes: Int) -> String {
        let hh = minutes / 60, mm = minutes % 60
        if hh > 0 && mm > 0 { return "\(hh) ч \(mm) мин" }
        if hh > 0 { return "\(hh) ч" }
        return "\(mm) мин"
    }

    private func hEn(_ minutes: Int) -> String {
        let hh = minutes / 60, mm = minutes % 60
        if hh > 0 && mm > 0 { return "\(hh)h \(mm)m" }
        if hh > 0 { return "\(hh)h" }
        return "\(mm)m"
    }

    private func withLeapLine(_ base: String, _ s: WeeklyStats, language: Language) -> String {
        guard let leapID = s.currentLeapID, !s.leapSignals.isEmpty else { return base }
        let signals = s.leapSignals.joined(separator: ", ")
        let line: String
        switch language {
        case .english:
            line = " This week signs matched leap #\(leapID): \(signals)."
        case .russian:
            line = " На этой неделе признаки совпали со скачком #\(leapID): \(signals)."
        case .german:
            line = " Diese Woche passten die Zeichen zu Schub #\(leapID): \(signals)."
        case .spanish:
            line = " Esta semana las señales coincidieron con el salto #\(leapID): \(signals)."
        case .french:
            line = " Cette semaine, les signes correspondaient au bond #\(leapID) : \(signals)."
        case .portuguese:
            line = " Esta semana os sinais coincidiram com o salto #\(leapID): \(signals)."
        case .chinese:
            line = " 本周迹象与飞跃期 #\(leapID) 相符：\(signals)。"
        }
        return base + line
    }

    // MARK: - English (also es/pt fallback)

    private func en(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Sleep looks healthy for this age — keep the current rhythm."
            : "Try an earlier bedtime and watch wake windows (~\(s.whoAwakeWindowMax) min) to add rest."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty
            ? (s.ageMonths < 6 ? "milk only, as expected for this age" : "no new foods")
            : s.newFoodsIntroduced.joined(separator: ", ")
        // Age outranks the default advice: solids must never be suggested under 6
        // months. A flagged allergen outranks both.
        let feedingRec: String
        if !s.allergensFlagged.isEmpty {
            feedingRec = "Avoid re-introducing flagged foods (\(s.allergensFlagged.joined(separator: ", "))) and consult your pediatrician."
        } else if s.ageMonths < 6 {
            feedingRec = "At this age milk feeds are all baby needs — keep offering breast milk or formula on demand."
        } else {
            feedingRec = "Introduce one new food at a time and watch for reactions."
        }
        return WeeklyInsightAI(
            sleepSummary: "This week baby slept on average \(hEn(s.avgSleepMinutesPerDay)) per day (\(String(format: "%.1f", s.avgNapsPerDay)) naps). Typical for this age is ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Around \(feeds) feedings per day. New foods this week: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: withLeapLine("A steady week — \(hEn(s.avgSleepMinutesPerDay)) sleep/day and \(feeds) feedings/day. You're doing great.", s, language: .english)
        )
    }

    // MARK: - Russian

    private func ru(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Сон в норме для этого возраста — сохраняйте текущий режим."
            : "Попробуйте укладывать раньше и следите за окнами бодрствования (~\(s.whoAwakeWindowMax) мин)."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty
            ? (s.ageMonths < 6 ? "только молоко — это норма для возраста" : "новых продуктов не было")
            : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec: String
        if !s.allergensFlagged.isEmpty {
            feedingRec = "Не вводите повторно продукты с реакцией (\(s.allergensFlagged.joined(separator: ", "))) и проконсультируйтесь с педиатром."
        } else if s.ageMonths < 6 {
            feedingRec = "В этом возрасте достаточно молока — продолжайте кормить грудью или смесью по требованию."
        } else {
            feedingRec = "Вводите по одному новому продукту и следите за реакцией."
        }
        return WeeklyInsightAI(
            sleepSummary: "На этой неделе малыш спал в среднем \(h(s.avgSleepMinutesPerDay)) в сутки (\(String(format: "%.1f", s.avgNapsPerDay)) дневных снов). Обычно в этом возрасте ≥ \(h(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Около \(feeds) кормлений в сутки. Новые продукты за неделю: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: withLeapLine("Спокойная неделя — \(h(s.avgSleepMinutesPerDay)) сна в сутки и \(feeds) кормлений. Вы отлично справляетесь.", s, language: .russian)
        )
    }

    // MARK: - German

    private func de(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Der Schlaf ist für dieses Alter gesund — behalte den Rhythmus bei."
            : "Versuche eine frühere Schlafenszeit und beachte die Wachfenster (~\(s.whoAwakeWindowMax) Min.)."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty
            ? (s.ageMonths < 6 ? "nur Milch — in diesem Alter zu erwarten" : "keine neuen Lebensmittel")
            : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec: String
        if !s.allergensFlagged.isEmpty {
            feedingRec = "Führe markierte Lebensmittel (\(s.allergensFlagged.joined(separator: ", "))) nicht erneut ein und frage den Kinderarzt."
        } else if s.ageMonths < 6 {
            feedingRec = "In diesem Alter reichen Milchmahlzeiten — biete weiterhin Muttermilch oder Formula nach Bedarf an."
        } else {
            feedingRec = "Führe neue Lebensmittel einzeln ein und achte auf Reaktionen."
        }
        return WeeklyInsightAI(
            sleepSummary: "Diese Woche schlief das Baby Ø \(hEn(s.avgSleepMinutesPerDay)) pro Tag (\(String(format: "%.1f", s.avgNapsPerDay)) Schläfchen). Üblich in diesem Alter sind ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Etwa \(feeds) Mahlzeiten pro Tag. Neue Lebensmittel diese Woche: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: withLeapLine("Eine ruhige Woche — \(hEn(s.avgSleepMinutesPerDay)) Schlaf/Tag und \(feeds) Mahlzeiten/Tag. Du machst das toll.", s, language: .german)
        )
    }

    // MARK: - Spanish

    private func es(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "El sueño está saludable para esta edad: mantén el ritmo actual."
            : "Prueba una hora de dormir más temprana y observa las ventanas de vigilia (~\(s.whoAwakeWindowMax) min) para sumar descanso."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty
            ? (s.ageMonths < 6 ? "solo leche, como corresponde a esta edad" : "ningún alimento nuevo")
            : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec: String
        if !s.allergensFlagged.isEmpty {
            feedingRec = "Evita reintroducir los alimentos marcados (\(s.allergensFlagged.joined(separator: ", "))) y consulta con tu pediatra."
        } else if s.ageMonths < 6 {
            feedingRec = "A esta edad la leche es suficiente: sigue ofreciendo leche materna o fórmula a demanda."
        } else {
            feedingRec = "Introduce un alimento nuevo cada vez y observa posibles reacciones."
        }
        return WeeklyInsightAI(
            sleepSummary: "Esta semana el bebé durmió una media de \(hEn(s.avgSleepMinutesPerDay)) al día (\(String(format: "%.1f", s.avgNapsPerDay)) siestas). Lo habitual a esta edad es ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Unas \(feeds) tomas al día. Nuevos alimentos esta semana: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: withLeapLine("Una semana estable: \(hEn(s.avgSleepMinutesPerDay)) de sueño/día y \(feeds) tomas/día. Lo estás haciendo muy bien.", s, language: .spanish)
        )
    }

    // MARK: - French

    private func fr(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Le sommeil est sain pour cet âge — gardez le rythme actuel."
            : "Essayez un coucher plus tôt et surveillez les fenêtres d’éveil (~\(s.whoAwakeWindowMax) min) pour ajouter du repos."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty
            ? (s.ageMonths < 6 ? "uniquement du lait, comme il se doit à cet âge" : "aucun nouvel aliment")
            : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec: String
        if !s.allergensFlagged.isEmpty {
            feedingRec = "Évitez de réintroduire les aliments signalés (\(s.allergensFlagged.joined(separator: ", "))) et consultez votre pédiatre."
        } else if s.ageMonths < 6 {
            feedingRec = "À cet âge, le lait suffit — continuez à proposer le lait maternel ou la préparation à la demande."
        } else {
            feedingRec = "Introduisez un seul nouvel aliment à la fois et surveillez les réactions."
        }
        return WeeklyInsightAI(
            sleepSummary: "Cette semaine, bébé a dormi en moyenne \(hEn(s.avgSleepMinutesPerDay)) par jour (\(String(format: "%.1f", s.avgNapsPerDay)) siestes). À cet âge, on compte plutôt ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Environ \(feeds) tétées par jour. Nouveaux aliments cette semaine : \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: withLeapLine("Une semaine régulière — \(hEn(s.avgSleepMinutesPerDay)) de sommeil/jour et \(feeds) tétées/jour. Vous faites un travail formidable.", s, language: .french)
        )
    }

    // MARK: - Portuguese

    private func pt(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "O sono está saudável para esta idade — mantenha o ritmo atual."
            : "Experimente uma hora de deitar mais cedo e observe as janelas de sono (~\(s.whoAwakeWindowMax) min) para acrescentar descanso."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty
            ? (s.ageMonths < 6 ? "apenas leite, como é esperado nesta idade" : "nenhum alimento novo")
            : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec: String
        if !s.allergensFlagged.isEmpty {
            feedingRec = "Evite reintroduzir os alimentos assinalados (\(s.allergensFlagged.joined(separator: ", "))) e consulte o seu pediatra."
        } else if s.ageMonths < 6 {
            feedingRec = "Nesta idade o leite é suficiente — continue a oferecer leite materno ou fórmula em livre demanda."
        } else {
            feedingRec = "Introduza um novo alimento de cada vez e observe possíveis reações."
        }
        return WeeklyInsightAI(
            sleepSummary: "Esta semana o bebé dormiu em média \(hEn(s.avgSleepMinutesPerDay)) por dia (\(String(format: "%.1f", s.avgNapsPerDay)) sestas). O habitual nesta idade é ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Cerca de \(feeds) mamadas por dia. Alimentos novos esta semana: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: withLeapLine("Uma semana estável — \(hEn(s.avgSleepMinutesPerDay)) de sono/dia e \(feeds) mamadas/dia. Está a fazer um ótimo trabalho.", s, language: .portuguese)
        )
    }

    // MARK: - Chinese

    private func hZh(_ minutes: Int) -> String {
        let hh = minutes / 60, mm = minutes % 60
        if hh > 0 && mm > 0 { return "\(hh) 小时 \(mm) 分钟" }
        if hh > 0 { return "\(hh) 小时" }
        return "\(mm) 分钟"
    }

    private func zh(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "这个年龄段的睡眠很健康——保持现在的节奏即可。"
            : "试着早点哄睡，并留意清醒时长（约 \(s.whoAwakeWindowMax) 分钟），以增加休息。"
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty
            ? (s.ageMonths < 6 ? "只有奶——这个月龄本该如此" : "没有新食物")
            : s.newFoodsIntroduced.joined(separator: "、")
        let feedingRec: String
        if !s.allergensFlagged.isEmpty {
            feedingRec = "不要再次引入已标记的食物（\(s.allergensFlagged.joined(separator: "、"))），并咨询儿科医生。"
        } else if s.ageMonths < 6 {
            feedingRec = "这个月龄只需奶量——继续按需喂母乳或配方奶。"
        } else {
            feedingRec = "每次只引入一种新食物，并留意是否有反应。"
        }
        return WeeklyInsightAI(
            sleepSummary: "本周宝宝平均每天睡 \(hZh(s.avgSleepMinutesPerDay))（\(String(format: "%.1f", s.avgNapsPerDay)) 次小睡）。这个月龄通常需要 ≥ \(hZh(s.whoMinSleepMinutes))。",
            sleepRecommendation: sleepRec,
            feedingSummary: "每天约 \(feeds) 次喂养。本周的新食物：\(foods)。",
            feedingRecommendation: feedingRec,
            overallSummary: withLeapLine("平稳的一周——每天 \(hZh(s.avgSleepMinutesPerDay)) 睡眠、\(feeds) 次喂养。你做得很棒。", s, language: .chinese)
        )
    }
}
