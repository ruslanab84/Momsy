import Foundation

// Citation rule (A4): a tip that states health information must cite sources
// (`isMedicalClaim: true` + non-empty `sources`). Tips driven by the in-house
// `CareHeuristics` thresholds stay neutral observations of the user's own log —
// no "norm", no "abnormal", no "see a doctor".

// MARK: - PRIORITY 1: Alert Rules

enum AlertRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        checkFeedingInterval(context)
        ?? checkDiaperCount(context)
        ?? checkStool(context)
        ?? checkSleepDeficit(context)
    }

    // Long gap since the last logged feed — neutral observation.
    private static func checkFeedingInterval(_ ctx: DailyContext) -> DailyTip? {
        guard let mins = ctx.minutesSinceLastFeed else { return nil }
        guard mins > CareHeuristics.maxFeedingInterval(ageMonths: ctx.ageMonths) else { return nil }
        let hours = mins / 60
        let name = ctx.babyName
        let text = LocalizedText(
            en: "It's been \(hours) h since \(name)'s last logged feed.",
            ru: "С последнего записанного кормления \(name) прошло \(hours) ч.",
            de: "Seit der letzten eingetragenen Mahlzeit von \(name) sind \(hours) Std. vergangen.",
            es: "Han pasado \(hours) h desde la última toma registrada de \(name).",
            fr: "\(hours) h se sont écoulées depuis la dernière tétée enregistrée de \(name).",
            pt: "Passaram \(hours) h desde a última mamada registada de \(name).",
            zh: "距离 \(name) 上次记录的喂奶已过去 \(hours) 小时。"
        )
        return DailyTip(text: text(ctx.language), contextHash: ctx.contextHash, category: .situational)
    }

    // Few wet diapers logged by the evening — neutral observation.
    private static func checkDiaperCount(_ ctx: DailyContext) -> DailyTip? {
        // diaperCount == 0 means nothing logged yet (fresh install / not tracking today),
        // not a real "0 wet diapers" — require ≥1 entry before mentioning it.
        guard ctx.diaperCount >= 1, ctx.diaperCount < 4, ctx.hour >= 18, ctx.ageMonths <= 6 else { return nil }
        let n = ctx.diaperCount
        let name = ctx.babyName
        let text = LocalizedText(
            en: "\(n) wet diapers logged for \(name) so far today.",
            ru: "Сегодня для \(name) пока записано подгузников: \(n).",
            de: "Heute bisher \(n) nasse Windeln für \(name) eingetragen.",
            es: "Hoy llevas \(n) pañales mojados registrados de \(name).",
            fr: "\(n) couches mouillées enregistrées pour \(name) aujourd’hui.",
            pt: "Hoje, até agora, \(n) fraldas molhadas registadas para \(name).",
            zh: "今天目前为 \(name) 记录了 \(n) 片湿尿布。"
        )
        return DailyTip(text: text(ctx.language), contextHash: ctx.contextHash, category: .situational)
    }

    // Several days without a logged stool — neutral observation.
    private static func checkStool(_ ctx: DailyContext) -> DailyTip? {
        // nil means no stool has ever been logged (fresh install / not tracking),
        // not a real streak — never mention it without at least one recorded stool.
        guard let days = ctx.daysSinceLastStool else { return nil }
        guard days >= CareHeuristics.maxDaysWithoutStool(ageMonths: ctx.ageMonths) else { return nil }
        let name = ctx.babyName
        let text = LocalizedText(
            en: "No stool logged for \(name) in the last \(days) days.",
            ru: "За последние \(days) дн. стул у \(name) не записан.",
            de: "In den letzten \(days) Tagen wurde kein Stuhlgang für \(name) eingetragen.",
            es: "No se ha registrado ninguna deposición de \(name) en los últimos \(days) días.",
            fr: "Aucune selle enregistrée pour \(name) ces \(days) derniers jours.",
            pt: "Nenhuma evacuação registada para \(name) nos últimos \(days) dias.",
            zh: "过去 \(days) 天没有记录 \(name) 的大便。"
        )
        return DailyTip(text: text(ctx.language), contextHash: ctx.contextHash, category: .situational)
    }

    // Logged sleep well below the WHO lower bound (evening only) — cited claim.
    private static func checkSleepDeficit(_ ctx: DailyContext) -> DailyTip? {
        // With no sleep logged (sleepCount == 0) totalSleepMinutes is 0 by absence,
        // not by a real deficit — only warn once at least one sleep has been tracked.
        guard ctx.hour >= 19, ctx.sleepCount >= 1 else { return nil }
        let minSleep = CareHeuristics.minSleepMinutes(ageMonths: ctx.ageMonths)
        guard ctx.totalSleepMinutes < minSleep - 90 else { return nil }
        let sleptH = ctx.totalSleepMinutes / 60
        let minH = minSleep / 60
        let name = ctx.babyName
        let text = LocalizedText(
            en: "\(name) has slept \(sleptH) h today. WHO recommends at least \(minH) h of sleep in 24 hours, including naps, at this age.",
            ru: "Сегодня \(name) спал \(sleptH) ч. ВОЗ рекомендует в этом возрасте не менее \(minH) ч сна за сутки, включая дневной.",
            de: "\(name) hat heute \(sleptH) Std. geschlafen. Die WHO empfiehlt in diesem Alter mindestens \(minH) Std. Schlaf in 24 Stunden, inklusive Nickerchen.",
            es: "\(name) ha dormido \(sleptH) h hoy. La OMS recomienda al menos \(minH) h de sueño en 24 horas, siestas incluidas, a esta edad.",
            fr: "\(name) a dormi \(sleptH) h aujourd’hui. L’OMS recommande au moins \(minH) h de sommeil sur 24 heures, siestes comprises, à cet âge.",
            pt: "\(name) dormiu \(sleptH) h hoje. A OMS recomenda pelo menos \(minH) h de sono em 24 horas, incluindo sestas, nesta idade.",
            zh: "\(name) 今天睡了 \(sleptH) 小时。世卫组织建议这个年龄每 24 小时至少睡 \(minH) 小时（含小睡）。"
        )
        return DailyTip(
            text: text(ctx.language), contextHash: ctx.contextHash, category: .alert,
            sources: [.whoPhysicalActivitySleepUnder5], isMedicalClaim: true
        )
    }
}

