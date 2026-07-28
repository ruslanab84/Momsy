import Foundation

/// Deterministic offline fallback. Builds a detailed, age-aware narrative purely from
/// `WeeklyStats` + reference ranges, so a useful report remains available without Gemini.
final class StaticWeeklyInsightService: WeeklyInsightService {

    func generate(context: WeeklyInsightContext) async throws -> WeeklyInsightAI {
        let s = context.stats
        switch context.language {
        case .russian: return ru(s)
        case .german: return de(s)
        case .spanish: return es(s)
        case .french: return fr(s)
        case .portuguese: return pt(s)
        case .chinese: return zh(s)
        default: return en(s)
        }
    }

    private enum SleepAssessment {
        case noData
        case below(Int)
        case within
        case above(Int)
    }

    private func sleepAssessment(_ s: WeeklyStats) -> SleepAssessment {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        guard s.avgSleepMinutesPerDay > 0 else { return .noData }
        if s.avgSleepMinutesPerDay < range.lowerBound {
            return .below(range.lowerBound - s.avgSleepMinutesPerDay)
        }
        if s.avgSleepMinutesPerDay > range.upperBound {
            return .above(s.avgSleepMinutesPerDay - range.upperBound)
        }
        return .within
    }

    private func h(_ minutes: Int) -> String {
        let hh = minutes / 60, mm = minutes % 60
        if hh > 0 && mm > 0 { return "\(hh) ч \(mm) мин" }
        if hh > 0 { return "\(hh) ч" }
        return "\(mm) мин"
    }

    private func hLatin(_ minutes: Int) -> String {
        let hh = minutes / 60, mm = minutes % 60
        if hh > 0 && mm > 0 { return "\(hh)h \(mm)m" }
        if hh > 0 { return "\(hh)h" }
        return "\(mm)m"
    }

    private func hZh(_ minutes: Int) -> String {
        let hh = minutes / 60, mm = minutes % 60
        if hh > 0 && mm > 0 { return "\(hh) 小时 \(mm) 分钟" }
        if hh > 0 { return "\(hh) 小时" }
        return "\(mm) 分钟"
    }

