import Foundation

/// Deterministic offline fallback. Builds an evidence-aware narrative from
/// `WeeklyStats` + WHO references, so a useful report remains available without Gemini.
final class StaticWeeklyInsightService: WeeklyInsightService {

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        switch context.language {
        case .russian: return russian(context.stats)
        case .german: return compact(context.stats, language: .german)
        case .spanish: return compact(context.stats, language: .spanish)
        case .french: return compact(context.stats, language: .french)
        case .portuguese: return compact(context.stats, language: .portuguese)
        case .chinese: return compact(context.stats, language: .chinese)
        default: return english(context.stats)
        }
    }

    private enum SleepComparison {
        case missing
        case below(minutes: Int)
        case within(aboveMinimum: Int, belowMaximum: Int)
        case above(minutes: Int)
    }

    private func sleepComparison(_ stats: WeeklyStats) -> SleepComparison {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: stats.ageMonths)
        let actual = stats.avgSleepMinutesPerDay
        guard actual > 0 else { return .missing }
        if actual < range.lowerBound { return .below(minutes: range.lowerBound - actual) }
        if actual > range.upperBound { return .above(minutes: actual - range.upperBound) }
        return .within(
            aboveMinimum: actual - range.lowerBound,
            belowMaximum: range.upperBound - actual
        )
    }

    private func decimal(_ value: Double) -> String {
        String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private func hoursEN(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours > 0 && remainder > 0 { return "\(hours)h \(remainder)m" }
        if hours > 0 { return "\(hours)h" }
        return "\(remainder)m"
    }

    private func hoursRU(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours > 0 && remainder > 0 { return "\(hours) ч \(remainder) мин" }
        if hours > 0 { return "\(hours) ч" }
        return "\(remainder) мин"
    }

    private func trendEN(_ minutes: Int) -> String {
        if abs(minutes) < 10 { return "The average is essentially unchanged from the previous week." }
        if minutes > 0 { return "That is \(minutes) minutes more sleep per day than the previous week." }
        return "That is \(abs(minutes)) minutes less sleep per day than the previous week."
    }

    private func trendRU(_ minutes: Int) -> String {
        if abs(minutes) < 10 { return "По сравнению с предыдущей неделей среднее почти не изменилось." }
        if minutes > 0 { return "Это на \(minutes) мин сна в сутки больше, чем неделей ранее." }
        return "Это на \(abs(minutes)) мин сна в сутки меньше, чем неделей ранее."
    }

    // MARK: - English

    private func english(_ stats: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: stats.ageMonths)
        let feeds = decimal(stats.avgFeedingsPerDay)
        let foods = stats.newFoodsIntroduced.isEmpty
            ? "No new foods were logged."
            : "New foods logged this week: \(stats.newFoodsIntroduced.joined(separator: ", "))."
        let reactions = stats.allergensFlagged.isEmpty
            ? "No allergen or reaction flags were recorded."
            : "Reaction or allergen flags were recorded for \(stats.allergensFlagged.joined(separator: ", "))."

        let sleepStatus: String
        let sleepRecommendation: String
        switch sleepComparison(stats) {
        case .missing:
            sleepStatus = "There is not enough sleep data to decide whether the baby's actual sleep was low or within range."
            sleepRecommendation = "Log every sleep start and stop for several consecutive days before interpreting the total. Check that overlapping sessions or forgotten stop times are not distorting the report. If sleep genuinely seems unusually short or the baby is difficult to wake, contact a pediatrician."
        case .below(let minutes):
            sleepStatus = "The logged average is below the lower end of the WHO range by \(hoursEN(minutes)) per day."
            sleepRecommendation = "First confirm that all naps and night sleep were logged, because missing sessions lower the average. If the logs are complete, try a consistent bedtime and use the app's approximate \(stats.whoAwakeWindowMax)-minute awake-window guide to avoid overtiredness. If the low pattern persists or the baby seems unwell, discuss it with a pediatrician."
        case .within(let aboveMinimum, let belowMaximum):
            sleepStatus = "The logged average is within the WHO range, \(hoursEN(aboveMinimum)) above its lower bound and \(hoursEN(belowMaximum)) below its upper bound."
            sleepRecommendation = "Keep the current sleep rhythm if the baby appears comfortable and alert while awake. Continue logging both naps and night sleep so week-to-week trends remain reliable. Treat the awake-window value of about \(stats.whoAwakeWindowMax) minutes as a planning estimate, not a strict medical rule."
        case .above(let minutes):
            sleepStatus = "The logged average is above the upper end of the WHO range by \(hoursEN(minutes)) per day."
            sleepRecommendation = "Check for overlapping sessions, duplicate logs, or timers that were stopped late. If the data is correct, watch the baby's usual alertness and feeding rather than trying to reduce sleep solely to match a number. Seek pediatric advice if unusually long sleep is new, persistent, or accompanied by difficulty waking or poor feeding."
        }

        let sleepSummary = [
            "This week the baby had \(hoursEN(stats.avgSleepMinutesPerDay)) of logged sleep per 24 hours on average.",
            "For this age, the WHO sleep range is \(hoursEN(range.lowerBound)) to \(hoursEN(range.upperBound)), including naps.",
            sleepStatus,
            "The logged split was \(hoursEN(stats.avgNightSleepMinutes)) at night and \(hoursEN(stats.avgDaySleepMinutes)) during the day, with about \(decimal(stats.avgNapsPerDay)) naps per day.",
            trendEN(stats.sleepTrendVsPrevWeekMinutes),
            "These values describe Momsy logs and may differ from the baby's true routine if tracking was incomplete."
        ].joined(separator: "\n\n")

        let feedingSummary: String
        let feedingRecommendation: String
        if stats.ageMonths < 6 {
            let interval = WhoNorms.maxFeedingInterval(ageMonths: stats.ageMonths)
            let heuristic = Int(ceil(1_440.0 / Double(interval)))
            let comparison: String
            if stats.avgFeedingsPerDay == 0 {
                comparison = "No milk feeds were logged, so the report cannot distinguish missing tracking from no feeding."
            } else if stats.avgFeedingsPerDay < Double(heuristic) {
                comparison = "The logged frequency is about \(decimal(Double(heuristic) - stats.avgFeedingsPerDay)) feeds per day below the app's reminder heuristic of roughly \(heuristic)+ feeds; this is not a WHO clinical intake target."
            } else {
                comparison = "The logged frequency is at or above the app's reminder heuristic of roughly \(heuristic)+ feeds per day; WHO guidance still favors responsive feeding rather than a fixed count."
            }
            feedingSummary = [
                "Momsy recorded an average of \(feeds) milk feeds per day, or \(stats.totalFeedings) feeds during the week.",
                "WHO breastfeeding guidance recommends feeding on demand, day and night, and does not set one universal feed count.",
                comparison,
                foods,
                reactions,
                "There were \(stats.totalDiapers) diaper logs, but the weekly total alone cannot prove hydration or adequate milk intake."
            ].joined(separator: "\n\n")
            feedingRecommendation = "Continue breast or formula feeding responsively and record feeds consistently if you want to compare weeks. Do not introduce solids or water solely because the logged count looks low before 6 months. If the low count reflects real feeding, wet diapers decrease, or the baby is unusually sleepy or hard to feed, contact a pediatrician."
        } else {
            let mealReference: String
            if let meals = WhoNorms.complementaryMealsPerDay(ageMonths: stats.ageMonths) {
                mealReference = "WHO suggests \(meals.lowerBound)-\(meals.upperBound) complementary meals per day at this age while milk feeding continues."
            } else {
                mealReference = "At this age, milk feeding can continue alongside a varied, age-appropriate family diet."
            }
            feedingSummary = [
                "Momsy recorded an average of \(feeds) milk feeds per day, or \(stats.totalFeedings) feeds during the week.",
                mealReference,
                "The food diary records introductions rather than every meal, so this report cannot classify complementary-meal frequency as low or normal.",
                foods,
                reactions,
                "There were \(stats.totalDiapers) diaper logs, but that total alone is not enough to judge hydration or intake."
            ].joined(separator: "\n\n")
            let allergenAction = stats.allergensFlagged.isEmpty
                ? "Introduce age-appropriate foods responsively and watch for reactions."
                : "Do not reintroduce the flagged foods without advice from the child's pediatrician."
            feedingRecommendation = "Continue milk feeding and offer age-appropriate complementary foods without forcing the child to eat. \(allergenAction) Log actual meals separately in the future if you want the report to compare meal frequency with WHO guidance."
        }

        let leap = leapSentence(stats, language: .english)
        let overall = "The main point this week is to interpret the sleep result together with logging completeness and the baby's usual behaviour. Feeding counts describe recorded events, not measured intake.\(leap) Keep tracking consistently and use the report as guidance rather than a diagnosis."

        return WeeklyInsightAI(
            sleepSummary: sleepSummary,
            sleepRecommendation: sleepRecommendation,
            feedingSummary: feedingSummary,
            feedingRecommendation: feedingRecommendation,
            overallSummary: overall
        )
    }

    // MARK: - Russian

    private func russian(_ stats: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: stats.ageMonths)
        let feeds = decimal(stats.avgFeedingsPerDay)
        let foods = stats.newFoodsIntroduced.isEmpty
            ? "Новые продукты на этой неделе не отмечены."
            : "За неделю отмечены новые продукты: \(stats.newFoodsIntroduced.joined(separator: ", "))."
        let reactions = stats.allergensFlagged.isEmpty
            ? "Отметок об аллергенах или реакциях нет."
            : "Реакция или аллерген отмечены для: \(stats.allergensFlagged.joined(separator: ", "))."

        let sleepStatus: String
        let sleepRecommendation: String
        switch sleepComparison(stats) {
        case .missing:
            sleepStatus = "Данных недостаточно, чтобы определить, был ли фактический сон малыша ниже нормы или находился в диапазоне."
            sleepRecommendation = "Несколько дней подряд отмечайте начало и окончание каждого сна. Проверьте, нет ли пересекающихся записей или таймеров, которые забыли остановить. Если малыш действительно спит необычно мало, выглядит вялым или его трудно разбудить, обратитесь к педиатру."
        case .below(let minutes):
            sleepStatus = "Среднее по записям ниже нижней границы диапазона ВОЗ на \(hoursRU(minutes)) в сутки."
            sleepRecommendation = "Сначала убедитесь, что записаны все дневные и ночные сны, потому что пропуски уменьшают среднее. Если записи полные, попробуйте стабильное время укладывания и используйте ориентир окна бодрствования около \(stats.whoAwakeWindowMax) мин, чтобы не допускать переутомления. Если низкое значение сохраняется или состояние малыша вызывает тревогу, обсудите это с педиатром."
        case .within(let aboveMinimum, let belowMaximum):
            sleepStatus = "Среднее находится в диапазоне ВОЗ: на \(hoursRU(aboveMinimum)) выше нижней границы и на \(hoursRU(belowMaximum)) ниже верхней."
            sleepRecommendation = "Сохраняйте текущий ритм, если малыш хорошо себя чувствует и активен во время бодрствования. Продолжайте записывать и дневной, и ночной сон, чтобы сравнение недель было надёжным. Окно бодрствования около \(stats.whoAwakeWindowMax) мин — это ориентир приложения, а не строгая медицинская норма."
        case .above(let minutes):
            sleepStatus = "Среднее по записям выше верхней границы диапазона ВОЗ на \(hoursRU(minutes)) в сутки."
            sleepRecommendation = "Проверьте дубли, пересекающиеся сессии и таймеры, которые остановили позже фактического пробуждения. Если данные верны, оценивайте обычную активность и кормление малыша, а не пытайтесь специально сокращать сон ради цифры. Обратитесь к педиатру, если длительный сон появился внезапно, сохраняется или малыша трудно разбудить и накормить."
        }

        let sleepSummary = [
            "На этой неделе в Momsy записано в среднем \(hoursRU(stats.avgSleepMinutesPerDay)) сна за 24 часа.",
            "Для этого возраста диапазон ВОЗ составляет \(hoursRU(range.lowerBound))–\(hoursRU(range.upperBound)) в сутки с учётом дневных снов.",
            sleepStatus,
            "Из них в среднем \(hoursRU(stats.avgNightSleepMinutes)) приходилось на ночь и \(hoursRU(stats.avgDaySleepMinutes)) на день; дневных снов было около \(decimal(stats.avgNapsPerDay)) в сутки.",
            trendRU(stats.sleepTrendVsPrevWeekMinutes),
            "Это анализ записей Momsy: при неполном учёте фактический режим малыша может отличаться."
        ].joined(separator: "\n\n")

        let feedingSummary: String
        let feedingRecommendation: String
        if stats.ageMonths < 6 {
            let interval = WhoNorms.maxFeedingInterval(ageMonths: stats.ageMonths)
            let heuristic = Int(ceil(1_440.0 / Double(interval)))
            let comparison: String
            if stats.avgFeedingsPerDay == 0 {
                comparison = "Кормления не записаны, поэтому невозможно отличить отсутствие данных от отсутствия кормлений."
            } else if stats.avgFeedingsPerDay < Double(heuristic) {
                comparison = "Записанная частота примерно на \(decimal(Double(heuristic) - stats.avgFeedingsPerDay)) кормления в сутки ниже внутреннего ориентира приложения около \(heuristic)+; это не клиническая норма ВОЗ."
            } else {
                comparison = "Записанная частота соответствует или превышает внутренний ориентир приложения около \(heuristic)+ кормлений, но ВОЗ рекомендует ориентироваться на сигналы ребёнка, а не на фиксированное число."
            }
            feedingSummary = [
                "В Momsy записано в среднем \(feeds) молочных кормления в сутки, всего \(stats.totalFeedings) за неделю.",
                "Рекомендации ВОЗ по грудному вскармливанию предполагают кормление по требованию днём и ночью и не задают единого числа кормлений для всех детей.",
                comparison,
                foods,
                reactions,
                "За неделю записано \(stats.totalDiapers) смен подгузника, но одно общее число не позволяет оценить гидратацию или достаточность питания."
            ].joined(separator: "\n\n")
            feedingRecommendation = "Продолжайте кормить грудным молоком или смесью с учётом сигналов малыша и записывайте кормления последовательно. До 6 месяцев не вводите прикорм или воду только из-за низкого числа в отчёте. Если низкая частота реальна, стало меньше мокрых подгузников, малыш слишком сонлив или плохо ест, обратитесь к педиатру."
        } else {
            let mealReference: String
            if let meals = WhoNorms.complementaryMealsPerDay(ageMonths: stats.ageMonths) {
                mealReference = "Для этого возраста ВОЗ рекомендует \(meals.lowerBound)–\(meals.upperBound) приёма прикорма в день при продолжении молочного кормления."
            } else {
                mealReference = "В этом возрасте молочное кормление может продолжаться вместе с разнообразной пищей, подходящей ребёнку."
            }
            feedingSummary = [
                "В Momsy записано в среднем \(feeds) молочных кормления в сутки, всего \(stats.totalFeedings) за неделю.",
                mealReference,
                "Дневник продуктов фиксирует знакомства с продуктами, а не каждый приём пищи, поэтому по этим данным нельзя назвать частоту прикорма низкой или нормальной.",
                foods,
                reactions,
                "За неделю записано \(stats.totalDiapers) смен подгузника, но этого числа недостаточно для оценки гидратации или объёма питания."
            ].joined(separator: "\n\n")
            let allergenAction = stats.allergensFlagged.isEmpty
                ? "Предлагайте подходящие по возрасту продукты без давления и наблюдайте за реакцией."
                : "Не предлагайте повторно отмеченные продукты без консультации с педиатром."
            feedingRecommendation = "Продолжайте молочное кормление и предлагайте прикорм с учётом сигналов голода и насыщения малыша. \(allergenAction) Для будущего точного сравнения с рекомендациями ВОЗ потребуется отдельно отмечать каждый полноценный приём прикорма."
        }

        let leap = leapSentence(stats, language: .russian)
        let overall = "Главное на этой неделе — оценивать результат сна вместе с полнотой записей и обычным самочувствием малыша. Число кормлений показывает события в дневнике, а не измеренный объём питания.\(leap) Продолжайте вести записи последовательно и воспринимайте отчёт как подсказку, а не диагноз."

        return WeeklyInsightAI(
            sleepSummary: sleepSummary,
            sleepRecommendation: sleepRecommendation,
            feedingSummary: feedingSummary,
            feedingRecommendation: feedingRecommendation,
            overallSummary: overall
        )
    }

    // MARK: - Other localized fallbacks

    private func compact(_ stats: WeeklyStats, language: Language) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: stats.ageMonths)
        let actual = hoursEN(stats.avgSleepMinutesPerDay)
        let min = hoursEN(range.lowerBound)
        let max = hoursEN(range.upperBound)
        let feeds = decimal(stats.avgFeedingsPerDay)
        let status: String
        switch sleepComparison(stats) {
        case .missing: status = localized("Sleep data is incomplete.", "Schlafdaten sind unvollständig.", "Los datos de sueño están incompletos.", "Les données de sommeil sont incomplètes.", "Os dados de sono estão incompletos.", "睡眠记录不完整。", language)
        case .below(let delta): status = localized("This is \(hoursEN(delta)) below the range.", "Das liegt \(hoursEN(delta)) unter dem Bereich.", "Está \(hoursEN(delta)) por debajo del rango.", "C'est \(hoursEN(delta)) sous la plage.", "Está \(hoursEN(delta)) abaixo do intervalo.", "比建议范围低 \(hoursEN(delta))。", language)
        case .within: status = localized("This is within the range.", "Das liegt im Bereich.", "Está dentro del rango.", "C'est dans la plage.", "Está dentro do intervalo.", "处于建议范围内。", language)
        case .above(let delta): status = localized("This is \(hoursEN(delta)) above the range; check the logs.", "Das liegt \(hoursEN(delta)) über dem Bereich; prüfe die Einträge.", "Está \(hoursEN(delta)) por encima; revisa los registros.", "C'est \(hoursEN(delta)) au-dessus; vérifiez les saisies.", "Está \(hoursEN(delta)) acima; verifique os registos.", "比建议范围高 \(hoursEN(delta))，请检查记录。", language)
        }
        let sleepSummary = localized(
            "Average logged sleep was \(actual) per day. WHO range: \(min)-\(max), including naps. \(status) Night/day split and tracking completeness should be considered before drawing conclusions.",
            "Der protokollierte Schlaf lag bei \(actual) pro Tag. WHO-Bereich: \(min)-\(max) einschließlich Nickerchen. \(status) Vor Schlussfolgerungen sollten Tag/Nacht-Verteilung und Vollständigkeit geprüft werden.",
            "El sueño registrado fue de \(actual) al día. Rango de la OMS: \(min)-\(max), incluidas las siestas. \(status) Hay que considerar el reparto día/noche y la calidad del registro.",
            "Le sommeil enregistré était de \(actual) par jour. Plage OMS : \(min)-\(max), siestes comprises. \(status) Il faut tenir compte de la répartition jour/nuit et de la qualité du suivi.",
            "O sono registado foi de \(actual) por dia. Intervalo da OMS: \(min)-\(max), incluindo sestas. \(status) Considere a divisão dia/noite e a qualidade do registo.",
            "平均记录睡眠为每天 \(actual)。世卫组织范围为 \(min)-\(max)，包括小睡。\(status) 解读前还应考虑昼夜分布和记录完整性。",
            language
        )
        let sleepRecommendation = localized(
            "Check that every sleep session was recorded and that timers did not overlap. Use the awake-window estimate as a flexible guide, not a medical rule. Contact a pediatrician if a concerning pattern is real and persistent.",
            "Prüfe, ob alle Schlafphasen vollständig und ohne Überschneidung erfasst wurden. Nutze Wachfenster nur als flexiblen Richtwert. Bei einem echten, anhaltenden auffälligen Muster den Kinderarzt fragen.",
            "Comprueba que todas las sesiones estén registradas y sin solapamientos. Usa las ventanas de vigilia como guía flexible. Consulta al pediatra si el patrón preocupante es real y persistente.",
            "Vérifiez que toutes les périodes sont enregistrées sans chevauchement. Utilisez les fenêtres d'éveil comme repère souple. Consultez le pédiatre si le schéma préoccupant est réel et persistant.",
            "Confirme que todas as sessões foram registadas sem sobreposição. Use as janelas de vigília como orientação flexível. Consulte o pediatra se o padrão preocupante for real e persistente.",
            "请确认所有睡眠都已记录且计时没有重叠。清醒时长仅作灵活参考。若异常模式真实且持续，请咨询儿科医生。",
            language
        )
        let feedingSummary = localized(
            "Momsy logged \(feeds) milk feeds per day and \(stats.totalFeedings) for the week. Logged events do not measure milk volume. Food-diary entries are not a complete meal count, and \(stats.totalDiapers) diaper logs alone cannot prove hydration.",
            "Momsy erfasste \(feeds) Milchmahlzeiten pro Tag und \(stats.totalFeedings) in der Woche. Einträge messen keine Milchmenge. Das Ernährungstagebuch ist keine vollständige Mahlzeitenzählung und \(stats.totalDiapers) Windeleinträge beweisen keine ausreichende Flüssigkeit.",
            "Momsy registró \(feeds) tomas de leche al día y \(stats.totalFeedings) en la semana. Los registros no miden el volumen de leche. El diario de alimentos no cuenta todas las comidas y \(stats.totalDiapers) pañales no demuestran hidratación.",
            "Momsy a enregistré \(feeds) tétées par jour et \(stats.totalFeedings) sur la semaine. Les saisies ne mesurent pas le volume de lait. Le journal alimentaire ne compte pas tous les repas et \(stats.totalDiapers) couches ne prouvent pas l'hydratation.",
            "A Momsy registou \(feeds) mamadas por dia e \(stats.totalFeedings) na semana. Os registos não medem o volume de leite. O diário alimentar não conta todas as refeições e \(stats.totalDiapers) fraldas não comprovam hidratação.",
            "Momsy 记录了每天 \(feeds) 次奶喂养，本周共 \(stats.totalFeedings) 次。记录不能测量奶量，食物日记也不是完整餐次；仅凭 \(stats.totalDiapers) 次尿布记录不能判断水分是否充足。",
            language
        )
        let feedingRecommendation = stats.ageMonths < 6
            ? localized("Feed responsively and do not add solids or water solely because a logged count looks low. Verify tracking and contact a pediatrician if the low pattern is real.", "Nach Bedarf füttern und nicht nur wegen einer niedrigen Zahl Beikost oder Wasser geben. Einträge prüfen und bei einem echten niedrigen Muster den Kinderarzt fragen.", "Alimenta según las señales y no añadas sólidos o agua solo por un recuento bajo. Verifica el registro y consulta al pediatra si el patrón es real.", "Nourrissez selon les signaux et n'ajoutez pas de solides ou d'eau uniquement pour un nombre bas. Vérifiez le suivi et consultez si le schéma est réel.", "Alimente de forma responsiva e não introduza sólidos ou água apenas por uma contagem baixa. Verifique os registos e consulte o pediatra se for real.", "按宝宝信号喂养，不要仅因记录次数低就添加辅食或水。先核对记录；若确实持续偏低，请咨询儿科医生。", language)
            : localized("Continue milk feeding and offer age-appropriate complementary foods responsively. Do not reintroduce any flagged food without pediatric advice.", "Milchfütterung fortsetzen und altersgerechte Beikost responsiv anbieten. Markierte Lebensmittel nicht ohne ärztlichen Rat erneut geben.", "Continúa la leche y ofrece alimentos complementarios apropiados sin forzar. No reintroduzcas alimentos marcados sin consejo pediátrico.", "Poursuivez le lait et proposez des aliments adaptés sans forcer. Ne réintroduisez pas un aliment signalé sans avis pédiatrique.", "Continue o leite e ofereça alimentos adequados sem forçar. Não reintroduza alimentos assinalados sem orientação pediátrica.", "继续奶喂养并根据宝宝信号提供适龄辅食。未经儿科医生建议，不要再次提供已标记食物。", language)
        let overall = localized("Use the report as a clear summary of logged patterns, not a diagnosis.", "Nutze den Bericht als Zusammenfassung der Einträge, nicht als Diagnose.", "Usa el informe como resumen de los registros, no como diagnóstico.", "Utilisez le rapport comme résumé des saisies, pas comme diagnostic.", "Use o relatório como resumo dos registos, não como diagnóstico.", "请把报告作为记录趋势的总结，而不是诊断。", language) + leapSentence(stats, language: language)
        return WeeklyInsightAI(sleepSummary: sleepSummary, sleepRecommendation: sleepRecommendation, feedingSummary: feedingSummary, feedingRecommendation: feedingRecommendation, overallSummary: overall)
    }

    private func leapSentence(_ stats: WeeklyStats, language: Language) -> String {
        guard let leapID = stats.currentLeapID, !stats.leapSignals.isEmpty else { return "" }
        let signals = stats.leapSignals.joined(separator: ", ")
        switch language {
        case .english: return " This week the logged signs overlapped with leap #\(leapID): \(signals), without proving that the leap caused them."
        case .russian: return " На этой неделе отмеченные признаки совпали со скачком №\(leapID): \(signals), но это не доказывает причинную связь."
        case .german: return " Die erfassten Zeichen überschnitten sich mit Schub #\(leapID): \(signals), ohne eine Ursache zu beweisen."
        case .spanish: return " Las señales coincidieron con el salto #\(leapID): \(signals), sin demostrar causalidad."
        case .french: return " Les signes coïncidaient avec le bond #\(leapID) : \(signals), sans prouver un lien causal."
        case .portuguese: return " Os sinais coincidiram com o salto #\(leapID): \(signals), sem provar causalidade."
        case .chinese: return " 本周记录的迹象与飞跃期 #\(leapID) 重合：\(signals)，但这不能证明因果关系。"
        }
    }

    private func localized(
        _ en: String,
        _ de: String,
        _ es: String,
        _ fr: String,
        _ pt: String,
        _ zh: String,
        _ language: Language
    ) -> String {
        switch language {
        case .german: return de
        case .spanish: return es
        case .french: return fr
        case .portuguese: return pt
        case .chinese: return zh
        default: return en
        }
    }
}