// MARK: - PRIORITY 2: Situational Rules

enum SituationalRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        checkJustFed(context)
        ?? checkLongAwake(context)
        ?? checkBathEvening(context)
        ?? checkBreastSide(context)
        ?? checkNoWalk(context)
    }

    // Just finished feeding (< 10 min ago, >= 5 min duration) — cited claim.
    private static func checkJustFed(_ ctx: DailyContext) -> DailyTip? {
        guard let minsAgo = ctx.minutesSinceLastFeed,
              minsAgo <= 10,
              ctx.lastFeedDurationMinutes >= 5 else { return nil }
        let name = ctx.babyName
        let text = LocalizedText(
            en: "After a feed, holding \(name) upright for a while may help with spitting up.",
            ru: "После кормления подержите \(name) какое-то время вертикально — это может помочь при срыгиваниях.",
            de: "Nach dem Füttern \(name) eine Weile aufrecht zu halten, kann bei Spucken helfen.",
            es: "Después de la toma, mantener a \(name) erguido un rato puede ayudar con las regurgitaciones.",
            fr: "Après la tétée, tenir \(name) droit un moment peut aider en cas de régurgitations.",
            pt: "Depois da mamada, manter \(name) na vertical durante algum tempo pode ajudar com o bolçar.",
            zh: "喂奶后让 \(name) 竖直待一会儿，可能有助于减少吐奶。"
        )
        return DailyTip(
            text: text(ctx.language), contextHash: ctx.contextHash, category: .situational,
            sources: [.nhsRefluxInBabies], isMedicalClaim: true
        )
    }

    // Long time awake since the last logged sleep — neutral observation.
    private static func checkLongAwake(_ ctx: DailyContext) -> DailyTip? {
        guard let awakeMins = ctx.minutesSinceLastSleepEnd, awakeMins > 0 else { return nil }
        guard awakeMins > CareHeuristics.awakeWindowMax(ageMonths: ctx.ageMonths) else { return nil }
        let name = ctx.babyName
        let text = LocalizedText(
            en: "\(name) has been awake for \(awakeMins) min since the last logged sleep.",
            ru: "\(name) бодрствует \(awakeMins) мин с последнего записанного сна.",
            de: "\(name) ist seit dem letzten eingetragenen Schlaf \(awakeMins) Min. wach.",
            es: "\(name) lleva \(awakeMins) min despierto desde el último sueño registrado.",
            fr: "Cela fait \(awakeMins) min que \(name) est éveillé depuis son dernier sommeil enregistré.",
            pt: "\(name) está acordado há \(awakeMins) min desde o último sono registado.",
            zh: "自上次记录的睡眠以来，\(name) 已清醒 \(awakeMins) 分钟。"
        )
        return DailyTip(text: text(ctx.language), contextHash: ctx.contextHash, category: .situational)
    }

    // Evening bath not done yet — cited claim.
    private static func checkBathEvening(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.hour >= 18, ctx.hour <= 21,
              ctx.bathCount == 0,
              ctx.ageMonths >= 1 else { return nil }
        let name = ctx.babyName
        let text = LocalizedText(
            en: "A bath can be a calming part of \(name)'s bedtime routine. Check the water is warm, not hot, before putting \(name) in.",
            ru: "Вечернее купание может стать спокойной частью ритуала отхода ко сну \(name). Перед купанием проверьте, что вода тёплая, а не горячая.",
            de: "Ein Bad kann ein beruhigender Teil der Abendroutine von \(name) sein. Prüfe vorher, dass das Wasser warm und nicht heiß ist.",
            es: "El baño puede ser una parte relajante de la rutina de antes de dormir de \(name). Comprueba que el agua esté templada, no caliente.",
            fr: "Le bain peut être un moment apaisant du rituel du coucher de \(name). Vérifiez que l’eau est tiède, pas chaude.",
            pt: "O banho pode ser uma parte calmante da rotina de deitar de \(name). Verifique se a água está morna, não quente.",
            zh: "洗澡可以成为 \(name) 睡前流程中让人放松的一环。放宝宝入水前，确认水温是温的而不是烫的。"
        )
        return DailyTip(
            text: text(ctx.language), contextHash: ctx.contextHash, category: .situational,
            sources: [.nhsHelpingBabySleep, .nhsWashingBathingBaby], isMedicalClaim: true
        )
    }

    // Repeatedly feeding from the same side — neutral observation.
    private static func checkBreastSide(_ ctx: DailyContext) -> DailyTip? {
        let sides = ctx.recentFeedSides
        guard sides.count >= 3 else { return nil }
        let prefix3 = Array(sides.prefix(3))
        guard Set(prefix3).count == 1 else { return nil }
        let side = prefix3[0]
        let isLeft = side.contains("лев") || side.lowercased().contains("left") || side.lowercased().contains("links")
        let text = LocalizedText(
            en: "The last 3 logged feeds were from the same side. Next time you could start with the \(isLeft ? "right" : "left") breast.",
            ru: "Последние 3 записанных кормления были с одной стороны. В следующий раз можно начать с \(isLeft ? "правой" : "левой") груди.",
            de: "Die letzten 3 eingetragenen Mahlzeiten waren auf derselben Seite. Beim nächsten Mal kannst du mit der \(isLeft ? "rechten" : "linken") Brust beginnen.",
            es: "Las últimas 3 tomas registradas fueron del mismo lado. La próxima vez puedes empezar por el pecho \(isLeft ? "derecho" : "izquierdo").",
            fr: "Les 3 dernières tétées enregistrées étaient du même côté. La prochaine fois, vous pouvez commencer par le sein \(isLeft ? "droit" : "gauche").",
            pt: "As últimas 3 mamadas registadas foram do mesmo lado. Da próxima vez pode começar pelo peito \(isLeft ? "direito" : "esquerdo").",
            zh: "最近记录的 3 次喂奶都是同一侧。下次可以先从\(isLeft ? "右侧" : "左侧")乳房开始。"
        )
        return DailyTip(text: text(ctx.language), contextHash: ctx.contextHash, category: .situational)
    }

    // No walk during daytime — neutral suggestion.
    private static func checkNoWalk(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.walkCount == 0,
              ctx.hour >= 10, ctx.hour <= 16,
              ctx.ageMonths >= 1 else { return nil }
        let text = LocalizedText(
            en: "No walk logged today yet. A little time outdoors together can be a nice break for you both.",
            ru: "Сегодня прогулок пока не записано. Немного времени на улице вместе — приятная передышка для вас обоих.",
            de: "Heute noch kein Spaziergang eingetragen. Ein bisschen Zeit draußen kann für euch beide eine schöne Pause sein.",
            es: "Hoy aún no hay ningún paseo registrado. Un rato al aire libre juntos puede ser un buen descanso para los dos.",
            fr: "Aucune promenade enregistrée aujourd’hui. Un petit moment dehors ensemble peut être une jolie pause pour vous deux.",
            pt: "Ainda não há passeios registados hoje. Um pouco de tempo ao ar livre juntos pode ser uma boa pausa para os dois.",
            zh: "今天还没有记录散步。一起到户外待一会儿，对你们俩都是不错的放松。"
        )
        return DailyTip(text: text(ctx.language), contextHash: ctx.contextHash, category: .situational)
    }
}

