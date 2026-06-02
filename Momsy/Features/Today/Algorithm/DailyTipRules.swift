import Foundation

// MARK: - PRIORITY 1: Alert Rules

enum AlertRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        checkFeedingInterval(context)
        ?? checkDiaperCount(context)
        ?? checkStool(context)
        ?? checkSleepDeficit(context)
    }

    // Alert A: too long since last feed
    private static func checkFeedingInterval(_ ctx: DailyContext) -> DailyTip? {
        guard let mins = ctx.minutesSinceLastFeed else { return nil }
        let maxInt = WhoNorms.maxFeedingInterval(ageMonths: ctx.ageMonths)
        guard mins > maxInt else { return nil }
        let hours = mins / 60
        let maxHours = maxInt / 60
        let text: String
        switch ctx.language {
        case .russian:
            text = "Прошло уже \(hours) ч с кормления. Для \(ctx.ageMonths) мес обычный интервал до \(maxHours) ч — если \(ctx.babyName) не просит сам, попробуйте предложить грудь."
        case .english, .portuguese:
            text = "It's been \(hours) hours since the last feed. For \(ctx.ageMonths) months, the usual interval is up to \(maxHours) h — if \(ctx.babyName) hasn't asked, try offering."
        case .spanish:
            text = "Han pasado \(hours) horas desde la última toma. Para \(ctx.ageMonths) meses, el intervalo habitual es de hasta \(maxHours) h — si \(ctx.babyName) no la pide, prueba a ofrecerle el pecho."
        case .german:
            text = "Es sind bereits \(hours) Stunden seit der letzten Mahlzeit vergangen. Für \(ctx.ageMonths) Monate ist das Intervall normalerweise bis zu \(maxHours) h — biete \(ctx.babyName) die Brust an."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }

    // Alert B: too few wet diapers
    private static func checkDiaperCount(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.diaperCount < 4, ctx.hour >= 18, ctx.ageMonths <= 6 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Сегодня пока \(ctx.diaperCount) подгузника — для \(ctx.ageMonths) мес норма 6–8 в день. Это сигнал о недостаточном питье. Предложите грудь или смесь чаще обычного."
        case .english, .portuguese:
            text = "Only \(ctx.diaperCount) wet diapers so far today — for \(ctx.ageMonths) months the norm is 6–8 per day. This signals insufficient fluid. Offer the breast or formula more often."
        case .spanish:
            text = "Solo \(ctx.diaperCount) pañales mojados hoy — para \(ctx.ageMonths) meses lo normal son 6–8 al día. Es señal de poca ingesta de líquido. Ofrece el pecho o la fórmula más a menudo."
        case .german:
            text = "Heute bisher nur \(ctx.diaperCount) Windeln — für \(ctx.ageMonths) Monate sind 6–8 pro Tag normal. Das ist ein Zeichen für zu wenig Trinken. Biete öfter Brust oder Fläschchen an."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }

    // Alert C: no stool for too many days
    private static func checkStool(_ ctx: DailyContext) -> DailyTip? {
        let alertDays = WhoNorms.maxDaysWithoutStool(ageMonths: ctx.ageMonths)
        guard ctx.daysSinceLastStool >= alertDays else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Стула не было \(ctx.daysSinceLastStool) дн. Попробуйте «велосипед»: положите \(ctx.babyName) на спину и аккуратно сгибайте ножки к животику 10–15 раз."
        case .english, .portuguese:
            text = "No stool for \(ctx.daysSinceLastStool) days. Try the bicycle exercise: lay \(ctx.babyName) on their back and gently cycle their legs toward the tummy 10–15 times."
        case .spanish:
            text = "Sin deposiciones desde hace \(ctx.daysSinceLastStool) días. Prueba el ejercicio de la bicicleta: pon a \(ctx.babyName) bocarriba y mueve sus piernas suavemente hacia la tripita 10–15 veces."
        case .german:
            text = "Seit \(ctx.daysSinceLastStool) Tagen kein Stuhl. Versuche die Fahrrad-Übung: Lege \(ctx.babyName) auf den Rücken und beuge die Beinchen sanft zum Bauch, 10–15 Mal."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }

    // Alert D: critical sleep deficit (evening only)
    private static func checkSleepDeficit(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.hour >= 19 else { return nil }
        let minSleep = WhoNorms.minSleepMinutes(ageMonths: ctx.ageMonths)
        let threshold = minSleep - 90
        guard ctx.totalSleepMinutes < threshold else { return nil }
        let sleptH = ctx.totalSleepMinutes / 60
        let deficit = (minSleep - ctx.totalSleepMinutes + 59) / 60
        let text: String
        switch ctx.language {
        case .russian:
            text = "Сегодня \(ctx.babyName) спал всего \(sleptH) ч — это на \(deficit) ч меньше нормы. Постарайтесь уложить пораньше — к 19:30–20:00."
        case .english, .portuguese:
            text = "\(ctx.babyName) has only slept \(sleptH) h today — \(deficit) h less than the norm. Try an earlier bedtime — around 19:30–20:00."
        case .spanish:
            text = "\(ctx.babyName) solo ha dormido \(sleptH) h hoy — \(deficit) h menos de lo normal. Intenta acostarlo antes — sobre las 19:30–20:00."
        case .german:
            text = "\(ctx.babyName) hat heute nur \(sleptH) Std. geschlafen — \(deficit) Std. weniger als normal. Versuche, früher ins Bett zu gehen — gegen 19:30–20:00."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .alert)
    }
}

// MARK: - PRIORITY 2: Situational Rules

