import Foundation

extension CareTipsCatalog {
    static let hygiene: [CareTip] = [

        CareTip(
            id: 1201, category: .hygiene, icon: "bandage.fill", ageFrom: 0, ageTo: 2,
            title: LocalizedText(
                en: "Umbilical cord care: clean, dry and uncovered",
                ru: "Уход за пупочной ранкой: чисто, сухо и открыто",
                de: "Nabelschnurpflege: sauber, trocken und offen"
            ),
            summary: LocalizedText(
                en: "Air is the main treatment — the stump falls off on its own in one to three weeks",
                ru: "Главное «лекарство» — воздух: остаток пуповины отпадает сам через одну-три недели",
                de: "Luft ist die Hauptbehandlung – der Stumpf fällt in ein bis drei Wochen von selbst ab"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Leave the stump exposed to air as much as possible.",
                    "Fold the nappy down below the stump so it never rubs or traps moisture.",
                    "Keep it dry: sponge baths until it has fallen off and the base has healed.",
                    "If it gets soiled, clean with plain water and let it air-dry completely.",
                    "Let it detach by itself — never pull, even if it is hanging by a thread."
                ],
                ru: [
                    "Как можно чаще оставляйте остаток пуповины открытым для воздуха.",
                    "Подворачивайте подгузник ниже пупка, чтобы он не натирал и не удерживал влагу.",
                    "Держите область сухой: до отпадения и заживления обходитесь обтираниями.",
                    "Если область загрязнилась, промойте чистой водой и дайте полностью высохнуть на воздухе.",
                    "Дайте остатку отпасть самому — не отрывайте, даже если он держится на волоске."
                ],
                de: [
                    "Lassen Sie den Stumpf so viel wie möglich der Luft ausgesetzt.",
                    "Falten Sie die Windel unter dem Stumpf nach unten, damit sie nie reibt oder Feuchtigkeit speichert.",
                    "Halten Sie es trocken: Schwammtäder, bis es abgefallen ist und die Basis verheilt ist.",
                    "Wenn es verschmutzt wird, mit klarem Wasser reinigen und vollständig an der Luft trocknen lassen.",
                    "Lassen Sie es von selbst abfallen – ziehen Sie nie daran, auch wenn es an einem Faden hängt."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "The stump is dead tissue that dries and separates naturally, and the drier it stays the faster that happens. Old routines involving alcohol or antiseptic have largely been dropped because they slow separation without reducing infection in healthy babies. A little dried blood or a slightly unpleasant smell in the final days is expected as it separates.",
                ru: "Остаток пуповины — это отмершая ткань, которая подсыхает и отделяется сама, и чем суше она остаётся, тем быстрее это происходит. От прежних схем с обработкой спиртом или антисептиком в основном отказались: у здоровых детей они замедляют отделение, не снижая риск инфекции. Немного подсохшей крови или слегка неприятный запах в последние дни перед отпадением — ожидаемо.",
                de: "Der Stumpf ist totes Gewebe, das natürlich austrocknet und sich trennt – je trockener es bleibt, desto schneller geschieht dies. Alte Routinen mit Alkohol oder Antiseptikum wurden weitgehend aufgegeben, da sie die Trennung verlangsamen, ohne Infektionen bei gesunden Babys zu reduzieren. Ein wenig getrocknetes Blut oder ein leicht unangenehmer Geruch in den letzten Tagen ist beim Ablösen normal."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Covering the stump with the nappy waistband.",
                    "Applying creams, powders, or antiseptic without being told to.",
                    "Full bath immersion before separation.",
                    "Helping it along when it seems ready to come off."
                ],
                ru: [
                    "Закрывать пупок резинкой подгузника.",
                    "Наносить кремы, присыпки или антисептик без назначения врача.",
                    "Полностью погружать ребёнка в ванночку до отпадения остатка.",
                    "«Помогать» остатку отпасть, когда он кажется готовым."
                ],
                de: [
                    "Den Stumpf mit dem Windelbund abdecken.",
                    "Cremes, Puder oder Antiseptikum anwenden, ohne dazu aufgefordert zu werden.",
                    "Vollständiges Bad vor der Trennung eintauchen.",
                    "Helfen, es zu entfernen, wenn es bereit scheint."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Redness spreading onto the skin around the base.",
                    "Pus, a foul discharge, or ongoing bleeding.",
                    "Your baby cries when the area is touched, or develops a fever.",
                    "The stump has not come away by three weeks."
                ],
                ru: [
                    "Покраснение распространяется на кожу вокруг основания.",
                    "Гной, дурно пахнущие выделения или непрекращающееся кровотечение.",
                    "Ребёнок плачет при прикосновении к этой области или у него поднялась температура.",
                    "Остаток пуповины не отпал к трём неделям."
                ],
                de: [
                    "Rötung breitet sich auf die Haut um die Basis aus.",
                    "Eiter, übler Ausfluss oder anhaltendes Bluten.",
                    "Ihr Baby weint, wenn die Stelle berührt wird, oder entwickelt Fieber.",
                    "Der Stumpf ist nicht in drei Wochen abgefallen."
                ]
            )
        ),