// MARK: - PRIORITY 3: Care Rules (always returns a tip)

enum CareRules {

    struct CareTip {
        let text: LocalizedText
        /// Empty only for neutral, non-medical copy.
        let sources: [MedicalSourceID]
        let isMedicalClaim: Bool

        static func claim(_ sources: [MedicalSourceID], _ text: LocalizedText) -> CareTip {
            CareTip(text: text, sources: sources, isMedicalClaim: true)
        }

        static func neutral(_ text: LocalizedText) -> CareTip {
            CareTip(text: text, sources: [], isMedicalClaim: false)
        }
    }

    static func evaluate(context: DailyContext) -> DailyTip {
        let pool = pool(ageMonths: context.ageMonths)
        let tip = pool[context.dayOfYear % pool.count]
        let text = tip.text(context.language).replacingOccurrences(of: "[name]", with: context.babyName)
        return DailyTip(
            text: text, contextHash: context.contextHash, category: .care,
            sources: tip.sources, isMedicalClaim: tip.isMedicalClaim
        )
    }

    static func pool(ageMonths age: Int) -> [CareTip] {
        switch age {
        case 0:       return newborn
        case 1...2:   return months1to2
        case 3...5:   return months3to5
        case 6...8:   return months6to8
        case 9...11:  return months9to11
        case 12...17: return months12to17
        default:      return months18to24
        }
    }

    // MARK: Pools