enum SituationalRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        checkJustFed(context)
        ?? checkLongAwake(context)
        ?? checkBathEvening(context)
        ?? checkFirstMorningSleep(context)
        ?? checkBreastSide(context)
        ?? checkNoWalk(context)
    }

    // SITU A: just finished feeding (< 10 min ago, >= 5 min duration)
    private static func checkJustFed(_ ctx: DailyContext) -> DailyTip? {
        guard let minsAgo = ctx.minutesSinceLastFeed,
              minsAgo <= 10,
              ctx.lastFeedDurationMinutes >= 5 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "После кормления подержите \(ctx.babyName) столбиком 10–15 мин — это помогает выйти воздуху и предотвращает срыгивание. Прижмите вертикально к плечу и слегка похлопайте по спинке."
        case .english, .portuguese:
            text = "Hold \(ctx.babyName) upright for 10–15 min after feeding — this helps air escape and prevents spit-up. Press them vertically against your shoulder and gently pat the back."
        case .spanish:
            text = "Mantén a \(ctx.babyName) erguido 10–15 min después de comer — ayuda a expulsar el aire y evita las regurgitaciones. Apóyalo en vertical sobre tu hombro y dale palmaditas suaves en la espalda."
        case .german:
            text = "Halte \(ctx.babyName) nach dem Stillen 10–15 Min. aufrecht — das hilft, die Luft herauszulassen und verhindert Spucken. Drücke das Baby senkrecht an deine Schulter und klopfe sanft auf den Rücken."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU C: awake too long
    private static func checkLongAwake(_ ctx: DailyContext) -> DailyTip? {
        guard let awakeMins = ctx.minutesSinceLastSleepEnd, awakeMins > 0 else { return nil }
        let awakeMax = WhoNorms.awakeWindowMax(ageMonths: ctx.ageMonths)
        guard awakeMins > awakeMax else { return nil }
        let overshoot = awakeMins - awakeMax
        let text: String
        if overshoot < 30 {
            switch ctx.language {
            case .russian:
                text = "\(ctx.babyName) уже \(awakeMins) мин бодрствует — пора укладывать. Зевота, потирание глаз, взгляд «в никуда» — не пропустите окно засыпания."
            case .english, .portuguese:
                text = "\(ctx.babyName) has been awake for \(awakeMins) min — time to settle down. Watch for yawning, eye-rubbing, or a glazed stare — don't miss the sleep window."
            case .spanish:
                text = "\(ctx.babyName) lleva \(awakeMins) min despierto — es hora de dormir. Atenta a bostezos, frotarse los ojos o mirada perdida — no pierdas la ventana de sueño."
            case .german:
                text = "\(ctx.babyName) ist seit \(awakeMins) Min. wach — es ist Zeit zum Einschlafen. Achte auf Gähnen, Augenreiben oder einen leeren Blick — verpasse das Einschlafffenster nicht."
            }
        } else {
            switch ctx.language {
            case .russian:
                text = "Окно засыпания уже пропущено — \(ctx.babyName) бодрствует \(awakeMins) мин. Переутомление затрудняет засыпание. Приглушите свет, уберите игрушки, начните ритуал сейчас."
            case .english, .portuguese:
                text = "The sleep window has passed — \(ctx.babyName) has been awake \(awakeMins) min. Overtiredness makes sleep harder. Dim the lights, put toys away, and start the bedtime routine now."
            case .spanish:
                text = "La ventana de sueño ya pasó — \(ctx.babyName) lleva \(awakeMins) min despierto. El sobrecansancio dificulta el sueño. Atenúa las luces, recoge los juguetes y empieza ya la rutina de dormir."
            case .german:
                text = "Das Einschlafffenster ist verpasst — \(ctx.babyName) ist seit \(awakeMins) Min. wach. Übermüdung erschwert das Einschlafen. Licht dämpfen, Spielzeug wegräumen, Routine jetzt beginnen."
            }
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU D: evening bath not done yet
    private static func checkBathEvening(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.hour >= 18, ctx.hour <= 21,
              ctx.bathCount == 0,
              ctx.ageMonths >= 1 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Вечернее купание — мощный ритуал сна. Температура воды 36–37°C, длительность 5–10 мин. После купания кожа охлаждается и мелатонин вырабатывается быстрее."
        case .english, .portuguese:
            text = "Evening bath is a powerful sleep ritual. Water temperature 36–37°C, duration 5–10 min. After bathing, the skin cools and melatonin is produced faster."
        case .spanish:
            text = "El baño de la tarde es un potente ritual de sueño. Temperatura del agua 36–37 °C, duración 5–10 min. Tras el baño, la piel se enfría y la melatonina se produce más rápido."
        case .german:
            text = "Das Abendbad ist ein starkes Einschlafritual. Wassertemperatur 36–37°C, Dauer 5–10 Min. Nach dem Bad kühlt die Haut ab und Melatonin wird schneller produziert."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU E: first morning nap window
    private static func checkFirstMorningSleep(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.hour >= 7, ctx.hour <= 10,
              ctx.sleepCount == 0 else { return nil }
        let awakeMax = WhoNorms.awakeWindowMax(ageMonths: ctx.ageMonths)
        guard let awakeMins = ctx.minutesSinceLastSleepEnd,
              awakeMins > Int(Double(awakeMax) * 0.7) else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Первый утренний сон — самый важный для \(ctx.babyName). Для \(ctx.ageMonths) мес он должен начинаться примерно через \(awakeMax) мин после пробуждения. Следите за первыми зевками."
        case .english, .portuguese:
            text = "The first morning nap is the most important for \(ctx.babyName). For \(ctx.ageMonths) months it should start about \(awakeMax) min after waking up. Watch for the first yawns."
        case .spanish:
            text = "La primera siesta de la mañana es la más importante para \(ctx.babyName). Para \(ctx.ageMonths) meses debería empezar unos \(awakeMax) min después de despertarse. Atenta a los primeros bostezos."
        case .german:
            text = "Der erste Morgenschlaf ist für \(ctx.babyName) der wichtigste. Mit \(ctx.ageMonths) Monaten sollte er etwa \(awakeMax) Min. nach dem Aufwachen beginnen. Achte auf die ersten Gähnzeichen."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU F: repeatedly feeding from same side
    private static func checkBreastSide(_ ctx: DailyContext) -> DailyTip? {
        let sides = ctx.recentFeedSides
        guard sides.count >= 3 else { return nil }
        let prefix3 = Array(sides.prefix(3))
        guard Set(prefix3).count == 1 else { return nil }
        let side = prefix3[0]
        let isLeft = side.contains("лев") || side.lowercased().contains("left") || side.lowercased().contains("links")
        let text: String
        switch ctx.language {
        case .russian:
            let other = isLeft ? "правую" : "левую"
            text = "Последние 3 кормления с одной стороны. Предложите \(other) грудь — равномерная нагрузка поддерживает лактацию и предотвращает застой."
        case .english, .portuguese:
            let other = isLeft ? "right" : "left"
            text = "The last 3 feeds were from the same side. Try the \(other) breast — balanced feeding supports lactation and prevents engorgement."
        case .spanish:
            let other = isLeft ? "derecho" : "izquierdo"
            text = "Las últimas 3 tomas fueron del mismo lado. Prueba el pecho \(other) — una lactancia equilibrada favorece la producción y evita la congestión."
        case .german:
            let other = isLeft ? "rechte" : "linke"
            text = "Die letzten 3 Stillmahlzeiten waren auf der gleichen Seite. Biete die \(other) Brust an — gleichmäßiges Stillen unterstützt die Laktation und verhindert Stauungen."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }

    // SITU G: no walk during daytime
    private static func checkNoWalk(_ ctx: DailyContext) -> DailyTip? {
        guard ctx.walkCount == 0,
              ctx.hour >= 10, ctx.hour <= 16,
              ctx.ageMonths >= 1 else { return nil }
        let text: String
        switch ctx.language {
        case .russian:
            text = "Прогулка на свежем воздухе регулирует циркадные ритмы \(ctx.babyName). Дневной свет снижает выработку мелатонина и улучшает ночной сон. Даже 20–30 минут на улице дают эффект."
        case .english, .portuguese:
            text = "Fresh air walks regulate \(ctx.babyName)'s circadian rhythm. Daylight suppresses melatonin and improves night sleep. Even 20–30 minutes outside makes a difference."
        case .spanish:
            text = "Pasear al aire libre regula el ritmo circadiano de \(ctx.babyName). La luz del día reduce la melatonina y mejora el sueño nocturno. Incluso 20–30 minutos fuera marcan la diferencia."
        case .german:
            text = "Spaziergänge an der frischen Luft regulieren den Tagesrhythmus von \(ctx.babyName). Tageslicht unterdrückt Melatonin und verbessert den Nachtschlaf. Schon 20–30 Minuten draußen helfen."
        }
        return DailyTip(text: text, contextHash: ctx.contextHash, category: .situational)
    }
}

// MARK: - PRIORITY 3: Care Rules (always returns a tip)

enum CareRules {

    static func evaluate(context: DailyContext) -> DailyTip {
        let pool = carePool(ageMonths: context.ageMonths, language: context.language)
        let idx = context.dayOfYear % pool.count
        let text = pool[idx].replacingOccurrences(of: "[name]", with: context.babyName)
        return DailyTip(text: text, contextHash: context.contextHash, category: .care)
    }

    private static func carePool(ageMonths age: Int, language lang: Language) -> [String] {
        switch age {
        case 0:       return newbornPool(lang)
        case 1...2:   return pool1_2m(lang)
        case 3...5:   return pool3_5m(lang)
        case 6...8:   return pool6_8m(lang)
        case 9...11:  return pool9_11m(lang)
        case 12...17: return pool12_17m(lang)
        default:      return pool18_24m(lang)
        }
    }

    // MARK: Pools

    private static func newbornPool(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Пупочная ранка заживает 10–14 дней. Обрабатывайте хлоргексидином 1–2 раза в день после купания, держите сухой.",
            "Новорождённый слышит голос мамы с рождения — разговаривайте спокойным голосом, это формирует нейронные связи.",
            "Время на животике — 2–3 раза в день по 1–2 мин, только пока [name] бодрствует. Укрепляет шею и готовит к перевороту.",
            "Пеленание помогает некоторым новорождённым спать дольше — руки вдоль тела, бёдра свободно, не туго.",
            "Контакт кожа-к-коже 1–2 часа в день стабилизирует температуру, дыхание и сердцебиение [name]."
        ]
        case .english, .portuguese: return [
            "The umbilical wound heals in 10–14 days. Clean with chlorhexidine 1–2 times a day after bathing and keep it dry.",
            "Newborns recognise mum's voice from birth — talking in a calm tone builds neural connections.",
            "Tummy time 2–3 times a day for 1–2 min while [name] is awake strengthens the neck and prepares for rolling.",
            "Swaddling helps some newborns sleep longer — arms along the body, hips free, not too tight.",
            "Skin-to-skin contact for 1–2 hours a day stabilises [name]'s temperature, breathing, and heart rate."
        ]
        case .spanish: return [
            "La herida del ombligo cicatriza en 10–14 días. Límpiala con clorhexidina 1–2 veces al día tras el baño y mantenla seca.",
            "Los recién nacidos reconocen la voz de mamá desde el nacimiento — hablar con tono calmado crea conexiones neuronales.",
            "El tiempo bocabajo 2–3 veces al día durante 1–2 min mientras [name] está despierto fortalece el cuello y prepara para darse la vuelta.",
            "Envolver al bebé ayuda a algunos recién nacidos a dormir más — brazos junto al cuerpo, caderas libres, sin apretar.",
            "El contacto piel con piel 1–2 horas al día estabiliza la temperatura, la respiración y el ritmo cardíaco de [name]."
        ]
        case .german: return [
            "Die Nabelwunde heilt in 10–14 Tagen. Reinige sie 1–2-mal täglich nach dem Bad mit Chlorhexidin und halte sie trocken.",
            "Neugeborene erkennen die Stimme der Mutter von Geburt an — ruhiges Sprechen baut neuronale Verbindungen auf.",
            "Bauchlage 2–3-mal täglich für 1–2 Min., nur wenn [name] wach ist, stärkt den Nacken und bereitet auf das Drehen vor.",
            "Pucken kann manchen Neugeborenen helfen, länger zu schlafen — Arme am Körper, Hüften frei, nicht zu fest.",
            "Hautkontakt 1–2 Stunden täglich stabilisiert die Temperatur, Atmung und den Herzrhythmus von [name]."
        ]
        }
    }

    private static func pool1_2m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Газики — норма. Лёгкий массаж животика по часовой стрелке и поза «тигр на ветке» (животиком на руке) помогают.",
            "Для стула попробуйте упражнение «велосипед»: аккуратно вращайте ножки [name] в воздухе 10–15 раз.",
            "Сосательный рефлекс самый сильный сейчас. Пустышка между кормлениями — помощь в самоуспокоении.",
            "Колики чаще всего достигают пика в 6 нед. Белый шум, покачивание и поза на животе хорошо помогают.",
            "Чёрно-белые книжки и карточки — идеальная игрушка для [name]. Контраст стимулирует зрительную кору."
        ]
        case .english, .portuguese: return [
            "Gas is normal. A gentle clockwise tummy massage and the tiger-on-the-branch position (tummy on arm) help.",
            "For bowel movements try the bicycle exercise: gently pedal [name]'s legs in the air 10–15 times.",
            "The sucking reflex is at its peak now. A pacifier between feeds supports self-soothing.",
            "Colic typically peaks around 6 weeks. White noise, rocking, and the tummy-down position work well.",
            "Black-and-white books and cards are the perfect toy for [name] — contrast strongly stimulates the visual cortex."
        ]
        case .spanish: return [
            "Los gases son normales. Ayuda un masaje suave en la tripita en sentido horario y la postura del tigre en la rama (bocabajo sobre el brazo).",
            "Para las deposiciones prueba el ejercicio de la bicicleta: pedalea suavemente las piernas de [name] en el aire 10–15 veces.",
            "El reflejo de succión está en su punto máximo ahora. Un chupete entre tomas favorece la autocalma.",
            "Los cólicos suelen alcanzar su pico hacia las 6 semanas. El ruido blanco, mecerlo y la postura bocabajo funcionan bien.",
            "Los libros y tarjetas en blanco y negro son el juguete perfecto para [name] — el contraste estimula con fuerza la corteza visual."
        ]
        case .german: return [
            "Blähungen sind normal. Eine sanfte Bauchmassage im Uhrzeigersinn und die Tiger-auf-dem-Ast-Haltung helfen.",
            "Für den Stuhlgang: Fahrradbewegungen — die Beinchen von [name] sanft 10–15-mal in der Luft kreisen.",
            "Der Saugreflex ist jetzt am stärksten. Ein Schnuller zwischen den Mahlzeiten unterstützt die Selbstberuhigung.",
            "Koliken erreichen häufig in der 6. Woche ihren Höhepunkt. Weißes Rauschen, Schaukeln und Bauchlage helfen gut.",
            "Schwarz-weiße Bücher und Karten sind das ideale Spielzeug für [name] — Kontrast regt die Sehrinde stark an."
        ]
        }
    }

    private static func pool3_5m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Чёрно-белые карточки и книжки стимулируют зрительную кору. 10–15 минут разглядывания картинок — отличная тренировка.",
            "Массаж всего тела 5–10 мин перед купанием улучшает сон [name]. Движения от центра к конечностям.",
            "Время на животике — до 30 мин в день суммарно. Подкладывайте валик под грудь — это облегчает удержание головы.",
            "Прорезыватели скоро понадобятся — охладите силиконовый в холодильнике (не в морозилке). Первые зубки у многих в 4–7 мес.",
            "Погремушки и хватательные игрушки тренируют моторику. Меняйте руку при подаче игрушки — обе стороны должны работать.",
            "Для развития концентрации покажите [name] собственное отражение в зеркале — в этом возрасте это вызывает живой интерес."
        ]
        case .english, .portuguese: return [
            "Black-and-white cards and books stimulate the visual cortex. 10–15 minutes of looking at pictures is excellent training.",
            "A 5–10 min full-body massage before the bath improves [name]'s sleep. Move from the centre out to the limbs.",
            "Tummy time up to 30 min per day in total. Roll a towel under the chest — it makes holding the head up easier.",
            "Teethers will soon be needed — chill a silicone one in the fridge (not freezer). First teeth often appear at 4–7 months.",
            "Rattles and grasping toys train motor skills. Alternate the hand you offer toys to — both sides need practice.",
            "Show [name] their reflection in a mirror for focus development — at this age it sparks immediate interest."
        ]
        case .spanish: return [
            "Las tarjetas y libros en blanco y negro estimulan la corteza visual. 10–15 minutos mirando imágenes es un entrenamiento excelente.",
            "Un masaje de cuerpo entero de 5–10 min antes del baño mejora el sueño de [name]. Muévete del centro hacia las extremidades.",
            "Tiempo bocabajo hasta 30 min al día en total. Enrolla una toalla bajo el pecho — facilita que sostenga la cabeza.",
            "Pronto harán falta mordedores — enfría uno de silicona en la nevera (no en el congelador). Los primeros dientes suelen salir a los 4–7 meses.",
            "Los sonajeros y juguetes para agarrar entrenan la motricidad. Alterna la mano con la que ofreces los juguetes — ambos lados necesitan práctica.",
            "Muéstrale a [name] su reflejo en un espejo para desarrollar la concentración — a esta edad despierta interés inmediato."
        ]
        case .german: return [
            "Schwarz-weiße Karten und Bücher stimulieren die Sehrinde. 10–15 Minuten Bilderbetrachten ist ausgezeichnetes Training.",
            "Eine 5–10-minütige Ganzkörpermassage vor dem Bad verbessert den Schlaf von [name]. Bewegungen vom Zentrum zu den Gliedmaßen.",
            "Bauchlage bis zu 30 Min. täglich. Rolle ein Handtuch unter die Brust — das erleichtert das Kopfheben.",
            "Beißringe werden bald gebraucht — kühle einen Silikon-Ring im Kühlschrank (nicht Gefrierfach). Erste Zähne oft mit 4–7 Mon.",
            "Rasseln und Greifspielzeug trainieren die Motorik. Wechsle die Hand beim Anbieten von Spielzeug — beide Seiten brauchen Übung.",
            "Zeige [name] sein Spiegelbild — in diesem Alter weckt das sofort Interesse und fördert die Konzentration."
        ]
        }
    }

    private static func pool6_8m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Прикорм вводите постепенно: одно новое блюдо раз в 3 дня, маленькими порциями. Овощи лучше фруктов в начале.",
            "Стимулируйте ползание: положите игрушку чуть дальше досягаемости [name]. Ползание развивает оба полушария одновременно.",
            "Речевое развитие: называйте всё что делаете вслух. «Сейчас едим», «берём ложку» — словарный запас формируется с 6 мес.",
            "Пинцетный захват (большой + указательный) формируется в 8–9 мес. Предлагайте маленькие мягкие кусочки еды для тренировки.",
            "Игра в «ку-ку» — не просто веселье. Она учит [name] концепции постоянства объектов: «мама уходит и возвращается»."
        ]
        case .english, .portuguese: return [
            "Introduce solids gradually: one new food every 3 days in small portions. Vegetables before fruit is a good starting order.",
            "Encourage crawling: place a toy just out of [name]'s reach. Crawling develops both hemispheres simultaneously.",
            "Speech development: narrate everything you do. We're eating now, picking up the spoon — vocabulary builds from 6 months.",
            "The pincer grasp (thumb + index) develops at 8–9 months. Offer small, soft pieces of food for practice.",
            "Peek-a-boo is more than fun. It teaches [name] object permanence: mummy leaves and comes back."
        ]
        case .spanish: return [
            "Introduce los sólidos poco a poco: un alimento nuevo cada 3 días en porciones pequeñas. Empezar por verduras antes que fruta es un buen orden.",
            "Fomenta el gateo: coloca un juguete justo fuera del alcance de [name]. Gatear desarrolla ambos hemisferios a la vez.",
            "Desarrollo del habla: narra todo lo que haces. «Ahora comemos», «cogemos la cuchara» — el vocabulario se forma desde los 6 meses.",
            "La pinza (pulgar + índice) se desarrolla a los 8–9 meses. Ofrece trocitos pequeños y blandos de comida para practicar.",
            "El cucú-tras es más que diversión. Le enseña a [name] la permanencia del objeto: mamá se va y vuelve."
        ]
        case .german: return [
            "Beikost schrittweise einführen: alle 3 Tage ein neues Lebensmittel in kleinen Mengen. Gemüse vor Obst ist ein guter Start.",
            "Kriechen anregen: lege ein Spielzeug knapp außer Reichweite von [name]. Krabbeln entwickelt beide Gehirnhälften gleichzeitig.",
            "Sprachentwicklung: kommentiere alles laut. Jetzt essen wir, nehmen den Löffel — der Wortschatz baut sich ab 6 Mon. auf.",
            "Der Pinzettengriff (Daumen + Zeigefinger) entwickelt sich mit 8–9 Mon. Biete kleine, weiche Bissen zum Üben an.",
            "Kuckuckspiele sind mehr als Spaß. Sie lehren [name] Objektpermanenz: Mama geht weg und kommt zurück."
        ]
        }
    }

    private static func pool9_11m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Первые шаги начинаются с хождения вдоль опоры. Не держите [name] за руки постоянно — нужен баланс самостоятельности.",
            "Речь: понимание слов опережает произношение. В 9–10 мес [name] понимает «нет», «дай», «иди». Говорите медленно и чётко.",
            "Ночные пробуждения в 9–10 мес — нормальный регресс сна. Это связано с новыми двигательными навыками. Пройдёт за 2–4 нед.",
            "Стаканчик с носиком — хорошее время вводить. В 12 мес ВОЗ рекомендует отказаться от ночного кормления при нормальном весе.",
            "Сортеры, стаканчики, коробки с крышками — лучшие игрушки для [name]. Концепция «внутри/снаружи» активно формируется."
        ]
        case .english, .portuguese: return [
            "First steps begin with cruising along furniture. Don't always hold [name]'s hands — independent balance needs practice.",
            "Speech: comprehension precedes production. At 9–10 months [name] understands no, give, come. Speak slowly and clearly.",
            "Night wakings at 9–10 months are a normal sleep regression linked to new motor skills. It passes in 2–4 weeks.",
            "A sippy cup is a good time to introduce. By 12 months the WHO recommends dropping night feeds at normal weight.",
            "Sorters, stacking cups, boxes with lids — the best toys for [name] right now. The inside/outside concept is forming."
        ]
        case .spanish: return [
            "Los primeros pasos empiezan caminando apoyado en los muebles. No le sujetes siempre las manos a [name] — el equilibrio autónomo necesita práctica.",
            "Habla: la comprensión va antes que la producción. A los 9–10 meses [name] entiende «no», «dame», «ven». Habla despacio y claro.",
            "Los despertares nocturnos a los 9–10 meses son una regresión del sueño normal ligada a nuevas destrezas motoras. Pasa en 2–4 semanas.",
            "Es buen momento para introducir el vaso con boquilla. Hacia los 12 meses la OMS recomienda dejar las tomas nocturnas si el peso es normal.",
            "Encajables, vasos apilables, cajas con tapa — los mejores juguetes para [name] ahora. El concepto dentro/fuera se está formando."
        ]
        case .german: return [
            "Erste Schritte beginnen mit Laufen entlang von Möbeln. Halte [name] nicht immer an den Händen — Balance braucht Eigenständigkeit.",
            "Sprache: Verstehen geht dem Sprechen voraus. Mit 9–10 Mon. versteht [name] nein, gib, komm. Langsam und deutlich sprechen.",
            "Nächtliches Aufwachen mit 9–10 Mon. ist eine normale Schlafregression durch neue Motorikfortschritte. Dauert 2–4 Wochen.",
            "Ein Schnabelbecher eignet sich jetzt gut. Ab 12 Mon. empfiehlt die WHO, bei normalem Gewicht auf Nachtmahlzeiten zu verzichten.",
            "Sortierer, Stapelbecher, Dosen mit Deckel — die besten Spielzeuge für [name]. Das Konzept innen/außen entwickelt sich gerade."
        ]
        }
    }

    private static func pool12_17m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Кризис 1 года — нормальное явление. Истерики от бессилия, а не манипуляция. Спокойная реакция родителя — лучший ответ.",
            "Словарный запас: 12 мес — 1–3 слова, 18 мес — 10–50 слов. Если к 18 мес нет 10 слов — консультация логопеда.",
            "Один дневной сон — переход обычно в 15–18 мес. Не торопите: ранний переход ведёт к перевозбуждению и плохому ночному сну.",
            "Рисование пальцами, лепка из теста развивают мелкую моторику и речь одновременно. 10 мин в день достаточно."
        ]
        case .english, .portuguese: return [
            "The one-year crisis is normal. Tantrums come from frustration, not manipulation. A calm parental response is the best reply.",
            "Vocabulary: 1–3 words at 12 months, 10–50 words at 18 months. Fewer than 10 words by 18 months: consult a speech therapist.",
            "The transition to one nap usually happens at 15–18 months. Don't rush it — early transition leads to over-stimulation.",
            "Finger painting and dough modelling develop fine motor skills and speech at the same time. Ten minutes a day is enough."
        ]
        case .spanish: return [
            "La crisis del primer año es normal. Las rabietas vienen de la frustración, no de la manipulación. Una respuesta tranquila de los padres es la mejor.",
            "Vocabulario: 1–3 palabras a los 12 meses, 10–50 a los 18. Menos de 10 palabras a los 18 meses: consulta a un logopeda.",
            "El paso a una sola siesta suele ocurrir a los 15–18 meses. No lo apresures — un cambio temprano lleva a la sobreexcitación.",
            "Pintar con los dedos y modelar masa desarrollan la motricidad fina y el habla a la vez. Diez minutos al día bastan."
        ]
        case .german: return [
            "Die Einjahres-Krise ist normal. Wutausbrüche kommen aus Hilflosigkeit, nicht aus Manipulation. Ruhige elterliche Reaktion ist die beste Antwort.",
            "Wortschatz: 1–3 Wörter mit 12 Mon., 10–50 Wörter mit 18 Mon. Weniger als 10 Wörter mit 18 Mon.: Logopäden konsultieren.",
            "Der Übergang zu einem Mittagsschlaf erfolgt meist mit 15–18 Mon. Nicht überstürzen — zu früher Übergang führt zu Überreizung.",
            "Malen mit Fingern und Kneten mit Teig entwickeln Feinmotorik und Sprache gleichzeitig. Zehn Minuten täglich genügen."
        ]
        }
    }

    private static func pool18_24m(_ lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Параллельная игра (рядом, но не вместе) — норма для этого возраста [name]. Социальная игра с ровесниками придёт позже, к 3 годам.",
            "2-словные фразы к 2 годам — ориентир развития речи. «Мама, дай», «хочу пить» — хороший знак. Нет фраз — к логопеду.",
            "Готовность к горшку появляется в 18–24 мес. Признаки: сухой подгузник 2 ч подряд, [name] указывает на горшок."
        ]
        case .english, .portuguese: return [
            "Parallel play (near but not together) is normal at [name]'s age. Social play with peers develops later, around 3 years.",
            "Two-word phrases by age 2 are a speech milestone. Mummy give, want drink are good signs. No phrases: see a speech therapist.",
            "Potty readiness appears at 18–24 months. Signs: dry nappy for 2 h in a row, [name] points to the potty."
        ]
        case .spanish: return [
            "El juego paralelo (cerca pero no juntos) es normal a la edad de [name]. El juego social con iguales llega más tarde, hacia los 3 años.",
            "Las frases de dos palabras hacia los 2 años son un hito del habla. «Mamá dame», «quiero agua» son buenas señales. Sin frases: acude a un logopeda.",
            "La preparación para el orinal aparece a los 18–24 meses. Señales: pañal seco 2 h seguidas, [name] señala el orinal."
        ]
        case .german: return [
            "Parallelspiel (nebeneinander, aber nicht miteinander) ist in [name]s Alter normal. Soziales Spiel mit Gleichaltrigen kommt später, um das 3. Jahr.",
            "Zweiwortsätze bis zum 2. Geburtstag sind ein Sprachmeilenstein. Mama gib, will trinken sind gute Zeichen. Keine Sätze: Logopäden aufsuchen.",
            "Die Töpfchenbereitschaft zeigt sich mit 18–24 Mon. Zeichen: trockene Windel 2 Std. am Stück, [name] zeigt auf den Topf."
        ]
        }
    }
}