    private func decimal(_ value: Double) -> String {
        String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private func appFeedMinimum(_ s: WeeklyStats) -> (minimum: Int, maxInterval: Int)? {
        guard s.ageMonths < 6 else { return nil }
        let interval = WhoNorms.maxFeedingInterval(ageMonths: s.ageMonths)
        return (Int(ceil(1_440.0 / Double(interval))), interval)
    }

    private func foods(_ s: WeeklyStats, none: String, separator: String = ", ") -> String {
        s.newFoodsIntroduced.isEmpty ? none : s.newFoodsIntroduced.joined(separator: separator)
    }

    private func flagged(_ s: WeeklyStats, none: String, separator: String = ", ") -> String {
        s.allergensFlagged.isEmpty ? none : s.allergensFlagged.joined(separator: separator)
    }

    private func withLeapLine(_ base: String, _ s: WeeklyStats, language: Language) -> String {
        guard let leapID = s.currentLeapID, !s.leapSignals.isEmpty else { return base }
        let signals = s.leapSignals.joined(separator: ", ")
        let line: String
        switch language {
        case .english: line = " Signs this week matched leap #\(leapID): \(signals), although the logs alone cannot prove that the leap caused the changes."
        case .russian: line = " На этой неделе отмечены признаки скачка №\(leapID): \(signals), однако по журналу нельзя утверждать, что именно скачок вызвал изменения."
        case .german: line = " Diese Woche passten die Zeichen zu Schub #\(leapID): \(signals), auch wenn das Protokoll keine Ursache beweist."
        case .spanish: line = " Esta semana las señales coincidieron con el salto #\(leapID): \(signals), aunque el registro no demuestra una causa."
        case .french: line = " Cette semaine, les signes correspondaient au bond #\(leapID) : \(signals), sans que le journal puisse prouver un lien de cause."
        case .portuguese: line = " Esta semana os sinais coincidiram com o salto #\(leapID): \(signals), embora o registo não prove uma causa."
        case .chinese: line = " 本周记录与飞跃期 #\(leapID) 的迹象相符：\(signals)，但日志本身不能证明因果关系。"
        }
        return base + line
    }

    // MARK: - English

    private func en(_ s: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let feeds = decimal(s.avgFeedingsPerDay)
        let sleepStatus: String
        let sleepRec: String
        switch sleepAssessment(s) {
        case .noData:
            sleepStatus = "No sleep duration was logged, so the app cannot classify the baby's true sleep."
            sleepRec = "Check that every sleep timer was started and stopped correctly. Log several complete days before comparing the pattern with a reference range. If the baby truly seems unusually sleepy, difficult to wake, or unable to settle, contact the pediatrician."
        case .below(let delta):
            sleepStatus = "The logged average is below the lower WHO bound by \(hLatin(delta)) per day."
            sleepRec = "First verify that naps and overnight sleep were logged completely. A consistent wind-down routine and an earlier bedtime may help, while the app's ~\(s.whoAwakeWindowMax)-minute awake-window estimate can be used only as a planning guide. If the low total is real and continues, discuss it with the pediatrician."
        case .within:
            sleepStatus = "The logged average is within the WHO range for this age."
            sleepRec = "Keep the routine that is working and continue following the baby's tired cues. Use the app's awake-window estimate as a flexible planning aid rather than a strict rule. Continue complete logging so next week's trend remains meaningful."
        case .above(let delta):
            sleepStatus = "The logged average is above the upper WHO bound by \(hLatin(delta)) per day."
            sleepRec = "Check for overlapping sessions or timers that were stopped late. If the records are accurate, keep regular wake and sleep times and observe the baby's usual alertness. Contact the pediatrician if increased sleep comes with unusual lethargy, poor feeding, or other concerns."
        }

        let feedingSummary: String
        let feedingRecommendation: String
        if let heuristic = appFeedMinimum(s) {
            let comparison = s.avgFeedingsPerDay < Double(heuristic.minimum)
                ? "This is below the app logging heuristic of about \(heuristic.minimum)+ feeds/day."
                : "This is at or above the app logging heuristic of about \(heuristic.minimum)+ feeds/day."
            feedingSummary = "Momsy recorded \(feeds) milk feeds per day, \(s.totalFeedings) in total. WHO recommends milk feeding on demand, day and night, and does not set one universal feed count. \(comparison) The heuristic is not a clinical intake target, and incomplete logging can make the number look low. There were \(s.totalDiapers) diaper logs, but the total alone cannot establish hydration."
            feedingRecommendation = "Continue responsive breast or formula feeding and follow hunger and fullness cues. Before 6 months, do not add solids or water unless the child's clinician gives specific advice. If the low logged pattern is complete or feeding and diaper output are concerning, contact the pediatrician."
        } else {
            let mealText: String
            if let meals = WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths) {
                mealText = "WHO suggests \(meals.lowerBound)-\(meals.upperBound) complementary meals per day at this age while milk feeding continues."
            } else {
                mealText = "A complete meal-frequency count is not available in this report."
            }
            feedingSummary = "Momsy recorded \(feeds) milk feeds per day, \(s.totalFeedings) in total. \(mealText) The food diary lists \(foods(s, none: "no new foods")), but new-food entries are not the same as a complete meal count. Reaction or allergen flags: \(flagged(s, none: "none"). There were \(s.totalDiapers) diaper logs, which should not be used alone to judge intake."
            feedingRecommendation = s.allergensFlagged.isEmpty
                ? "Continue milk feeding and offer age-appropriate foods responsively without forcing the child to eat. Use a meal log if you want a reliable comparison with WHO meal frequency. Introduce foods in a way that makes reactions easy to identify."
                : "Do not re-introduce the flagged foods (\(s.allergensFlagged.joined(separator: ", "))) without professional guidance. Record the timing and symptoms of any reaction. Contact the pediatrician, and seek urgent care for breathing difficulty, facial swelling, or severe symptoms."
        }

        return WeeklyInsightAI(
            sleepSummary: "Momsy recorded an average of \(hLatin(s.avgSleepMinutesPerDay)) of sleep per day, including \(hLatin(s.avgNightSleepMinutes)) at night and \(hLatin(s.avgDaySleepMinutes)) during the day. The WHO range for this age is \(hLatin(range.lowerBound))-\(hLatin(range.upperBound)) in 24 hours, including naps. \(sleepStatus) The average was \(decimal(s.avgNapsPerDay)) daytime naps per day and the change versus last week was \(s.sleepTrendVsPrevWeekMinutes) minutes per day. These figures describe logged sessions and may be lower or higher if tracking was incomplete.",
            sleepRecommendation: sleepRec,
            feedingSummary: feedingSummary,
            feedingRecommendation: feedingRecommendation,
            overallSummary: withLeapLine("This report shows the recorded pattern rather than a diagnosis. The main item to watch is whether sleep and feeding logs are complete enough for a fair comparison. Keep tracking consistently and use the pediatrician for concerns about the baby's actual behaviour or intake.", s, language: .english)
        )
    }