    private static let newborn: [CareTip] = [
        .claim([.whoPostnatalCare2022], LocalizedText(
            en: "Keep [name]'s umbilical cord stump clean and dry, and don't put anything on it unless your health worker advises it.",
            ru: "Держите пупочный остаток [name] чистым и сухим и ничего на него не наносите, если врач или патронажная сестра не посоветовали иное.",
            de: "Halte den Nabelschnurrest von [name] sauber und trocken und trage nichts darauf auf, außer auf Rat deiner Hebamme oder Ärztin.",
            es: "Mantén limpio y seco el muñón del cordón umbilical de [name] y no le apliques nada salvo que te lo indique tu profesional sanitario.",
            fr: "Gardez le moignon du cordon ombilical de [name] propre et sec, et n’y appliquez rien sauf avis de votre professionnel de santé.",
            pt: "Mantenha o coto umbilical de [name] limpo e seco e não aplique nada, a não ser que o profissional de saúde o recomende.",
            zh: "保持 [name] 的脐带残端清洁干燥，除非医护人员建议，不要在上面涂抹任何东西。"
        )),
        .claim([.whoEarlyChildhoodDevelopment2020], LocalizedText(
            en: "Talk and sing to [name] during everyday care — responsive, playful interaction supports early development.",
            ru: "Разговаривайте с [name] и пойте во время повседневного ухода — чуткое, игровое общение поддерживает раннее развитие.",
            de: "Sprich und singe mit [name] bei der täglichen Pflege — liebevolle, spielerische Zuwendung unterstützt die frühe Entwicklung.",
            es: "Habla y canta a [name] durante los cuidados diarios — la interacción cercana y lúdica favorece el desarrollo temprano.",
            fr: "Parlez et chantez à [name] pendant les soins du quotidien — une interaction attentive et ludique soutient le développement précoce.",
            pt: "Fale e cante para [name] durante os cuidados do dia a dia — a interação atenta e lúdica apoia o desenvolvimento inicial.",
            zh: "在日常照护中多和 [name] 说话、唱歌——积极回应、充满乐趣的互动有助于早期发展。"
        )),
        .claim([.whoPhysicalActivitySleepUnder5], LocalizedText(
            en: "Give [name] short sessions of tummy time while awake and watched, spread through the day.",
            ru: "Выкладывайте [name] на животик короткими сессиями в течение дня — только когда малыш бодрствует и под присмотром.",
            de: "Lege [name] tagsüber immer wieder kurz auf den Bauch — nur im Wachzustand und unter Aufsicht.",
            es: "Pon a [name] boca abajo en sesiones cortas repartidas a lo largo del día, siempre despierto y vigilado.",
            fr: "Installez [name] sur le ventre par courtes séances réparties dans la journée, uniquement éveillé et sous surveillance.",
            pt: "Coloque [name] de barriga para baixo em sessões curtas ao longo do dia, sempre acordado e vigiado.",
            zh: "在 [name] 清醒且有人看护时，每天分几次进行短时间的俯卧（趴卧）练习。"
        )),
        .claim([.aapSwaddling], LocalizedText(
            en: "Swaddling helps some newborns sleep longer — arms along the body, hips free, not too tight.",
            ru: "Пеленание помогает некоторым новорождённым спать дольше — руки вдоль тела, бёдра свободно, не туго.",
            de: "Pucken kann manchen Neugeborenen helfen, länger zu schlafen — Arme am Körper, Hüften frei, nicht zu fest.",
            es: "Envolver al bebé ayuda a algunos recién nacidos a dormir más — brazos junto al cuerpo, caderas libres, sin apretar.",
            fr: "L’emmaillotage aide certains nouveau-nés à dormir plus longtemps — bras le long du corps, hanches libres, pas trop serré.",
            pt: "Enrolar em fralda ajuda alguns recém-nascidos a dormir mais — braços ao longo do corpo, ancas livres, sem apertar.",
            zh: "包裹（蜡烛包）能帮助一些新生儿睡得更久——手臂沿身体放好，髋部留有活动空间，不要包太紧。"
        )),
        .claim([.whoPostnatalCare2022], LocalizedText(
            en: "Skin-to-skin contact helps keep [name] warm and supports breastfeeding.",
            ru: "Контакт кожа-к-коже помогает [name] сохранять тепло и поддерживает грудное вскармливание.",
            de: "Hautkontakt hilft, [name] warm zu halten, und unterstützt das Stillen.",
            es: "El contacto piel con piel ayuda a mantener a [name] caliente y favorece la lactancia materna.",
            fr: "Le peau à peau aide [name] à garder sa chaleur et favorise l’allaitement.",
            pt: "O contacto pele com pele ajuda a manter [name] quente e favorece a amamentação.",
            zh: "肌肤接触有助于 [name] 保暖，也有助于母乳喂养。"
        ))
    ]