// MARK: - PRIORITY 4: Development (leap) Rules — fallback, usually unreachable

enum DevelopmentRules {

    static func evaluate(context: DailyContext) -> DailyTip? {
        guard let leapName = context.currentLeapName else { return nil }
        let text = leapTip(for: leapName, name: context.babyName, language: context.language)
        return DailyTip(text: text, contextHash: context.contextHash, category: .development)
    }

    private static func leapTip(for leapName: String, name: String, language: Language) -> String {
        switch language {
        case .russian:  return russianLeapTip(leapName: leapName, name: name)
        case .english, .portuguese:  return englishLeapTip(leapName: leapName, name: name)
        case .spanish:  return spanishLeapTip(leapName: leapName, name: name)
        case .german:   return germanLeapTip(leapName: leapName, name: name)
        }
    }

    private static func spanishLeapTip(leapName: String, name: String) -> String {
        switch leapName {
        case _ where leapName.contains("Sense") || leapName.contains("ощущен"):
            return "Habla con voz tranquila y evita los ruidos bruscos — el sistema auditivo de \(name) aún se está calibrando."
        case _ where leapName.contains("Pattern") || leapName.contains("узор"):
            return "Muéstrale a \(name) tarjetas geométricas en blanco y negro. El cerebro busca patrones — el contraste estimula la corteza visual con más fuerza."
        case _ where leapName.contains("Transition") || leapName.contains("движен"):
            return "Tiempo bocabajo a diario — \(name) practica el control del cuerpo. Enrolla una manta bajo el pecho como apoyo."
        case _ where leapName.contains("Event") || leapName.contains("событ"):
            return "En este salto de causa y efecto, los juguetes de pulsar y sonar son los mejores. \(name) descubre: mis acciones cambian el mundo."
        case _ where leapName.contains("Relation") || leapName.contains("отношен"):
            return "La ansiedad por separación ahora no es un capricho — es normal. El cucú-tras ayuda a \(name) a aprender: mamá se va y vuelve."
        case _ where leapName.contains("Categor") || leapName.contains("категор"):
            return "Encajables y vasos apilables de distintos tamaños son juguetes ideales. \(name) clasifica el mundo: grande/pequeño, dentro/fuera."
        case _ where leapName.contains("Sequence") || leapName.contains("последоват"):
            return "Las rutinas sencillas ayudan a \(name) a anticipar lo que viene. Una secuencia constante antes de dormir reduce la ansiedad."
        case _ where leapName.contains("Program") || leapName.contains("програм"):
            return "Los primeros «no» y protestas son señal de independencia sana. Dale a \(name) opciones simples: ¿vaso rojo o azul?"
        case _ where leapName.contains("Principle") || leapName.contains("принцип"):
            return "«Por qué» y «no» son las palabras clave de esta etapa. Explica con frases cortas: caliente — no se puede, duele."
        case _ where leapName.contains("System") || leapName.contains("систем"):
            return "El juego de roles florece ahora. Una cocinita o herramientas de juguete — \(name) construye un modelo del mundo."
        default:
            return "Un salto del desarrollo es pasajero. Abraza a \(name) más a menudo y responde a sus señales — es el mejor apoyo."
        }
    }

