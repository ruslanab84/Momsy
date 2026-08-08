import Foundation

extension CareTipsCatalog {
    static let safety: [CareTip] = [

        CareTip(
            id: 1501, category: .safety, icon: "car.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Car seat basics: rear-facing, snug harness, no coats",
                ru: "Автокресло: спиной вперёд, плотные ремни, без верхней одежды"
            ),
            summary: LocalizedText(
                en: "Rear-facing as long as the seat allows, and the harness flat against the body",
                ru: "Спиной вперёд столько, сколько позволяет кресло, ремни — плотно к телу"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep the seat rear-facing for as long as your seat's height and weight limits permit.",
                    "Set the harness slots at or just below the shoulders in a rear-facing seat.",
                    "Tighten until you cannot pinch a horizontal fold of webbing at the shoulder.",
                    "Position the chest clip at armpit level.",
                    "Remove bulky coats and snowsuits; strap your baby in first, then lay the coat or a blanket over the harness."
                ],
                ru: [
                    "Устанавливайте кресло спиной вперёд так долго, как позволяют ограничения по росту и весу для вашей модели.",
                    "В кресле, установленном спиной вперёд, ремни должны выходить на уровне плеч или чуть ниже.",
                    "Затягивайте так, чтобы у плеча нельзя было защипнуть горизонтальную складку ремня.",
                    "Нагрудный зажим располагайте на уровне подмышек.",
                    "Снимайте объёмные куртки и комбинезоны: сначала пристегните ребёнка, затем накройте его курткой или пледом поверх ремней."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "In a frontal collision a rear-facing seat spreads the force across the whole back and supports the head and neck, which is exactly what a baby's proportionally heavy head and soft neck need. A padded coat compresses to almost nothing under crash forces, leaving several centimetres of slack in a harness that felt tight in the driveway — which is how a correctly fastened child ends up loose in a crash.",
                ru: "При лобовом столкновении кресло, установленное спиной вперёд, распределяет нагрузку по всей спине и поддерживает голову и шею — именно то, что нужно ребёнку с непропорционально тяжёлой головой и слабой шеей. Утеплённая куртка при ударе сжимается почти до нуля, оставляя несколько сантиметров слабины в ремнях, которые казались тугими во дворе, — так правильно пристёгнутый ребёнок оказывается свободным в момент аварии."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Turning forward-facing on a birthday rather than at the seat's limit.",
                    "A loose harness or a chest clip sitting on the tummy.",
                    "Winter coats, snowsuits or aftermarket padding under the straps.",
                    "Second-hand seats of unknown history, or any seat involved in a crash."
                ],
                ru: [
                    "Разворачивать кресло лицом вперёд «по дню рождения», а не по достижении ограничений кресла.",
                    "Слабо затянутые ремни или нагрудный зажим, съехавший на живот.",
                    "Зимние куртки, комбинезоны или сторонние подкладки под ремнями.",
                    "Бывшие в употреблении кресла с неизвестной историей или любое кресло, побывавшее в аварии."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby's head slumps forward or breathing sounds laboured in the seat — check the recline angle urgently.",
                    "Premature or low birth weight babies may need a car seat tolerance check before discharge.",
                    "After any collision, have your baby assessed even if they seem completely fine."
                ],
                ru: [
                    "Голова ребёнка заваливается вперёд или дыхание в кресле кажется затруднённым — срочно проверьте угол наклона.",
                    "Недоношенным детям и детям с низким весом при рождении перед выпиской может потребоваться проверка переносимости автокресла.",
                    "После любого столкновения покажите ребёнка врачу, даже если он выглядит совершенно здоровым."
                ]
            )
        ),

        CareTip(
            id: 1502, category: .safety, icon: "exclamationmark.triangle.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Never step away from the changing table",
                ru: "Никогда не отходите от пеленального столика"
            ),
            summary: LocalizedText(
                en: "One hand stays on your baby, always — rolling arrives without warning",
                ru: "Одна рука всегда на ребёнке — первый переворот случается без предупреждения"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep everything you need within arm's reach before you start.",
                    "Keep one hand on your baby's tummy or chest throughout, including while reaching for wipes.",
                    "If you must leave for any reason, take your baby with you or put them on the floor.",
                    "Consider changing on a mat on the floor from the newborn stage.",
                    "Use the strap if your changing table has one, but never as a substitute for your hand."
                ],
                ru: [
                    "Заранее положите всё необходимое на расстоянии вытянутой руки.",
                    "Всё время держите одну руку на животе или груди ребёнка, в том числе когда тянетесь за салфетками.",
                    "Если нужно отойти по любой причине, возьмите ребёнка с собой или положите его на пол.",
                    "Рассмотрите вариант переодевать ребёнка на коврике на полу уже с периода новорождённости.",
                    "Используйте ремень, если он есть на столике, но никогда не как замену своей руке."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "The first roll is unpredictable and often happens weeks before parents expect it — many falls involve a baby who had never rolled before. Falls from changing height are among the most common injuries in the first year, and the head takes most of the impact. The single-hand rule works because it does not depend on you correctly predicting when your baby will develop a new skill.",
                ru: "Первый переворот непредсказуем и часто случается на несколько недель раньше, чем ожидают родители: во многих падениях участвует ребёнок, который до этого ни разу не переворачивался. Падения с высоты пеленального столика — одна из самых частых травм на первом году, и основной удар приходится на голову. Правило «одна рука на ребёнке» работает потому, что не зависит от вашей способности угадать, когда появится новый навык."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Turning to grab a nappy from a shelf just out of reach.",
                    "Trusting a strap or raised sides to hold a determined baby.",
                    "Answering the door or the phone mid-change.",
                    "Assuming a baby who has not rolled yet cannot roll today."
                ],
                ru: [
                    "Отвернуться, чтобы взять подгузник с полки чуть дальше вытянутой руки.",
                    "Полагаться на ремень или бортики, что они удержат настойчивого ребёнка.",
                    "Открывать дверь или отвечать на звонок посреди переодевания.",
                    "Считать, что ребёнок, который ещё не переворачивался, не перевернётся сегодня."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any fall from height in a baby under a year — seek advice even without visible injury.",
                    "Loss of consciousness, vomiting, unusual drowsiness, or a bulging soft spot after a fall — emergency.",
                    "A swelling on the head, or any change in behaviour, feeding or responsiveness."
                ],
                ru: [
                    "Любое падение с высоты у ребёнка до года — обратитесь к врачу даже без видимых повреждений.",
                    "Потеря сознания, рвота, необычная сонливость или выбухающий родничок после падения — экстренная ситуация.",
                    "Припухлость на голове или любые изменения в поведении, кормлении и реакциях."
                ]
            )
        ),

        CareTip(
            id: 1503, category: .safety, icon: "shield.lefthalf.filled", ageFrom: 5, ageTo: 24,
            title: LocalizedText(
                en: "Baby-proof before your baby moves",
                ru: "Обезопасьте дом до того, как ребёнок поедет"
            ),
            summary: LocalizedText(
                en: "Do it at five months, not on the day they first crawl",
                ru: "Делайте это в пять месяцев, а не в день первого ползания"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Get down on the floor and look at the room from your baby's eye level.",
                    "Anchor bookcases, chests of drawers and televisions to the wall.",
                    "Fit stair gates at the top and bottom, and lock away cleaning products, medicines and small batteries.",
                    "Move cords and blind pulls out of reach and tie them up high.",
                    "Check for anything that fits through a toilet-roll tube — that is roughly the choking size limit."
                ],
                ru: [
                    "Опуститесь на пол и посмотрите на комнату с высоты глаз ребёнка.",
                    "Закрепите к стене книжные шкафы, комоды и телевизоры.",
                    "Поставьте ворота безопасности вверху и внизу лестницы, уберите под замок бытовую химию, лекарства и мелкие батарейки.",
                    "Уберите провода и шнуры жалюзи из зоны досягаемости и подвяжите их повыше.",
                    "Проверьте, что нет предметов, проходящих во втулку от туалетной бумаги, — это примерный предел размера, опасного удушьем."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Mobility arrives suddenly: a baby who has never moved forward can cross a room within a day of working out how. Preparing early means you are not improvising while also watching a newly mobile child. Furniture tip-overs and button batteries deserve particular attention because both cause severe harm quickly and both are easy to overlook.",
                ru: "Подвижность появляется внезапно: ребёнок, который никогда не двигался вперёд, может пересечь комнату уже на следующий день после того, как понял, как это делается. Подготовка заранее избавляет от необходимости импровизировать, одновременно присматривая за только что «поехавшим» ребёнком. Опрокидывание мебели и дисковые батарейки заслуживают особого внимания: и то и другое быстро приводит к тяжёлым последствиям и легко упускается из виду."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Waiting for the first crawl before starting.",
                    "Forgetting rooms your baby is 'never' in — bathroom, kitchen, grandparents' house.",
                    "Pressure-fitted gates at the top of stairs, where screw-fitted ones are needed.",
                    "Handbags left on the floor with medication or coins inside."
                ],
                ru: [
                    "Ждать первого ползания, прежде чем начать.",
                    "Забывать про комнаты, где ребёнок «никогда» не бывает, — ванную, кухню, квартиру бабушки и дедушки.",
                    "Ставить распорные ворота наверху лестницы, где нужны прикрученные к стене.",
                    "Оставлять на полу сумки с лекарствами или монетами внутри."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any suspicion your baby has swallowed a button battery or a magnet — go to emergency immediately, do not wait for symptoms.",
                    "Suspected poisoning — call emergency services and keep the packaging with you.",
                    "Choking that clears but is followed by ongoing coughing or noisy breathing."
                ],
                ru: [
                    "Любое подозрение, что ребёнок проглотил дисковую батарейку или магнит, — немедленно в скорую помощь, не ждите симптомов.",
                    "Подозрение на отравление — вызывайте экстренные службы и держите упаковку при себе.",
                    "Эпизод удушья, который прошёл, но после него сохраняется кашель или шумное дыхание."
                ]
            )
        ),

        CareTip(
            id: 1504, category: .safety, icon: "drop.triangle.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Water safety: never out of arm's reach",
                ru: "Безопасность на воде: всегда на расстоянии вытянутой руки"
            ),
            summary: LocalizedText(
                en: "A few centimetres of water is enough, and drowning is silent",
                ru: "Достаточно нескольких сантиметров воды, и утопление происходит беззвучно"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep a hand on your baby for the entire bath, every time.",
                    "Empty the bath immediately afterwards.",
                    "Keep toilet lids down and bathroom doors closed; buckets and basins emptied after use.",
                    "Set the household hot water thermostat to a safe limit and always run cold water into the bath first.",
                    "Treat bath seats and rings as toys, not as safety devices."
                ],
                ru: [
                    "Держите руку на ребёнке всё время купания, каждый раз.",
                    "Сразу после купания сливайте воду.",
                    "Держите крышку унитаза опущенной, дверь в ванную закрытой, а вёдра и тазы — пустыми после использования.",
                    "Выставьте на водонагревателе безопасный предел температуры и всегда наливайте в ванночку сначала холодную воду.",
                    "Относитесь к стульчикам и кругам для купания как к игрушкам, а не средствам безопасности."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Infant drowning happens in seconds, in very little water, and almost silently — there is no splashing or shouting to alert you. A baby who slips under cannot right themselves, and the reflex response makes it worse rather than better. Scalds are the other bathroom risk: a baby's skin burns at lower temperatures and in less time than an adult's.",
                ru: "Утопление младенца происходит за секунды, в совсем небольшом количестве воды и почти беззвучно — не будет ни плеска, ни крика, которые вас предупредят. Ребёнок, соскользнувший под воду, не может подняться сам, а рефлекторная реакция только ухудшает положение. Второй риск в ванной — ожоги: кожа ребёнка обжигается при более низкой температуре и за меньшее время, чем кожа взрослого."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Leaving the room for a towel or a phone.",
                    "Asking an older sibling to supervise.",
                    "Running hot water into the bath while the baby is already in it.",
                    "Buckets or paddling pools left with water in them."
                ],
                ru: [
                    "Выйти из комнаты за полотенцем или телефоном.",
                    "Просить старшего ребёнка присмотреть.",
                    "Доливать горячую воду, когда ребёнок уже в ванночке.",
                    "Оставлять вёдра или надувные бассейны с водой."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any submersion, even brief, followed by coughing, breathing changes or drowsiness — seek care immediately.",
                    "A scald that blisters, covers a large area, or affects the face, hands or nappy area.",
                    "Vomiting or unusual sleepiness in the hours after any water incident."
                ],
                ru: [
                    "Любое погружение под воду, даже кратковременное, после которого появились кашель, изменения дыхания или сонливость, — немедленно к врачу.",
                    "Ожог с пузырями, обширный ожог или ожог лица, кистей рук либо области подгузника.",
                    "Рвота или необычная сонливость в течение нескольких часов после любого происшествия с водой."
                ]
            )
        ),

        CareTip(
            id: 1505, category: .safety, icon: "cross.case.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Be ready for an emergency before you need to be",
                ru: "Подготовьтесь к экстренной ситуации заранее"
            ),
            summary: LocalizedText(
                en: "Save the numbers, take an infant first-aid course, and know your own address",
                ru: "Сохраните номера, пройдите курс первой помощи младенцам и знайте свой адрес наизусть"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Save your local emergency number and your paediatrician's number in your phone now.",
                    "Write your full address, including the entry code and floor, somewhere visible — people forget it under stress.",
                    "Take an infant first-aid and CPR course; infant technique differs from the adult version and cannot be learned from a video alone.",
                    "Refresh the training every couple of years, and make sure anyone who cares for your baby has done it too.",
                    "Keep a small first-aid kit and your baby's health record where anyone can find them."
                ],
                ru: [
                    "Прямо сейчас сохраните в телефоне номер экстренных служб и номер вашего педиатра.",
                    "Напишите на видном месте полный адрес, включая код домофона и этаж, — в стрессе его забывают.",
                    "Пройдите курс первой помощи и сердечно-лёгочной реанимации для младенцев: техника для детей отличается от взрослой, и по одному видео её не освоить.",
                    "Обновляйте навыки раз в пару лет и убедитесь, что курс прошли все, кто остаётся с ребёнком.",
                    "Держите небольшую аптечку и медицинскую карту ребёнка там, где их сможет найти любой."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "In an emergency you will not read instructions or research technique — you will do whatever you have already practised. Infant CPR uses two fingers rather than two hands and a different rate and depth, so adult training does not transfer. Preparing in advance is not pessimism; it is the same reason you check where the exits are on a plane you fully expect to land normally.",
                ru: "В экстренной ситуации вы не будете читать инструкции и искать технику — вы сделаете то, что уже отрабатывали. При реанимации младенца используют два пальца, а не две руки, а также другую частоту и глубину нажатий, поэтому взрослые навыки сюда не переносятся. Готовиться заранее — это не пессимизм: по той же причине вы смотрите, где выходы в самолёте, который наверняка сядет нормально."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Assuming adult first aid is close enough.",
                    "Relying on a video watched once.",
                    "Leaving carers without emergency contacts or medical details.",
                    "Skipping refresher training after the first year."
                ],
                ru: [
                    "Считать, что взрослой первой помощи «достаточно близко».",
                    "Полагаться на один просмотренный ролик.",
                    "Оставлять тех, кто сидит с ребёнком, без экстренных контактов и медицинских сведений.",
                    "Пропускать повторные курсы после первого года."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Difficulty breathing, blue or grey lips or skin, or unresponsiveness — call emergency services immediately.",
                    "A seizure, or a rash that does not fade under pressure.",
                    "Any choking episode that needed intervention should be assessed afterwards."
                ],
                ru: [
                    "Затруднённое дыхание, синие или серые губы либо кожа, отсутствие реакции — немедленно вызывайте экстренные службы.",
                    "Судороги или сыпь, которая не бледнеет при надавливании.",
                    "Любой эпизод удушья, потребовавший вмешательства, нужно показать врачу после."
                ]
            )
        )
    ]
}