        CareTip(
            id: 1202, category: .hygiene, icon: "drop.fill", ageFrom: 0, ageTo: 3,
            title: LocalizedText(
                en: "Bathing a newborn: short, warm and not every day",
                ru: "Купание новорождённого: коротко, тепло и не каждый день",
                de: "Baden eines Neugeborenen: kurz, warm und nicht jeden Tag"
            ),
            summary: LocalizedText(
                en: "Two or three baths a week at around 37 °C is plenty for new skin",
                ru: "Двух-трёх купаний в неделю при температуре около 37 °C достаточно для новой кожи",
                de: "Zwei- oder dreimal pro Woche Baden bei etwa 37 °C ist ausreichend für neue Haut"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Check the water with your elbow or a thermometer — around 37 °C, comfortably warm rather than hot.",
                    "Keep baths to five or ten minutes and fill the water to about 10–13 cm.",
                    "Gather everything first: towel, clean nappy, clothes, water. Never step away, not for a second.",
                    "Support the head and neck with one forearm and hold the outer arm or shoulder with that hand.",
                    "Use plain water in the early weeks, or a small amount of unperfumed baby wash. Top-and-tail on the days between baths."
                ],
                ru: [
                    "Проверяйте воду локтем или термометром — около 37 °C, приятно тёплая, а не горячая.",
                    "Купайте пять-десять минут, наливая воду примерно на 10–13 см.",
                    "Сначала приготовьте всё: полотенце, чистый подгузник, одежду, воду. Никогда не отходите, даже на секунду.",
                    "Поддерживайте голову и шею одним предплечьем, а этой же кистью держите дальнее плечо или ручку.",
                    "В первые недели используйте только воду или небольшое количество детского средства без ароматизаторов. В остальные дни просто подмывайте и умывайте."
                ],
                de: [
                    "Überprüfen Sie das Wasser mit Ihrem Ellbogen oder einem Thermometer – etwa 37 °C, angenehm warm statt heiß.",
                    "Halten Sie Bäder auf fünf bis zehn Minuten und füllen Sie das Wasser auf etwa 10–13 cm.",
                    "Bereiten Sie alles vor: Handtuch, saubere Windel, Kleidung, Wasser. Gehen Sie nie weg, nicht für eine Sekunde.",
                    "Stützen Sie Kopf und Nacken mit einem Unterarm und halten Sie den äußeren Arm oder die Schulter mit dieser Hand.",
                    "Verwenden Sie in den ersten Wochen reines Wasser oder eine kleine Menge unparfümiertes Babywaschmittel. An anderen Tagen einfach Intimpflege machen."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Newborn skin is thinner than adult skin and is still building its protective barrier, so frequent washing and fragranced products strip more than they clean. Two or three baths a week keeps the skin comfortable while the nappy area and face — the parts that actually get dirty — are cleaned daily. Short baths also avoid the rapid heat loss that leaves babies chilled and unsettled afterwards.",
                ru: "Кожа новорождённого тоньше кожи взрослого и ещё формирует защитный барьер, поэтому частое мытьё и средства с ароматизаторами смывают больше, чем очищают. Два-три купания в неделю сохраняют кожу в порядке, тогда как область подгузника и лицо — то, что действительно загрязняется, — очищаются ежедневно. Короткие купания также избавляют от быстрой потери тепла, из-за которой ребёнок мёрзнет и потом беспокоится.",
                de: "Neugeborene Haut ist dünner als Erwachsenenhaut und bildet noch ihre Schutzbarriere, daher entfernt häufiges Waschen und duftende Produkte mehr, als sie reinigen. Zwei- oder dreimal pro Woche Baden hält die Haut komfortabel, während der Windelbereich und das Gesicht – die Teile, die wirklich schmutzig werden – täglich gereinigt werden. Kurze Bäder vermeiden auch den schnellen Wärmeverlust, der Babys abkühlt und danach unruhig macht."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Testing the water with a hand, which is far less sensitive than an elbow.",
                    "Daily baths with soap in the first weeks.",
                    "Bath seats or rings used as a reason to look away.",
                    "Bathing straight after a feed, which often ends in spit-up."
                ],
                ru: [
                    "Проверять воду рукой — она гораздо менее чувствительна, чем локоть.",
                    "Ежедневные купания с мылом в первые недели.",
                    "Считать, что стульчик или круг для купания позволяют отвести взгляд.",
                    "Купать сразу после кормления — это часто заканчивается срыгиванием."
                ],
                de: [
                    "Wasser mit der Hand testen, die viel weniger empfindlich ist als ein Ellbogen.",
                    "Tägliche Bäder mit Seife in den ersten Wochen.",
                    "Badewannen oder Ringe als Grund zu verwenden, um abzusehen.",
                    "Direkt nach der Fütterung baden, was oft mit Aufstoßen endet."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Persistent dry, cracked or weeping patches that do not improve.",
                    "A rash that spreads after bathing.",
                    "Your baby becomes cold and mottled during or after baths."
                ],
                ru: [
                    "Стойкие сухие, потрескавшиеся или мокнущие участки кожи, которые не проходят.",
                    "Сыпь, которая распространяется после купания.",
                    "Ребёнок замерзает, кожа становится мраморной во время или после купания."
                ],
                de: [
                    "Anhaltend trockene, rissige oder nässende Stellen, die sich nicht bessern.",
                    "Ein Ausschlag, der nach dem Baden auftritt.",
                    "Ihr Baby wird während oder nach Bädern kalt und fleckig."
                ]
            )
        ),

        CareTip(
            id: 1203, category: .hygiene, icon: "wind", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Preventing nappy rash: air time and a barrier",
                ru: "Профилактика пелёночного дерматита: воздушные ванны и защитный крем",
                de: "Windelausschlag verhindern: Luftzeit und eine Schutzbarriere"
            ),
            summary: LocalizedText(
                en: "Change often, dry thoroughly, and let the skin breathe once a day",
                ru: "Меняйте подгузник часто, тщательно просушивайте кожу и раз в день давайте ей подышать",
                de: "Wechseln Sie häufig, trocknen Sie gründlich ab und lassen Sie die Haut einmal täglich atmen"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Change as soon as you notice a wet or dirty nappy, and at least every two to three hours in the early months.",
                    "Clean with water and cotton wool or fragrance-free wipes, front to back.",
                    "Pat completely dry — moisture left in the creases is what starts most rashes.",
                    "Apply a thin layer of barrier cream on clean dry skin if the area looks pink.",
                    "Give ten minutes of nappy-free time on a towel each day."
                ],
                ru: [
                    "Меняйте подгузник сразу, как заметили, что он мокрый или грязный, и не реже чем каждые два-три часа в первые месяцы.",
                    "Очищайте водой с ватой или салфетками без ароматизаторов, движениями спереди назад.",
                    "Просушивайте промакивающими движениями досуха — именно влага в складках чаще всего запускает раздражение.",
                    "Если кожа порозовела, нанесите тонкий слой защитного крема на чистую сухую кожу.",
                    "Каждый день давайте ребёнку десять минут полежать без подгузника на полотенце."
                ],
                de: [
                    "Wechseln Sie die Windel sofort, wenn Sie eine nasse oder schmutzige Windel bemerken, und mindestens alle zwei bis drei Stunden in den frühen Monaten.",
                    "Reinigen Sie mit Wasser und Wattestäbchen oder parfümfreien Tüchern von vorne nach hinten.",
                    "Vollständig trockentupfen – Feuchtigkeit in den Falten ist das, was die meisten Ausschläge verursacht.",
                    "Tragen Sie eine dünne Schicht Schutzcrème auf saubere trockene Haut auf, wenn die Stelle rosa aussieht.",
                    "Geben Sie jedem Tag zehn Minuten windelfrei auf einem Handtuch."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Nappy rash is mostly a moisture problem: wet skin softens, friction breaks the surface, and the ammonia from urine irritates what is left. Air time and thorough drying address the cause directly, which is why they work better than any cream. A barrier ointment then keeps the next wet nappy off skin that is already sore.",
                ru: "Пелёночный дерматит — прежде всего проблема влаги: намокшая кожа размягчается, трение повреждает её поверхность, а аммиак из мочи раздражает всё остальное. Воздушные ванны и тщательное просушивание работают с самой причиной — поэтому они эффективнее любого крема. А защитная мазь потом не даёт следующему мокрому подгузнику контактировать с уже раздражённой кожей.",
                de: "Windelausschlag ist hauptsächlich ein Feuchtigkeitsproblem: nasse Haut wird weich, Reibung zerstört die Oberfläche, und Ammoniak aus dem Urin reizt den Rest. Luftzeit und gründliches Trocknen adressieren direkt die Ursache – deshalb wirken sie besser als jede Creme. Eine Schutzunguentum hält die nächste nasse Windel dann von bereits entzündeter Haut fern."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Scrubbing sore skin instead of patting it.",
                    "A thick layer of cream over damp skin, which seals the moisture in.",
                    "Fragranced or alcohol-based wipes on broken skin.",
                    "Talcum powder — it can be inhaled and does not help."
                ],
                ru: [
                    "Растирать раздражённую кожу вместо промакивания.",
                    "Наносить толстый слой крема на влажную кожу — это запирает влагу внутри.",
                    "Использовать салфетки с ароматизаторами или спиртом на повреждённой коже.",
                    "Тальк — его можно вдохнуть, и он не помогает."
                ],
                de: [
                    "Wunde Haut reiben statt tupfen.",
                    "Eine dicke Crèmeschicht auf feuchter Haut auftragen, die Feuchtigkeit einschließt.",
                    "Parfümierte oder alkoholbasierte Tücher auf beschädigter Haut verwenden.",
                    "Talkumpuder – es kann eingeatmet werden und hilft nicht."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "The rash has bright red patches with small spots spreading beyond the edges — this can be thrush.",
                    "Blisters, open sores, or areas of raw weeping skin.",
                    "No improvement after three days of good care.",
                    "Rash plus fever or an unsettled, unwell baby."
                ],
                ru: [
                    "Сыпь с яркими красными участками и мелкими элементами за их границами — это может быть кандидоз.",
                    "Пузыри, открытые ранки или участки мокнущей повреждённой кожи.",
                    "Нет улучшения после трёх дней правильного ухода.",
                    "Сыпь вместе с температурой или ребёнок беспокоен и выглядит нездоровым."
                ],
                de: [
                    "Der Ausschlag hat leuchtend rote Flecken mit kleinen Flecken, die über die Kanten hinausgehen – das kann Soor sein.",
                    "Blasen, offene Wunden oder Bereiche von roher nässender Haut.",
                    "Keine Verbesserung nach drei Tagen guter Pflege.",
                    "Ausschlag plus Fieber oder ein verängstigtes, unwohles Baby."
                ]
            )
        ),

        CareTip(
            id: 1204, category: .hygiene, icon: "scissors", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Trimming tiny nails without the drama",
                ru: "Как стричь крошечные ногти без слёз",
                de: "Winzige Nägel schneiden ohne Drama"
            ),
            summary: LocalizedText(
                en: "Cut during sleep, follow the natural shape, and file the corners",
                ru: "Стригите во сне, повторяйте естественную форму и подпиливайте уголки",
                de: "Schneiden Sie im Schlaf, folgen Sie der natürlichen Form und feilen Sie die Ecken"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Choose a time when your baby is deeply asleep or relaxed after a bath.",
                    "Press the fingertip pad gently away from the nail before you cut.",
                    "Cut fingernails straight across following the curve, and toenails straight across with no rounding at the corners.",
                    "Smooth the edges with a soft emery board — that is what stops the scratching.",
                    "Expect to trim fingernails roughly weekly and toenails every few weeks."
                ],
                ru: [
                    "Выбирайте время, когда ребёнок крепко спит или расслаблен после купания.",
                    "Перед стрижкой мягко отведите подушечку пальца от ногтя.",
                    "Ногти на руках стригите прямо, следуя изгибу, а на ногах — строго прямо, не закругляя уголки.",
                    "Сгладьте края мягкой пилочкой — именно это избавляет от царапин.",
                    "Ногти на руках обычно нужно стричь примерно раз в неделю, на ногах — раз в несколько недель."
                ],
                de: [
                    "Wählen Sie einen Zeitpunkt, wenn Ihr Baby tief schläft oder sich nach einem Bad entspannt.",
                    "Schieben Sie das Fingerkissen vor dem Schneiden sanft vom Nagel weg.",
                    "Schneiden Sie Fingernägel gerade, der Kurve folgend, und Zehennägel gerade mit abgerundeten Ecken.",
                    "Glätten Sie die Kanten mit einer weichen Nagelfeile – das stoppt das Kratzen.",
                    "Erwarten Sie, Fingernägel etwa wöchentlich zu schneiden und Zehennägel alle paar Wochen."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Newborn nails are soft and grow surprisingly fast, and sharp edges leave scratches on the face within hours. The reason to file rather than cut short is that the nail bed sits very close to the free edge in babies, so cutting deep is both painful and an infection risk. Rounded toenail corners are the main cause of ingrown nails later.",
                ru: "Ногти новорождённого мягкие и растут удивительно быстро, а острые края оставляют царапины на лице уже через несколько часов. Подпиливать лучше, чем стричь коротко, потому что у младенцев ногтевое ложе расположено очень близко к свободному краю: срезать глубоко и больно, и рискованно из-за инфекции. Закруглённые уголки ногтей на ногах — главная причина их врастания в будущем.",
                de: "Neugeborene Nägel sind weich und wachsen überraschend schnell, und scharfe Kanten hinterlassen Kratzer im Gesicht innerhalb von Stunden. Der Grund zum Feilen statt kurz schneiden ist, dass das Nagelbett bei Babys sehr nah am freien Rand sitzt, daher ist tiefes Schneiden sowohl schmerzhaft als auch ein Infektionsrisiko. Abgerundete Zehennägelecken sind die Hauptursache für eingewachsene Nägel später."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Biting the nails off — the adult mouth carries bacteria into any small tear.",
                    "Cutting too short in the hope of going longer between trims.",
                    "Rounding toenail corners.",
                    "Scratch mittens used permanently, which limits the hand exploration babies need."
                ],
                ru: [
                    "Обкусывать ногти — из рта взрослого бактерии попадают в любую микротрещину.",
                    "Стричь слишком коротко в надежде реже возвращаться к этой процедуре.",
                    "Закруглять уголки ногтей на ногах.",
                    "Постоянно держать ребёнка в антицарапках — это ограничивает нужное ему исследование мира руками."
                ],
                de: [
                    "Die Nägel abbeißen – der Erwachsenenmund trägt Bakterien in jeden kleinen Riss.",
                    "Zu kurz schneiden in der Hoffnung, länger zwischen den Schnitten zu gehen.",
                    "Zehennägelecken abrunden.",
                    "Kratzmittel permanent verwenden, was die Handexporation begrenzt, die Babys brauchen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Redness, swelling or pus around a nail fold.",
                    "An ingrown toenail that does not settle.",
                    "A cut that keeps bleeding after a few minutes of gentle pressure."
                ],
                ru: [
                    "Покраснение, отёк или гной вокруг ногтевого валика.",
                    "Вросший ноготь на ноге, который не проходит.",
                    "Порез продолжает кровить после нескольких минут мягкого прижатия."
                ],
                de: [
                    "Rötung, Schwellung oder Eiter um eine Nagelfalte.",
                    "Ein eingewachsener Zehennagel, der sich nicht beruhigt.",
                    "Ein Schnitt, der nach ein paar Minuten sanftem Druck weiterblütet."
                ]
            )
        ),

        CareTip(
            id: 1205, category: .hygiene, icon: "nose.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Nose and ear care: clean the outside only",
                ru: "Уход за носом и ушами: чистим только снаружи",
                de: "Nase- und Ohrenpflege: nur die Außenseite reinigen"
            ),
            summary: LocalizedText(
                en: "Saline and a soft cloth — nothing goes inside the nostril or ear canal",
                ru: "Солевой раствор и мягкая салфетка — ничего не вводим в нос и слуховой проход",
                de: "Salzwasser und ein weiches Tuch – nichts geht in Nasenlöcher oder Gehörgang"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Wipe the outer ear and the folds behind it with a damp cloth, then dry.",
                    "For a blocked nose, put one or two saline drops in each nostril and wait a minute.",
                    "Clear softened mucus with a bulb syringe or nasal aspirator, or let your baby sneeze it out.",
                    "Try saline about ten minutes before a feed, so your baby can breathe while sucking.",
                    "Leave earwax alone — it moves out of the canal by itself."
                ],
                ru: [
                    "Протрите наружное ухо и складки за ним влажной салфеткой, затем просушите.",
                    "При заложенности носа закапайте одну-две капли солевого раствора в каждую ноздрю и подождите минуту.",
                    "Уберите размягчённую слизь аспиратором или грушей либо дайте ребёнку вычихнуть её.",
                    "Закапывайте солевой раствор примерно за десять минут до кормления, чтобы ребёнок мог дышать во время сосания.",
                    "Ушную серу не трогайте — она выходит из слухового прохода сама."
                ],
                de: [
                    "Wischen Sie das äußere Ohr und die Falten dahinter mit einem feuchten Tuch ab, dann trocknen.",
                    "Bei verstopfter Nase geben Sie ein oder zwei Tropfen Kochsalzlösung in jedes Nasenloch und warten eine Minute.",
                    "Entfernen Sie verdünnte Flüssigkeit mit einer Ballonspritze oder einem Nasensauger, oder lassen Sie Ihr Baby niesen.",
                    "Versuchen Sie Salzwasser etwa zehn Minuten vor einer Fütterung, damit Ihr Baby während des Saugens atmen kann.",
                    "Lassen Sie Ohrenschmalz allein – es verlässt den Gehörgang von selbst."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Babies breathe mainly through the nose for the first months, so even a modest blockage disrupts feeding and sleep more than it would in an adult. Saline thins mucus so it can move; it does not medicate anything, which is why it is safe to repeat. Cotton buds push wax deeper and can damage a very short, delicate ear canal, so the rule is simple: nothing smaller than your fingertip goes in.",
                ru: "Первые месяцы дети дышат в основном носом, поэтому даже небольшая заложенность нарушает кормление и сон сильнее, чем у взрослого. Солевой раствор разжижает слизь, чтобы она могла выйти; он не является лекарством — поэтому его безопасно применять повторно. Ватные палочки продвигают серу глубже и могут повредить очень короткий и нежный слуховой проход, так что правило простое: ничего тоньше вашего пальца внутрь не вводится.",
                de: "Babys atmen in den ersten Monaten hauptsächlich durch die Nase, daher stört selbst eine bescheidene Blockierung die Fütterung und den Schlaf mehr als bei einem Erwachsenen. Salzwasser verdünnt Schleim, damit er sich bewegen kann; es ist kein Medikament, daher ist es sicher wiederzuholten. Wattestäbchen schieben Wachs tiefer hinein und können einen sehr kurzen, empfindlichen Gehörgang beschädigen, also lautet die Regel: nichts Kleineres als Ihr Fingertipp geht hinein."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Cotton buds inside the nostril or ear canal.",
                    "Ear candles, which are ineffective and carry a burn risk.",
                    "Aggressive suction that irritates the nasal lining and increases swelling.",
                    "Decongestant drops for infants without medical advice."
                ],
                ru: [
                    "Ватные палочки внутри носа или слухового прохода.",
                    "Ушные свечи — они неэффективны и опасны ожогом.",
                    "Слишком активное отсасывание, которое раздражает слизистую носа и усиливает отёк.",
                    "Сосудосуживающие капли младенцу без назначения врача."
                ],
                de: [
                    "Wattestäbchen im Nasenloch oder Gehörgang.",
                    "Ohrenkerzen, die unwirksam sind und ein Brandrisiko tragen.",
                    "Aggressive Absaugung, die die Nasenschleimhaut reizt und Schwellungen verstärkt.",
                    "Abschwellende Tropfen für Säuglinge ohne ärztliche Beratung."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby pulls at one ear alongside fever or unusual crying.",
                    "Discharge or blood from the ear.",
                    "A blocked nose that stops your baby feeding, or breathing that looks laboured.",
                    "Any suspicion an object has been pushed into the nose or ear."
                ],
                ru: [
                    "Ребёнок тянет себя за одно ухо на фоне температуры или необычного плача.",
                    "Выделения или кровь из уха.",
                    "Заложенность носа, из-за которой ребёнок не может есть, или затруднённое дыхание.",
                    "Любое подозрение, что в нос или ухо попал посторонний предмет."
                ],
                de: [
                    "Ihr Baby zieht an einem Ohr mit Fieber oder ungewöhnlichem Weinen.",
                    "Ausfluss oder Blut aus dem Ohr.",
                    "Eine verstopfte Nase, die Ihr Baby füttert, oder anstrengend aussehende Atmung.",
                    "Jeder Verdacht, dass ein Gegenstand in Nase oder Ohr gedrückt wurde."
                ]
            )
        )
    ]
}