    private static func russianLeapTip(leapName: String, name: String) -> String {
        switch leapName {
        case _ where leapName.contains("ощущен") || leapName.contains("Sense"):
            return "Разговаривайте спокойным голосом и избегайте резких звуков — слуховая система \(name) ещё настраивается."
        case _ where leapName.contains("узор") || leapName.contains("Pattern"):
            return "Покажите \(name) чёрно-белые карточки с геометрическими фигурами. Мозг ищет паттерны — контраст стимулирует зрительную кору сильнее всего."
        case _ where leapName.contains("движен") || leapName.contains("Transition"):
            return "Время на животике каждый день — \(name) тренирует контроль над телом. Подкладывайте под грудь свёрнутое одеяло."
        case _ where leapName.contains("событ") || leapName.contains("Event"):
            return "В скачок причинно-следственных связей игрушки «нажми — звук» — лучшие. \(name) открывает: «мои действия меняют мир»."
        case _ where leapName.contains("отношен") || leapName.contains("Relation"):
            return "Тревога разлуки сейчас — не каприз, а норма. Игра «ку-ку» помогает \(name) понять: мама уходит и возвращается."
        case _ where leapName.contains("категор") || leapName.contains("Categor"):
            return "Сортеры, стаканчики разного размера — идеальные игрушки. \(name) классифицирует мир: большой/маленький, внутри/снаружи."
        case _ where leapName.contains("последоват") || leapName.contains("Sequence"):
            return "Простые ритуалы помогают \(name) понять «что будет дальше». Одна и та же последовательность перед сном снижает тревогу."
        case _ where leapName.contains("програм") || leapName.contains("Program"):
            return "Первые «нет» и протесты — признак здоровой независимости. Давайте \(name) простой выбор: «красная или синяя кружка?»"
        case _ where leapName.contains("принцип") || leapName.contains("Principle"):
            return "«Почему?» и «нет» — главные слова этого этапа. Объясняйте коротко: «горячо — нельзя, больно»."
        case _ where leapName.contains("систем") || leapName.contains("System"):
            return "Ролевые игры расцветают сейчас. Маленькая кухня, инструменты — \(name) строит модель мира."
        default:
            return "Скачок развития — это временно. Чаще обнимайте \(name) и отвечайте на сигналы — это лучшая поддержка."
        }
    }