    private static let months1to2: [CareTip] = [
        .claim([.nhsColic], LocalizedText(
            en: "If [name] seems windy, holding them upright during feeds and burping them afterwards may help.",
            ru: "Если [name] беспокоят газики, держите малыша вертикальнее во время кормления и дайте срыгнуть воздух после.",
            de: "Wenn [name] Blähungen zu haben scheint, kann es helfen, beim Füttern aufrecht zu halten und danach aufstoßen zu lassen.",
            es: "Si [name] parece tener gases, puede ayudar mantenerlo erguido durante las tomas y hacerle eructar después.",
            fr: "Si [name] semble avoir des gaz, le tenir droit pendant la tétée et lui faire faire son rot ensuite peut aider.",
            pt: "Se [name] parecer ter gases, pode ajudar mantê-lo na vertical durante a mamada e pô-lo a arrotar depois.",
            zh: "如果 [name] 似乎肚子胀气，喂奶时尽量竖着抱，喂完后帮宝宝拍嗝，可能会有帮助。"
        )),
        .claim([.nhsColic], LocalizedText(
            en: "Colic usually starts when a baby is a few weeks old and normally stops by 6 months. Gently rocking [name] or white noise may help.",
            ru: "Колики обычно начинаются в возрасте нескольких недель и, как правило, проходят к 6 месяцам. Может помочь мягкое укачивание [name] или белый шум.",
            de: "Koliken beginnen meist, wenn ein Baby wenige Wochen alt ist, und hören normalerweise bis zum 6. Monat auf. Sanftes Wiegen von [name] oder weißes Rauschen können helfen.",
            es: "Los cólicos suelen empezar cuando el bebé tiene pocas semanas y normalmente desaparecen hacia los 6 meses. Mecer suavemente a [name] o el ruido blanco pueden ayudar.",
            fr: "Les coliques commencent généralement quand bébé a quelques semaines et cessent normalement vers 6 mois. Bercer doucement [name] ou un bruit blanc peuvent aider.",
            pt: "As cólicas costumam começar quando o bebé tem poucas semanas e normalmente passam por volta dos 6 meses. Embalar [name] suavemente ou ruído branco podem ajudar.",
            zh: "肠绞痛通常在宝宝几周大时开始，一般到 6 个月时消失。轻轻摇晃 [name] 或播放白噪音可能会有帮助。"
        )),
        .neutral(LocalizedText(
            en: "Black-and-white books and cards make a great first toy for [name] — young babies love high-contrast pictures.",
            ru: "Чёрно-белые книжки и карточки — отличная первая игрушка для [name]: малыши любят контрастные картинки.",
            de: "Schwarz-weiße Bücher und Karten sind ein tolles erstes Spielzeug für [name] — kleine Babys lieben kontrastreiche Bilder.",
            es: "Los libros y tarjetas en blanco y negro son un gran primer juguete para [name]: a los bebés les encantan las imágenes de alto contraste.",
            fr: "Les livres et cartes en noir et blanc sont un super premier jouet pour [name] — les tout-petits adorent les images contrastées.",
            pt: "Livros e cartões a preto e branco são um ótimo primeiro brinquedo para [name] — os bebés adoram imagens de alto contraste.",
            zh: "黑白书和卡片是 [name] 很好的第一件玩具——小宝宝很喜欢高对比度的图片。"
        ))
    ]

