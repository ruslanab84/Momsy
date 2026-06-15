import Foundation

/// Deterministic offline fallback. Builds a warm narrative purely from
/// `WeeklyStats` + WHO norms, so a report is always available without network.
final class StaticWeeklyInsightService: WeeklyInsightService {

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        let s = context.stats
        switch context.language {
        case .russian: return ru(s)
        case .german:  return de(s)
        case .french:  return fr(s)
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

    // MARK: - English (also es/pt fallback)

    private func en(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Sleep looks healthy for this age — keep the current rhythm."
            : "Try an earlier bedtime and watch wake windows (~\(s.whoAwakeWindowMax) min) to add rest."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty ? "no new foods" : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec = s.allergensFlagged.isEmpty
            ? "Introduce one new food at a time and watch for reactions."
            : "Avoid re-introducing flagged foods (\(s.allergensFlagged.joined(separator: ", "))) and consult your pediatrician."
        return WeeklyInsightAI(
            sleepSummary: "This week baby slept on average \(hEn(s.avgSleepMinutesPerDay)) per day (\(String(format: "%.1f", s.avgNapsPerDay)) naps). WHO suggests ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Around \(feeds) feedings per day. New foods this week: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: "A steady week — \(hEn(s.avgSleepMinutesPerDay)) sleep/day and \(feeds) feedings/day. You're doing great."
        )
    }

    // MARK: - Russian

    private func ru(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Сон в норме для этого возраста — сохраняйте текущий режим."
            : "Попробуйте укладывать раньше и следите за окнами бодрствования (~\(s.whoAwakeWindowMax) мин)."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty ? "новых продуктов не было" : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec = s.allergensFlagged.isEmpty
            ? "Вводите по одному новому продукту и следите за реакцией."
            : "Не вводите повторно продукты с реакцией (\(s.allergensFlagged.joined(separator: ", "))) и проконсультируйтесь с педиатром."
        return WeeklyInsightAI(
            sleepSummary: "На этой неделе малыш спал в среднем \(h(s.avgSleepMinutesPerDay)) в сутки (\(String(format: "%.1f", s.avgNapsPerDay)) дневных снов). ВОЗ рекомендует ≥ \(h(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Около \(feeds) кормлений в сутки. Новые продукты за неделю: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: "Спокойная неделя — \(h(s.avgSleepMinutesPerDay)) сна в сутки и \(feeds) кормлений. Вы отлично справляетесь."
        )
    }

    // MARK: - German

    private func de(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Der Schlaf ist für dieses Alter gesund — behalte den Rhythmus bei."
            : "Versuche eine frühere Schlafenszeit und beachte die Wachfenster (~\(s.whoAwakeWindowMax) Min.)."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty ? "keine neuen Lebensmittel" : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec = s.allergensFlagged.isEmpty
            ? "Führe neue Lebensmittel einzeln ein und achte auf Reaktionen."
            : "Führe markierte Lebensmittel (\(s.allergensFlagged.joined(separator: ", "))) nicht erneut ein und frage den Kinderarzt."
        return WeeklyInsightAI(
            sleepSummary: "Diese Woche schlief das Baby Ø \(hEn(s.avgSleepMinutesPerDay)) pro Tag (\(String(format: "%.1f", s.avgNapsPerDay)) Schläfchen). WHO empfiehlt ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Etwa \(feeds) Mahlzeiten pro Tag. Neue Lebensmittel diese Woche: \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: "Eine ruhige Woche — \(hEn(s.avgSleepMinutesPerDay)) Schlaf/Tag und \(feeds) Mahlzeiten/Tag. Du machst das toll."
        )
    }

    // MARK: - French

    private func fr(_ s: WeeklyStats) -> WeeklyInsightAI {
        let enough = s.avgSleepMinutesPerDay >= s.whoMinSleepMinutes
        let sleepRec = enough
            ? "Le sommeil est sain pour cet âge — gardez le rythme actuel."
            : "Essayez un coucher plus tôt et surveillez les fenêtres d’éveil (~\(s.whoAwakeWindowMax) min) pour ajouter du repos."
        let feeds = String(format: "%.1f", s.avgFeedingsPerDay)
        let foods = s.newFoodsIntroduced.isEmpty ? "aucun nouvel aliment" : s.newFoodsIntroduced.joined(separator: ", ")
        let feedingRec = s.allergensFlagged.isEmpty
            ? "Introduisez un seul nouvel aliment à la fois et surveillez les réactions."
            : "Évitez de réintroduire les aliments signalés (\(s.allergensFlagged.joined(separator: ", "))) et consultez votre pédiatre."
        return WeeklyInsightAI(
            sleepSummary: "Cette semaine, bébé a dormi en moyenne \(hEn(s.avgSleepMinutesPerDay)) par jour (\(String(format: "%.1f", s.avgNapsPerDay)) siestes). L’OMS recommande ≥ \(hEn(s.whoMinSleepMinutes)).",
            sleepRecommendation: sleepRec,
            feedingSummary: "Environ \(feeds) tétées par jour. Nouveaux aliments cette semaine : \(foods).",
            feedingRecommendation: feedingRec,
            overallSummary: "Une semaine régulière — \(hEn(s.avgSleepMinutesPerDay)) de sommeil/jour et \(feeds) tétées/jour. Vous faites un travail formidable."
        )
    }
}