    private static func englishLeapTip(leapName: String, name: String) -> String {
        switch leapName {
        case _ where leapName.contains("Sense") || leapName.contains("ощущен"):
            return "Speak in a calm voice and avoid sudden sounds — \(name)'s auditory system is still calibrating."
        case _ where leapName.contains("Pattern") || leapName.contains("узор"):
            return "Show \(name) black-and-white geometric cards. The brain seeks patterns — contrast stimulates the visual cortex most powerfully."
        case _ where leapName.contains("Transition") || leapName.contains("движен"):
            return "Daily tummy time — \(name) is practising body control. Roll a blanket under the chest for support."
        case _ where leapName.contains("Event") || leapName.contains("событ"):
            return "During this cause-and-effect leap, press-and-sound toys are best. \(name) is discovering: my actions change the world."
        case _ where leapName.contains("Relation") || leapName.contains("отношен"):
            return "Separation anxiety now is not a whim — it's normal. Peek-a-boo helps \(name) learn: mummy leaves and comes back."
        case _ where leapName.contains("Categor") || leapName.contains("категор"):
            return "Sorters and stacking cups of different sizes are ideal toys. \(name) is classifying the world: big/small, inside/outside."
        case _ where leapName.contains("Sequence") || leapName.contains("последоват"):
            return "Simple rituals help \(name) predict what comes next. A consistent bedtime sequence reduces anxiety."
        case _ where leapName.contains("Program") || leapName.contains("програм"):
            return "First no's and protests are a sign of healthy independence. Give \(name) simple choices: red or blue cup?"
        case _ where leapName.contains("Principle") || leapName.contains("принцип"):
            return "Why and no are the key words of this stage. Keep explanations short: hot — not allowed, it hurts."
        case _ where leapName.contains("System") || leapName.contains("систем"):
            return "Role play is blossoming now. A toy kitchen or tools — \(name) is building a model of the world."
        default:
            return "A developmental leap is temporary. Hug \(name) more often and respond to their signals — that's the best support."
        }
    }