    private static let months3to5: [CareTip] = [
        .neutral(LocalizedText(
            en: "Looking at picture books together is a lovely awake-time activity — 10–15 minutes is plenty.",
            ru: "Рассматривать вместе книжки с картинками — приятное занятие в период бодрствования; 10–15 минут вполне достаточно.",
            de: "Gemeinsam Bilderbücher anschauen ist eine schöne Beschäftigung in der Wachzeit — 10–15 Minuten reichen völlig.",
            es: "Mirar juntos libros con imágenes es una actividad preciosa para los ratos despierto — 10–15 minutos son suficientes.",
            fr: "Regarder des imagiers ensemble est une jolie activité d’éveil — 10 à 15 minutes suffisent largement.",
            pt: "Ver livros de imagens juntos é uma atividade ótima para os momentos acordado — 10–15 minutos chegam.",
            zh: "一起看图画书是清醒时很好的亲子活动——10–15 分钟就足够了。"
        )),
        .claim([.whoPhysicalActivitySleepUnder5], LocalizedText(
            en: "For babies who can't crawl yet, WHO recommends at least 30 minutes of tummy time a day, spread out while [name] is awake.",
            ru: "Для малышей, которые ещё не ползают, ВОЗ рекомендует не менее 30 минут в день на животике, распределённых по времени бодрствования [name].",
            de: "Für Babys, die noch nicht krabbeln, empfiehlt die WHO mindestens 30 Minuten Bauchlage am Tag, verteilt auf die Wachzeiten von [name].",
            es: "Para los bebés que aún no gatean, la OMS recomienda al menos 30 minutos al día boca abajo, repartidos mientras [name] está despierto.",
            fr: "Pour les bébés qui ne rampent pas encore, l’OMS recommande au moins 30 minutes par jour sur le ventre, réparties pendant les temps d’éveil de [name].",
            pt: "Para bebés que ainda não gatinham, a OMS recomenda pelo menos 30 minutos por dia de barriga para baixo, distribuídos enquanto [name] está acordado.",
            zh: "对于还不会爬的宝宝，世卫组织建议每天至少俯卧 30 分钟，分散在 [name] 清醒的时间里进行。"
        )),
        .claim([.nhsTeething], LocalizedText(
            en: "Most babies start teething around 6 months. A teething ring cooled in the fridge (never the freezer) can soothe sore gums.",
            ru: "У большинства малышей зубки начинают резаться около 6 месяцев. Прорезыватель, охлаждённый в холодильнике (не в морозилке), может успокоить дёсны.",
            de: "Bei den meisten Babys beginnt das Zahnen um den 6. Monat. Ein im Kühlschrank (nie im Gefrierfach) gekühlter Beißring kann das Zahnfleisch beruhigen.",
            es: "La mayoría de los bebés empiezan la dentición hacia los 6 meses. Un mordedor enfriado en la nevera (nunca en el congelador) puede aliviar las encías.",
            fr: "La plupart des bébés commencent à faire leurs dents vers 6 mois. Un anneau de dentition rafraîchi au réfrigérateur (jamais au congélateur) peut soulager les gencives.",
            pt: "A maioria dos bebés começa a ter dentes por volta dos 6 meses. Um mordedor arrefecido no frigorífico (nunca no congelador) pode aliviar as gengivas.",
            zh: "大多数宝宝在 6 个月左右开始出牙。放在冰箱冷藏（不要冷冻）过的牙胶可以舒缓牙龈不适。"
        )),
        .neutral(LocalizedText(
            en: "Rattles and grasping toys train motor skills. Alternate the hand you offer toys to — both sides need practice.",
            ru: "Погремушки и хватательные игрушки тренируют моторику. Меняйте руку при подаче игрушки — обе стороны должны работать.",
            de: "Rasseln und Greifspielzeug trainieren die Motorik. Wechsle die Hand beim Anbieten von Spielzeug — beide Seiten brauchen Übung.",
            es: "Los sonajeros y juguetes para agarrar entrenan la motricidad. Alterna la mano con la que ofreces los juguetes — ambos lados necesitan práctica.",
            fr: "Les hochets et jouets à saisir entraînent la motricité. Alternez la main avec laquelle vous tendez les jouets — les deux côtés ont besoin de pratique.",
            pt: "Roca e brinquedos de agarrar treinam a motricidade. Alterne a mão com que oferece os brinquedos — ambos os lados precisam de prática.",
            zh: "摇铃和可抓握的玩具能锻炼精细动作。递玩具时左右手交替——两侧都要练习。"
        )),
        .neutral(LocalizedText(
            en: "Show [name] their reflection in a mirror for focus development — at this age it sparks immediate interest.",
            ru: "Для развития концентрации покажите [name] собственное отражение в зеркале — в этом возрасте это вызывает живой интерес.",
            de: "Zeige [name] sein Spiegelbild — in diesem Alter weckt das sofort Interesse und fördert die Konzentration.",
            es: "Muéstrale a [name] su reflejo en un espejo para desarrollar la concentración — a esta edad despierta interés inmediato.",
            fr: "Montrez à [name] son reflet dans un miroir — à cet âge, cela éveille un intérêt immédiat et développe la concentration.",
            pt: "Mostre a [name] o seu reflexo num espelho para desenvolver a concentração — nesta idade desperta interesse imediato.",
            zh: "让 [name] 看镜子里的自己，能培养专注力——这个年龄会立刻产生浓厚兴趣。"
        ))
    ]

    private static let months6to8: [CareTip] = [
        .claim([.whoComplementaryFeeding2023], LocalizedText(
            en: "From 6 months, [name] needs solid foods alongside milk. Offer a variety: vegetables, fruit, and animal-source foods such as eggs, meat or fish.",
            ru: "С 6 месяцев [name] нужен прикорм в дополнение к молоку. Предлагайте разнообразную еду: овощи, фрукты и продукты животного происхождения — яйца, мясо, рыбу.",
            de: "Ab 6 Monaten braucht [name] zusätzlich zur Milch feste Nahrung. Biete Abwechslung an: Gemüse, Obst und tierische Lebensmittel wie Eier, Fleisch oder Fisch.",
            es: "A partir de los 6 meses, [name] necesita alimentos sólidos además de la leche. Ofrece variedad: verduras, fruta y alimentos de origen animal como huevo, carne o pescado.",
            fr: "Dès 6 mois, [name] a besoin d’aliments solides en plus du lait. Proposez de la variété : légumes, fruits et aliments d’origine animale comme œuf, viande ou poisson.",
            pt: "A partir dos 6 meses, [name] precisa de alimentos sólidos além do leite. Ofereça variedade: legumes, fruta e alimentos de origem animal como ovo, carne ou peixe.",
            zh: "从 6 个月起，[name] 在喝奶之外还需要添加辅食。提供多样化的食物：蔬菜、水果，以及蛋、肉、鱼等动物性食物。"
        )),
        .neutral(LocalizedText(
            en: "Encourage crawling: place a toy just out of [name]'s reach.",
            ru: "Стимулируйте ползание: положите игрушку чуть дальше, чем [name] может дотянуться.",
            de: "Ermutige zum Krabbeln: Lege ein Spielzeug knapp außer Reichweite von [name].",
            es: "Anima a gatear: pon un juguete justo fuera del alcance de [name].",
            fr: "Encouragez le quatre-pattes : placez un jouet juste hors de portée de [name].",
            pt: "Incentive o gatinhar: coloque um brinquedo mesmo fora do alcance de [name].",
            zh: "鼓励爬行：把玩具放在 [name] 刚好够不着的地方。"
        )),
        .neutral(LocalizedText(
            en: "Speech development: narrate everything you do. We're eating now, picking up the spoon — vocabulary builds from 6 months.",
            ru: "Речевое развитие: называйте всё что делаете вслух. «Сейчас едим», «берём ложку» — словарный запас формируется с 6 мес.",
            de: "Sprachentwicklung: kommentiere alles laut. Jetzt essen wir, nehmen den Löffel — der Wortschatz baut sich ab 6 Mon. auf.",
            es: "Desarrollo del habla: narra todo lo que haces. «Ahora comemos», «cogemos la cuchara» — el vocabulario se forma desde los 6 meses.",
            fr: "Développement du langage : commentez tout ce que vous faites à voix haute. « On mange », « on prend la cuillère » — le vocabulaire se construit dès 6 mois.",
            pt: "Desenvolvimento da fala: narre tudo o que faz. «Agora vamos comer», «pegamos na colher» — o vocabulário forma-se a partir dos 6 meses.",
            zh: "语言发展：把你做的每件事说出来。「我们要吃饭啦」「拿起勺子」——词汇量从 6 个月开始积累。"
        )),
        .neutral(LocalizedText(
            en: "Peek-a-boo is more than fun. It teaches [name] object permanence: mummy leaves and comes back.",
            ru: "Игра в «ку-ку» — не просто веселье. Она учит [name] концепции постоянства объектов: «мама уходит и возвращается».",
            de: "Kuckuckspiele sind mehr als Spaß. Sie lehren [name] Objektpermanenz: Mama geht weg und kommt zurück.",
            es: "El cucú-tras es más que diversión. Le enseña a [name] la permanencia del objeto: mamá se va y vuelve.",
            fr: "Le jeu du coucou est bien plus qu’un jeu. Il apprend à [name] la permanence de l’objet : maman s’en va et revient.",
            pt: "O jogo do cu-cu é mais do que diversão. Ensina a [name] a permanência do objeto: a mamã sai e volta.",
            zh: "躲猫猫不只是好玩。它教会 [name] 客体永存：妈妈会离开，也会回来。"
        ))
    ]