    // MARK: - Russian

    private func ru(_ s: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let feeds = decimal(s.avgFeedingsPerDay)
        let sleepStatus: String
        let sleepRec: String
        switch sleepAssessment(s) {
        case .noData:
            sleepStatus = "Продолжительность сна не зафиксирована, поэтому определить реальный режим малыша невозможно."
            sleepRec = "Проверьте, что каждый таймер сна был запущен и остановлен правильно. Записывайте несколько полных суток, прежде чем сравнивать режим с нормативным диапазоном. Если малыш действительно необычно сонлив, его трудно разбудить или он плохо засыпает, обратитесь к педиатру."
        case .below(let delta):
            sleepStatus = "По журналу сон ниже нижней границы ВОЗ на \(h(delta)) в сутки."
            sleepRec = "Сначала проверьте, полностью ли записаны ночной сон и все дневные сны. Может помочь спокойный повторяющийся ритуал и немного более раннее укладывание; ориентир окна бодрствования около \(s.whoAwakeWindowMax) минут является подсказкой приложения, а не строгой нормой ВОЗ. Если дефицит подтверждается полными записями и сохраняется, обсудите это с педиатром."
        case .within:
            sleepStatus = "Среднее значение по журналу находится в диапазоне ВОЗ для этого возраста."
            sleepRec = "Сохраняйте работающий ритм и ориентируйтесь на признаки усталости малыша. Окно бодрствования используйте гибко, а не как жёсткий таймер. Продолжайте полностью записывать сон, чтобы сравнение следующей недели было точным."
        case .above(let delta):
            sleepStatus = "По журналу сон выше верхней границы ВОЗ на \(h(delta)) в сутки."
            sleepRec = "Проверьте, нет ли пересекающихся записей или таймеров, остановленных слишком поздно. Если данные точны, сохраняйте регулярное время сна и бодрствования и наблюдайте за обычной активностью малыша. При необычной вялости, ухудшении кормления или других тревожных признаках обратитесь к педиатру."
        }

        let feedingSummary: String
        let feedingRecommendation: String
        if let heuristic = appFeedMinimum(s) {
            let comparison = s.avgFeedingsPerDay < Double(heuristic.minimum)
                ? "Это ниже внутреннего ориентира приложения — примерно \(heuristic.minimum)+ записей в сутки."
                : "Это не ниже внутреннего ориентира приложения — примерно \(heuristic.minimum)+ записей в сутки."
            feedingSummary = "В Momsy записано в среднем \(feeds) молочных кормлений в сутки, всего \(s.totalFeedings) за неделю. ВОЗ рекомендует кормить по требованию днём и ночью и не устанавливает единую обязательную цифру кормлений. \(comparison) Этот ориентир не является медицинской нормой, а неполные записи могут искусственно уменьшить число. За неделю отмечено \(s.totalDiapers) смен подгузника, но по общему количеству без разделения нельзя оценить достаточность питания или жидкости."
            feedingRecommendation = "Продолжайте кормление грудным молоком или смесью по сигналам голода и насыщения. До 6 месяцев не добавляйте прикорм или воду без индивидуальной рекомендации врача. Если низкая частота подтверждается полными записями или есть сомнения по кормлению и подгузникам, свяжитесь с педиатром."
        } else {
            let mealText: String
            if let meals = WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths) {
                mealText = "Для этого возраста ВОЗ рекомендует \(meals.lowerBound)-\(meals.upperBound) приёма прикорма в день при продолжении молочного кормления."
            } else {
                mealText = "В отчёте нет полного подсчёта всех приёмов пищи."
            }
            feedingSummary = "В Momsy записано в среднем \(feeds) молочных кормлений в сутки, всего \(s.totalFeedings) за неделю. \(mealText) В дневнике новых продуктов указано: \(foods(s, none: "новых продуктов нет")), но эти записи не равны полному числу приёмов пищи. Отмеченные аллергены или реакции: \(flagged(s, none: "нет"). Смен подгузника записано \(s.totalDiapers), и этого общего числа недостаточно для оценки питания."
            feedingRecommendation = s.allergensFlagged.isEmpty
                ? "Продолжайте молочное кормление и предлагайте подходящую по возрасту пищу без давления на ребёнка. Для точного сравнения с частотой ВОЗ записывайте именно приёмы пищи, а не только новые продукты. Новые продукты вводите так, чтобы возможную реакцию было легко заметить."
                : "Не вводите повторно отмеченные продукты (\(s.allergensFlagged.joined(separator: ", "))) без рекомендации специалиста. Запишите время и симптомы реакции. Обратитесь к педиатру, а при затруднении дыхания, отёке лица или тяжёлых симптомах — за неотложной помощью."
        }

