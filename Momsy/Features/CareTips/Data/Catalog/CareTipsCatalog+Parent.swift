import Foundation

extension CareTipsCatalog {
    static let parent: [CareTip] = [

        CareTip(
            id: 1601, category: .parent, icon: "person.2.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Split the night into shifts",
                ru: "Разделите ночь на смены",
                de: "Teilen Sie die Nacht in Schichten auf"
            ),
            summary: LocalizedText(
                en: "One protected four-hour block each beats two people half-awake all night",
                ru: "Четыре часа непрерывного сна у каждого лучше, чем двое полубодрствующих всю ночь",
                de: "Vier Stunden ununterbrochener Schlaf für jeden ist besser als zwei halbwache Menschen die ganze Nacht"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Divide the night into two blocks — for example one parent covers until 2am, the other from 2am.",
                    "The off-duty parent sleeps elsewhere if possible, with earplugs and no monitor.",
                    "If breastfeeding, the non-feeding parent still does the nappy change, the resettle and the return to the cot.",
                    "Agree the split in advance rather than negotiating at 3am.",
                    "Rotate which parent gets the earlier block so the harder half is shared."
                ],
                ru: [
                    "Разделите ночь на два блока — например, один родитель дежурит до 2 часов ночи, другой — с 2 часов.",
                    "Свободный от дежурства родитель по возможности спит в другой комнате, с берушами и без радионяни.",
                    "При грудном вскармливании второй родитель всё равно меняет подгузник, укачивает и укладывает обратно в кроватку.",
                    "Договоритесь о смене заранее, а не выясняйте это в три часа ночи.",
                    "Чередуйте, кому достаётся ранний блок, чтобы более тяжёлая половина ночи делилась поровну."
                ],
                de: [
                    "Teilen Sie die Nacht in zwei Blöcke auf – zum Beispiel ein Elternteil übernimmt bis 2 Uhr, der andere ab 2 Uhr.",
                    "Das freie Elternteil schläft wenn möglich in einem anderen Zimmer, mit Ohrstöpseln und ohne Babyphone.",
                    "Wenn gestillt wird, wechselt das nicht stillende Elternteil trotzdem die Windel, beruhigt das Baby und legt es zurück ins Bettchen.",
                    "Einigen Sie sich vorher auf die Aufteilung, anstatt um 3 Uhr morgens zu verhandeln.",
                    "Wechseln Sie ab, wer die frühere Schicht bekommt, damit die schwierigere Hälfte gerecht verteilt ist."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Sleep restores in cycles of roughly ninety minutes, and a full uninterrupted block does far more for functioning than the same total hours broken into fragments. Two adults each half-awake all night end up with two impaired parents; a shift system produces one rested parent every night. Agreeing it in advance also removes the nightly negotiation, which is where most of the resentment tends to accumulate.",
                ru: "Сон восстанавливает силы циклами примерно по девяносто минут, и один непрерывный блок даёт гораздо больше, чем то же количество часов, разбитое на фрагменты. Если оба взрослых полубодрствуют всю ночь, наутро истощены оба; при системе смен каждую ночь один родитель отдохнул. Договорённость заранее также убирает ночные препирательства — именно там обычно копится взаимное раздражение.",
                de: "Der Schlaf findet in etwa 90-minütigen Zyklen statt, und ein durchgehender Block hilft viel besser als dieselbe Gesamtstundenzahl in Fragmenten. Zwei halbwache Erwachsene die ganze Nacht lang führen zu zwei erschöpften Eltern – ein Schichtsystem dagegen bringt jede Nacht einen ausgeruhten Elternteil. Sich vorher auf die Aufteilung zu einigen beseitigt auch die nächtliche Verhandlung, in der sich normalerweise der Unmut sammelt."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Both parents waking for every feed out of solidarity.",
                    "The non-feeding parent assuming there is nothing useful to do.",
                    "Deciding who gets up in the moment, every time.",
                    "Filling the off-duty block with chores instead of sleep."
                ],
                ru: [
                    "Оба родителя просыпаются на каждое кормление из солидарности.",
                    "Родитель, который не кормит, считает, что от него всё равно нет пользы.",
                    "Каждый раз решать, кто встаёт, прямо в момент пробуждения.",
                    "Тратить своё свободное от дежурства время на домашние дела вместо сна."
                ],
                de: [
                    "Beide Eltern wachen bei jedem Füttern aus Solidarität auf.",
                    "Das nicht stillende Elternteil denkt, dass es ja sowieso nichts tun kann.",
                    "Jedes Mal neu entscheiden, wer aufsteht, anstatt es vorher zu planen.",
                    "Die freie Zeit für Haushaltsarbeit statt Schlaf nutzen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "You cannot sleep even when your baby is asleep and someone else is on duty.",
                    "Exhaustion is affecting your driving, your safety, or your ability to care for your baby.",
                    "Persistent low mood or anxiety alongside the tiredness."
                ],
                ru: [
                    "Вы не можете уснуть, даже когда ребёнок спит и дежурит кто-то другой.",
                    "Истощение сказывается на вождении, вашей безопасности или способности ухаживать за ребёнком.",
                    "Стойко сниженное настроение или тревога наряду с усталостью."
                ],
                de: [
                    "Sie können nicht schlafen, obwohl das Baby schläft und jemand anderes wacht.",
                    "Erschöpfung beeinflusst Ihr Fahren, Ihre Sicherheit oder Ihre Fähigkeit, sich um Ihr Baby zu kümmern.",
                    "Anhaltend gedrückte Stimmung oder Angst zusammen mit der Müdigkeit."
                ]
            )
        ),

        CareTip(
            id: 1602, category: .parent, icon: "heart.text.square.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Baby blues or something more",
                ru: "Послеродовая хандра или нечто большее",
                de: "Babyblues oder etwas Ernsteres"
            ),
            summary: LocalizedText(
                en: "Tearfulness in the first two weeks is common; low mood that persists deserves support",
                ru: "Плаксивость в первые две недели — обычное дело; стойко сниженное настроение требует помощи",
                de: "Tränenfluss in den ersten zwei Wochen ist normal; anhaltend gedrückte Stimmung verdient Unterstützung"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Expect the baby blues: weepiness, mood swings and sensitivity peaking around days three to five and easing within two weeks.",
                    "Track how you feel over time — Momsy's Wellbeing screen includes the EPDS questionnaire.",
                    "Tell one person how you are actually doing, not the version you give at the door.",
                    "Protect the basics where you can: food, water, daylight, one block of sleep.",
                    "If low mood, anxiety or numbness lasts beyond two weeks, book an appointment. Bring your partner if that helps."
                ],
                ru: [
                    "Будьте готовы к послеродовой хандре: слезливость, перепады настроения и чувствительность достигают пика примерно на третий—пятый день и проходят в течение двух недель.",
                    "Отслеживайте своё состояние во времени — на экране «Самочувствие» в Momsy есть опросник EPDS.",
                    "Расскажите хотя бы одному человеку, как вы себя чувствуете на самом деле, а не дежурную версию для гостей.",
                    "По возможности обеспечьте себе базовое: еду, воду, дневной свет, один блок сна.",
                    "Если сниженное настроение, тревога или опустошённость держатся дольше двух недель, запишитесь к врачу. Возьмите с собой партнёра, если так легче."
                ],
                de: [
                    "Rechnen Sie mit Babyblues: Tränenfluss, Stimmungsschwankungen und Überempfindlichkeit, die etwa am dritten bis fünften Tag ihren Höhepunkt erreichen und innerhalb von zwei Wochen abklingen.",
                    "Beobachten Sie Ihr Wohlbefinden über die Zeit – der Wellbeing-Bereich in Momsy enthält den EPDS-Fragebogen.",
                    "Vertrauen Sie sich einer Person an – sagen Sie, wie es Ihnen wirklich geht, nicht die Version, die Sie der Tür zeigen.",
                    "Achten Sie auf die Basics: Essen, Wasser, Tageslicht, einen Schlafblock.",
                    "Wenn gedrückte Stimmung, Angst oder Taubheit länger als zwei Wochen anhalten, vereinbaren Sie einen Termin. Bringen Sie Ihren Partner mit, wenn das hilft."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Baby blues are driven by an abrupt hormonal shift after birth and resolve on their own. Postnatal depression and anxiety are different: they persist, they deepen, and they respond well to treatment — but only when someone knows about them. They are common, they affect fathers and partners too, and they are not a verdict on how much you love your baby.",
                ru: "Послеродовая хандра вызвана резким гормональным сдвигом после родов и проходит сама. Послеродовая депрессия и тревожное расстройство — другое: они не проходят, а углубляются, и хорошо поддаются лечению — но только если о них кто-то знает. Они встречаются часто, затрагивают и отцов, и партнёров, и они ничего не говорят о том, насколько сильно вы любите своего ребёнка.",
                de: "Babyblues entstehen durch einen abrupten Hormonumbruch nach der Geburt und vergehen von selbst. Postpartale Depression und Angst sind anders: Sie bleiben, sie verschärfen sich, und sie sprechen gut auf Behandlung an – aber nur, wenn jemand davon weiß. Sie sind häufig, betreffen auch Väter und Partner, und sie sagen nichts über Ihre Liebe zu Ihrem Baby aus."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Waiting for it to pass because everyone says the first months are hard.",
                    "Assuming it cannot be depression because you love your baby.",
                    "Hiding it from your partner or your doctor.",
                    "Believing partners and fathers are not affected."
                ],
                ru: [
                    "Ждать, что само пройдёт, потому что все говорят, что первые месяцы тяжёлые.",
                    "Считать, что это не может быть депрессией, раз вы любите своего ребёнка.",
                    "Скрывать своё состояние от партнёра или врача.",
                    "Думать, что партнёров и отцов это не касается."
                ],
                de: [
                    "Warten, dass es von selbst vergeht, weil alle sagen, dass die ersten Monate hart sind.",
                    "Denken, dass es keine Depression sein kann, weil Sie Ihr Baby lieben.",
                    "Es vor Ihrem Partner oder Arzt verbergen.",
                    "Glauben, dass Partner und Väter nicht betroffen sind."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Low mood, anxiety or emptiness lasting more than two weeks.",
                    "Difficulty bonding, or persistent guilt and worthlessness.",
                    "Panic attacks, intrusive frightening thoughts, or being unable to sleep even when your baby sleeps.",
                    "Any thought of harming yourself or your baby — contact emergency services or your doctor straight away. This is urgent and treatable, and asking for help is the right move."
                ],
                ru: [
                    "Сниженное настроение, тревога или чувство пустоты дольше двух недель.",
                    "Трудности с привязанностью к ребёнку либо стойкое чувство вины и никчёмности.",
                    "Панические атаки, навязчивые пугающие мысли или невозможность уснуть, даже когда ребёнок спит.",
                    "Любые мысли о причинении вреда себе или ребёнку — немедленно обратитесь в скорую помощь или к врачу. Это срочно, это лечится, и попросить о помощи — правильный шаг."
                ],
                de: [
                    "Gedrückte Stimmung, Angst oder Leere, die länger als zwei Wochen andauert.",
                    "Schwierigkeiten beim Bonding oder hartnäckige Schuldgefühle und Wertlosigkeit.",
                    "Panikattacken, aufdringliche beängstigende Gedanken oder Unfähigkeit zu schlafen, selbst wenn Ihr Baby schläft.",
                    "Gedanken, sich selbst oder Ihr Baby zu verletzen – kontaktieren Sie sofort den Notfalldienst oder Ihren Arzt. Das ist dringend und behandelbar, und um Hilfe zu bitten ist der richtige Weg."
                ]
            )
        ),

        CareTip(
            id: 1603, category: .parent, icon: "hand.raised.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Never shake a baby: have a walk-away plan",
                ru: "Никогда не трясите ребёнка: заранее продумайте план отхода",
                de: "Schütteln Sie ein Baby nie: haben Sie einen Ausstiegsplan"
            ),
            summary: LocalizedText(
                en: "Decide now what you will do when you have nothing left, so you do not decide in the moment",
                ru: "Решите заранее, что будете делать, когда силы кончатся, чтобы не решать это в критический момент",
                de: "Entscheiden Sie jetzt, was Sie tun werden, wenn Ihnen nichts mehr bleibt, damit Sie es nicht im Moment entscheiden müssen"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Agree the plan in advance: when you reach your limit, put your baby down on their back in the cot.",
                    "Leave the room, close the door, and set a timer for five or ten minutes.",
                    "Breathe slowly, drink water, step outside, or call someone.",
                    "Go back when you are calmer. A crying baby in a safe cot is fine for a few minutes; a shaken baby is not.",
                    "Make sure everyone who ever cares for your baby — partner, relatives, babysitters — knows this plan and knows it is allowed."
                ],
                ru: [
                    "Договоритесь о плане заранее: когда чувствуете, что дошли до предела, положите ребёнка на спину в кроватку.",
                    "Выйдите из комнаты, закройте дверь и поставьте таймер на пять или десять минут.",
                    "Дышите медленно, выпейте воды, выйдите на воздух или позвоните кому-нибудь.",
                    "Вернитесь, когда успокоитесь. Плачущий ребёнок в безопасной кроватке несколько минут — это нормально; ребёнок, которого потрясли, — нет.",
                    "Убедитесь, что каждый, кто когда-либо остаётся с ребёнком — партнёр, родственники, няня, — знает этот план и знает, что так поступать можно."
                ],
                de: [
                    "Einigen Sie sich vorher auf den Plan: Wenn Sie Ihre Grenze erreichen, legen Sie Ihr Baby auf den Rücken ins Bettchen.",
                    "Verlassen Sie das Zimmer, schließen Sie die Tür und stellen Sie einen Timer für fünf oder zehn Minuten.",
                    "Atmen Sie langsam, trinken Sie Wasser, gehen Sie nach draußen oder rufen Sie jemanden an.",
                    "Kommen Sie zurück, wenn Sie ruhiger sind. Ein weininendes Baby in einem sicheren Bettchen ist für ein paar Minuten in Ordnung; ein geschütteltes Baby nicht.",
                    "Stellen Sie sicher, dass jeder, der sich jemals um Ihr Baby kümmert – Partner, Verwandte, Babysitter – diesen Plan kennt und weiß, dass er erlaubt ist."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Shaking causes catastrophic and permanent brain injury in seconds, and it almost always happens to loving parents at the end of a long stretch of inconsolable crying. Crying peaks around six to eight weeks, exactly when parents are most exhausted, which is why the plan has to exist before the moment arrives. Choosing to walk away is not neglect — it is the responsible thing to do.",
                ru: "Тряска за секунды вызывает катастрофическое и необратимое повреждение мозга, и почти всегда это происходит с любящими родителями в конце долгого безутешного плача. Пик плача приходится на шестую—восьмую неделю — ровно тогда, когда родители измотаны сильнее всего, поэтому план должен существовать до наступления этого момента. Отойти в сторону — это не пренебрежение, а ответственный поступок.",
                de: "Schütteln verursacht in Sekunden katastrophale und permanente Hirnverletzungen, und es passiert fast immer liebenden Eltern am Ende einer langen Phase untröstlichen Weinens. Der Höhepunkt des Weinens liegt um die sechste bis achte Woche – genau dann, wenn Eltern am meisten erschöpft sind – daher muss der Plan existieren, bevor der Moment kommt. Sich wegzubegeben ist kein Verwahrlosung – es ist das Verantwortungsvolle."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Believing this only happens to other kinds of parents.",
                    "Continuing to hold a baby while feeling anger rise.",
                    "Not telling other carers that walking away is expected and allowed.",
                    "Feeling ashamed of reaching a limit — every parent has one."
                ],
                ru: [
                    "Считать, что такое случается только с «другими» родителями.",
                    "Продолжать держать ребёнка на руках, чувствуя нарастающий гнев.",
                    "Не сказать другим ухаживающим, что отойти в сторону — ожидаемо и допустимо.",
                    "Стыдиться того, что дошли до предела, — предел есть у каждого родителя."
                ],
                de: [
                    "Glauben, dass dies nur anderen Arten von Eltern widerfährt.",
                    "Weitermachen, ein Baby zu halten, während Sie spüren, wie der Ärger steigt.",
                    "Anderen Betreuern nicht sagen, dass sich Wegbegeben erwartet und erlaubt ist.",
                    "Sich schämen, eine Grenze erreicht zu haben – jeder Elternteil hat eine."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "If your baby has been shaken or dropped, seek emergency care immediately, whatever the circumstances.",
                    "Vomiting, unusual drowsiness, irritability, a bulging fontanelle, seizures or breathing changes after any head impact.",
                    "If you frequently feel close to losing control, tell your doctor or health visitor. Support exists and asking for it protects everyone."
                ],
                ru: [
                    "Если ребёнка потрясли или уронили, немедленно обратитесь за экстренной помощью, независимо от обстоятельств.",
                    "Рвота, необычная сонливость, раздражительность, выбухающий родничок, судороги или изменения дыхания после любого удара головой.",
                    "Если вы часто чувствуете, что близки к потере контроля, скажите об этом врачу или патронажной сестре. Помощь существует, и обращение за ней защищает всех."
                ],
                de: [
                    "Wenn Ihr Baby geschüttelt oder fallen gelassen wurde, suchen Sie sofort ärztliche Hilfe auf, unter allen Umständen.",
                    "Erbrechen, ungewöhnliche Schläfrigkeit, Reizbarkeit, ausbeulende Fontanelle, Krampfanfälle oder Atemveränderungen nach einem Kopfstoß.",
                    "Wenn Sie häufig das Gefühl haben, die Kontrolle zu verlieren, teilen Sie dies Ihrem Arzt oder Ihre Hebamme mit. Hilfe ist vorhanden und die Bitte darum schützt alle."
                ]
            )
        )
    ]
}
