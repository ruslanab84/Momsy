import Foundation

extension CareTipsCatalog {
    static let sleep: [CareTip] = [

        CareTip(
            id: 1101, category: .sleep, icon: "bed.double.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "The ABC of safe sleep: Alone, on the Back, in a Cot",
                ru: "Азбука безопасного сна: один, на спине, в кроватке"
            ),
            summary: LocalizedText(
                en: "The single most protective habit of the first year, for every sleep",
                ru: "Самая защитная привычка первого года — и она нужна на каждый сон"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Alone: your baby sleeps on their own surface, with nobody and nothing else on it.",
                    "Back: on the back for every nap and every night, until they roll both ways by themselves.",
                    "Cot: a cot, crib or moses basket that meets current safety standards.",
                    "Apply it to every sleep, including short daytime naps and sleeps away from home.",
                    "Make sure everyone who ever settles your baby — partner, grandparents, nanny — follows the same three rules."
                ],
                ru: [
                    "Один: ребёнок спит на своей отдельной поверхности, где нет ни людей, ни предметов.",
                    "На спине: на спине на каждый дневной сон и на всю ночь, пока он не начнёт самостоятельно переворачиваться в обе стороны.",
                    "В кроватке: в детской кроватке, колыбели или корзине, соответствующей действующим стандартам безопасности.",
                    "Соблюдайте это на каждый сон, включая короткие дневные и сон вне дома.",
                    "Убедитесь, что все, кто когда-либо укладывает ребёнка — партнёр, бабушки и дедушки, няня, — следуют этим же трём правилам."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Back sleeping is the change most strongly associated with the fall in sudden infant death rates worldwide. On the back, the airway stays open and the swallowing reflex is better positioned to protect it, which is also why healthy babies do not choke when they sleep this way. The value of the rule comes from consistency: occasional exceptions, including at other people's homes, are where the risk concentrates.",
                ru: "Сон на спине — то изменение, которое сильнее всего связано со снижением частоты синдрома внезапной детской смерти во всём мире. На спине дыхательные пути остаются открытыми, а глотательный рефлекс лучше расположен для их защиты — поэтому здоровые дети в такой позе не поперхиваются. Ценность правила — в постоянстве: именно на редких исключениях, в том числе в гостях, и концентрируется риск."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Side sleeping as a compromise — it is unstable and the baby can roll to the front.",
                    "Front sleeping for naps because the baby settles better that way.",
                    "Different rules for daytime naps than for the night.",
                    "Assuming a baby who has rolled once is ready to sleep on their front."
                ],
                ru: [
                    "Сон на боку как «компромисс» — эта поза неустойчива, и ребёнок может перевернуться на живот.",
                    "Укладывать на живот на дневной сон, потому что так ребёнок засыпает лучше.",
                    "Разные правила для дневного сна и для ночи.",
                    "Считать, что ребёнок, перевернувшийся один раз, уже готов спать на животе."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby is very unsettled on their back and has been diagnosed with reflux — ask before changing anything.",
                    "Any breathing pause, colour change, or floppiness during sleep — seek help immediately.",
                    "A health professional has advised a different position for a medical reason; follow their instruction, not this card."
                ],
                ru: [
                    "Ребёнок очень беспокоен на спине и у него диагностирован рефлюкс — спросите врача, прежде чем что-то менять.",
                    "Любая пауза в дыхании, изменение цвета кожи или вялость во время сна — немедленно обратитесь за помощью.",
                    "Врач рекомендовал другое положение по медицинским показаниям: следуйте его назначению, а не этой карточке."
                ]
            )
        ),

        CareTip(
            id: 1102, category: .sleep, icon: "checkmark.shield.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "A firm, flat, empty sleep surface",
                ru: "Твёрдая, ровная и пустая поверхность для сна"
            ),
            summary: LocalizedText(
                en: "Nothing in the cot but a fitted sheet and your baby",
                ru: "В кроватке только натянутая простыня и сам ребёнок"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Use a firm, flat mattress that fits the cot frame with no gaps at the edges.",
                    "Cover it with one well-fitted sheet and nothing else.",
                    "Remove pillows, duvets, loose blankets, cot bumpers, positioners, wedges and soft toys.",
                    "Use a sleeping bag or a light tucked blanket that reaches no higher than the chest, with feet at the foot of the cot.",
                    "Keep the cot away from cords, blind pulls, and anything hanging within reach."
                ],
                ru: [
                    "Используйте твёрдый ровный матрас, который точно подходит к кроватке без зазоров по краям.",
                    "Застелите его одной хорошо натянутой простынёй и больше ничем.",
                    "Уберите подушки, одеяла, свободные пледы, бортики, позиционеры, клинья и мягкие игрушки.",
                    "Используйте спальный мешок либо лёгкий подвёрнутый пледик не выше уровня груди, уложив ребёнка ножками к нижнему краю кроватки.",
                    "Держите кроватку вдали от проводов, шнуров жалюзи и всего, что свисает в пределах досягаемости."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "A soft or cluttered surface can mould around the face or let a baby rebreathe their own exhaled air, and young babies cannot reliably move their head away from an obstruction. Cot bumpers and sleep positioners were designed to solve problems that a correctly sized cot does not have, and both have caused harm. The safest cot looks almost empty, which feels wrong to most parents and is exactly right.",
                ru: "Мягкая или заставленная поверхность может облепить лицо или заставить ребёнка вдыхать собственный выдохнутый воздух, а маленькие дети не могут надёжно отвернуть голову от препятствия. Бортики и позиционеры для сна придумали для решения проблем, которых у правильно подобранной кроватки нет, и и то и другое приводило к трагедиям. Самая безопасная кроватка выглядит почти пустой — большинству родителей это кажется неправильным, и это именно то, что нужно."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Adding a comforter or muslin 'just for naps'.",
                    "A mattress topper or extra padding for comfort.",
                    "A duvet or pillow in the first year.",
                    "Letting the baby sleep on a sofa, armchair or beanbag with an adult."
                ],
                ru: [
                    "Добавлять игрушку-комфортер или пелёнку «только на дневной сон».",
                    "Класть наматрасник или дополнительную подкладку «для удобства».",
                    "Одеяло или подушка на первом году жизни.",
                    "Давать ребёнку спать на диване, в кресле или на бескаркасном пуфе вместе со взрослым."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby cannot settle at all on a firm flat surface after the newborn weeks.",
                    "Reflux is severe enough that you are considering a wedge or an incline — ask first.",
                    "You find your baby with bedding over the face, even once."
                ],
                ru: [
                    "После периода новорождённости ребёнок совсем не может уснуть на твёрдой ровной поверхности.",
                    "Рефлюкс настолько выражен, что вы думаете о клине или наклоне — сначала спросите врача.",
                    "Вы обнаружили ребёнка с постельным бельём на лице, даже однократно."
                ]
            )
        ),

        CareTip(
            id: 1103, category: .sleep, icon: "house.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Share a room, not a bed, for the first six months",
                ru: "Первые шесть месяцев — одна комната, но не одна кровать"
            ),
            summary: LocalizedText(
                en: "Same room, separate surface — close enough to hear, safe enough to sleep",
                ru: "Та же комната, отдельная поверхность: достаточно близко, чтобы слышать, и достаточно безопасно, чтобы спать"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Place the cot, crib or bedside sleeper within arm's reach of your bed.",
                    "Keep this arrangement for at least the first six months, including naps if you are in the room.",
                    "Feed in bed if you need to, but move your baby back to their own surface before you sleep.",
                    "If you might fall asleep while feeding, clear the bed of pillows and duvets first as a precaution.",
                    "Never sleep with your baby on a sofa or armchair — this carries a much higher risk than a bed."
                ],
                ru: [
                    "Поставьте кроватку, колыбель или приставную кроватку на расстоянии вытянутой руки от своей постели.",
                    "Сохраняйте такую расстановку минимум первые шесть месяцев, в том числе на дневной сон, если вы в комнате.",
                    "Кормите в постели, если так нужно, но переложите ребёнка на его поверхность, прежде чем сами уснёте.",
                    "Если есть риск, что вы уснёте во время кормления, заранее уберите с постели подушки и одеяла.",
                    "Никогда не засыпайте с ребёнком на диване или в кресле — это гораздо опаснее, чем кровать."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Room-sharing is associated with a lower risk of sudden infant death, and it makes night feeds far less exhausting because nobody has to cross the house. Bed-sharing is a different thing: adult bedding, mattress softness and the presence of another body change the picture. Separating the two ideas lets you keep the benefit of closeness without the associated risk.",
                ru: "Сон в одной комнате связан с более низким риском синдрома внезапной детской смерти, и он делает ночные кормления заметно менее изматывающими, потому что не нужно ходить через всю квартиру. Совместный сон в одной кровати — это другое: взрослое постельное бельё, мягкость матраса и присутствие другого тела меняют картину. Разделение этих двух понятий позволяет сохранить пользу близости без связанного с ней риска."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Moving the baby to their own room early because they seem noisy sleepers.",
                    "Falling asleep on the sofa during night feeds.",
                    "Bed-sharing after alcohol, sedating medication, or extreme exhaustion.",
                    "A bedside sleeper that is not securely fixed, leaving a gap against the adult mattress."
                ],
                ru: [
                    "Рано переселять ребёнка в отдельную комнату из-за того, что он «шумно спит».",
                    "Засыпать на диване во время ночных кормлений.",
                    "Спать с ребёнком в одной кровати после алкоголя, успокоительных препаратов или при крайнем истощении.",
                    "Ненадёжно закреплённая приставная кроватка, из-за которой остаётся щель у взрослого матраса."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby was premature or had a low birth weight — ask about additional precautions.",
                    "You find yourself repeatedly falling asleep while feeding — say so; there are safer arrangements.",
                    "Snoring, pauses in breathing, or noisy laboured breathing during sleep."
                ],
                ru: [
                    "Ребёнок родился раньше срока или с низким весом — спросите о дополнительных мерах предосторожности.",
                    "Вы регулярно засыпаете во время кормления — скажите об этом: есть более безопасные варианты.",
                    "Храп, паузы в дыхании или шумное затруднённое дыхание во сне."
                ]
            )
        ),

        CareTip(
            id: 1104, category: .sleep, icon: "thermometer.medium", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Room temperature and how to dress for sleep",
                ru: "Температура в комнате и как одевать на сон"
            ),
            summary: LocalizedText(
                en: "Aim for 18–21 °C and check the chest, not the hands",
                ru: "Ориентир — 18–21 °C, проверяйте грудь, а не ручки"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep the sleep room between about 18 and 21 °C where you can.",
                    "Dress your baby in one more layer than you are comfortable in, counting the sleeping bag as a layer.",
                    "Check temperature by slipping two fingers onto the chest or the back of the neck.",
                    "Use a lighter sleeping bag in summer and a warmer one in winter rather than adding loose blankets.",
                    "Remove hats and hoods indoors — babies release heat through the head."
                ],
                ru: [
                    "По возможности держите в комнате для сна примерно от 18 до 21 °C.",
                    "Одевайте ребёнка на один слой теплее, чем комфортно вам, считая спальный мешок за слой.",
                    "Проверяйте температуру, просунув два пальца на грудь или заднюю поверхность шеи.",
                    "Летом берите более тонкий спальный мешок, зимой — более тёплый, вместо того чтобы добавлять свободные пледы.",
                    "Дома снимайте шапочки и капюшоны — дети отдают тепло через голову."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Overheating is a recognised risk factor for sudden infant death, and babies cannot take off a layer or push away a blanket the way an adult can. Cool hands and feet are normal for months and are a poor guide, because circulation to the extremities is still developing. The chest tells you the truth: it should feel warm and dry, never hot or clammy.",
                ru: "Перегрев — признанный фактор риска синдрома внезапной детской смерти, а ребёнок не может снять слой одежды или отбросить одеяло, как взрослый. Прохладные ручки и ножки нормальны в течение месяцев и плохо подходят как ориентир, потому что кровообращение в конечностях ещё формируется. Правду говорит грудь: она должна быть тёплой и сухой, но не горячей и не влажной."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Adding layers because the hands feel cold.",
                    "Leaving a hat on for indoor sleep.",
                    "A hot water bottle or electric blanket in the cot.",
                    "Placing the cot next to a radiator or in direct sunlight."
                ],
                ru: [
                    "Добавлять слои одежды из-за того, что ручки холодные.",
                    "Оставлять шапочку на время сна дома.",
                    "Грелка или электрическое одеяло в кроватке.",
                    "Ставить кроватку у радиатора или под прямыми солнечными лучами."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby is sweating, flushed, or breathing rapidly during sleep.",
                    "The chest feels hot and clammy even after removing a layer.",
                    "A fever appears alongside unusual drowsiness or refusal to feed."
                ],
                ru: [
                    "Ребёнок потеет, у него покраснело лицо или учащённое дыхание во сне.",
                    "Грудь горячая и влажная даже после того, как вы сняли один слой одежды.",
                    "Появилась температура вместе с необычной сонливостью или отказом от еды."
                ]
            )
        ),

        CareTip(
            id: 1105, category: .sleep, icon: "moon.fill", ageFrom: 0, ageTo: 4,
            title: LocalizedText(
                en: "Swaddling — and stopping at the first sign of rolling",
                ru: "Пеленание — и отказ от него при первых переворотах"
            ),
            summary: LocalizedText(
                en: "Snug at the arms, loose at the hips, and finished before rolling starts",
                ru: "Плотно у ручек, свободно в бёдрах и закончить до начала переворотов"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Use a thin breathable fabric or a purpose-made swaddle, never a heavy blanket.",
                    "Keep it firm across the chest but loose enough to slide two fingers under the top edge.",
                    "Leave plenty of room at the hips so the legs can bend up and out.",
                    "Always place a swaddled baby on their back, never on the side or front.",
                    "Stop swaddling completely at the first sign of rolling — usually somewhere between two and four months. Move to a sleeping bag with arms free."
                ],
                ru: [
                    "Используйте тонкую дышащую ткань или специальный конверт для пеленания, но не плотное одеяло.",
                    "Пеленайте плотно на уровне груди, но так, чтобы под верхний край проходили два пальца.",
                    "Оставляйте достаточно места в бёдрах, чтобы ножки могли сгибаться и разводиться.",
                    "Запелёнатого ребёнка всегда кладите на спину, никогда на бок или на живот.",
                    "Полностью прекратите пеленание при первых признаках переворотов — обычно между двумя и четырьмя месяцами. Перейдите на спальный мешок со свободными руками."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Swaddling dampens the startle reflex that wakes newborns from light sleep, which is why it often buys everyone a longer stretch. The danger point is rolling: a swaddled baby who turns onto their front cannot use their arms to lift or turn their head. Hip room matters too, because tightly straightened legs can interfere with normal hip development in the early months.",
                ru: "Пеленание сглаживает рефлекс вздрагивания, который будит новорождённого из поверхностного сна, — поэтому оно часто даёт всем более длинный отрезок сна. Опасный момент — перевороты: запелёнатый ребёнок, оказавшийся на животе, не может опереться руками, чтобы поднять или повернуть голову. Свобода в бёдрах тоже важна: туго выпрямленные ножки могут нарушить нормальное развитие тазобедренных суставов в первые месяцы."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Wrapping the legs straight and tight.",
                    "Continuing to swaddle after the first roll because it still helps sleep.",
                    "Swaddling on top of thick clothing, which risks overheating.",
                    "Covering the neck or chin with the top edge of the fabric."
                ],
                ru: [
                    "Пеленать ножки туго и выпрямленными.",
                    "Продолжать пеленать после первого переворота, потому что это всё ещё помогает спать.",
                    "Пеленать поверх плотной одежды — риск перегрева.",
                    "Закрывать верхним краем ткани шею или подбородок."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "You hear a click from the hips, or the legs seem to move unevenly.",
                    "Your baby overheats when swaddled even in light layers.",
                    "Your baby rolls while swaddled — stop immediately and mention it at the next check-up."
                ],
                ru: [
                    "Вы слышите щелчок в области бёдер или ножки двигаются несимметрично.",
                    "Ребёнок перегревается в пеленании даже в лёгкой одежде.",
                    "Ребёнок перевернулся запелёнатым — сразу прекратите пеленание и скажите об этом на следующем осмотре."
                ]
            )
        ),

        CareTip(
            id: 1106, category: .sleep, icon: "clock.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Wake windows and the overtired trap",
                ru: "Окна бодрствования и ловушка перевозбуждения"
            ),
            summary: LocalizedText(
                en: "Watch the clock and the baby — a short awake stretch prevents a long fight",
                ru: "Следите и за часами, и за ребёнком: короткое бодрствование избавляет от долгой борьбы"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Use rough guides: about 45–60 minutes awake for a newborn, 1.5–2 hours around 3–4 months, 2–3 hours by 6 months, 3–4 hours near a year.",
                    "Start winding down at the first tired cues — a fixed stare, red eyebrows, ear pulling, sudden clumsiness in movement.",
                    "Treat the ranges as a starting point and adjust to your own baby over a week of observation.",
                    "Track sleep in Momsy for a few days to see the real pattern rather than the remembered one.",
                    "Shorten the wake window rather than lengthening it when settling has been difficult."
                ],
                ru: [
                    "Ориентировочные рамки: около 45–60 минут бодрствования у новорождённого, 1,5–2 часа в 3–4 месяца, 2–3 часа к 6 месяцам, 3–4 часа ближе к году.",
                    "Начинайте успокаивать при первых признаках усталости — застывший взгляд, покраснение вокруг бровей, потягивание за ухо, внезапная неловкость движений.",
                    "Считайте эти рамки отправной точкой и подстраивайте под своего ребёнка, наблюдая в течение недели.",
                    "Понаблюдайте за сном в Momsy несколько дней, чтобы увидеть реальную картину, а не ту, которая запомнилась.",
                    "Если укладывание идёт тяжело, сокращайте окно бодрствования, а не удлиняйте его."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "When a baby stays awake past their limit, the body releases stress hormones to keep going, and those same hormones then make falling asleep harder and staying asleep shorter. That is the counter-intuitive part of infant sleep: an overtired baby fights sleep more, not less. Catching the window early is usually the difference between a five-minute settle and forty-five minutes of crying.",
                ru: "Когда ребёнок бодрствует дольше своего предела, организм выбрасывает гормоны стресса, чтобы держаться, и эти же гормоны потом мешают уснуть и сокращают сон. В этом парадокс детского сна: переутомлённый ребёнок сопротивляется сну сильнее, а не слабее. Поймать окно вовремя — обычно разница между пятиминутным укладыванием и сорока пятью минутами плача."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Keeping the baby up longer in the hope of a better night.",
                    "Following a chart from the internet instead of your own baby's signals.",
                    "Missing the earliest cues and waiting for eye rubbing or crying.",
                    "Expecting the same window every time of day — the first one of the morning is usually shortest."
                ],
                ru: [
                    "Специально не давать ребёнку спать дольше в надежде на лучшую ночь.",
                    "Следовать таблице из интернета вместо сигналов собственного ребёнка.",
                    "Пропускать самые ранние признаки и ждать, пока он начнёт тереть глаза или плакать.",
                    "Ожидать одинаковое окно в любое время дня — первое, утреннее, обычно самое короткое."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby sleeps far more or far less than the guides over several weeks and seems unwell with it.",
                    "Sleep is constantly broken by pain, coughing, or laboured breathing.",
                    "You are worried about development alongside unusual sleep patterns."
                ],
                ru: [
                    "Ребёнок неделями спит намного больше или намного меньше ориентиров и при этом выглядит нездоровым.",
                    "Сон постоянно прерывается из-за боли, кашля или затруднённого дыхания.",
                    "Необычный режим сна сочетается с вашими опасениями по поводу развития."
                ]
            )
        ),

        CareTip(
            id: 1107, category: .sleep, icon: "sparkles", ageFrom: 2, ageTo: 12,
            title: LocalizedText(
                en: "Build a twenty-minute bedtime routine",
                ru: "Создайте двадцатиминутный ритуал перед сном"
            ),
            summary: LocalizedText(
                en: "The same short sequence every night becomes a signal your baby can read",
                ru: "Одна и та же короткая последовательность каждый вечер становится понятным ребёнку сигналом"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Choose three or four steps and keep the order fixed: for example bath, sleeping bag, feed, one short song.",
                    "Keep the whole thing to about twenty minutes — long routines drift past the tired window.",
                    "Dim the lights and lower your voice from the first step onwards.",
                    "Finish in the room where your baby will sleep.",
                    "Use the same shortened version away from home so the signal still works when everything else is unfamiliar."
                ],
                ru: [
                    "Выберите три-четыре шага и не меняйте их порядок: например, купание, спальный мешок, кормление, одна короткая песенка.",
                    "Укладывайтесь примерно в двадцать минут — длинные ритуалы выходят за окно усталости.",
                    "С первого шага приглушите свет и говорите тише.",
                    "Заканчивайте в той комнате, где ребёнок будет спать.",
                    "Вне дома используйте ту же, только сокращённую версию, чтобы сигнал работал, когда всё вокруг незнакомо."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Babies cannot tell time, but they are excellent at recognising sequences. A repeated pattern of dimming light, a familiar smell and a predictable order tells the body what is coming, and melatonin release follows the cue. The routine is doing something real; it is not a superstition. Consistency matters far more than the specific contents, which is why simple routines usually outperform elaborate ones.",
                ru: "Дети не умеют определять время, но прекрасно распознают последовательности. Повторяющееся сочетание приглушённого света, знакомого запаха и предсказуемого порядка сообщает организму, что будет дальше, и выброс мелатонина следует за этим сигналом. Ритуал действительно работает, это не суеверие. Постоянство важнее конкретного содержания — поэтому простые ритуалы обычно эффективнее сложных."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Changing the order depending on who is putting the baby down.",
                    "Screens or bright overhead light during the wind-down.",
                    "Starting the routine only after the baby is already overtired.",
                    "Abandoning the routine on holiday or when visiting family."
                ],
                ru: [
                    "Менять порядок в зависимости от того, кто укладывает ребёнка.",
                    "Экраны или яркий верхний свет во время подготовки ко сну.",
                    "Начинать ритуал, когда ребёнок уже переутомлён.",
                    "Отказываться от ритуала в отпуске или в гостях у родственников."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Bedtime is consistently distressing for months despite a stable routine.",
                    "Your baby wakes screaming and cannot be comforted, night after night.",
                    "You are running out of resources to cope with the nights — say this out loud to your doctor or health visitor."
                ],
                ru: [
                    "Укладывание месяцами проходит тяжело, несмотря на стабильный ритуал.",
                    "Ребёнок просыпается с криком и не успокаивается, ночь за ночью.",
                    "У вас заканчиваются силы выдерживать ночи — скажите об этом врачу или патронажной сестре прямо."
                ]
            )
        )
    ]
}