        return WeeklyInsightAI(
            sleepSummary: "По журналу малыш спал в среднем \(h(s.avgSleepMinutesPerDay)) в сутки: \(h(s.avgNightSleepMinutes)) ночью и \(h(s.avgDaySleepMinutes)) днём. Диапазон ВОЗ для этого возраста составляет \(h(range.lowerBound))-\(h(range.upperBound)) за 24 часа вместе с дневными снами. \(sleepStatus) В среднем отмечено \(decimal(s.avgNapsPerDay)) дневных снов, а изменение относительно прошлой недели составило \(s.sleepTrendVsPrevWeekMinutes) минут в сутки. Значения отражают только записанные сессии и могут искажаться при пропущенных или незакрытых таймерах.",
            sleepRecommendation: sleepRec,
            feedingSummary: feedingSummary,
            feedingRecommendation: feedingRecommendation,
            overallSummary: withLeapLine("Отчёт показывает картину по записям, а не медицинский диагноз. Главное на следующей неделе — вести сон и кормления достаточно полно, чтобы сравнение было честным. При сомнениях ориентируйтесь на состояние малыша и рекомендации педиатра, а не только на цифры приложения.", s, language: .russian)
        )
    }

    // MARK: - German

    private func de(_ s: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let feeds = decimal(s.avgFeedingsPerDay)
        let status: String
        switch sleepAssessment(s) {
        case .noData: status = "Es wurde keine Schlafdauer erfasst, daher ist keine verlässliche Einordnung möglich."
        case .below(let d): status = "Der protokollierte Wert liegt \(hLatin(d)) pro Tag unter der WHO-Untergrenze."
        case .within: status = "Der protokollierte Wert liegt im WHO-Bereich für dieses Alter."
        case .above(let d): status = "Der protokollierte Wert liegt \(hLatin(d)) pro Tag über der WHO-Obergrenze."
        }
        let underSix = s.ageMonths < 6
        let feedGuide = underSix
            ? "Die WHO empfiehlt Milchnahrung nach Bedarf, Tag und Nacht, und keine feste universelle Anzahl."
            : (WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths).map { "Die WHO empfiehlt in diesem Alter \($0.lowerBound)-\($0.upperBound) Beikostmahlzeiten pro Tag bei fortgesetzter Milchernährung." } ?? "Eine vollständige Mahlzeitenzahl liegt nicht vor.")
        let feedRec = underSix
            ? "Weiter nach Hunger- und Sättigungssignalen stillen oder Flasche geben. Vor 6 Monaten keine Beikost oder Wasser ohne individuelle ärztliche Empfehlung geben. Bei tatsächlich geringer Aufnahme oder Sorgen den Kinderarzt kontaktieren."
            : (s.allergensFlagged.isEmpty
                ? "Milchernährung fortsetzen und altersgerechte Lebensmittel ohne Zwang anbieten. Für einen WHO-Vergleich vollständige Mahlzeiten und nicht nur neue Lebensmittel protokollieren. Reaktionen sorgfältig beobachten."
                : "Markierte Lebensmittel (\(s.allergensFlagged.joined(separator: ", "))) nicht ohne fachliche Anleitung erneut geben. Symptome und Zeitpunkt dokumentieren. Bei schweren Reaktionen sofort medizinische Hilfe suchen.")
        return WeeklyInsightAI(
            sleepSummary: "Erfasst wurden durchschnittlich \(hLatin(s.avgSleepMinutesPerDay)) Schlaf pro Tag, davon \(hLatin(s.avgNightSleepMinutes)) nachts und \(hLatin(s.avgDaySleepMinutes)) tagsüber. Der WHO-Bereich beträgt \(hLatin(range.lowerBound))-\(hLatin(range.upperBound)) in 24 Stunden einschließlich Nickerchen. \(status) Es gab durchschnittlich \(decimal(s.avgNapsPerDay)) Nickerchen pro Tag und eine Veränderung von \(s.sleepTrendVsPrevWeekMinutes) Minuten gegenüber der Vorwoche. Unvollständige oder überlappende Timer können die Werte verzerren.",
            sleepRecommendation: "Zuerst die Vollständigkeit der Schlafprotokolle prüfen. Einen ruhigen, regelmäßigen Ablauf beibehalten und Müdigkeitssignale beachten; das Wachfenster von etwa \(s.whoAwakeWindowMax) Minuten ist nur eine flexible App-Hilfe. Bei anhaltend auffälligem Schlaf oder Begleitsymptomen den Kinderarzt fragen.",
            feedingSummary: "Erfasst wurden \(feeds) Milchmahlzeiten pro Tag und \(s.totalFeedings) in der Woche. \(feedGuide) Neue Lebensmittel: \(foods(s, none: "keine"); Reaktions- oder Allergenhinweise: \(flagged(s, none: "keine"). Neue-Lebensmittel-Einträge sind kein vollständiger Mahlzeitenzähler. Insgesamt wurden \(s.totalDiapers) Windelwechsel erfasst, was allein keine Aussage über die Versorgung erlaubt.",
            feedingRecommendation: feedRec,
            overallSummary: withLeapLine("Der Bericht beschreibt protokollierte Muster und keine Diagnose. Entscheidend ist eine vollständige Erfassung, bevor Werte als niedrig oder normal bewertet werden. Bei Sorgen zählt der Zustand des Kindes mehr als eine einzelne App-Zahl.", s, language: .german)
        )
    }

    // MARK: - Spanish

    private func es(_ s: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let feeds = decimal(s.avgFeedingsPerDay)
        let status: String
        switch sleepAssessment(s) {
        case .noData: status = "No se registró duración de sueño, por lo que no puede clasificarse el sueño real."
        case .below(let d): status = "El promedio registrado está \(hLatin(d)) al día por debajo del límite inferior de la OMS."
        case .within: status = "El promedio registrado está dentro del rango de la OMS para esta edad."
        case .above(let d): status = "El promedio registrado está \(hLatin(d)) al día por encima del límite superior de la OMS."
        }
        let underSix = s.ageMonths < 6
        let feedGuide = underSix
            ? "La OMS recomienda alimentación con leche a demanda, de día y de noche, sin una cifra universal fija de tomas."
            : (WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths).map { "La OMS recomienda \($0.lowerBound)-\($0.upperBound) comidas complementarias al día a esta edad, manteniendo la leche." } ?? "Este informe no incluye un recuento completo de comidas.")
        let feedRec = underSix
            ? "Continúa con leche materna o fórmula siguiendo las señales de hambre y saciedad. Antes de los 6 meses no añadas sólidos ni agua salvo indicación individual del profesional. Si el patrón bajo es real o preocupa la ingesta, consulta al pediatra."
            : (s.allergensFlagged.isEmpty
                ? "Mantén la leche y ofrece alimentos apropiados para la edad sin forzar. Registra comidas completas si deseas compararlas con la frecuencia de la OMS. Introduce los alimentos de forma que sea fácil reconocer una reacción."
                : "No vuelvas a ofrecer los alimentos marcados (\(s.allergensFlagged.joined(separator: ", "))) sin orientación profesional. Anota el momento y los síntomas. Busca atención urgente ante dificultad respiratoria, hinchazón facial o síntomas graves.")
        return WeeklyInsightAI(
            sleepSummary: "Momsy registró una media de \(hLatin(s.avgSleepMinutesPerDay)) de sueño al día: \(hLatin(s.avgNightSleepMinutes)) nocturno y \(hLatin(s.avgDaySleepMinutes)) diurno. El rango de la OMS es \(hLatin(range.lowerBound))-\(hLatin(range.upperBound)) en 24 horas, incluidas las siestas. \(status) Se registraron \(decimal(s.avgNapsPerDay)) siestas al día y un cambio de \(s.sleepTrendVsPrevWeekMinutes) minutos frente a la semana anterior. Los temporizadores incompletos pueden alterar la comparación.",
            sleepRecommendation: "Comprueba primero que todo el sueño se haya registrado. Mantén una rutina tranquila y usa la ventana de vigilia de unos \(s.whoAwakeWindowMax) minutos solo como guía flexible. Consulta al pediatra si el patrón llamativo es real y persiste o aparece con otros síntomas.",
            feedingSummary: "Se registraron \(feeds) tomas de leche al día y \(s.totalFeedings) en la semana. \(feedGuide) Nuevos alimentos: \(foods(s, none: "ninguno"); alertas de reacción o alérgeno: \(flagged(s, none: "ninguna"). El diario de alimentos nuevos no equivale a un recuento completo de comidas. Hubo \(s.totalDiapers) cambios de pañal registrados, insuficientes por sí solos para valorar la ingesta.",
            feedingRecommendation: feedRec,
            overallSummary: withLeapLine("El informe describe lo registrado y no es un diagnóstico. La prioridad es completar los registros antes de llamar bajo o normal a un patrón. Ante dudas, importa más el estado del bebé que una cifra aislada de la aplicación.", s, language: .spanish)
        )
    }

    // MARK: - French

    private func fr(_ s: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let feeds = decimal(s.avgFeedingsPerDay)
        let status: String
        switch sleepAssessment(s) {
        case .noData: status = "Aucune durée de sommeil n'a été enregistrée, donc le sommeil réel ne peut pas être classé."
        case .below(let d): status = "La moyenne enregistrée est inférieure de \(hLatin(d)) par jour à la limite basse de l'OMS."
        case .within: status = "La moyenne enregistrée se situe dans la plage de l'OMS pour cet âge."
        case .above(let d): status = "La moyenne enregistrée dépasse de \(hLatin(d)) par jour la limite haute de l'OMS."
        }
        let underSix = s.ageMonths < 6
        let feedGuide = underSix
            ? "L'OMS recommande une alimentation lactée à la demande, jour et nuit, sans nombre universel fixe de tétées."
            : (WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths).map { "L'OMS conseille \($0.lowerBound)-\($0.upperBound) repas complémentaires par jour à cet âge, tout en poursuivant le lait." } ?? "Le rapport ne contient pas un comptage complet des repas.")
        let feedRec = underSix
            ? "Poursuivez le lait maternel ou infantile selon les signes de faim et de satiété. Avant 6 mois, n'ajoutez ni solides ni eau sans conseil médical individualisé. Si la faible fréquence est réelle ou si l'alimentation inquiète, contactez le pédiatre."
            : (s.allergensFlagged.isEmpty
                ? "Poursuivez le lait et proposez des aliments adaptés sans forcer l'enfant. Enregistrez les repas complets pour les comparer à la fréquence OMS. Introduisez les aliments de façon à pouvoir identifier une réaction."
                : "Ne redonnez pas les aliments signalés (\(s.allergensFlagged.joined(separator: ", "))) sans avis professionnel. Notez l'heure et les symptômes. Consultez en urgence en cas de gêne respiratoire, gonflement du visage ou symptômes sévères.")
        return WeeklyInsightAI(
            sleepSummary: "Momsy a enregistré en moyenne \(hLatin(s.avgSleepMinutesPerDay)) de sommeil par jour, dont \(hLatin(s.avgNightSleepMinutes)) la nuit et \(hLatin(s.avgDaySleepMinutes)) le jour. La plage OMS est de \(hLatin(range.lowerBound))-\(hLatin(range.upperBound)) sur 24 heures, siestes comprises. \(status) La moyenne était de \(decimal(s.avgNapsPerDay)) siestes par jour, avec une variation de \(s.sleepTrendVsPrevWeekMinutes) minutes par rapport à la semaine précédente. Des minuteurs incomplets peuvent fausser les chiffres.",
            sleepRecommendation: "Vérifiez d'abord que tous les épisodes de sommeil sont complets. Gardez une routine calme et utilisez la fenêtre d'éveil d'environ \(s.whoAwakeWindowMax) minutes comme repère souple seulement. Parlez-en au pédiatre si l'écart est réel, persistant ou associé à d'autres signes."
            ,feedingSummary: "Momsy a enregistré \(feeds) tétées ou biberons par jour, soit \(s.totalFeedings) dans la semaine. \(feedGuide) Nouveaux aliments : \(foods(s, none: "aucun"); réactions ou allergènes signalés : \(flagged(s, none: "aucun"). Le journal des nouveaux aliments n'est pas un comptage complet des repas. \(s.totalDiapers) changes ont été enregistrés, ce qui ne suffit pas seul à évaluer les apports.",
            feedingRecommendation: feedRec,
            overallSummary: withLeapLine("Ce rapport décrit les données enregistrées et ne constitue pas un diagnostic. La priorité est de compléter le suivi avant de qualifier un rythme de faible ou normal. En cas d'inquiétude, l'état du bébé compte davantage qu'un chiffre isolé de l'application.", s, language: .french)
        )
    }

    // MARK: - Portuguese

    private func pt(_ s: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let feeds = decimal(s.avgFeedingsPerDay)
        let status: String
        switch sleepAssessment(s) {
        case .noData: status = "Não foi registada duração de sono, por isso não é possível classificar o sono real."
        case .below(let d): status = "A média registada está \(hLatin(d)) por dia abaixo do limite inferior da OMS."
        case .within: status = "A média registada está dentro do intervalo da OMS para esta idade."
        case .above(let d): status = "A média registada está \(hLatin(d)) por dia acima do limite superior da OMS."
        }
        let underSix = s.ageMonths < 6
        let feedGuide = underSix
            ? "A OMS recomenda leite a pedido, de dia e de noite, sem um número universal fixo de mamadas."
            : (WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths).map { "A OMS recomenda \($0.lowerBound)-\($0.upperBound) refeições complementares por dia nesta idade, mantendo o leite." } ?? "O relatório não contém uma contagem completa das refeições.")
        let feedRec = underSix
            ? "Continue leite materno ou fórmula seguindo os sinais de fome e saciedade. Antes dos 6 meses, não acrescente sólidos nem água sem orientação individual do profissional. Se a baixa frequência for real ou houver preocupação com a alimentação, contacte o pediatra."
            : (s.allergensFlagged.isEmpty
                ? "Mantenha o leite e ofereça alimentos adequados à idade sem forçar. Registe refeições completas para comparar com a frequência da OMS. Introduza os alimentos de forma que seja fácil reconhecer uma reação."
                : "Não volte a oferecer os alimentos assinalados (\(s.allergensFlagged.joined(separator: ", "))) sem orientação profissional. Registe o momento e os sintomas. Procure ajuda urgente perante dificuldade respiratória, inchaço facial ou sintomas graves.")
        return WeeklyInsightAI(
            sleepSummary: "A Momsy registou em média \(hLatin(s.avgSleepMinutesPerDay)) de sono por dia, sendo \(hLatin(s.avgNightSleepMinutes)) à noite e \(hLatin(s.avgDaySleepMinutes)) durante o dia. O intervalo da OMS é \(hLatin(range.lowerBound))-\(hLatin(range.upperBound)) em 24 horas, incluindo sestas. \(status) Houve em média \(decimal(s.avgNapsPerDay)) sestas por dia e uma alteração de \(s.sleepTrendVsPrevWeekMinutes) minutos face à semana anterior. Temporizadores incompletos podem distorcer a comparação.",
            sleepRecommendation: "Confirme primeiro se todo o sono foi registado. Mantenha uma rotina calma e use a janela de vigília de cerca de \(s.whoAwakeWindowMax) minutos apenas como guia flexível. Fale com o pediatra se o padrão invulgar for real, persistente ou acompanhado de outros sinais.",
            feedingSummary: "Foram registadas \(feeds) mamadas por dia e \(s.totalFeedings) na semana. \(feedGuide) Novos alimentos: \(foods(s, none: "nenhum"); reações ou alergénios assinalados: \(flagged(s, none: "nenhum"). O diário de novos alimentos não é uma contagem completa das refeições. Foram registadas \(s.totalDiapers) trocas de fralda, o que por si só não permite avaliar a ingestão.",
            feedingRecommendation: feedRec,
            overallSummary: withLeapLine("O relatório descreve o que foi registado e não é um diagnóstico. A prioridade é completar os registos antes de classificar um padrão como baixo ou normal. Em caso de dúvida, o estado do bebé é mais importante do que um número isolado da aplicação.", s, language: .portuguese)
        )
    }

    // MARK: - Chinese

    private func zh(_ s: WeeklyStats) -> WeeklyInsightAI {
        let range = WhoNorms.sleepRangeMinutes(ageMonths: s.ageMonths)
        let feeds = decimal(s.avgFeedingsPerDay)
        let status: String
        switch sleepAssessment(s) {
        case .noData: status = "本周没有记录睡眠时长，因此无法判断宝宝真实睡眠是否达标。"
        case .below(let d): status = "记录值每天比世卫组织下限少 \(hZh(d))。"
        case .within: status = "记录的平均睡眠位于该年龄的世卫组织建议范围内。"
        case .above(let d): status = "记录值每天比世卫组织上限多 \(hZh(d))。"
        }
        let underSix = s.ageMonths < 6
        let feedGuide = underSix
            ? "世卫组织建议昼夜按需喂奶，并没有适用于所有宝宝的固定喂养次数。"
            : (WhoNorms.complementaryMealsPerDay(ageMonths: s.ageMonths).map { "世卫组织建议该年龄每天 \($0.lowerBound)-\($0.upperBound) 次辅食，同时继续奶类喂养。" } ?? "本报告没有完整的正餐次数。")
        let feedRec = underSix
            ? "继续根据饥饿和饱足信号进行母乳或配方奶喂养。6个月前不要自行添加辅食或水，除非医生给出个别建议。如果记录完整但喂养次数确实偏低或家长担心摄入，请联系儿科医生。"
            : (s.allergensFlagged.isEmpty
                ? "继续奶类喂养，并在不强迫的情况下提供适龄食物。若要与世卫组织餐次建议比较，请记录完整餐次而不只是新食物。每次引入食物时注意观察反应。"
                : "在没有专业指导时，不要再次给予已标记食物（\(s.allergensFlagged.joined(separator: "、")）。记录反应时间和症状。若出现呼吸困难、面部肿胀或严重症状，请立即就医。")
        return WeeklyInsightAI(
            sleepSummary: "Momsy记录的平均睡眠为每天 \(hZh(s.avgSleepMinutesPerDay))，其中夜间 \(hZh(s.avgNightSleepMinutes))、白天 \(hZh(s.avgDaySleepMinutes))。该年龄世卫组织建议的24小时总睡眠范围为 \(hZh(range.lowerBound))-\(hZh(range.upperBound))，包括小睡。\(status) 平均每天记录 \(decimal(s.avgNapsPerDay)) 次小睡，与上周相比每天变化 \(s.sleepTrendVsPrevWeekMinutes) 分钟。漏记或未及时停止计时器会影响比较结果。",
            sleepRecommendation: "先确认夜间睡眠和所有小睡是否完整记录。保持平静而规律的睡前流程，并把约 \(s.whoAwakeWindowMax) 分钟的清醒窗口只作为灵活的应用参考。若异常模式真实且持续，或伴随其他症状，请咨询儿科医生。",
            feedingSummary: "本周平均每天记录 \(feeds) 次奶类喂养，共 \(s.totalFeedings) 次。\(feedGuide) 新食物：\(foods(s, none: "无", separator: "、"))；反应或过敏原标记：\(flagged(s, none: "无", separator: "、"))。新食物日记并不等于完整餐次记录。本周记录 \(s.totalDiapers) 次换尿布，仅凭总数不能判断摄入是否充足。",
            feedingRecommendation: feedRec,
            overallSummary: withLeapLine("本报告反映的是已记录模式，而不是医学诊断。下一周最重要的是完整记录睡眠和喂养，再判断偏低或正常。若有担忧，应优先关注宝宝实际状态并咨询儿科医生，而不是只看应用中的单个数字。", s, language: .chinese)
        )
    }
}
