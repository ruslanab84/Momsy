import Foundation

extension CareTipsCatalog {
    static let comfort: [CareTip] = [

        CareTip(
            id: 1301, category: .comfort, icon: "waveform", ageFrom: 0, ageTo: 4,
            title: LocalizedText(
                en: "Soothing a colicky evening",
                ru: "Как успокоить малыша в колики вечером"
            ),
            summary: LocalizedText(
                en: "Layer several calming inputs at once and give each combination a few minutes",
                ru: "Сочетайте сразу несколько успокаивающих приёмов и давайте каждой комбинации несколько минут"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Try the calming set together: a snug wrap, holding on the side or over your forearm, a steady shushing sound, gentle rhythmic movement, and something to suck.",
                    "Keep the rhythm constant — babies settle to repetition, not variety.",
                    "Reduce input elsewhere: dim the lights, turn off the television, move to a quieter room.",
                    "Change holder every twenty minutes if there are two of you.",
                    "If nothing works and you feel your patience going, put your baby down safely in the cot and step away for a few minutes."
                ],
                ru: [
                    "Пробуйте успокаивающий набор целиком: плотное пеленание, положение на боку или на предплечье, ровный звук «ш-ш-ш», мягкое ритмичное покачивание и что-то, что можно пососать.",
                    "Держите ритм постоянным — малышей успокаивает повторение, а не разнообразие.",
                    "Уберите лишние раздражители: приглушите свет, выключите телевизор, перейдите в более тихую комнату.",
                    "Если вас двое, меняйтесь каждые двадцать минут.",
                    "Если ничего не помогает и вы чувствуете, что терпение на исходе, безопасно положите ребёнка в кроватку и отойдите на несколько минут."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Colic in the sense of long unexplained evening crying peaks around six weeks and settles for most babies by three or four months. These techniques imitate the constant motion, pressure and sound of the womb, which is why several at once tends to work better than any one alone. Knowing there is an end point matters as much as the techniques themselves — this phase is finite even when it does not feel that way.",
                ru: "Колики в смысле долгого необъяснимого вечернего плача достигают пика примерно к шести неделям и у большинства детей проходят к трём-четырём месяцам. Эти приёмы имитируют постоянное движение, давление и звук в утробе — поэтому несколько сразу работают лучше, чем любой из них по отдельности. Знание, что у этого есть конец, важно не меньше самих приёмов: этот период конечен, даже когда так не кажется."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Switching technique every thirty seconds before any of them can work.",
                    "Colic drops, herbal remedies or gripe water without medical advice.",
                    "Assuming crying always means hunger and feeding continuously.",
                    "Blaming yourself — colic is not caused by anything you did or did not do."
                ],
                ru: [
                    "Менять приём каждые тридцать секунд, не дав ни одному подействовать.",
                    "Капли от колик, травяные средства или укропная вода без совета врача.",
                    "Считать, что плач всегда означает голод, и кормить без остановки.",
                    "Винить себя — колики не вызваны ничем, что вы сделали или не сделали."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Crying starts suddenly after a calm period, or the cry sounds high-pitched and unusual.",
                    "Crying with fever, vomiting, blood in the stool, or refusal to feed.",
                    "Poor weight gain alongside the crying.",
                    "You feel unable to cope — this is a reason to ask for help, not a failure."
                ],
                ru: [
                    "Плач начинается внезапно после спокойного периода либо звучит пронзительно и непривычно.",
                    "Плач с температурой, рвотой, кровью в стуле или отказом от еды.",
                    "Плохая прибавка в весе наряду с плачем.",
                    "Вы чувствуете, что не справляетесь, — это повод попросить помощи, а не признак неудачи."
                ]
            )
        ),

