import Foundation

extension CareTipsCatalog {
    static let feeding: [CareTip] = [

        CareTip(
            id: 1001, category: .feeding, icon: "arrow.up.circle.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Hold your baby upright after every feed",
                ru: "Держите ребёнка вертикально после каждого кормления"
            ),
            summary: LocalizedText(
                en: "Ten to fifteen minutes vertical lets swallowed air come up before milk does",
                ru: "Десять-пятнадцать минут столбиком дают воздуху выйти раньше молока"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Newborns swallow air with almost every feed, and the valve between the stomach and the food pipe is still soft and easily opened. When your baby lies flat straight after a feed, that trapped air pushes milk back up with it. Staying upright lets the air rise above the milk and escape on its own, which usually means less spitting up, fewer squirming episodes and a calmer settle afterwards.",
                ru: "Новорождённые заглатывают воздух почти при каждом кормлении, а клапан между желудком и пищеводом ещё мягкий и легко открывается. Если сразу после еды положить ребёнка горизонтально, задержавшийся воздух выталкивает молоко вместе с собой. В вертикальном положении воздух поднимается над молоком и выходит сам — обычно это означает меньше срыгиваний, меньше беспокойных выгибаний и более спокойное засыпание."
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
                ]
            )
        ),

        CareTip(
            id: 1002, category: .feeding, icon: "hands.sparkles.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Three burping positions and when each one works",
                ru: "Три позы для отрыжки и когда какая работает"
            ),
            summary: LocalizedText(
                en: "If one hold does not work in five minutes, change position instead of patting longer",
                ru: "Если поза не сработала за пять минут, меняйте её, а не продолжайте похлопывать"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Air sits wherever the stomach happens to be shaped at that moment, so a hold that releases a burp today may do nothing tomorrow. Changing the angle moves the bubble towards the top of the stomach where it can escape. Mid-feed burping helps more than a single attempt at the end, because a smaller stomach releases air more easily than a full one.",
                ru: "Воздух располагается там, где в этот момент оказалась форма желудка, поэтому поза, сработавшая сегодня, завтра может не дать ничего. Смена угла перемещает пузырь к верхней части желудка, откуда он может выйти. Отрыжка в середине кормления помогает больше, чем одна попытка в конце: из менее наполненного желудка воздух выходит легче."
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
                ]
            )
        ),

        CareTip(
            id: 1003, category: .feeding, icon: "eye.fill", ageFrom: 0, ageTo: 4,
            title: LocalizedText(
                en: "Catch hunger cues before the crying starts",
                ru: "Замечайте признаки голода до начала плача"
            ),
            summary: LocalizedText(
                en: "Crying is a late signal — feeding at the early cues is calmer for everyone",
                ru: "Плач — поздний сигнал: кормление по ранним признакам спокойнее для всех"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "A crying baby has an arched tongue and a tense jaw, which makes a deep latch physically harder to achieve. Feeds that start from crying tend to be shorter, more frantic, and involve swallowing more air. Reading the early cues also builds your confidence in your own observations, which is worth as much as the smoother feed itself.",
                ru: "У плачущего ребёнка язык выгнут, а челюсть напряжена — глубокий захват физически даётся труднее. Кормления, начатые с плача, обычно короче, более суетливы и сопровождаются заглатыванием большего количества воздуха. Умение читать ранние признаки к тому же укрепляет доверие к собственным наблюдениям, а это ценно не меньше, чем более спокойное кормление."
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
                ]
            )
        ),

        CareTip(
            id: 1004, category: .feeding, icon: "drop.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Paced bottle feeding: keep the bottle horizontal",
                ru: "Кормление из бутылочки в темпе ребёнка: держите бутылочку горизонтально"
            ),
            summary: LocalizedText(
                en: "Let your baby set the rhythm instead of letting gravity empty the bottle",
                ru: "Пусть ритм задаёт ребёнок, а не сила тяжести, опустошающая бутылочку"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "With a vertical bottle, milk flows whether or not the baby is actively sucking, so they must keep swallowing to avoid choking. That overrides the natural pause-and-breathe rhythm they use at the breast, and it bypasses the fullness signal, which is why fast bottle feeds often end with wind, spit-up and a distressed baby. Pacing gives the appetite feedback loop time to work.",
                ru: "При вертикальной бутылочке молоко течёт независимо от того, сосёт ребёнок или нет, поэтому ему приходится всё время глотать, чтобы не поперхнуться. Это перебивает естественный ритм «пауза — вдох», который он использует у груди, и обходит сигнал насыщения — поэтому быстрые кормления из бутылочки часто заканчиваются газиками, срыгиванием и беспокойством. Кормление в темпе ребёнка даёт механизму насыщения время сработать."
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
                ]
            )
        ),

        CareTip(
            id: 1005, category: .feeding, icon: "timer", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Preparing and storing formula safely",
                ru: "Как безопасно готовить и хранить смесь"
            ),
            summary: LocalizedText(
                en: "Fresh is safest: make each bottle when you need it and discard leftovers",
                ru: "Безопаснее всего свежая: готовьте каждую бутылочку перед кормлением и выливайте остатки"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Formula powder is not a sterile product, and a warm made-up bottle is an excellent growth medium. Two things protect your baby: water hot enough to kill bacteria at the point of mixing, and a short window between making and drinking. Scoop accuracy matters just as much — over-concentrated formula strains immature kidneys, and over-diluted formula quietly holds back weight gain.",
                ru: "Сухая смесь не является стерильным продуктом, а тёплая разведённая бутылочка — отличная среда для роста бактерий. Ребёнка защищают две вещи: вода, достаточно горячая в момент разведения, чтобы убить бактерии, и короткий промежуток между приготовлением и кормлением. Точность дозировки важна не меньше: слишком концентрированная смесь перегружает незрелые почки, а слишком разведённая незаметно тормозит прибавку в весе."
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
                ]
            )
        ),

        CareTip(
            id: 1006, category: .feeding, icon: "arrow.uturn.up", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Spit-up or vomiting: how to tell them apart",
                ru: "Срыгивание или рвота: как отличить"
            ),
            summary: LocalizedText(
                en: "A relaxed dribble is normal; forceful, distressed, or coloured is not",
                ru: "Спокойное подтекание — норма; фонтаном, с беспокойством или цветное — нет"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Around half of all babies spit up in the first months, simply because the ring of muscle at the top of the stomach is still maturing. That is a laundry problem, not a medical one, as long as your baby is comfortable and gaining weight. Vomiting is a different event with different causes, so separating the two in your own mind saves a lot of unnecessary worry — and makes the genuinely concerning episodes stand out.",
                ru: "Примерно половина всех младенцев срыгивает в первые месяцы просто потому, что мышечное кольцо в верхней части желудка ещё дозревает. Это проблема стирки, а не медицины, пока ребёнку комфортно и он прибавляет в весе. Рвота — другое событие с другими причинами, поэтому умение различать их избавляет от множества лишних тревог и позволяет заметить действительно настораживающие эпизоды."
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
                ]
            )
        ),

        CareTip(
            id: 1007, category: .feeding, icon: "fork.knife", ageFrom: 5, ageTo: 8,
            title: LocalizedText(
                en: "Starting solids: read your baby, not the calendar",
                ru: "Начало прикорма: смотрите на ребёнка, а не на календарь"
            ),
            summary: LocalizedText(
                en: "Around six months, and only when all three readiness signs are there",
                ru: "Примерно в шесть месяцев и только при наличии всех трёх признаков готовности"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "The readiness signs exist because swallowing solid food safely depends on trunk control and on the tongue-thrust reflex fading, not on a date. Starting before those are in place raises the risk of choking and rarely helps sleep, despite the folklore. Starting well after six months can make new textures harder to accept and leaves iron stores unsupported.",
                ru: "Признаки готовности существуют потому, что безопасное глотание твёрдой пищи зависит от контроля корпуса и угасания выталкивающего рефлекса языка, а не от даты в календаре. Начало прикорма до их появления повышает риск подавиться и, вопреки народному мнению, редко улучшает сон. Начало заметно позже шести месяцев затрудняет принятие новых текстур и оставляет без поддержки запасы железа."
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
                ]
            )
        ),

        CareTip(
            id: 1008, category: .feeding, icon: "moon.stars.fill", ageFrom: 0, ageTo: 3,
            title: LocalizedText(
                en: "Evening cluster feeding is normal, not a sign of low supply",
                ru: "Вечерние частые прикладывания — норма, а не признак нехватки молока"
            ),
            summary: LocalizedText(
                en: "Back-to-back feeds between late afternoon and bedtime are a phase, not a problem",
                ru: "Кормления одно за другим с вечера до отбоя — это этап, а не проблема"
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
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Milk fat content and volume vary naturally through the day, and evening feeds tend to be shorter and less satisfying individually — so babies simply take more of them. Frequent evening stimulation also signals the breast to make more milk for the following day. Knowing the pattern is expected takes away the two things that make it hard: the fear that something is wrong, and the sense that it will never end.",
                ru: "Жирность и объём молока естественным образом меняются в течение дня, а вечерние кормления обычно короче и по отдельности менее насыщающие — поэтому дети просто берут грудь чаще. Частая вечерняя стимуляция к тому же сигнализирует груди вырабатывать больше молока на следующий день. Понимание, что так и должно быть, убирает две главные трудности: страх, что что-то не так, и ощущение, что это никогда не закончится."
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
                ]
            )
        )
    ]
}