    private static func germanLeapTip(leapName: String, name: String) -> String {
        switch leapName {
        case _ where leapName.contains("Sinne") || leapName.contains("ощущен"):
            return "Sprich ruhig und vermeide plötzliche Geräusche — \(name)s Hörsystem kalibriert sich noch."
        case _ where leapName.contains("Muster") || leapName.contains("узор"):
            return "Zeige \(name) schwarz-weiße geometrische Karten. Das Gehirn sucht Muster — Kontrast stimuliert die Sehrinde am stärksten."
        case _ where leapName.contains("Übergang") || leapName.contains("движен"):
            return "Tägliche Bauchlage — \(name) übt Körperkontrolle. Rolle eine Decke unter die Brust zur Unterstützung."
        case _ where leapName.contains("Ereignis") || leapName.contains("событ"):
            return "Beim Ursache-Wirkungs-Sprung sind Drück-und-Ton-Spielzeuge am besten. \(name) entdeckt: meine Handlungen verändern die Welt."
        case _ where leapName.contains("Beziehung") || leapName.contains("отношен"):
            return "Trennungsangst ist jetzt keine Laune — es ist normal. Kuckuckspiele helfen \(name) zu verstehen: Mama geht und kommt wieder."
        case _ where leapName.contains("Kategor") || leapName.contains("категор"):
            return "Sortierer und Stapelbecher verschiedener Größen sind ideale Spielzeuge. \(name) klassifiziert: groß/klein, drinnen/draußen."
        default:
            return "Ein Entwicklungssprung ist vorübergehend. Umarme \(name) öfter und reagiere auf Signale — das ist die beste Unterstützung."
        }
    }
}