        CareTip(
            id: 1302, category: .comfort, icon: "arrow.triangle.2.circlepath", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Releasing trapped wind",
                ru: "Как помочь отойти газикам"
            ),
            summary: LocalizedText(
                en: "Bicycle legs, a warm tummy and a few minutes of patience",
                ru: "«Велосипед» ножками, тёплый животик и несколько минут терпения"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Lay your baby on their back and cycle the legs slowly, one at a time.",
                    "Bring both knees gently up towards the tummy, hold for a few seconds, release. Repeat several times.",
                    "Massage the tummy in slow clockwise circles with warm hands, following the direction of the gut.",
                    "Try a few minutes of tummy time across your lap while your baby is awake and supervised.",
                    "Do all of this before a feed or well after one, not immediately afterwards."
                ],
                ru: [
                    "Положите ребёнка на спину и медленно «крутите велосипед» ножками, поочерёдно.",
                    "Мягко подтяните оба колена к животику, задержите на несколько секунд, отпустите. Повторите несколько раз.",
                    "Массируйте живот медленными круговыми движениями по часовой стрелке тёплыми руками, по ходу кишечника.",
                    "Выложите ребёнка на несколько минут на животик у себя на коленях, пока он бодрствует и под присмотром.",
                    "Делайте всё это до кормления или заметно позже, но не сразу после."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "An immature digestive system moves gas slowly, and a baby who cannot yet change position has no way to help it along. Leg movement and clockwise massage follow the path of the large intestine and physically encourage gas towards the exit. Warmth relaxes the abdominal wall, which is why the same movements work better with warm hands than cold ones.",
                ru: "Незрелая пищеварительная система продвигает газы медленно, а ребёнок, который ещё не может сменить позу, никак не способен себе помочь. Движения ножками и массаж по часовой стрелке повторяют ход толстой кишки и физически продвигают газы к выходу. Тепло расслабляет брюшную стенку — поэтому те же движения тёплыми руками работают лучше, чем холодными."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Massaging straight after a feed, which usually brings milk back up.",
                    "Pressing firmly on a full tummy.",
                    "Anticlockwise circles, working against the natural direction.",
                    "Simethicone drops or herbal teas without asking your doctor first."
                ],
                ru: [
                    "Массировать сразу после кормления — обычно это заканчивается срыгиванием.",
                    "Сильно надавливать на полный живот.",
                    "Круговые движения против часовой стрелки, против естественного направления.",
                    "Капли с симетиконом или травяные чаи без предварительной консультации с врачом."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "The tummy is hard, swollen, or tender to touch.",
                    "No stool for an unusually long stretch alongside distress and vomiting.",
                    "Blood or mucus in the stool.",
                    "Drawing the legs up with screaming that comes in sharp waves."
                ],
                ru: [
                    "Живот твёрдый, вздутый или болезненный при прикосновении.",
                    "Необычно долгое отсутствие стула вместе с беспокойством и рвотой.",
                    "Кровь или слизь в стуле.",
                    "Ребёнок поджимает ножки и кричит резкими приступами."
                ]
            )
        ),

        CareTip(
            id: 1303, category: .comfort, icon: "thermometer.high", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Measuring a fever and knowing the thresholds",
                ru: "Как измерять температуру и какие пороги важны"
            ),
            summary: LocalizedText(
                en: "Under three months, any fever is an immediate call — no exceptions",
                ru: "До трёх месяцев любая лихорадка — повод немедленно обратиться к врачу, без исключений"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Measure with a digital thermometer under the arm for young babies, or use the device your doctor recommends.",
                    "Record the number and the time in Momsy so you can show the curve, not a single point.",
                    "Watch behaviour as well as the number: feeding, alertness, wet nappies, breathing, skin colour.",
                    "Keep fluids going — more frequent breast or formula feeds, and water too once solids have started.",
                    "Do not overwrap. One light layer helps heat escape."
                ],
                ru: [
                    "Измеряйте цифровым термометром в подмышечной впадине у маленьких детей или прибором, который рекомендовал ваш врач.",
                    "Записывайте значение и время в Momsy, чтобы показать врачу динамику, а не одну точку.",
                    "Следите не только за цифрой, но и за поведением: кормление, активность, мокрые подгузники, дыхание, цвет кожи.",
                    "Поддерживайте питьевой режим — чаще прикладывайте к груди или давайте смесь, а после введения прикорма и воду.",
                    "Не кутайте. Один лёгкий слой одежды помогает теплу уходить."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "In babies under three months the immune system cannot contain infection reliably, so a temperature of 38 °C or above is treated as urgent regardless of how well the baby seems. From three months onwards, behaviour carries more information than the number itself: a baby with 39 °C who drinks and responds to you is usually less concerning than one at 38 °C who is limp and will not feed.",
                ru: "У детей до трёх месяцев иммунная система не может надёжно сдержать инфекцию, поэтому температура 38 °C и выше считается неотложной ситуацией независимо от того, насколько хорошо выглядит ребёнок. После трёх месяцев поведение говорит больше, чем сама цифра: ребёнок с 39 °C, который пьёт и реагирует на вас, обычно менее тревожен, чем ребёнок с 38 °C, который вялый и отказывается от еды."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Judging temperature by touch alone.",
                    "Wrapping a hot baby in blankets.",
                    "Any medication without confirming the dose for your baby's age and weight with a professional.",
                    "Cold baths or alcohol rubs to bring the temperature down."
                ],
                ru: [
                    "Оценивать температуру только на ощупь.",
                    "Укутывать горячего ребёнка в одеяла.",
                    "Давать любое лекарство, не уточнив у специалиста дозу для возраста и веса ребёнка.",
                    "Холодные ванны или обтирания спиртом, чтобы сбить температуру."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any fever of 38 °C or more in a baby under three months — seek care immediately.",
                    "Fever with a rash that does not fade under pressure, a stiff neck, or a bulging fontanelle — emergency.",
                    "Difficult or rapid breathing, unusual drowsiness, or a weak cry.",
                    "Fever lasting more than 48 hours, or a baby who will not drink."
                ],
                ru: [
                    "Любая температура 38 °C и выше у ребёнка младше трёх месяцев — обратитесь за помощью немедленно.",
                    "Температура с сыпью, которая не бледнеет при надавливании, ригидность шеи или выбухающий родничок — экстренная ситуация.",
                    "Затруднённое или учащённое дыхание, необычная сонливость или слабый крик.",
                    "Температура держится дольше 48 часов или ребёнок отказывается пить."
                ]
            )
        ),

        CareTip(
            id: 1304, category: .comfort, icon: "mouth.fill", ageFrom: 4, ageTo: 24,
            title: LocalizedText(
                en: "Teething relief that is actually safe",
                ru: "Безопасная помощь при прорезывании зубов"
            ),
            summary: LocalizedText(
                en: "Cool pressure works; necklaces and numbing gels do not belong here",
                ru: "Прохлада и давление помогают; бусы и обезболивающие гели здесь неуместны"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Offer a firm rubber or silicone teether, chilled in the fridge rather than the freezer.",
                    "Rub the gum with a clean finger or a cool damp flannel using steady pressure.",
                    "Let your baby chew on a cold clean cloth under supervision.",
                    "Wipe drool from the chin and neck often and apply a barrier cream to prevent a drool rash.",
                    "Keep routines calm and expect a few unsettled nights around each tooth."
                ],
                ru: [
                    "Дайте плотный резиновый или силиконовый прорезыватель, охлаждённый в холодильнике, а не в морозилке.",
                    "Разотрите десну чистым пальцем или прохладной влажной салфеткой, надавливая ровно и мягко.",
                    "Дайте ребёнку пожевать холодную чистую ткань под присмотром.",
                    "Часто вытирайте слюну с подбородка и шеи и наносите защитный крем, чтобы не было раздражения.",
                    "Сохраняйте спокойный режим дня и будьте готовы к нескольким беспокойным ночам на каждый зуб."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Pressure on the gum interrupts the pain signal from the tooth pushing through, and cold reduces local swelling — which is why a chilled teether outperforms almost everything sold for the purpose. Amber necklaces are a strangulation and choking risk with no proven benefit, and some numbing gels contain ingredients not considered safe for infants. Teething also does not cause high fever or diarrhoea; if those appear, look for another explanation.",
                ru: "Давление на десну перебивает болевой сигнал от прорезывающегося зуба, а холод уменьшает местный отёк — поэтому охлаждённый прорезыватель эффективнее почти всего, что продают для этой цели. Янтарные бусы — риск удушения и попадания в дыхательные пути без доказанной пользы, а некоторые обезболивающие гели содержат вещества, небезопасные для младенцев. Прорезывание зубов также не вызывает высокой температуры и диареи; если они появились, ищите другую причину."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Amber or wooden bead necklaces.",
                    "Teethers frozen solid, which are too hard for delicate gums.",
                    "Numbing gels containing benzocaine or lidocaine.",
                    "Blaming a high fever or a persistent illness on teething."
                ],
                ru: [
                    "Янтарные или деревянные бусы.",
                    "Замороженные до твёрдости прорезыватели — они слишком жёсткие для нежных дёсен.",
                    "Обезболивающие гели с бензокаином или лидокаином.",
                    "Списывать высокую температуру или затяжную болезнь на зубы."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Fever above 38 °C, which is not caused by teething.",
                    "Diarrhoea, vomiting, or a rash across the body.",
                    "Refusal to feed for more than a day.",
                    "Swollen, bleeding gums, or no teeth at all by around 15 months."
                ],
                ru: [
                    "Температура выше 38 °C — она не вызвана прорезыванием зубов.",
                    "Диарея, рвота или сыпь по всему телу.",
                    "Отказ от еды дольше суток.",
                    "Отёкшие, кровоточащие дёсны или полное отсутствие зубов примерно к 15 месяцам."
                ]
            )
        ),

        CareTip(
            id: 1305, category: .comfort, icon: "comb.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Cradle cap: harmless and self-resolving",
                ru: "Себорейные корочки: безобидны и проходят сами"
            ),
            summary: LocalizedText(
                en: "Soften, comb gently, wash out — and accept that time does most of the work",
                ru: "Размягчить, аккуратно вычесать, смыть — и помнить, что основную работу делает время"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Massage a little baby oil or an unfragranced emollient into the scalp and leave it for an hour or overnight.",
                    "Loosen the softened scales with a soft brush or a fine comb, always gently.",
                    "Wash out with a mild baby shampoo, then brush the hair through.",
                    "Repeat every few days rather than daily.",
                    "If it does not shift, leave it — it clears on its own within months."
                ],
                ru: [
                    "Вотрите в кожу головы немного детского масла или эмолента без отдушек и оставьте на час или на ночь.",
                    "Размягчённые чешуйки аккуратно приподнимите мягкой щёткой или частым гребнем.",
                    "Смойте мягким детским шампунем, затем расчешите волосы.",
                    "Повторяйте раз в несколько дней, а не ежедневно.",
                    "Если корочки не поддаются, оставьте их — они проходят сами за несколько месяцев."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Cradle cap comes from overactive oil glands stimulated by hormones still circulating from pregnancy, so it is neither an infection nor a sign of poor hygiene, and it does not itch or bother your baby. Softening first is the whole trick: dry scales are attached to skin, oiled scales are not. Picking at dry patches breaks the skin underneath and opens the door to genuine infection.",
                ru: "Себорейные корочки возникают из-за избыточной работы сальных желёз под действием гормонов, оставшихся с беременности, — это не инфекция и не признак плохой гигиены, они не зудят и не беспокоят ребёнка. Весь секрет в предварительном размягчении: сухие чешуйки держатся за кожу, промасленные — нет. Ковыряние сухих участков повреждает кожу под ними и открывает путь настоящей инфекции."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Picking or scratching off dry flakes with a fingernail.",
                    "Adult anti-dandruff shampoo.",
                    "Daily washing, which strips the scalp and can make it worse.",
                    "Assuming it means your baby is uncomfortable — it almost never is."
                ],
                ru: [
                    "Соскабливать или сдирать сухие чешуйки ногтем.",
                    "Взрослый шампунь от перхоти.",
                    "Ежедневное мытьё, которое пересушивает кожу головы и может ухудшить состояние.",
                    "Думать, что ребёнку от этого дискомфортно, — почти никогда это не так."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "The patches spread to the face, neck or body.",
                    "Redness, weeping, swelling, or a smell — signs of infection.",
                    "Your baby scratches at the scalp or seems itchy.",
                    "It has not improved by around a year."
                ],
                ru: [
                    "Участки распространяются на лицо, шею или тело.",
                    "Покраснение, мокнутие, отёк или запах — признаки инфекции.",
                    "Ребёнок расчёсывает голову или выглядит так, будто его беспокоит зуд.",
                    "К году состояние не улучшилось."
                ]
            )
        )
    ]
}