    private static let months9to11: [CareTip] = [
        .neutral(LocalizedText(
            en: "First steps begin with cruising along furniture. Don't always hold [name]'s hands — independent balance needs practice.",
            ru: "Первые шаги начинаются с хождения вдоль опоры. Не держите [name] за руки постоянно — нужен баланс самостоятельности.",
            de: "Erste Schritte beginnen mit Laufen entlang von Möbeln. Halte [name] nicht immer an den Händen — Balance braucht Eigenständigkeit.",
            es: "Los primeros pasos empiezan caminando apoyado en los muebles. No le sujetes siempre las manos a [name] — el equilibrio autónomo necesita práctica.",
            fr: "Les premiers pas commencent en marchant le long des meubles. Ne tenez pas toujours [name] par les mains — l’équilibre autonome a besoin de pratique.",
            pt: "Os primeiros passos começam a andar apoiado nos móveis. Não segure sempre as mãos de [name] — o equilíbrio autónomo precisa de prática.",
            zh: "迈出第一步从扶着家具横走开始。不要一直牵着 [name] 的手——独立平衡需要练习。"
        )),
        .neutral(LocalizedText(
            en: "Speech: comprehension precedes production. At 9–10 months [name] understands no, give, come. Speak slowly and clearly.",
            ru: "Речь: понимание слов опережает произношение. В 9–10 мес [name] понимает «нет», «дай», «иди». Говорите медленно и чётко.",
            de: "Sprache: Verstehen geht dem Sprechen voraus. Mit 9–10 Mon. versteht [name] nein, gib, komm. Langsam und deutlich sprechen.",
            es: "Habla: la comprensión va antes que la producción. A los 9–10 meses [name] entiende «no», «dame», «ven». Habla despacio y claro.",
            fr: "Langage : la compréhension précède la production. À 9–10 mois, [name] comprend « non », « donne », « viens ». Parlez lentement et clairement.",
            pt: "Fala: a compreensão precede a produção. Aos 9–10 meses [name] entende «não», «dá», «vem». Fale devagar e com clareza.",
            zh: "语言：理解先于表达。9–10 个月时 [name] 能听懂「不」「给」「过来」。说话要慢而清晰。"
        )),
        .neutral(LocalizedText(
            en: "Now is a good time to introduce a sippy cup.",
            ru: "Стаканчик с носиком — хорошее время вводить.",
            de: "Ein Schnabelbecher eignet sich jetzt gut.",
            es: "Es buen momento para introducir el vaso con boquilla.",
            fr: "C’est un bon moment pour introduire le gobelet à bec.",
            pt: "É boa altura para introduzir o copo com bico.",
            zh: "现在是引入鸭嘴杯的好时机。"
        )),
        .neutral(LocalizedText(
            en: "Sorters, stacking cups, boxes with lids — the best toys for [name] right now. The inside/outside concept is forming.",
            ru: "Сортеры, стаканчики, коробки с крышками — лучшие игрушки для [name]. Концепция «внутри/снаружи» активно формируется.",
            de: "Sortierer, Stapelbecher, Dosen mit Deckel — die besten Spielzeuge für [name]. Das Konzept innen/außen entwickelt sich gerade.",
            es: "Encajables, vasos apilables, cajas con tapa — los mejores juguetes para [name] ahora. El concepto dentro/fuera se está formando.",
            fr: "Boîtes à formes, gobelets à empiler, boîtes à couvercle — les meilleurs jouets pour [name] en ce moment. La notion dedans/dehors se construit.",
            pt: "Encaixes, copos de empilhar, caixas com tampa — os melhores brinquedos para [name] agora. O conceito dentro/fora está a formar-se.",
            zh: "形状分类盒、套叠杯、带盖的盒子是 [name] 现在最好的玩具。「里面/外面」的概念正在形成。"
        ))
    ]

