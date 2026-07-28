import Foundation

/// Deterministic offline fallback. It mirrors the evidence rules used by Gemini so the
/// report remains detailed, age-aware, and honest when the network or model is unavailable.
final class StaticWeeklyInsightService: WeeklyInsightService {

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        makeReport(stats: context.stats, language: context.language)
    }

    private enum SleepAssessment {
        case noData
        case below(minutes: Int)
        case within
        case above(minutes: Int)
    }

    private func makeReport(stats s: WeeklyStats, language: Language) -> WeeklyInsightAI {
        let sleepRange = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let sleepStatus = sleepAssessment(s, range: sleepRange)
        let feeds = decimal(s.avgFeedingsPerDay)
        let sleepRangeText = "\(duration(sleepRange.lowerBound, language))-\(duration(sleepRange.upperBound, language))"

        let sleepSummary = [
            tr(language,
               "Momsy recorded an average of \(duration(s.avgSleepMinutesPerDay, language)) of sleep per day.",
               "Momsy зафиксировал в среднем \(duration(s.avgSleepMinutesPerDay, language)) сна в сутки.",
               "Momsy erfasste durchschnittlich \(duration(s.avgSleepMinutesPerDay, language)) Schlaf pro Tag.",
               "Momsy registró una media de \(duration(s.avgSleepMinutesPerDay, language)) de sueño al día.",
               "Momsy a enregistré en moyenne \(duration(s.avgSleepMinutesPerDay, language)) de sommeil par jour.",
               "A Momsy registou em média \(duration(s.avgSleepMinutesPerDay, language)) de sono por dia.",
               "Momsy记录的平均睡眠为每天\(duration(s.avgSleepMinutesPerDay, language))。"),
            tr(language,
               "The WHO range for this age is \(sleepRangeText) in 24 hours, including naps.",
               "Диапазон ВОЗ для этого возраста составляет \(sleepRangeText) за 24 часа вместе с дневными снами.",
               "Der WHO-Bereich für dieses Alter beträgt \(sleepRangeText) in 24 Stunden einschließlich Nickerchen.",
               "El rango de la OMS para esta edad es de \(sleepRangeText) en 24 horas, incluidas las siestas.",
               "La plage de l’OMS pour cet âge est de \(sleepRangeText) sur 24 heures, siestes comprises.",
               "O intervalo da OMS para esta idade é de \(sleepRangeText) em 24 horas, incluindo sestas.",
               "该年龄世卫组织建议的24小时总睡眠范围为\(sleepRangeText)，包括小睡。"),
            sleepStatusText(sleepStatus, language: language),
            tr(language,
               "The logged split was \(duration(s.avgNightSleepMinutes, language)) at night and \(duration(s.avgDaySleepMinutes, language)) during the day, with \(decimal(s.avgNapsPerDay)) naps per day.",
               "По журналу это \(duration(s.avgNightSleepMinutes, language)) ночью и \(duration(s.avgDaySleepMinutes, language)) днём, в среднем \(decimal(s.avgNapsPerDay)) дневных снов.",
               "Davon entfielen \(duration(s.avgNightSleepMinutes, language)) auf die Nacht und \(duration(s.avgDaySleepMinutes, language)) auf den Tag, bei \(decimal(s.avgNapsPerDay)) Nickerchen täglich.",
               "El reparto registrado fue de \(duration(s.avgNightSleepMinutes, language)) por la noche y \(duration(s.avgDaySleepMinutes, language)) durante el día, con \(decimal(s.avgNapsPerDay)) siestas diarias.",
               "La répartition enregistrée était de \(duration(s.avgNightSleepMinutes, language)) la nuit et \(duration(s.avgDaySleepMinutes, language)) le jour, avec \(decimal(s.avgNapsPerDay)) siestes quotidiennes.",
               "O registo mostra \(duration(s.avgNightSleepMinutes, language)) à noite e \(duration(s.avgDaySleepMinutes, language)) durante o dia, com \(decimal(s.avgNapsPerDay)) sestas por dia.",
               "记录中夜间睡眠为\(duration(s.avgNightSleepMinutes, language))，白天为\(duration(s.avgDaySleepMinutes, language))，平均每天\(decimal(s.avgNapsPerDay))次小睡。"),
            sleepTrendAndLoggingNote(s, language: language)
        ].joined(separator: " ")

        let sleepRecommendation = sleepRecommendationText(s, assessment: sleepStatus, language: language)

        let feedingSummary = [
            tr(language,
               "Momsy recorded \(feeds) milk feeds per day and \(s.totalFeedings) feeds in total this week.",
               "В Momsy записано в среднем \(feeds) молочных кормлений в сутки и \(s.totalFeedings) кормлений за неделю.",
               "Momsy erfasste \(feeds) Milchmahlzeiten pro Tag und insgesamt \(s.totalFeedings) in dieser Woche.",
               "Momsy registró \(feeds) tomas de leche al día y \(s.totalFeedings) en total durante la semana.",
               "Momsy a enregistré \(feeds) tétées ou biberons par jour et \(s.totalFeedings) au total cette semaine.",
               "A Momsy registou \(feeds) mamadas por dia e \(s.totalFeedings) no total da semana.",
               "Momsy本周记录平均每天\(feeds)次奶类喂养，共\(s.totalFeedings)次。"),
            feedingReferenceText(s, language: language),
            feedingComparisonText(s, language: language),
            foodAndReactionText(s, language: language),
            diaperCaveatText(s, language: language)
        ].joined(separator: " ")

        let feedingRecommendation = feedingRecommendationText(s, language: language)
        let overall = overallText(s, language: language)

        return WeeklyInsightAI(
            sleepSummary: sleepSummary,
            sleepRecommendation: sleepRecommendation,
            feedingSummary: feedingSummary,
            feedingRecommendation: feedingRecommendation,
            overallSummary: overall
        )
    }

    private func sleepAssessment(_ s: WeeklyStats, range: ClosedRange<Int>) -> SleepAssessment {
        guard s.avgSleepMinutesPerDay > 0 else { return .noData }
        if s.avgSleepMinutesPerDay < range.lowerBound {
            return .below(minutes: range.lowerBound - s.avgSleepMinutesPerDay)
        }
        if s.avgSleepMinutesPerDay > range.upperBound {
            return .above(minutes: s.avgSleepMinutesPerDay - range.upperBound)
        }
        return .within
    }

    private func sleepStatusText(_ assessment: SleepAssessment, language: Language) -> String {
        switch assessment {
        case .noData:
            return tr(language,
                      "No sleep duration was logged, so the app cannot classify the baby’s true sleep.",
                      "Продолжительность сна не записана, поэтому приложение не может оценить реальный сон малыша.",
                      "Es wurde keine Schlafdauer erfasst, daher kann der tatsächliche Schlaf nicht eingeordnet werden.",
                      "No se registró duración de sueño, por lo que no puede clasificarse el sueño real del bebé.",
                      "Aucune durée de sommeil n’a été enregistrée, donc le sommeil réel ne peut pas être classé.",
                      "Não foi registada duração de sono, por isso o sono real do bebé não pode ser classificado.",
                      "没有记录睡眠时长，因此应用无法判断宝宝的真实睡眠。")
        case .below(let minutes):
            return tr(language,
                      "The logged average is below the lower WHO bound by \(duration(minutes, language)) per day.",
                      "Среднее значение по журналу ниже нижней границы ВОЗ на \(duration(minutes, language)) в сутки.",
                      "Der protokollierte Durchschnitt liegt \(duration(minutes, language)) pro Tag unter der WHO-Untergrenze.",
                      "El promedio registrado está \(duration(minutes, language)) al día por debajo del límite inferior de la OMS.",
                      "La moyenne enregistrée est inférieure de \(duration(minutes, language)) par jour à la limite basse de l’OMS.",
                      "A média registada está \(duration(minutes, language)) por dia abaixo do limite inferior da OMS.",
                      "记录值每天比世卫组织下限少\(duration(minutes, language))。")
        case .within:
            return tr(language,
                      "The logged average is within the WHO range for this age.",
                      "Среднее значение по журналу находится в диапазоне ВОЗ для этого возраста.",
                      "Der protokollierte Durchschnitt liegt im WHO-Bereich für dieses Alter.",
                      "El promedio registrado está dentro del rango de la OMS para esta edad.",
                      "La moyenne enregistrée se situe dans la plage de l’OMS pour cet âge.",
                      "A média registada está dentro do intervalo da OMS para esta idade.",
                      "记录的平均睡眠位于该年龄的世卫组织建议范围内。")
        case .above(let minutes):
            return tr(language,
                      "The logged average is above the upper WHO bound by \(duration(minutes, language)) per day.",
                      "Среднее значение по журналу выше верхней границы ВОЗ на \(duration(minutes, language)) в сутки.",
                      "Der protokollierte Durchschnitt liegt \(duration(minutes, language)) pro Tag über der WHO-Obergrenze.",
                      "El promedio registrado está \(duration(minutes, language)) al día por encima del límite superior de la OMS.",
                      "La moyenne enregistrée dépasse de \(duration(minutes, language)) par jour la limite haute de l’OMS.",
                      "A média registada está \(duration(minutes, language)) por dia acima do limite superior da OMS.",
                      "记录值每天比世卫组织上限多\(duration(minutes, language))。")
        }
    }

    private func sleepTrendAndLoggingNote(_ s: WeeklyStats, language: Language) -> String {
        let delta = s.sleepTrendVsPrevWeekMinutes
        let trend: String
        if abs(delta) < 10 {
            trend = tr(language, "about the same", "примерно без изменений", "ungefähr gleich", "prácticamente igual", "à peu près identique", "praticamente igual", "基本不变")
        } else if delta > 0 {
            trend = tr(language, "\(delta) minutes more", "на \(delta) минут больше", "\(delta) Minuten mehr", "\(delta) minutos más", "\(delta) minutes de plus", "mais \(delta) minutos", "多\(delta)分钟")
        } else {
            trend = tr(language, "\(abs(delta)) minutes less", "на \(abs(delta)) минут меньше", "\(abs(delta)) Minuten weniger", "\(abs(delta)) minutos menos", "\(abs(delta)) minutes de moins", "menos \(abs(delta)) minutos", "少\(abs(delta))分钟")
        }
        return tr(language,
                  "Compared with last week, the daily average was \(trend); incomplete or overlapping timers can distort this comparison.",
                  "По сравнению с прошлой неделей среднее за сутки было \(trend); пропущенные или пересекающиеся таймеры могут исказить сравнение.",
                  "Gegenüber der Vorwoche war der Tagesdurchschnitt \(trend); unvollständige oder überlappende Timer können den Vergleich verzerren.",
                  "Frente a la semana anterior, el promedio diario fue \(trend); los temporizadores incompletos o solapados pueden alterar la comparación.",
                  "Par rapport à la semaine précédente, la moyenne quotidienne était \(trend); des minuteurs incomplets ou superposés peuvent fausser la comparaison.",
                  "Em comparação com a semana anterior, a média diária ficou \(trend); temporizadores incompletos ou sobrepostos podem distorcer a comparação.",
                  "与上周相比，每日平均睡眠\(trend)；漏记或重叠计时可能影响比较。")
    }

    private func sleepRecommendationText(_ s: WeeklyStats, assessment: SleepAssessment, language: Language) -> String {
        let verify = tr(language,
                        "First verify that overnight sleep and every nap were logged completely.",
                        "Сначала проверьте, полностью ли записаны ночной сон и все дневные сны.",
                        "Prüfen Sie zuerst, ob Nachtschlaf und alle Nickerchen vollständig erfasst wurden.",
                        "Comprueba primero que el sueño nocturno y todas las siestas se hayan registrado por completo.",
                        "Vérifiez d’abord que le sommeil nocturne et toutes les siestes ont été entièrement enregistrés.",
                        "Confirme primeiro se o sono noturno e todas as sestas foram registados por completo.",
                        "先确认夜间睡眠和所有小睡是否完整记录。")
        let routine = tr(language,
                         "Keep a calm, predictable routine and use the app’s awake-window estimate of about \(s.whoAwakeWindowMax) minutes only as a flexible planning guide.",
                         "Сохраняйте спокойный предсказуемый режим, а ориентир окна бодрствования около \(s.whoAwakeWindowMax) минут используйте только как гибкую подсказку приложения.",
                         "Behalten Sie einen ruhigen, vorhersehbaren Ablauf bei und nutzen Sie das App-Wachfenster von etwa \(s.whoAwakeWindowMax) Minuten nur flexibel.",
                         "Mantén una rutina tranquila y predecible y usa la ventana de vigilia de unos \(s.whoAwakeWindowMax) minutos solo como guía flexible.",
                         "Gardez une routine calme et prévisible et utilisez la fenêtre d’éveil d’environ \(s.whoAwakeWindowMax) minutes comme simple repère souple.",
                         "Mantenha uma rotina calma e previsível e use a janela de vigília de cerca de \(s.whoAwakeWindowMax) minutos apenas como guia flexível.",
                         "保持平静且可预测的作息，并把约\(s.whoAwakeWindowMax)分钟的清醒窗口仅作为灵活参考。")
        let contact: String
        switch assessment {
        case .below:
            contact = tr(language,
                         "If the low total is confirmed by complete records and continues, discuss it with the pediatrician.",
                         "Если низкое значение подтверждается полными записями и сохраняется, обсудите это с педиатром.",
                         "Wenn der niedrige Wert durch vollständige Aufzeichnungen bestätigt wird und anhält, sprechen Sie mit dem Kinderarzt.",
                         "Si el valor bajo se confirma con registros completos y persiste, consúltalo con el pediatra.",
                         "Si la valeur basse est confirmée par un suivi complet et persiste, parlez-en au pédiatre.",
                         "Se o valor baixo for confirmado por registos completos e persistir, fale com o pediatra.",
                         "如果完整记录仍显示睡眠偏低且持续，请咨询儿科医生。")
        case .above:
            contact = tr(language,
                         "Check for overlapping sessions or timers stopped late, and contact the pediatrician if increased sleep comes with unusual lethargy or poor feeding.",
                         "Проверьте пересекающиеся сессии и поздно остановленные таймеры; при необычной вялости или ухудшении кормления обратитесь к педиатру.",
                         "Prüfen Sie überlappende Sitzungen oder spät gestoppte Timer und fragen Sie bei ungewöhnlicher Schläfrigkeit oder schlechter Nahrungsaufnahme den Kinderarzt.",
                         "Revisa sesiones solapadas o temporizadores detenidos tarde y consulta al pediatra si el aumento de sueño se acompaña de letargo o peor alimentación.",
                         "Vérifiez les sessions superposées ou les minuteurs arrêtés tardivement et consultez si le sommeil accru s’accompagne de léthargie ou d’une baisse des prises.",
                         "Verifique sessões sobrepostas ou temporizadores parados tarde e contacte o pediatra se o aumento do sono vier com letargia ou pior alimentação.",
                         "检查是否有重叠记录或过晚停止的计时；若睡眠增多伴随异常乏力或进食变差，请咨询儿科医生。")
        case .noData:
            contact = tr(language,
                         "Log several complete days before comparing the pattern, and contact the pediatrician if the baby is unusually sleepy, difficult to wake, or unable to settle.",
                         "Записывайте несколько полных суток перед сравнением; при необычной сонливости, трудном пробуждении или выраженных проблемах с засыпанием обратитесь к педиатру.",
                         "Erfassen Sie mehrere vollständige Tage vor einem Vergleich und fragen Sie bei ungewöhnlicher Schläfrigkeit oder schwerem Aufwecken den Kinderarzt.",
                         "Registra varios días completos antes de comparar y consulta si el bebé está inusualmente somnoliento o cuesta despertarlo.",
                         "Enregistrez plusieurs journées complètes avant de comparer et consultez si le bébé est anormalement somnolent ou difficile à réveiller.",
                         "Registe vários dias completos antes de comparar e contacte o pediatra se o bebé estiver invulgarmente sonolento ou difícil de acordar.",
                         "先完整记录数天再比较；若宝宝异常嗜睡、难以唤醒或难以安抚入睡，请咨询儿科医生。")
        case .within:
            contact = tr(language,
                         "Continue complete logging so next week’s comparison remains meaningful, and follow the baby’s tired cues rather than a strict timer.",
                         "Продолжайте полностью записывать сон, чтобы сравнение следующей недели было точным, и ориентируйтесь на признаки усталости, а не на жёсткий таймер.",
                         "Erfassen Sie weiter vollständig und orientieren Sie sich an Müdigkeitssignalen statt an einem starren Timer.",
                         "Sigue registrando de forma completa y atiende a las señales de cansancio en lugar de seguir un temporizador rígido.",
                         "Continuez un suivi complet et fiez-vous aux signes de fatigue plutôt qu’à un minuteur strict.",
                         "Continue a registar de forma completa e siga os sinais de cansaço em vez de um temporizador rígido.",
                         "继续完整记录，并以宝宝的疲倦信号为主，而不是严格依赖计时器。")
        }
        return [verify, routine, contact].joined(separator: " ")
    }

    private func feedingReferenceText(_ s: WeeklyStats, language: Language) -> String {
        if s.ageMonths < 6 {
            return tr(language,
                      "WHO recommends exclusive milk feeding for the first 6 months and feeding on demand, day and night; it does not define one universal feed count.",
                      "ВОЗ рекомендует исключительно молочное питание первые 6 месяцев и кормление по требованию днём и ночью; единой обязательной цифры кормлений нет.",
                      "Die WHO empfiehlt in den ersten 6 Monaten ausschließlich Milch und Füttern nach Bedarf, Tag und Nacht; eine universelle feste Anzahl gibt es nicht.",
                      "La OMS recomienda alimentación exclusivamente láctea durante los primeros 6 meses y a demanda, de día y de noche; no fija una cifra universal de tomas.",
                      "L’OMS recommande une alimentation exclusivement lactée pendant les 6 premiers mois et à la demande, jour et nuit; elle ne fixe pas un nombre universel de tétées.",
                      "A OMS recomenda alimentação exclusivamente láctea nos primeiros 6 meses e a pedido, de dia e de noite; não define um número universal de mamadas.",
                      "世卫组织建议前6个月仅进行奶类喂养，并昼夜按需喂养；没有适用于所有宝宝的固定次数。")
        }
        if let meals = WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths) {
            let snacks = WhoNorms.complementarySnacksPerDay(ageMonths: s.ageMonths)
            let snackText = snacks.map { " \($0.lowerBound)-\($0.upperBound)" } ?? ""
            return tr(language,
                      "WHO suggests \(meals.lowerBound)-\(meals.upperBound) complementary meals per day for this age while milk feeding continues\(snacks == nil ? "." : ", with\(snackText) nutritious snacks as needed.")",
                      "Для этого возраста ВОЗ рекомендует \(meals.lowerBound)-\(meals.upperBound) приёма прикорма в день при продолжении молочного кормления\(snacks == nil ? "." : " и \(snackText.trimmingCharacters(in: .whitespaces)) питательных перекуса при необходимости.")",
                      "Die WHO empfiehlt in diesem Alter \(meals.lowerBound)-\(meals.upperBound) Beikostmahlzeiten pro Tag bei fortgesetzter Milchernährung.",
                      "La OMS recomienda \(meals.lowerBound)-\(meals.upperBound) comidas complementarias al día a esta edad, manteniendo la leche.",
                      "L’OMS conseille \(meals.lowerBound)-\(meals.upperBound) repas complémentaires par jour à cet âge, tout en poursuivant le lait.",
                      "A OMS recomenda \(meals.lowerBound)-\(meals.upperBound) refeições complementares por dia nesta idade, mantendo o leite.",
                      "世卫组织建议该年龄每天\(meals.lowerBound)-\(meals.upperBound)次辅食，同时继续奶类喂养。")
        }
        return tr(language,
                  "The report does not contain a complete meal-frequency count for this age.",
                  "В отчёте нет полного подсчёта всех приёмов пищи для этого возраста.",
                  "Der Bericht enthält keine vollständige Mahlzeitenzahl für dieses Alter.",
                  "El informe no contiene un recuento completo de comidas para esta edad.",
                  "Le rapport ne contient pas un comptage complet des repas pour cet âge.",
                  "O relatório não contém uma contagem completa das refeições para esta idade.",
                  "本报告没有该年龄的完整餐次统计。")
    }

    private func feedingComparisonText(_ s: WeeklyStats, language: Language) -> String {
        if s.ageMonths < 6 {
            let maxInterval = WhoNorms.maxFeedingInterval(ageMonths: s.ageMonths)
            let minimum = Int(ceil(1_440.0 / Double(maxInterval)))
            let isLow = s.avgFeedingsPerDay < Double(minimum)
            return tr(language,
                      "The logged frequency is \(isLow ? "below" : "at or above") the app heuristic of about \(minimum)+ feeds per day, but that heuristic is not a WHO clinical intake target and incomplete logging can change the result.",
                      "Частота записей \(isLow ? "ниже" : "не ниже") внутреннего ориентира приложения — примерно \(minimum)+ кормлений в сутки, но это не медицинская норма ВОЗ, а неполные записи могут изменить результат.",
                      "Die erfasste Häufigkeit liegt \(isLow ? "unter" : "bei oder über") der App-Heuristik von etwa \(minimum)+ Mahlzeiten täglich; dies ist kein klinischer WHO-Zielwert.",
                      "La frecuencia registrada está \(isLow ? "por debajo" : "al nivel o por encima") de la heurística de la app de unas \(minimum)+ tomas al día, pero no es un objetivo clínico de la OMS.",
                      "La fréquence enregistrée est \(isLow ? "inférieure" : "au moins égale") au repère de l’application d’environ \(minimum)+ tétées par jour, mais ce n’est pas une cible clinique de l’OMS.",
                      "A frequência registada está \(isLow ? "abaixo" : "igual ou acima") da heurística da aplicação de cerca de \(minimum)+ mamadas por dia, mas não é um alvo clínico da OMS.",
                      "记录频率\(isLow ? "低于" : "达到或高于")应用内部约每天\(minimum)+次的参考值，但这不是世卫组织的临床摄入目标。")
        }
        return tr(language,
                  "Momsy currently receives new-food diary entries rather than a complete meal count, so this report cannot honestly classify complementary meal frequency as low or normal.",
                  "Momsy сейчас получает записи о новых продуктах, а не полный подсчёт приёмов пищи, поэтому отчёт не может честно назвать частоту прикорма низкой или нормальной.",
                  "Momsy erhält Einträge zu neuen Lebensmitteln statt einer vollständigen Mahlzeitenzahl, daher kann die Beikosthäufigkeit nicht ehrlich als niedrig oder normal eingestuft werden.",
                  "Momsy recibe entradas de alimentos nuevos y no un recuento completo de comidas, por lo que no puede clasificar honestamente la frecuencia como baja o normal.",
                  "Momsy reçoit des entrées de nouveaux aliments et non un comptage complet des repas; la fréquence ne peut donc pas être classée honnêtement comme faible ou normale.",
                  "A Momsy recebe registos de novos alimentos e não uma contagem completa das refeições, por isso não pode classificar honestamente a frequência como baixa ou normal.",
                  "Momsy目前获得的是新食物日记，而不是完整餐次，因此不能诚实地把辅食频率判断为偏低或正常。")
    }

    private func foodAndReactionText(_ s: WeeklyStats, language: Language) -> String {
        let foodList = list(s.newFoodsIntroduced, language: language)
        let reactionList = list(s.allergensFlagged, language: language)
        return tr(language,
                  "New-food diary entries: \(foodList); allergen or reaction flags: \(reactionList).",
                  "Записи о новых продуктах: \(foodList); отмеченные аллергены или реакции: \(reactionList).",
                  "Neue Lebensmittel: \(foodList); Allergen- oder Reaktionshinweise: \(reactionList).",
                  "Nuevos alimentos: \(foodList); alertas de alérgeno o reacción: \(reactionList).",
                  "Nouveaux aliments : \(foodList); allergènes ou réactions signalés : \(reactionList).",
                  "Novos alimentos: \(foodList); alergénios ou reações assinalados: \(reactionList).",
                  "新食物记录：\(foodList)；过敏原或反应标记：\(reactionList)。")
    }

    private func diaperCaveatText(_ s: WeeklyStats, language: Language) -> String {
        tr(language,
           "There were \(s.totalDiapers) diaper logs, but the aggregate has no wet/dirty breakdown and cannot establish hydration or intake adequacy by itself.",
           "За неделю записано \(s.totalDiapers) смен подгузника, но без разделения на мокрые и грязные по этому числу нельзя оценить достаточность жидкости или питания.",
           "Es wurden \(s.totalDiapers) Windelwechsel erfasst; ohne Nass-/Stuhl-Aufteilung lässt sich daraus allein keine ausreichende Versorgung ableiten.",
           "Se registraron \(s.totalDiapers) cambios de pañal, pero sin desglose de mojados y sucios no permiten valorar por sí solos la hidratación o la ingesta.",
           "\(s.totalDiapers) changes ont été enregistrés, mais sans distinction mouillé/selles ce total ne permet pas d’évaluer seul l’hydratation ou les apports.",
           "Foram registadas \(s.totalDiapers) trocas de fralda, mas sem divisão entre molhadas e sujas o total não permite avaliar sozinho a hidratação ou a ingestão.",
           "本周记录\(s.totalDiapers)次换尿布，但没有尿湿/排便分类，仅凭总数不能判断水分或摄入是否充足。")
    }

    private func feedingRecommendationText(_ s: WeeklyStats, language: Language) -> String {
        if s.ageMonths < 6 {
            return tr(language,
                      "Continue responsive breast or formula feeding and follow hunger and fullness cues. Before 6 months, do not add solids or water unless the child’s clinician gives individual advice. If a low logged pattern is complete or feeding and diaper output are concerning, contact the pediatrician.",
                      "Продолжайте кормление грудным молоком или смесью по сигналам голода и насыщения. До 6 месяцев не добавляйте прикорм или воду без индивидуальной рекомендации врача. Если низкая частота подтверждается полными записями или есть сомнения по кормлению и подгузникам, обратитесь к педиатру.",
                      "Stillen oder Flasche weiter nach Hunger- und Sättigungssignalen anbieten. Vor 6 Monaten keine Beikost oder Wasser ohne individuelle ärztliche Empfehlung geben. Bei bestätigter niedriger Häufigkeit oder Sorgen den Kinderarzt fragen.",
                      "Continúa con leche materna o fórmula según las señales de hambre y saciedad. Antes de los 6 meses no añadas sólidos ni agua salvo indicación individual. Si el patrón bajo es completo o preocupa la ingesta, consulta al pediatra.",
                      "Poursuivez le lait maternel ou infantile selon les signes de faim et de satiété. Avant 6 mois, n’ajoutez ni solides ni eau sans conseil individualisé. Si la faible fréquence est confirmée ou inquiète, contactez le pédiatre.",
                      "Continue leite materno ou fórmula seguindo os sinais de fome e saciedade. Antes dos 6 meses, não acrescente sólidos nem água sem orientação individual. Se a baixa frequência for confirmada ou preocupante, contacte o pediatra.",
                      "继续根据饥饿和饱足信号进行母乳或配方奶喂养。6个月前不要自行添加辅食或水，除非医生给出个别建议。若完整记录仍显示频率偏低或家长担心摄入，请咨询儿科医生。")
        }
        if !s.allergensFlagged.isEmpty {
            let items = s.allergensFlagged.joined(separator: ", ")
            return tr(language,
                      "Do not re-introduce the flagged foods (\(items)) without professional guidance. Record the timing and symptoms of any reaction. Seek urgent care for breathing difficulty, facial swelling, or severe symptoms.",
                      "Не вводите повторно отмеченные продукты (\(items)) без рекомендации специалиста. Запишите время и симптомы реакции. При затруднении дыхания, отёке лица или тяжёлых симптомах обращайтесь за неотложной помощью.",
                      "Markierte Lebensmittel (\(items)) nicht ohne fachliche Anleitung erneut geben. Zeitpunkt und Symptome dokumentieren. Bei Atemnot, Gesichtsschwellung oder schweren Symptomen sofort Hilfe suchen.",
                      "No vuelvas a ofrecer los alimentos marcados (\(items)) sin orientación profesional. Anota el momento y los síntomas. Busca atención urgente ante dificultad respiratoria, hinchazón facial o síntomas graves.",
                      "Ne redonnez pas les aliments signalés (\(items)) sans avis professionnel. Notez l’heure et les symptômes. Consultez en urgence en cas de gêne respiratoire, gonflement du visage ou symptômes sévères.",
                      "Não volte a oferecer os alimentos assinalados (\(items)) sem orientação profissional. Registe o momento e os sintomas. Procure ajuda urgente perante dificuldade respiratória, inchaço facial ou sintomas graves.",
                      "在没有专业指导时，不要再次给予已标记食物（\(items)）。记录反应时间和症状。若出现呼吸困难、面部肿胀或严重症状，请立即就医。")
        }
        return tr(language,
                  "Continue milk feeding and offer age-appropriate foods responsively without forcing the child to eat. Record complete meals if you want a reliable comparison with WHO meal frequency. Introduce foods in a way that makes possible reactions easy to identify.",
                  "Продолжайте молочное кормление и предлагайте подходящую по возрасту пищу без давления на ребёнка. Для надёжного сравнения с частотой ВОЗ записывайте полные приёмы пищи. Вводите продукты так, чтобы возможную реакцию было легко заметить.",
                  "Milchernährung fortsetzen und altersgerechte Lebensmittel ohne Zwang anbieten. Für einen verlässlichen WHO-Vergleich vollständige Mahlzeiten erfassen. Lebensmittel so einführen, dass Reaktionen erkennbar bleiben.",
                  "Mantén la leche y ofrece alimentos apropiados para la edad sin forzar. Registra comidas completas para compararlas de forma fiable con la frecuencia de la OMS. Introduce alimentos de modo que sea fácil reconocer una reacción.",
                  "Poursuivez le lait et proposez des aliments adaptés sans forcer. Enregistrez des repas complets pour une comparaison fiable avec la fréquence OMS. Introduisez les aliments de façon à pouvoir identifier une réaction.",
                  "Mantenha o leite e ofereça alimentos adequados à idade sem forçar. Registe refeições completas para uma comparação fiável com a frequência da OMS. Introduza os alimentos de forma que seja fácil reconhecer uma reação.",
                  "继续奶类喂养，并在不强迫的情况下提供适龄食物。若要可靠比较世卫组织餐次建议，请记录完整餐次。引入食物时应便于识别可能的反应。")
    }

    private func overallText(_ s: WeeklyStats, language: Language) -> String {
        var result = tr(language,
                        "This report describes recorded patterns rather than a diagnosis. The main priority next week is complete sleep and feeding tracking so comparisons remain fair. The baby’s actual behaviour and the pediatrician’s advice matter more than one app number.",
                        "Этот отчёт описывает картину по записям, а не медицинский диагноз. Главная задача следующей недели — полностью записывать сон и кормления, чтобы сравнение было честным. Реальное состояние малыша и рекомендации педиатра важнее одной цифры приложения.",
                        "Dieser Bericht beschreibt protokollierte Muster und keine Diagnose. Wichtig ist eine vollständige Schlaf- und Ernährungserfassung für faire Vergleiche. Der tatsächliche Zustand des Kindes und ärztlicher Rat zählen mehr als eine einzelne App-Zahl.",
                        "Este informe describe patrones registrados y no es un diagnóstico. La prioridad es completar el seguimiento de sueño y alimentación para comparar con justicia. El estado real del bebé y el consejo del pediatra importan más que una cifra aislada.",
                        "Ce rapport décrit les données enregistrées et ne constitue pas un diagnostic. La priorité est de compléter le suivi du sommeil et de l’alimentation pour comparer équitablement. L’état réel du bébé et l’avis du pédiatre comptent plus qu’un chiffre isolé.",
                        "Este relatório descreve padrões registados e não é um diagnóstico. A prioridade é completar o registo de sono e alimentação para comparações justas. O estado real do bebé e a orientação do pediatra importam mais do que um número isolado.",
                        "本报告反映的是已记录模式，而不是医学诊断。下一周应优先完整记录睡眠和喂养，以便公平比较。宝宝的实际状态和儿科医生建议比应用中的单个数字更重要。")
        if let leapID = s.currentLeapID, !s.leapSignals.isEmpty {
            let signals = s.leapSignals.joined(separator: ", ")
            result += " " + tr(language,
                               "Signs this week matched leap #\(leapID): \(signals), although the logs alone cannot prove causation.",
                               "На этой неделе отмечены признаки скачка №\(leapID): \(signals), однако по журналу нельзя доказать причинную связь.",
                               "Diese Woche passten Zeichen zu Schub #\(leapID): \(signals), wobei das Protokoll keine Ursache beweist.",
                               "Esta semana hubo señales compatibles con el salto #\(leapID): \(signals), aunque el registro no demuestra causalidad.",
                               "Cette semaine, des signes correspondaient au bond #\(leapID) : \(signals), sans que le journal prouve une causalité.",
                               "Esta semana houve sinais compatíveis com o salto #\(leapID): \(signals), embora o registo não prove causalidade.",
                               "本周记录与飞跃期#\(leapID)的迹象相符：\(signals)，但日志本身不能证明因果关系。")
        }
        return result
    }

    private func duration(_ minutes: Int, _ language: Language) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        switch language {
        case .russian:
            if hours > 0 && remainder > 0 { return "\(hours) ч \(remainder) мин" }
            if hours > 0 { return "\(hours) ч" }
            return "\(remainder) мин"
        case .chinese:
            if hours > 0 && remainder > 0 { return "\(hours)小时\(remainder)分钟" }
            if hours > 0 { return "\(hours)小时" }
            return "\(remainder)分钟"
        default:
            if hours > 0 && remainder > 0 { return "\(hours)h \(remainder)m" }
            if hours > 0 { return "\(hours)h" }
            return "\(remainder)m"
        }
    }

    private func decimal(_ value: Double) -> String {
        String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private func list(_ items: [String], language: Language) -> String {
        guard !items.isEmpty else {
            return tr(language, "none", "нет", "keine", "ninguno", "aucun", "nenhum", "无")
        }
        return items.joined(separator: language == .chinese ? "、" : ", ")
    }

    private func tr(
        _ language: Language,
        _ en: String,
        _ ru: String,
        _ de: String,
        _ es: String,
        _ fr: String,
        _ pt: String,
        _ zh: String
    ) -> String {
        switch language {
        case .english: return en
        case .russian: return ru
        case .german: return de
        case .spanish: return es
        case .french: return fr
        case .portuguese: return pt
        case .chinese: return zh
        }
    }
}