// MARK: - PRIORITY 5: Default Tips (ultimate fallback)

enum DefaultTips {

    static func evaluate(context: DailyContext) -> DailyTip {
        let pool = tips(for: context.language)
        let idx = context.dayOfYear % pool.count
        let text = pool[idx].replacingOccurrences(of: "[name]", with: context.babyName)
        return DailyTip(text: text, contextHash: context.contextHash, category: .defaultTip)
    }

    private static func tips(for lang: Language) -> [String] {
        switch lang {
        case .russian: return [
            "Зрительный контакт во время кормления укрепляет привязанность и стимулирует развитие мозга [name].",
            "Пение колыбельных формирует музыкальный слух и речевые центры. Ритм и мелодия важнее идеального голоса.",
            "Объятия и тактильный контакт снижают кортизол. Лучшее «лекарство» сегодня — просто подержать [name] на руках.",
            "Читайте вслух с первых дней. Ритм речи и интонации строят основу для будущего чтения и развития речи.",
            "Называйте эмоции [name]: «ты расстроен», «ты радуешься» — эмоциональный интеллект начинается с первых месяцев жизни."
        ]
        case .english, .portuguese: return [
            "Eye contact during feeding strengthens attachment and stimulates [name]'s brain development.",
            "Singing lullabies builds musical hearing and speech centres. Rhythm and melody matter more than a perfect voice.",
            "Hugs and touch lower cortisol levels. The best medicine today is simply holding [name] in your arms.",
            "Read aloud from the very first days. The rhythm of speech and intonation lay the foundation for future reading.",
            "Name [name]'s emotions: you're upset, you're happy — emotional intelligence begins in the first months of life."
        ]
        case .spanish: return [
            "El contacto visual durante la toma fortalece el apego y estimula el desarrollo cerebral de [name].",
            "Cantar nanas desarrolla el oído musical y los centros del habla. El ritmo y la melodía importan más que una voz perfecta.",
            "Los abrazos y el contacto bajan el cortisol. La mejor medicina hoy es simplemente tener a [name] en brazos.",
            "Lee en voz alta desde los primeros días. El ritmo del habla y la entonación sientan las bases de la futura lectura.",
            "Nombra las emociones de [name]: estás molesto, estás contento — la inteligencia emocional empieza en los primeros meses de vida."
        ]
        case .german: return [
            "Blickkontakt beim Stillen stärkt die Bindung und fördert die Gehirnentwicklung von [name].",
            "Das Singen von Schlafliedern baut musikalisches Gehör und Sprachzentren auf. Rhythmus und Melodie sind wichtiger als eine perfekte Stimme.",
            "Umarmungen und Körperkontakt senken den Cortisolspiegel. Das beste Medikament heute ist, [name] einfach auf dem Arm zu halten.",
            "Vorlesen von den ersten Tagen an — der Sprachrhythmus und Intonationen legen das Fundament für zukünftiges Lesen.",
            "[name]s Gefühle benennen: du bist traurig, du freust dich — emotionale Intelligenz beginnt in den ersten Lebensmonaten."
        ]
        }
    }
}