    private static let months12to17: [CareTip] = [
        .neutral(LocalizedText(
            en: "The one-year crisis is normal. Tantrums come from frustration, not manipulation. A calm parental response is the best reply.",
            ru: "Кризис 1 года — нормальное явление. Истерики от бессилия, а не манипуляция. Спокойная реакция родителя — лучший ответ.",
            de: "Die Einjahres-Krise ist normal. Wutausbrüche kommen aus Hilflosigkeit, nicht aus Manipulation. Ruhige elterliche Reaktion ist die beste Antwort.",
            es: "La crisis del primer año es normal. Las rabietas vienen de la frustración, no de la manipulación. Una respuesta tranquila de los padres es la mejor.",
            fr: "La crise de la première année est normale. Les colères viennent de la frustration, non de la manipulation. Une réponse parentale calme est la meilleure.",
            pt: "A crise do primeiro ano é normal. As birras vêm da frustração, não da manipulação. Uma resposta calma dos pais é a melhor.",
            zh: "一岁叛逆期很正常。发脾气是出于无力感，而非操控。家长保持平静是最好的回应。"
        )),
        .neutral(LocalizedText(
            en: "Finger painting and dough modelling develop fine motor skills and speech at the same time. Ten minutes a day is enough.",
            ru: "Рисование пальцами, лепка из теста развивают мелкую моторику и речь одновременно. 10 мин в день достаточно.",
            de: "Malen mit Fingern und Kneten mit Teig entwickeln Feinmotorik und Sprache gleichzeitig. Zehn Minuten täglich genügen.",
            es: "Pintar con los dedos y modelar masa desarrollan la motricidad fina y el habla a la vez. Diez minutos al día bastan.",
            fr: "Peindre avec les doigts et modeler de la pâte développent la motricité fine et le langage en même temps. Dix minutes par jour suffisent.",
            pt: "Pintar com os dedos e modelar massa desenvolvem a motricidade fina e a fala ao mesmo tempo. Dez minutos por dia são suficientes.",
            zh: "手指画、玩面团能同时锻炼精细动作和语言。每天 10 分钟就够了。"
        ))
    ]

    private static let months18to24: [CareTip] = [
        .neutral(LocalizedText(
            en: "Parallel play (near but not together) is normal at [name]'s age. Social play with peers develops later, around 3 years.",
            ru: "Параллельная игра (рядом, но не вместе) — норма для этого возраста [name]. Социальная игра с ровесниками придёт позже, к 3 годам.",
            de: "Parallelspiel (nebeneinander, aber nicht miteinander) ist in [name]s Alter normal. Soziales Spiel mit Gleichaltrigen kommt später, um das 3. Jahr.",
            es: "El juego paralelo (cerca pero no juntos) es normal a la edad de [name]. El juego social con iguales llega más tarde, hacia los 3 años.",
            fr: "Le jeu en parallèle (à côté, mais pas ensemble) est normal à l’âge de [name]. Le jeu social avec les pairs vient plus tard, vers 3 ans.",
            pt: "O jogo paralelo (perto, mas não em conjunto) é normal na idade de [name]. O jogo social com pares surge mais tarde, por volta dos 3 anos.",
            zh: "平行游戏（在旁边玩但不一起玩）是 [name] 这个年龄的正常表现。与同伴的社交游戏要到 3 岁左右才会出现。"
        )),
        .neutral(LocalizedText(
            en: "Potty readiness appears at 18–24 months. Signs: dry nappy for 2 h in a row, [name] points to the potty.",
            ru: "Готовность к горшку появляется в 18–24 мес. Признаки: сухой подгузник 2 ч подряд, [name] указывает на горшок.",
            de: "Die Töpfchenbereitschaft zeigt sich mit 18–24 Mon. Zeichen: trockene Windel 2 Std. am Stück, [name] zeigt auf den Topf.",
            es: "La preparación para el orinal aparece a los 18–24 meses. Señales: pañal seco 2 h seguidas, [name] señala el orinal.",
            fr: "Le signe de propreté apparaît à 18–24 mois. Indices : couche sèche 2 h d’affilée, [name] montre le pot.",
            pt: "A prontidão para o bacio surge aos 18–24 meses. Sinais: fralda seca durante 2 h seguidas, [name] aponta para o bacio.",
            zh: "如厕准备能力在 18–24 个月出现。迹象：尿布连续 2 小时保持干燥、[name] 会指向便盆。"
        ))
    ]
}
