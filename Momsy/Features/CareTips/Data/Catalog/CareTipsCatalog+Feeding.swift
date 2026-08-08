import Foundation

extension CareTipsCatalog {
    static let feeding: [CareTip] = [

        CareTip(
            id: 1001, category: .feeding, icon: "arrow.up.circle.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Hold your baby upright after every feed",
                ru: "Держите ребёнка вертикально после каждого кормления",
                de: "Halten Sie Ihr Baby nach dem Füttern aufrecht"
            ),
            summary: LocalizedText(
                en: "Ten to fifteen minutes vertical lets swallowed air come up before milk does",
                ru: "Десять-пятнадцать минут столбиком дают воздуху выйти раньше молока",
                de: "Zehn bis fünfzehn Minuten aufrecht lassen die Luft vor der Milch nach oben kommen"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Lift your baby onto your shoulder so their chest rests against you and their chin clears your shoulder.",
                    "Support the head and neck with one hand; keep the spine straight rather than curled.",
                    "Stay upright for 10–15 minutes after a full feed, a little longer if your baby is prone to spitting up.",
                    "Pat or stroke the back gently and rhythmically — pressure is never needed.",
                    "Swap to a sitting-on-your-lap hold if your arm tires; the point is the vertical spine, not the exact position."
                ],
                ru: [
                    "Поднимите ребёнка к своему плечу так, чтобы его грудь прилегала к вам, а подбородок был выше вашего плеча.",
                    "Поддерживайте голову и шею одной рукой; спина должна быть прямой, а не скруглённой.",
                    "Держите вертикально 10–15 минут после полного кормления, чуть дольше — если ребёнок часто срыгивает.",
                    "Мягко и ритмично похлопывайте или поглаживайте спинку — давить никогда не нужно.",
                    "Если рука устала, пересадите ребёнка к себе на колени: важна вертикальная спина, а не конкретная поза."
                ],
                de: [
                    "Heben Sie Ihr Baby auf Ihre Schulter, sodass die Brust gegen Sie anliegt und das Kinn über Ihrer Schulter ist.",
                    "Stützen Sie Kopf und Nacken mit einer Hand; halten Sie die Wirbelsäule gerade und nicht gekrümmt.",
                    "Bleiben Sie 10–15 Minuten nach einer vollständigen Mahlzeit aufrecht, etwas länger, wenn Ihr Baby zum Spucken neigt.",
                    "Klopfen oder streicheln Sie den Rücken sanft und rhythmisch — Druck ist niemals erforderlich.",
                    "Wechseln Sie zu einem Halt auf Ihrem Schoß, wenn Ihr Arm müde wird; wichtig ist die aufrechte Wirbelsäule, nicht die exakte Position."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Newborns swallow air with almost every feed, and the valve between the stomach and the food pipe is still soft and easily opened. When your baby lies flat straight after a feed, that trapped air pushes milk back up with it. Staying upright lets the air rise above the milk and escape on its own, which usually means less spitting up, fewer squirming episodes and a calmer settle afterwards.",
                ru: "Новорождённые заглатывают воздух почти при каждом кормлении, а клапан между желудком и пищеводом ещё мягкий и легко открывается. Если сразу после еды положить ребёнка горизонтально, задержавшийся воздух выталкивает молоко вместе с собой. В вертикальном положении воздух поднимается над молоком и выходит сам — обычно это означает меньше срыгиваний, меньше беспокойных выгибаний и более спокойное засыпание.",
                de: "Neugeborene schlucken bei fast jedem Füttern Luft, und das Ventil zwischen Magen und Speiseröhre ist noch weich und leicht zu öffnen. Wenn Ihr Baby direkt nach dem Füttern flach liegt, drückt die eingeschlossene Luft die Milch mit nach oben. Wenn Sie aufrecht bleiben, kann die Luft über der Milch aufsteigen und von selbst entweichen, was normalerweise weniger Spucken, weniger Zappeln und eine ruhigere Beruhigung danach bedeutet."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Putting the baby straight down because they fell asleep at the breast or bottle.",
                    "Curling the body forward so the tummy is compressed — this makes reflux more likely, not less.",
                    "Firm patting in the belief that harder means faster.",
                    "Using a car seat or bouncer as the upright position — the slouched angle folds the tummy."
                ],
                ru: [
                    "Сразу класть ребёнка, потому что он уснул у груди или с бутылочкой.",
                    "Сгибать тело вперёд, сдавливая живот, — так рефлюкс становится вероятнее, а не наоборот.",
                    "Сильно похлопывать в расчёте, что «сильнее — значит быстрее».",
                    "Использовать автокресло или шезлонг как «вертикальное положение» — сутулый угол складывает живот."
                ],
                de: [
                    "Das Baby sofort hinlegen, weil es an der Brust oder Flasche eingeschlafen ist.",
                    "Den Körper nach vorne krümmen, sodass der Bauch gepresst wird — das macht Reflux wahrscheinlicher, nicht weniger.",
                    "Festes Klopfen in der Annahme, dass stärker schneller ist.",
                    "Einen Autositz oder eine Wippe als aufrechte Position verwenden — der gekrümmte Winkel faltet den Bauch."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Spit-up is green, yellow, or contains blood.",
                    "Your baby arches, screams, or refuses feeds regularly after eating.",
                    "Weight gain slows or nappies become noticeably drier.",
                    "Milk comes back forcefully and repeatedly, not as a gentle dribble."
                ],
                ru: [
                    "Срыгиваемое содержимое зелёное, жёлтое или с кровью.",
                    "Ребёнок регулярно выгибается, кричит или отказывается от еды после кормления.",
                    "Прибавка в весе замедлилась или подгузники стали заметно суше.",
                    "Молоко выходит фонтаном и повторно, а не как небольшое подтекание."
                ],
                de: [
                    "Spucken ist grün, gelb oder enthält Blut.",
                    "Ihr Baby wölbt sich regelmäßig, schreit oder lehnt Mahlzeiten nach dem Essen ab.",
                    "Gewichtszunahme verlangsamt sich oder Windeln werden merklich trockener.",
                    "Milch kommt kräftig und wiederholt zurück, nicht als sanftes Rinnsal."
                ]
            )
        ),

        CareTip(
            id: 1002, category: .feeding, icon: "hands.sparkles.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Three burping positions and when each one works",
                ru: "Три позы для отрыжки и когда какая работает",
                de: "Drei Positionen zum Aufstoßen und wann jede funktioniert"
            ),
            summary: LocalizedText(
                en: "If one hold does not work in five minutes, change position instead of patting longer",
                ru: "Если поза не сработала за пять минут, меняйте её, а не продолжайте похлопывать",
                de: "Wenn eine Position in fünf Minuten nicht funktioniert, wechseln Sie sie, anstatt länger zu klopfen"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Over the shoulder: chest against you, chin above the shoulder — the classic first attempt.",
                    "Sitting on your lap: support the chin and jaw with your palm (never the throat), lean the body slightly forward, pat between the shoulder blades.",
                    "Face down across your lap: tummy on your thighs, head slightly higher than the body, one hand steadying the back.",
                    "Give each position about five minutes, then switch rather than continuing with the same one.",
                    "Burp mid-feed too — when you swap sides, or after roughly 60 ml from a bottle."
                ],
                ru: [
                    "Столбиком у плеча: грудь прижата к вам, подбородок выше плеча — классическая первая попытка.",
                    "Сидя у вас на коленях: поддерживайте подбородок и челюсть ладонью (никогда не горло), слегка наклоните корпус вперёд, похлопывайте между лопатками.",
                    "Лёжа животом поперёк ваших коленей: живот на бёдрах, голова чуть выше тела, одна рука придерживает спину.",
                    "Пробуйте каждую позу около пяти минут, затем меняйте, а не продолжайте ту же самую.",
                    "Делайте паузу на отрыжку и в середине кормления — при смене груди или примерно после 60 мл из бутылочки."
                ],
                de: [
                    "Über der Schulter: Brust gegen Sie, Kinn über der Schulter — der klassische erste Versuch.",
                    "Sitzend auf Ihrem Schoß: Kinn und Kiefer mit der Handfläche stützen (niemals die Kehle), den Körper leicht nach vorne neigen, zwischen den Schulterblättern klopfen.",
                    "Bauchlage über Ihrem Schoß: Bauch auf Ihren Oberschenkeln, Kopf leicht höher als der Körper, eine Hand stabilisiert den Rücken.",
                    "Geben Sie jeder Position etwa fünf Minuten, dann wechseln Sie, anstatt bei derselben zu bleiben.",
                    "Lassen Sie Ihr Baby auch während der Fütterung aufstoßen — beim Seitenwechsel oder nach etwa 60 ml aus der Flasche."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Air sits wherever the stomach happens to be shaped at that moment, so a hold that releases a burp today may do nothing tomorrow. Changing the angle moves the bubble towards the top of the stomach where it can escape. Mid-feed burping helps more than a single attempt at the end, because a smaller stomach releases air more easily than a full one.",
                ru: "Воздух располагается там, где в этот момент оказалась форма желудка, поэтому поза, сработавшая сегодня, завтра может не дать ничего. Смена угла перемещает пузырь к верхней части желудка, откуда он может выйти. Отрыжка в середине кормления помогает больше, чем одна попытка в конце: из менее наполненного желудка воздух выходит легче.",
                de: "Luft sitzt dort, wo der Magen in diesem Moment geformt ist, also kann eine Position, die heute zu einem Aufstoßen führt, morgen nichts bewirken. Eine Winkeländerung verschiebt die Blase in Richtung Magenöffnung, von wo aus sie entweichen kann. Aufstoßen während der Fütterung hilft mehr als ein einzelner Versuch am Ende, weil ein kleinerer Magen Luft leichter freisetzt als ein voller."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Patting for twenty minutes in one position with no result.",
                    "Supporting the throat instead of the jaw in the sitting hold.",
                    "Assuming every feed must end with an audible burp — many do not, and that is fine.",
                    "Waiting until the baby is already crying with discomfort before starting."
                ],
                ru: [
                    "Похлопывать двадцать минут в одной позе без результата.",
                    "В позе сидя поддерживать горло вместо челюсти.",
                    "Считать, что каждое кормление должно заканчиваться слышимой отрыжкой, — часто её нет, и это нормально.",
                    "Ждать, пока ребёнок начнёт плакать от дискомфорта, и только потом начинать."
                ],
                de: [
                    "Zwanzig Minuten in einer Position klopfen ohne Ergebnis.",
                    "In der sitzenden Position die Kehle statt des Kiefers stützen.",
                    "Annehmen, dass jede Fütterung mit hörbarem Aufstoßen enden muss — viele tun das nicht, und das ist in Ordnung.",
                    "Warten, bis das Baby bereits vor Unbehagen weint, bevor Sie beginnen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby seems to be in pain during or after most feeds despite burping.",
                    "Feeds regularly end in inconsolable crying that lasts over an hour.",
                    "You notice wheezing, coughing, or colour change during feeds."
                ],
                ru: [
                    "Несмотря на отрыжку, ребёнок явно испытывает боль во время или после большинства кормлений.",
                    "Кормления регулярно заканчиваются безутешным плачем дольше часа.",
                    "Вы замечаете хрипы, кашель или изменение цвета кожи во время кормления."
                ],
                de: [
                    "Ihr Baby scheint trotz Aufstoßen während oder nach den meisten Mahlzeiten Schmerzen zu haben.",
                    "Fütterungen enden regelmäßig mit untröstlichem Weinen, das länger als eine Stunde dauert.",
                    "Sie bemerken Pfeifen, Husten oder Farbveränderungen während der Fütterung."
                ]
            )
        ),

        CareTip(
            id: 1003, category: .feeding, icon: "eye.fill", ageFrom: 0, ageTo: 4,
            title: LocalizedText(
                en: "Catch hunger cues before the crying starts",
                ru: "Замечайте признаки голода до начала плача",
                de: "Erkennen Sie Hungersignale, bevor das Weinen beginnt"
            ),
            summary: LocalizedText(
                en: "Crying is a late signal — feeding at the early cues is calmer for everyone",
                ru: "Плач — поздний сигнал: кормление по ранним признакам спокойнее для всех",
                de: "Weinen ist ein spätes Signal — die Fütterung bei frühen Zeichen ist für alle ruhiger"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Watch for early cues: stirring, mouth opening, turning the head side to side, hands moving to the face.",
                    "Mid cues: stretching, increasing body movement, hands going into the mouth, small fussing sounds.",
                    "Late cues: full crying, a red face, agitated jerky movements.",
                    "Offer a feed at the early or mid stage — latching is easier and the feed is usually more efficient.",
                    "If crying has already started, calm first: skin-to-skin, gentle rocking, a quiet voice, then offer."
                ],
                ru: [
                    "Следите за ранними признаками: ребёнок зашевелился, открывает рот, поворачивает голову из стороны в сторону, тянет руки к лицу.",
                    "Средние признаки: потягивания, усиление движений, руки во рту, короткие похныкивания.",
                    "Поздние признаки: полноценный плач, покрасневшее лицо, резкие возбуждённые движения.",
                    "Предлагайте грудь или бутылочку на ранней или средней стадии — захват легче, а кормление обычно эффективнее.",
                    "Если плач уже начался, сначала успокойте: контакт кожа к коже, мягкое покачивание, тихий голос, и только потом предлагайте еду."
                ],
                de: [
                    "Achten Sie auf frühe Zeichen: Bewegungen, Mundöffnen, Kopfdrehen von Seite zu Seite, Hände bewegen sich zum Gesicht.",
                    "Mittlere Zeichen: Stretching, zunehmende Körperbewegungen, Hände zum Mund, kleine Brabbel- oder Quengelgeräusche.",
                    "Späte Zeichen: vollständiges Weinen, rotes Gesicht, zuckende Bewegungen.",
                    "Bieten Sie die Fütterung in einem frühen oder mittleren Stadium an — das Anlegen ist einfacher und die Fütterung ist meist effizienter.",
                    "Wenn das Weinen bereits begonnen hat, beruhigen Sie zuerst: Haut-zu-Haut-Kontakt, sanftes Wiegen, ruhige Stimme, dann anbieten."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "A crying baby has an arched tongue and a tense jaw, which makes a deep latch physically harder to achieve. Feeds that start from crying tend to be shorter, more frantic, and involve swallowing more air. Reading the early cues also builds your confidence in your own observations, which is worth as much as the smoother feed itself.",
                ru: "У плачущего ребёнка язык выгнут, а челюсть напряжена — глубокий захват физически даётся труднее. Кормления, начатые с плача, обычно короче, более суетливы и сопровождаются заглатыванием большего количества воздуха. Умение читать ранние признаки к тому же укрепляет доверие к собственным наблюдениям, а это ценно не меньше, чем более спокойное кормление.",
                de: "Ein weinendes Baby hat eine gewölbte Zunge und einen angespannten Kiefer, was einen tiefen Halt physisch schwieriger macht. Fütterungen, die aus Weinen beginnen, sind in der Regel kürzer, wilder und beinhalten mehr Luft schlucken. Das Lesen der frühen Zeichen stärkt auch Ihr Vertrauen in Ihre eigenen Beobachtungen, was genauso wertvoll ist wie die sanftere Fütterung selbst."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Feeding strictly by the clock and ignoring what the baby is showing.",
                    "Reading every mouth movement as hunger — babies also mouth their hands to self-soothe and explore.",
                    "Using a dummy to postpone a clear feeding cue in the early weeks."
                ],
                ru: [
                    "Кормить строго по часам, игнорируя то, что показывает ребёнок.",
                    "Принимать любое движение ртом за голод — дети также тянут руки в рот, чтобы успокоиться и исследовать мир.",
                    "Использовать пустышку, чтобы отложить явный сигнал голода в первые недели."
                ],
                de: [
                    "Streng nach der Uhr füttern und ignorieren, was das Baby zeigt.",
                    "Jede Mundbewegung als Hunger auslegen — Babys führen ihre Hände auch zum Mund, um sich selbst zu beruhigen und die Welt zu erkunden.",
                    "In den ersten Wochen einen Schnuller verwenden, um ein klares Hungersignal zu verschieben."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby is consistently too sleepy to show hunger cues and has to be woken for every feed.",
                    "Fewer than six wet nappies a day after the first week.",
                    "Feeding cues appear constantly and feeds never seem to satisfy."
                ],
                ru: [
                    "Ребёнок постоянно слишком сонный, чтобы подавать признаки голода, и его приходится будить на каждое кормление.",
                    "Меньше шести мокрых подгузников в сутки после первой недели.",
                    "Признаки голода появляются постоянно, и кормления как будто никогда не насыщают."
                ],
                de: [
                    "Ihr Baby ist durchgehend zu schläfrig, um Hungersignale zu zeigen, und muss bei jeder Fütterung geweckt werden.",
                    "Weniger als sechs nasse Windeln pro Tag nach der ersten Woche.",
                    "Hungersignale erscheinen ständig und Fütterungen scheinen nie zufriedenzustellen."
                ]
            )
        ),

        CareTip(
            id: 1004, category: .feeding, icon: "drop.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Paced bottle feeding: keep the bottle horizontal",
                ru: "Кормление из бутылочки в темпе ребёнка: держите бутылочку горизонтально",
                de: "Tempogerechtiges Flaschenfahren: Halten Sie die Flasche horizontal"
            ),
            summary: LocalizedText(
                en: "Let your baby set the rhythm instead of letting gravity empty the bottle",
                ru: "Пусть ритм задаёт ребёнок, а не сила тяжести, опустошающая бутылочку",
                de: "Lassen Sie Ihr Baby den Rhythmus vorgeben, anstatt die Schwerkraft die Flasche zu leeren"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Hold your baby semi-upright, head above the tummy — not lying flat.",
                    "Keep the bottle roughly horizontal, filling only the tip of the teat with milk.",
                    "Touch the teat to the lips and wait for the mouth to open rather than pushing it in.",
                    "Pause every 20–30 seconds by tipping the bottle down slightly; let your baby breathe and decide to continue.",
                    "Aim for the feed to last 10–20 minutes, and stop when your baby turns away — even with milk left."
                ],
                ru: [
                    "Держите ребёнка полувертикально, голова выше живота, а не горизонтально.",
                    "Держите бутылочку почти горизонтально, чтобы молоком был заполнен только кончик соски.",
                    "Коснитесь соской губ и подождите, пока рот откроется, а не вставляйте её силой.",
                    "Каждые 20–30 секунд делайте паузу, слегка опуская бутылочку: дайте ребёнку подышать и решить, продолжать ли.",
                    "Стремитесь, чтобы кормление длилось 10–20 минут, и заканчивайте, когда ребёнок отворачивается, — даже если молоко осталось."
                ],
                de: [
                    "Halten Sie Ihr Baby halbaufrecht, mit dem Kopf über dem Bauch — nicht flach liegend.",
                    "Halten Sie die Flasche grob horizontal, wobei nur die Spitze des Saugers mit Milch gefüllt ist.",
                    "Berühren Sie den Sauger an den Lippen und warten Sie, bis sich der Mund öffnet, anstatt ihn hineinzuschieben.",
                    "Machen Sie alle 20–30 Sekunden eine Pause, indem Sie die Flasche leicht neigen; lassen Sie Ihr Baby atmen und selbst entscheiden, ob es weitermachen möchte.",
                    "Zielen Sie darauf ab, dass die Fütterung 10–20 Minuten dauert, und stoppen Sie, wenn sich Ihr Baby abwendet — auch wenn noch Milch vorhanden ist."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "With a vertical bottle, milk flows whether or not the baby is actively sucking, so they must keep swallowing to avoid choking. That overrides the natural pause-and-breathe rhythm they use at the breast, and it bypasses the fullness signal, which is why fast bottle feeds often end with wind, spit-up and a distressed baby. Pacing gives the appetite feedback loop time to work.",
                ru: "При вертикальной бутылочке молоко течёт независимо от того, сосёт ребёнок или нет, поэтому ему приходится всё время глотать, чтобы не поперхнуться. Это перебивает естественный ритм «пауза — вдох», который он использует у груди, и обходит сигнал насыщения — поэтому быстрые кормления из бутылочки часто заканчиваются газиками, срыгиванием и беспокойством. Кормление в темпе ребёнка даёт механизму насыщения время сработать.",
                de: "Bei einer vertikalen Flasche fließt die Milch, ob das Baby aktiv saugt oder nicht, also muss es ständig schlucken, um nicht zu ersticken. Dies setzt den natürlichen Pause-Atem-Rhythmus außer Kraft, den es an der Brust nutzt, und umgeht das Sättigungssignal – deshalb enden schnelle Flaschenmahlzeiten oft mit Blähungen, Spucken und einem gestressten Baby. Das Tempo gibt der Appetitfeedback-Schleife Zeit zu wirken."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Propping the bottle on a cushion and leaving the baby to it — a choking risk, never safe.",
                    "Encouraging the last few millilitres after the baby has clearly stopped.",
                    "Moving up a teat size to shorten feeds.",
                    "Feeding with the baby lying flat on their back."
                ],
                ru: [
                    "Подпирать бутылочку подушкой и оставлять ребёнка одного — риск удушья, так делать нельзя.",
                    "Уговаривать доесть последние миллилитры, когда ребёнок явно закончил.",
                    "Переходить на соску с большим потоком, чтобы сократить кормление.",
                    "Кормить ребёнка, лежащего плашмя на спине."
                ],
                de: [
                    "Die Flasche auf einem Kissen abstützen und das Baby allein lassen — ein Erstickungsrisiko, niemals sicher.",
                    "Die letzten Milliliter zu ermutigen, nachdem das Baby eindeutig gestoppt hat.",
                    "Zu einer größeren Saugergröße wechseln, um Fütterungen zu verkürzen.",
                    "Das Baby füttern, während es flach auf dem Rücken liegt."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Milk regularly leaks from the corners of the mouth, or your baby gulps and splutters.",
                    "Feeds take over 40 minutes and leave your baby exhausted.",
                    "Coughing, gagging, or colour change during bottle feeds."
                ],
                ru: [
                    "Молоко регулярно вытекает из уголков рта или ребёнок захлёбывается и давится.",
                    "Кормление занимает больше 40 минут и полностью изматывает ребёнка.",
                    "Кашель, рвотные позывы или изменение цвета кожи во время кормления из бутылочки."
                ],
                de: [
                    "Milch tritt regelmäßig aus den Mundwinkeln aus, oder Ihr Baby schluckt und sprudelt.",
                    "Fütterungen dauern über 40 Minuten und erschöpfen Ihr Baby.",
                    "Husten, Würgen oder Farbveränderungen während der Flaschenmahlzeit."
                ]
            )
        ),

        CareTip(
            id: 1005, category: .feeding, icon: "timer", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Preparing and storing formula safely",
                ru: "Как безопасно готовить и хранить смесь",
                de: "Formel sicher zubereiten und lagern"
            ),
            summary: LocalizedText(
                en: "Fresh is safest: make each bottle when you need it and discard leftovers",
                ru: "Безопаснее всего свежая: готовьте каждую бутылочку перед кормлением и выливайте остатки",
                de: "Frisch ist am sichersten: Machen Sie jede Flasche, wenn Sie sie brauchen, und entsorgen Sie Reste"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Wash hands, then clean and sterilise bottles and teats for the whole first year.",
                    "Boil fresh water and let it cool for no more than 30 minutes before mixing, so it is still hot enough to kill bacteria in the powder.",
                    "Add water to the bottle first, then the exact number of level scoops stated on the tin.",
                    "Cool quickly under a running cold tap, holding the lid on, and test on your inner wrist — it should feel lukewarm, not warm.",
                    "Throw away anything left in the bottle within two hours of the feed starting."
                ],
                ru: [
                    "Вымойте руки, а бутылочки и соски мойте и стерилизуйте в течение всего первого года.",
                    "Вскипятите свежую воду и дайте ей остыть не более 30 минут перед разведением, чтобы она была ещё достаточно горячей и убила бактерии в порошке.",
                    "Сначала налейте в бутылочку воду, затем добавьте точное число мерных ложек без горки, указанное на банке.",
                    "Быстро охладите под струёй холодной воды, удерживая крышку, и проверьте на внутренней стороне запястья — должно быть чуть тёплым, не горячим.",
                    "Всё, что осталось в бутылочке, выливайте в течение двух часов с начала кормления."
                ],
                de: [
                    "Waschen Sie sich die Hände, reinigen und sterilisieren Sie dann Flaschen und Sauger das ganze erste Jahr.",
                    "Frisches Wasser kochen und vor dem Mischen nicht länger als 30 Minuten abkühlen lassen, damit es noch heiß genug ist, um Bakterien im Pulver abzutöten.",
                    "Wasser zuerst in die Flasche geben, dann die genaue Anzahl der auf der Dose angegebenen ebenen Messlöffel hinzufügen.",
                    "Schnell unter fließendem kaltem Wasser abkühlen, den Deckel halten und an der Innenseite des Handgelenks testen — es sollte sich lauwarm anfühlen, nicht warm.",
                    "Alles, was in der Flasche verbleibt, innerhalb von zwei Stunden nach Beginn der Fütterung entfernen."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Formula powder is not a sterile product, and a warm made-up bottle is an excellent growth medium. Two things protect your baby: water hot enough to kill bacteria at the point of mixing, and a short window between making and drinking. Scoop accuracy matters just as much — over-concentrated formula strains immature kidneys, and over-diluted formula quietly holds back weight gain.",
                ru: "Сухая смесь не является стерильным продуктом, а тёплая разведённая бутылочка — отличная среда для роста бактерий. Ребёнка защищают две вещи: вода, достаточно горячая в момент разведения, чтобы убить бактерии, и короткий промежуток между приготовлением и кормлением. Точность дозировки важна не меньше: слишком концентрированная смесь перегружает незрелые почки, а слишком разведённая незаметно тормозит прибавку в весе.",
                de: "Formelprder ist kein steriles Produkt, und eine warm zubereitete Flasche ist ein ausgezeichnetes Wachstumsmedium. Zwei Dinge schützen Ihr Baby: Wasser, das heiß genug ist, um Bakterien zum Zeitpunkt des Mischens abzutöten, und ein kurzes Fenster zwischen Herstellung und Konsum. Die Genauigkeit der Dosierung ist genauso wichtig — zu konzentrierte Formel belastet unreife Nieren, und zu verdünnte Formel bremst unauffällig das Gewichtswachstum."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Packing or heaping the scoop instead of levelling it off.",
                    "Making up a batch of bottles for the day and leaving them at room temperature.",
                    "Reheating a partly drunk bottle for later.",
                    "Using a microwave, which creates hot spots that can scald the mouth."
                ],
                ru: [
                    "Утрамбовывать порошок в мерной ложке или набирать с горкой вместо того, чтобы снимать излишек.",
                    "Готовить сразу несколько бутылочек на день и оставлять их при комнатной температуре.",
                    "Подогревать недопитую бутылочку, чтобы использовать позже.",
                    "Греть в микроволновой печи — она создаёт горячие точки, которыми можно обжечь рот."
                ],
                de: [
                    "Den Messlöffel stopfen oder häufen, anstatt ihn abzustreichen.",
                    "Mehrere Flaschen für den Tag zubereiten und bei Raumtemperatur stehen lassen.",
                    "Eine teilweise getrunkene Flasche später aufwärmen.",
                    "Eine Mikrowelle verwenden, die heiße Stellen erzeugt, die den Mund verbrennen können."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Vomiting, diarrhoea, or fever after a feed.",
                    "Your baby refuses formula they normally accept, or develops a rash after feeds.",
                    "Weight gain slows despite normal feed volumes."
                ],
                ru: [
                    "Рвота, диарея или температура после кормления.",
                    "Ребёнок отказывается от смеси, которую обычно ест, или после кормлений появляется сыпь.",
                    "Прибавка в весе замедлилась при обычных объёмах кормления."
                ],
                de: [
                    "Erbrechen, Durchfall oder Fieber nach einer Mahlzeit.",
                    "Ihr Baby lehnt Formel ab, die es normalerweise akzeptiert, oder entwickelt nach den Mahlzeiten einen Ausschlag.",
                    "Die Gewichtszunahme verlangsamt sich trotz normaler Fütterungsmengen."
                ]
            )
        ),

        CareTip(
            id: 1006, category: .feeding, icon: "arrow.uturn.up", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Spit-up or vomiting: how to tell them apart",
                ru: "Срыгивание или рвота: как отличить",
                de: "Spucken oder Erbrechen: wie man sie unterscheidet"
            ),
            summary: LocalizedText(
                en: "A relaxed dribble is normal; forceful, distressed, or coloured is not",
                ru: "Спокойное подтекание — норма; фонтаном, с беспокойством или цветное — нет",
                de: "Ein entspanntes Rinnsal ist normal; gewaltsam, angespannt oder gefärbt ist es nicht"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Look at the force: spit-up rolls out of the mouth, vomit is expelled with effort.",
                    "Look at your baby: after spit-up they carry on as if nothing happened; after vomiting they are usually upset.",
                    "Look at the colour: milky white or slightly curdled is expected; green, yellow, brown or blood-streaked is not.",
                    "Note the volume — a tablespoon spreads widely on a muslin and often looks like far more than it is.",
                    "Log episodes in Momsy so you can show a pattern rather than a memory at the next appointment."
                ],
                ru: [
                    "Обратите внимание на силу: при срыгивании содержимое просто вытекает изо рта, рвота выбрасывается с усилием.",
                    "Посмотрите на ребёнка: после срыгивания он ведёт себя как ни в чём не бывало, после рвоты обычно расстроен.",
                    "Посмотрите на цвет: молочно-белое или слегка створоженное — ожидаемо; зелёное, жёлтое, коричневое или с прожилками крови — нет.",
                    "Оцените объём — столовая ложка широко расплывается по пелёнке и часто выглядит куда обильнее, чем есть.",
                    "Отмечайте эпизоды в Momsy, чтобы на приёме показать динамику, а не полагаться на память."
                ],
                de: [
                    "Achten Sie auf die Kraft: Spucken fließt aus dem Mund, Erbrechen wird mit Anstrengung ausgestoßen.",
                    "Schauen Sie Ihr Baby an: Nach dem Spucken machen sie weiter, als wäre nichts passiert; nach dem Erbrechen sind sie normalerweise verärgert.",
                    "Achten Sie auf die Farbe: Milchweiß oder leicht geronnen ist normal; grün, gelb, braun oder blutgestreift ist nicht normal.",
                    "Beachten Sie die Menge — ein Esslöffel breitet sich auf einem Tuch weit aus und sieht oft viel größer aus als es ist.",
                    "Notieren Sie Episoden in Momsy, damit Sie beim nächsten Termin ein Muster zeigen können, anstatt sich auf Ihre Erinnerung zu verlassen."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Around half of all babies spit up in the first months, simply because the ring of muscle at the top of the stomach is still maturing. That is a laundry problem, not a medical one, as long as your baby is comfortable and gaining weight. Vomiting is a different event with different causes, so separating the two in your own mind saves a lot of unnecessary worry — and makes the genuinely concerning episodes stand out.",
                ru: "Примерно половина всех младенцев срыгивает в первые месяцы просто потому, что мышечное кольцо в верхней части желудка ещё дозревает. Это проблема стирки, а не медицины, пока ребёнку комфортно и он прибавляет в весе. Рвота — другое событие с другими причинами, поэтому умение различать их избавляет от множества лишних тревог и позволяет заметить действительно настораживающие эпизоды.",
                de: "Etwa die Hälfte aller Babys speien in den ersten Monaten, einfach weil der Muskelring oben am Magen noch ausreift. Das ist ein Wäscheproblem, kein medizinisches, solange Ihr Baby komfortabel ist und an Gewicht zunimmt. Erbrechen ist ein anderes Ereignis mit anderen Ursachen, also spart das Trennen der beiden in Ihrem Kopf viel unnötige Sorge — und macht die wirklich besorgniserregenden Episoden hervorgehoben."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Cutting feed volumes because of frequent spit-up, which can affect weight gain.",
                    "Switching formula repeatedly without medical advice.",
                    "Judging severity by how large the stain looks.",
                    "Adding thickeners or cereal to bottles without a doctor's guidance."
                ],
                ru: [
                    "Уменьшать объём кормления из-за частых срыгиваний — это может сказаться на прибавке в весе.",
                    "Постоянно менять смесь без совета врача.",
                    "Оценивать серьёзность по размеру пятна.",
                    "Добавлять в бутылочку загустители или кашу без назначения врача."
                ],
                de: [
                    "Fütterungsmengen aufgrund von häufigem Spucken reduzieren, was die Gewichtszunahme beeinträchtigen kann.",
                    "Formel wiederholt ohne ärztliche Anleitung wechseln.",
                    "Den Schweregrad anhand der Größe des Flecks beurteilen.",
                    "Verdickte oder Getreide in Flaschen ohne ärztliche Anleitung hinzufügen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Vomit is green or yellow, contains blood, or looks like coffee grounds.",
                    "Vomiting is forceful and repeated after most feeds.",
                    "Signs of dehydration: dry mouth, sunken fontanelle, far fewer wet nappies, unusual drowsiness.",
                    "Vomiting together with fever, a swollen tummy, or refusal to feed."
                ],
                ru: [
                    "Рвотные массы зелёные или жёлтые, с кровью либо цвета кофейной гущи.",
                    "Рвота фонтаном и повторяется после большинства кормлений.",
                    "Признаки обезвоживания: сухость во рту, запавший родничок, заметно меньше мокрых подгузников, необычная сонливость.",
                    "Рвота вместе с температурой, вздутым животом или отказом от еды."
                ],
                de: [
                    "Erbrechen ist grün oder gelb, enthält Blut oder sieht wie Kaffeesatz aus.",
                    "Erbrechen ist gewaltsam und wiederholt sich nach den meisten Mahlzeiten.",
                    "Anzeichen von Dehydrierung: trockener Mund, eingefallener Fontanelle, deutlich weniger nasse Windeln, ungewöhnliche Schläfrigkeit.",
                    "Erbrechen zusammen mit Fieber, aufgeblähtem Bauch oder Fütterungsverweigerung."
                ]
            )
        ),

        CareTip(
            id: 1007, category: .feeding, icon: "fork.knife", ageFrom: 5, ageTo: 8,
            title: LocalizedText(
                en: "Starting solids: read your baby, not the calendar",
                ru: "Начало прикорма: смотрите на ребёнка, а не на календарь",
                de: "Feste Nahrung beginnen: Schauen Sie auf Ihr Baby, nicht auf den Kalender"
            ),
            summary: LocalizedText(
                en: "Around six months, and only when all three readiness signs are there",
                ru: "Примерно в шесть месяцев и только при наличии всех трёх признаков готовности",
                de: "Ungefähr sechs Monate alt und nur wenn alle drei Bereitschaftszeichen vorhanden sind"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Check the three signs together: sitting up with little support, steady head and neck control, and coordinated reaching for food and bringing it to the mouth.",
                    "Start with a single food at a time, offered once a day at a calm moment when your baby is not overly hungry.",
                    "Keep milk as the main source of nutrition — early solids are practice, not replacement calories.",
                    "Expect most of the first meals to end up on the face, the bib and the floor. That is the process working.",
                    "Log new foods and any reactions in Momsy's Food Diary."
                ],
                ru: [
                    "Проверьте все три признака вместе: ребёнок сидит с минимальной поддержкой, уверенно держит голову и шею, скоординированно тянется к еде и подносит её ко рту.",
                    "Начинайте с одного продукта за раз, предлагая его один раз в день в спокойный момент, когда ребёнок не слишком голоден.",
                    "Молоко остаётся основным источником питания — ранний прикорм это тренировка, а не замена калорий.",
                    "Будьте готовы, что большая часть первых порций окажется на лице, слюнявчике и полу. Так и должно быть.",
                    "Записывайте новые продукты и любые реакции в «Дневник питания» в Momsy."
                ],
                de: [
                    "Überprüfen Sie alle drei Zeichen zusammen: Aufrecht sitzen mit minimaler Unterstützung, stabiler Kopf- und Nackenk ontrolle und koordiniertes Greifen nach Essen und Hinführen zum Mund.",
                    "Beginnen Sie mit einer Mahlzeit auf einmal, angeboten einmal täglich in einem ruhigen Moment, wenn Ihr Baby nicht zu hungrig ist.",
                    "Milch bleibt die Hauptenergiequelle — frühe Nahrung ist Übung, kein Ersatz für Kalorien.",
                    "Erwarten Sie, dass die meisten ersten Mahlzeiten auf dem Gesicht, der Lätzchen und dem Boden landen. Das ist der Prozess der richtig funktioniert.",
                    "Notieren Sie neue Lebensmittel und alle Reaktionen in Momsys Ernährungstagebuch."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "The readiness signs exist because swallowing solid food safely depends on trunk control and on the tongue-thrust reflex fading, not on a date. Starting before those are in place raises the risk of choking and rarely helps sleep, despite the folklore. Starting well after six months can make new textures harder to accept and leaves iron stores unsupported.",
                ru: "Признаки готовности существуют потому, что безопасное глотание твёрдой пищи зависит от контроля корпуса и угасания выталкивающего рефлекса языка, а не от даты в календаре. Начало прикорма до их появления повышает риск подавиться и, вопреки народному мнению, редко улучшает сон. Начало заметно позже шести месяцев затрудняет принятие новых текстур и оставляет без поддержки запасы железа.",
                de: "Die Bereitschaftszeichen existieren, weil das sichere Schlucken fester Nahrung von der Rumpfkontrolle und dem Verblassen des Zungenstoß-Reflexes abhängt, nicht von einem Datum. Wenn man vorher beginnt, erhöht sich das Erstickungsrisiko und hilft selten beim Schlaf, trotz folkloristischer Annahmen. Wenn man viel später als sechs Monate beginnt, kann es schwieriger werden, neue Texturen zu akzeptieren, und die Eisenvorräte erhalten keine Unterstützung."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Adding cereal to bottles in the hope of longer nights.",
                    "Judging readiness by weight or by how interested the baby seems in watching you eat.",
                    "Introducing several new foods on the same day, which hides the source of any reaction.",
                    "Treating a screwed-up face as rejection — new tastes often need many exposures."
                ],
                ru: [
                    "Добавлять кашу в бутылочку в надежде на более длинные ночи.",
                    "Оценивать готовность по весу или по тому, с каким интересом ребёнок смотрит, как вы едите.",
                    "Вводить несколько новых продуктов в один день — так не понять, что вызвало реакцию.",
                    "Считать сморщенное лицо отказом — новым вкусам часто нужно много повторных знакомств."
                ],
                de: [
                    "Getreide in Flaschen hinzufügen, in der Hoffnung auf längere Nächte.",
                    "Bereitschaft nach Gewicht oder danach beurteilen, wie interessiert das Baby beim Zuschauen beim Essen wirkt.",
                    "An einem Tag mehrere neue Lebensmittel einführen, was die Quelle einer Reaktion verbirgt.",
                    "Ein verzogenes Gesicht als Ablehnung behandeln — neue Geschmäcker brauchen oft viele Wiederholungen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby cannot sit with support or hold their head steady at six months.",
                    "Repeated gagging that turns into silent choking, or coughing that does not settle.",
                    "Any rash, swelling, vomiting or breathing change after a new food.",
                    "Consistent refusal of all solids by eight months."
                ],
                ru: [
                    "В шесть месяцев ребёнок не может сидеть с поддержкой или уверенно держать голову.",
                    "Повторяющиеся рвотные позывы, переходящие в беззвучное удушье, или непроходящий кашель.",
                    "Любая сыпь, отёк, рвота или изменение дыхания после нового продукта.",
                    "Стойкий отказ от любого прикорма к восьми месяцам."
                ],
                de: [
                    "Ihr Baby kann sich mit Unterstützung nicht hinsetzen oder den Kopf mit sechs Monaten nicht stabil halten.",
                    "Wiederholtes Würgen, das zu stillem Ersticken führt, oder Husten, der sich nicht bessert.",
                    "Irgendwelche Ausschläge, Schwellungen, Erbrechen oder Atemveränderungen nach einer neuen Mahlzeit.",
                    "Anhaltende Weigerung aller festen Nahrung mit acht Monaten."
                ]
            )
        ),

        CareTip(
            id: 1008, category: .feeding, icon: "moon.stars.fill", ageFrom: 0, ageTo: 3,
            title: LocalizedText(
                en: "Evening cluster feeding is normal, not a sign of low supply",
                ru: "Вечерние частые прикладывания — норма, а не признак нехватки молока",
                de: "Abendliches Cluster-Füttern ist normal, kein Zeichen niedriger Versorgung"
            ),
            summary: LocalizedText(
                en: "Back-to-back feeds between late afternoon and bedtime are a phase, not a problem",
                ru: "Кормления одно за другим с вечера до отбоя — это этап, а не проблема",
                de: "Aufeinanderfolgende Fütterungen zwischen spätem Nachmittag und Schlafenszeit sind eine Phase, kein Problem"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Expect clusters most often in the late afternoon and evening, and around growth spurts.",
                    "Set yourself up before it starts: water, snacks, a charged phone, a comfortable seat.",
                    "Offer whenever your baby asks rather than trying to stretch intervals during the cluster.",
                    "Hand the baby over between feeds if a co-parent is around — the feeding parent needs the breaks more than the cuddles.",
                    "Check the reassuring signs: enough wet nappies, steady weight gain, and periods of alert calm during the day."
                ],
                ru: [
                    "Чаще всего такие серии кормлений бывают ближе к вечеру и вечером, а также в периоды скачков роста.",
                    "Подготовьтесь заранее: вода, перекус, заряженный телефон, удобное место.",
                    "Предлагайте грудь по каждому запросу, не пытаясь растягивать интервалы в этот период.",
                    "Передавайте ребёнка между кормлениями, если рядом второй родитель, — кормящему родителю нужнее перерывы, чем объятия.",
                    "Проверьте обнадёживающие признаки: достаточно мокрых подгузников, стабильная прибавка в весе и периоды спокойного бодрствования днём."
                ],
                de: [
                    "Erwarten Sie Cluster am häufigsten am späten Nachmittag und Abend sowie um Wachstumsschübe.",
                    "Bereiten Sie sich vor: Wasser, Snacks, ein aufgeladenes Telefon, ein bequemer Sitz.",
                    "Bieten Sie immer dann an, wenn Ihr Baby fragt, anstatt zu versuchen, die Intervalle während des Clusters zu verlängern.",
                    "Geben Sie das Baby zwischen den Mahlzeiten ab, wenn ein Co-Elternteil in der Nähe ist — das fütternde Elternteil braucht eher Pausen als Umarmungen.",
                    "Überprüfen Sie die beruhigenden Zeichen: ausreichend nasse Windeln, konstante Gewichtszunahme und Phasen ruhigen Wachseins während des Tages."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Milk fat content and volume vary naturally through the day, and evening feeds tend to be shorter and less satisfying individually — so babies simply take more of them. Frequent evening stimulation also signals the breast to make more milk for the following day. Knowing the pattern is expected takes away the two things that make it hard: the fear that something is wrong, and the sense that it will never end.",
                ru: "Жирность и объём молока естественным образом меняются в течение дня, а вечерние кормления обычно короче и по отдельности менее насыщающие — поэтому дети просто берут грудь чаще. Частая вечерняя стимуляция к тому же сигнализирует груди вырабатывать больше молока на следующий день. Понимание, что так и должно быть, убирает две главные трудности: страх, что что-то не так, и ощущение, что это никогда не закончится.",
                de: "Der Milchfettgehalt und das Volumen variieren natürlich im Laufe des Tages, und Abendmahlzeiten sind in der Regel kürzer und weniger befriedigend — also nehmen Babys einfach mehr von ihnen. Häufige abendliche Stimulation signalisiert der Brust auch, mehr Milch für den nächsten Tag zu produzieren. Zu wissen, dass dieses Muster zu erwarten ist, nimmt zwei Dinge, die es schwer machen, weg: die Angst, dass etwas nicht stimmt, und das Gefühl, dass es nie enden wird."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Reading the cluster as proof that milk has run out and topping up in panic.",
                    "Timing feeds and enforcing intervals during the cluster window.",
                    "Assuming a baby who cannot settle in the evening is simply hungry rather than overtired."
                ],
                ru: [
                    "Принимать серию частых кормлений за доказательство, что молоко закончилось, и в панике докармливать смесью.",
                    "Засекать время кормлений и выдерживать интервалы в этот вечерний период.",
                    "Считать, что ребёнок, который не может успокоиться вечером, просто голоден, а не переутомлён."
                ],
                de: [
                    "Das Cluster als Beweis lesen, dass die Milch aufgebraucht ist, und in Panik nachfüttern.",
                    "Fütterungen zeitlich planen und Intervalle während des Cluster-Fensters durchsetzen.",
                    "Angenommen, ein Baby, das sich abends nicht beruhigen kann, ist einfach hungrig und nicht überfordert."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Fewer than six wet nappies a day after the first week.",
                    "No weight gain over two weeks, or weight loss.",
                    "Your baby is hard to rouse, unusually floppy, or feeds weakly.",
                    "Feeding is painful for you, or nipples are cracked and bleeding."
                ],
                ru: [
                    "Меньше шести мокрых подгузников в сутки после первой недели.",
                    "Нет прибавки в весе в течение двух недель или вес снижается.",
                    "Ребёнка трудно разбудить, он необычно вялый или слабо сосёт.",
                    "Кормление болезненно для вас или соски потрескались и кровоточат."
                ],
                de: [
                    "Weniger als sechs nasse Windeln pro Tag nach der ersten Woche.",
                    "Keine Gewichtszunahme über zwei Wochen oder Gewichtsverlust.",
                    "Ihr Baby ist schwer zu wecken, ungewöhnlich schlaff oder saugt schwach.",
                    "Füttern ist für Sie schmerzhaft oder die Brustwarzen sind gerissen und bluten."
                ]
            )
        )
    ]
}
