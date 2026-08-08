import Foundation

extension CareTipsCatalog {
    static let development: [CareTip] = [

        CareTip(
            id: 1401, category: .development, icon: "figure.child", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Tummy time from the first week",
                ru: "Выкладывание на живот с первой недели",
                de: "Bauchzeit ab der ersten Woche"
            ),
            summary: LocalizedText(
                en: "Start with three to five minutes a few times a day and build from there",
                ru: "Начните с трёх-пяти минут несколько раз в день и постепенно увеличивайте",
                de: "Beginnen Sie mit drei bis fünf Minuten mehrmals am Tag und bauen Sie auf"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Begin on day one or two: chest-to-chest on your reclined body counts as tummy time.",
                    "Move to a firm flat surface for short sessions, two or three times a day.",
                    "Choose the moment well — after a nappy change, before a feed, never straight after eating.",
                    "Get down to eye level, talk, and use a mirror or a high-contrast card to give them a reason to lift.",
                    "Build towards roughly an hour spread across the day by three months. Always awake and supervised."
                ],
                ru: [
                    "Начинайте с первого-второго дня: положение грудь к груди на вашем полулежащем теле тоже считается выкладыванием на живот.",
                    "Переходите к твёрдой ровной поверхности для коротких занятий два-три раза в день.",
                    "Выбирайте подходящий момент — после смены подгузника, перед кормлением, но никогда сразу после еды.",
                    "Опуститесь на уровень глаз ребёнка, разговаривайте, покажите зеркало или контрастную картинку, чтобы у него был повод поднять голову.",
                    "К трём месяцам стремитесь примерно к часу в сутки суммарно. Всегда только в бодрствовании и под присмотром."
                ],
                de: [
                    "Beginnen Sie am ersten oder zweiten Tag: Brust an Brust auf Ihrem halbaufgerichteten Körper zählt auch als Bauchzeit.",
                    "Gehen Sie zu einer festen, ebenen Fläche für kurze Einheiten, zwei- oder dreimal täglich über.",
                    "Wählen Sie den richtigen Moment – nach dem Windelwechsel, vor der Fütterung, nie direkt nach dem Essen.",
                    "Gehen Sie auf Augenhöhe, sprechen Sie und nutzen Sie einen Spiegel oder eine hochkontrastive Karte, um dem Baby einen Grund zu geben, den Kopf zu heben.",
                    "Arbeiten Sie bis drei Monaten auf insgesamt etwa eine Stunde pro Tag hin, verteilt über den Tag. Immer wach und überwacht."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Everything from head control to rolling, sitting and eventually crawling depends on the neck, shoulder and back strength that only develops against gravity. Since babies now spend nights and naps on their backs — correctly so — the awake hours are where that work has to happen. It also takes pressure off the back of the skull, which protects head shape at the same time.",
                ru: "Всё — от удержания головы до переворотов, сидения и в итоге ползания — зависит от силы мышц шеи, плечевого пояса и спины, которая развивается только в работе против силы тяжести. Поскольку ночью и в дневной сон дети теперь спят на спине (и это правильно), эта работа приходится на время бодрствования. Заодно снимается давление с затылка, что помогает сохранить форму головы.",
                de: "Alles – von der Kopfkontrolle über das Rollen und Sitzen bis hin zum Krabbeln – hängt von der Nacken-, Schulter- und Rückenstärke ab, die sich nur gegen die Schwerkraft entwickelt. Da Babys nun Nächte und Nickerchen auf dem Rücken verbringen – zu Recht – geschieht diese Entwicklung während der wachen Stunden. Dies entlastet auch die Rückseite des Schädels, was gleichzeitig die Kopfform schützt."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Skipping it because the baby protests — short frequent sessions beat one long unhappy one.",
                    "Tummy time straight after a feed.",
                    "Only on a soft mattress or sofa, where there is nothing firm to push against.",
                    "Leaving the baby unattended, or letting them fall asleep on their front."
                ],
                ru: [
                    "Отказываться из-за протестов ребёнка — короткие частые подходы лучше одного долгого и мучительного.",
                    "Выкладывать на живот сразу после кормления.",
                    "Делать это только на мягком матрасе или диване, где не от чего оттолкнуться.",
                    "Оставлять ребёнка без присмотра или позволять ему уснуть на животе."
                ],
                de: [
                    "Es auslassen, weil das Baby protestiert – kurze häufige Einheiten sind besser als eine lange unglückliche.",
                    "Bauchzeit direkt nach der Fütterung.",
                    "Nur auf einer weichen Matratze oder einem Sofa, wo es nichts zum Abstoßen gibt.",
                    "Das Baby ohne Aufsicht lassen oder es auf dem Bauch einschlafen lassen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "No head lift at all by three months.",
                    "Your baby consistently turns the head to only one side.",
                    "One side of the body feels stiffer or is clearly used less.",
                    "Head control seems to go backwards after it had been improving."
                ],
                ru: [
                    "К трём месяцам ребёнок совсем не поднимает голову.",
                    "Ребёнок постоянно поворачивает голову только в одну сторону.",
                    "Одна сторона тела кажется более напряжённой или явно меньше используется.",
                    "Контроль головы ухудшился после того, как уже улучшался."
                ],
                de: [
                    "Mit drei Monaten hebt das Baby den Kopf gar nicht.",
                    "Ihr Baby dreht den Kopf konsistent nur nach einer Seite.",
                    "Eine Seite des Körpers fühlt sich steifer an oder wird deutlich weniger benutzt.",
                    "Die Kopfkontrolle scheint sich zu verschlechtern, nachdem sie sich verbessert hatte."
                ]
            )
        ),

        CareTip(
            id: 1402, category: .development, icon: "circle.righthalf.filled", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Keeping head shape round",
                ru: "Как сохранить круглую форму головы",
                de: "Kopfform rund halten"
            ),
            summary: LocalizedText(
                en: "Vary the pressure point: alternate head position, cot orientation and carrying arm",
                ru: "Меняйте точку давления: положение головы, ориентацию в кроватке и руку, на которой носите",
                de: "Variieren Sie den Druckpunkt: wechseln Sie Kopfposition, Bettenausrichtung und Tragearm"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Alternate which end of the cot the head goes to each night, so your baby turns towards the room from both sides.",
                    "Move the mobile or the interesting side of the room from time to time.",
                    "Switch the arm you carry and feed on, even if bottle feeding.",
                    "Increase awake time off the back of the head — tummy time, side-lying play, upright carrying.",
                    "Limit time in car seats, bouncers and swings to what travel actually requires."
                ],
                ru: [
                    "Каждую ночь кладите ребёнка головой к разным концам кроватки, чтобы он поворачивался к комнате то одной, то другой стороной.",
                    "Время от времени перевешивайте мобиль или меняйте «интересную» сторону комнаты.",
                    "Меняйте руку, на которой носите и кормите, в том числе при кормлении из бутылочки.",
                    "Увеличивайте время бодрствования без опоры на затылок — выкладывание на живот, игра на боку, ношение вертикально.",
                    "Ограничьте время в автокресле, шезлонге и качелях тем, что действительно нужно для поездки."
                ],
                de: [
                    "Wechseln Sie jede Nacht, welches Ende des Bettes der Kopf zu liegt, damit Ihr Baby sich von beiden Seiten zum Zimmer umdreht.",
                    "Bewegen Sie das Mobile oder die interessante Seite des Zimmers von Zeit zu Zeit.",
                    "Wechseln Sie den Arm, auf dem Sie das Baby tragen und füttern, auch beim Flaschenfttern.",
                    "Erhöhen Sie die Wachzeit ohne Druck auf dem Hinterkopf – Bauchzeit, Seitenlage-Spiel, aufrechtes Tragen.",
                    "Begrenzen Sie die Zeit in Autositzen, Bouncern und Schaukeln auf das, was Reisen tatsächlich erfordern."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "An infant skull is soft and reshapes under sustained pressure, so a baby who always rests on the same spot develops a flat area there. The fix is variety rather than any device, and the earlier it starts the more effectively the skull rounds out on its own. Persistent one-sided turning sometimes means a tight neck muscle, which responds well to early physiotherapy and less well to waiting.",
                ru: "Череп младенца мягкий и меняет форму под постоянным давлением, поэтому у ребёнка, который всегда лежит на одном и том же месте, там образуется уплощение. Решение — разнообразие положений, а не какое-либо приспособление, и чем раньше начать, тем эффективнее череп округляется сам. Стойкий поворот головы в одну сторону иногда означает укорочение мышцы шеи, которое хорошо поддаётся ранней физиотерапии и плохо — выжиданию.",
                de: "Der Säuglingssschädel ist weich und verformt sich unter anhältendem Druck, daher entwickelt ein Baby, das immer an der gleichen Stelle ruht, dort eine flache Stelle. Die Lösung ist Vielfalt statt eines Geräts, und je früher es beginnt, desto wirksamer nimmt der Schädel von selbst Form an. Persistentes einseitiges Drehen bedeutet manchmal einen verspannten Nackenmuskel, der gut auf frühe Physiotherapie anspricht und weniger auf Abwarten."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Head-shaping pillows or positioners in the cot — unsafe for sleep and not effective.",
                    "Long daily stretches in a car seat or bouncer.",
                    "Always feeding and carrying on the same side.",
                    "Changing sleep position to the front to relieve pressure."
                ],
                ru: [
                    "Ортопедические подушки и позиционеры в кроватке — небезопасны для сна и неэффективны.",
                    "Долгое ежедневное пребывание в автокресле или шезлонге.",
                    "Всегда кормить и носить на одной и той же стороне.",
                    "Перекладывать ребёнка спать на живот, чтобы снять давление."
                ],
                de: [
                    "Kopfformende Kissen oder Positionierer im Bett – unsicher zum Schlafen und nicht wirksam.",
                    "Lange tägliche Zeiten im Autositz oder Bouncer.",
                    "Immer auf der gleichen Seite füttern und tragen.",
                    "Schlafposition zur Front ändern, um Druck zu entlasten."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "A visible flat area that is not improving with position changes by around four months.",
                    "Your baby cannot or will not turn the head one way.",
                    "The face or ears look asymmetric.",
                    "Any concern about head size or shape at a routine check."
                ],
                ru: [
                    "Заметное уплощение, которое к четырём месяцам не уменьшается при смене положений.",
                    "Ребёнок не может или не хочет поворачивать голову в одну сторону.",
                    "Лицо или уши выглядят несимметрично.",
                    "Любые сомнения по поводу размера или формы головы на плановом осмотре."
                ],
                de: [
                    "Eine sichtbare flache Stelle, die sich bis etwa vier Monate mit Positionswechseln nicht verbessert.",
                    "Ihr Baby kann oder will den Kopf in eine Richtung nicht drehen.",
                    "Das Gesicht oder die Ohren sehen asymmetrisch aus.",
                    "Bedenken bezüglich der Kopfgröße oder -form bei der Routineuntersuchung."
                ]
            )
        ),

        CareTip(
            id: 1403, category: .development, icon: "bubble.left.and.bubble.right.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Serve and return: answer every babble",
                ru: "Диалог с малышом: отвечайте на каждое агуканье",
                de: "Serve and Return: Antworten Sie auf jedes Brabbeln"
            ),
            summary: LocalizedText(
                en: "Your reply to a sound is what builds language, long before words appear",
                ru: "Именно ваш ответ на звук строит речь — задолго до первых слов",
                de: "Ihre Antwort auf einen Laut ist es, der Sprache aufbaut, lange bevor Worte erscheinen"
            ),
            whatToDo: LocalizedList(
                en: [
                    "When your baby makes a sound, look at them, respond, and pause as if waiting for a reply.",
                    "Name what they are looking at rather than what you want them to look at.",
                    "Narrate ordinary routines out loud — nappy changes, cooking, getting dressed.",
                    "Use warm exaggerated intonation; the sing-song voice is genuinely easier for a baby to process.",
                    "Keep it two-way — leave gaps rather than filling every silence."
                ],
                ru: [
                    "Когда ребёнок издаёт звук, посмотрите на него, ответьте и сделайте паузу, будто ждёте ответа.",
                    "Называйте то, на что смотрит он, а не то, на что вы хотите обратить его внимание.",
                    "Проговаривайте вслух обычные дела — смену подгузника, готовку, одевание.",
                    "Говорите тепло и с подчёркнутой интонацией: напевная речь действительно легче для восприятия младенцем.",
                    "Сохраняйте диалог — оставляйте паузы, а не заполняйте каждую тишину."
                ],
                de: [
                    "Wenn Ihr Baby einen Laut macht, schauen Sie es an, antworten Sie und machen Sie eine Pause, als würden Sie auf eine Antwort warten.",
                    "Benennen Sie, worauf es schaut, nicht worauf Sie es schauen lassen möchten.",
                    "Erzählen Sie alltägliche Routinen laut – Windelwechsel, Kochen, Anziehen.",
                    "Nutzen Sie warme, übertriebene Intonation; die Singsan-Stimme ist wirklich einfacher für ein Baby zu verarbeiten.",
                    "Halten Sie es bidirektional – lassen Sie Lücken, statt jede Stille zu füllen."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Language develops through back-and-forth exchanges, not through volume of speech directed at a child. Each time your baby vocalises and you respond, they learn that sounds cause responses — the foundation of conversation. Research consistently finds that the number of these turn-taking exchanges predicts later language ability better than the total number of words a child hears.",
                ru: "Речь развивается через обмен репликами, а не через объём слов, обращённых к ребёнку. Каждый раз, когда ребёнок издаёт звук, а вы отвечаете, он усваивает, что звуки вызывают отклик, — это основа диалога. Исследования стабильно показывают, что число таких обменов предсказывает будущий уровень речи лучше, чем общее количество услышанных слов.",
                de: "Sprache entwickelt sich durch gegenseitige Austausche, nicht durch die Lautstärke der an ein Kind gerichteten Rede. Jedes Mal, wenn Ihr Baby vokalisiert und Sie antworten, lernt es, dass Laute Reaktionen hervorrufen – die Grundlage von Gesprächen. Forschung zeigt konsistent, dass die Anzahl dieser Rollentausch-Austausche die spätere Sprachfähigkeit besser vorhersagt als die Gesamtzahl der Wörter, die ein Kind hört."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Background television or radio treated as language exposure — it does not respond.",
                    "Filling every gap so there is no space for the baby to take a turn.",
                    "Waiting for real words before starting conversations.",
                    "Correcting babble instead of answering it."
                ],
                ru: [
                    "Считать фоновый телевизор или радио речевой средой — они не отвечают.",
                    "Заполнять каждую паузу, не оставляя ребёнку места для своей реплики.",
                    "Ждать настоящих слов, прежде чем начинать разговоры.",
                    "Исправлять лепет вместо того, чтобы отвечать на него."
                ],
                de: [
                    "Hintergrund-Fernseh- oder Radioberieselung als Sprachexposition zu betrachten – es antwortet nicht.",
                    "Jede Lücke zu füllen, sodass das Baby keine Gelegenheit hat, einen Zug zu machen.",
                    "Auf echte Worte warten, bevor man Gespräche beginnt.",
                    "Brabbellaute korrigieren, statt sie zu beantworten."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "No cooing or vocal sounds by around four months.",
                    "No babbling with consonants by nine months.",
                    "No response to their name or to loud sounds.",
                    "A loss of sounds, gestures or eye contact that were previously there — mention this promptly."
                ],
                ru: [
                    "К четырём месяцам нет гуления и голосовых звуков.",
                    "К девяти месяцам нет лепета с согласными звуками.",
                    "Ребёнок не реагирует на своё имя или на громкие звуки.",
                    "Исчезли звуки, жесты или зрительный контакт, которые уже были, — сообщите об этом врачу без промедления."
                ],
                de: [
                    "Kein Gurren oder Vokallaute bis etwa vier Monate.",
                    "Kein Brabbeln mit Konsonanten bis neun Monate.",
                    "Keine Reaktion auf ihren Namen oder auf laute Geräusche.",
                    "Verlust von Lauten, Gesten oder Augenkontakt, die vorher da waren – erwähnen Sie dies sofort."
                ]
            )
        ),

        CareTip(
            id: 1404, category: .development, icon: "heart.fill", ageFrom: 0, ageTo: 3,
            title: LocalizedText(
                en: "Skin-to-skin — and why fathers should do it too",
                ru: "Контакт кожа к коже — и почему он нужен и отцам",
                de: "Haut-zu-Haut – und warum auch Väter das tun sollten"
            ),
            summary: LocalizedText(
                en: "Bare chest, bare back covered, and twenty unhurried minutes",
                ru: "Голая грудь, укрытая спинка малыша и двадцать неспешных минут",
                de: "Nackte Brust, bedeckter Rücken und zwanzig ungehörte Minuten"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Undress your baby to the nappy and place them chest-down on your bare chest.",
                    "Cover their back with a light blanket, leaving the face clear and visible at all times.",
                    "Stay upright and awake — if you feel sleepy, move your baby to the cot first.",
                    "Aim for at least twenty minutes so both of you can settle into it.",
                    "Share it: fathers, partners and adoptive parents get the same benefits."
                ],
                ru: [
                    "Разденьте ребёнка до подгузника и положите его животом на вашу обнажённую грудь.",
                    "Укройте спинку лёгким одеялом, лицо всегда должно оставаться открытым и видимым.",
                    "Оставайтесь в полусидячем положении и не засыпайте — если клонит в сон, сначала переложите ребёнка в кроватку.",
                    "Стремитесь хотя бы к двадцати минутам, чтобы вы оба успели расслабиться.",
                    "Делите это между собой: отцы, партнёры и приёмные родители получают такую же пользу."
                ],
                de: [
                    "Ziehen Sie Ihr Baby bis zur Windel aus und legen Sie es mit der Brust nach unten auf Ihre nackte Brust.",
                    "Bedecken Sie seinen Rücken mit einer leichten Decke, wobei das Gesicht jederzeit klar und sichtbar bleiben muss.",
                    "Bleiben Sie aufrecht und wach – wenn Sie sich schläfrig fühlen, legen Sie Ihr Baby zuerst ins Bett.",
                    "Streben Sie mindestens zwanzig Minuten an, damit ihr euch beide beruhigen könnt.",
                    "Teilen Sie es: Väter, Partner und Adoptiveltern bekommen die gleichen Vorteile."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Direct skin contact stabilises a baby's heart rate, breathing and temperature, and it lowers stress hormones in both the baby and the adult holding them. For the parent it triggers oxytocin release, which supports bonding and, for the feeding parent, milk supply. It is one of the few things that is simultaneously good for the baby, good for the adult, and free.",
                ru: "Прямой контакт кожи стабилизирует у ребёнка частоту сердцебиения, дыхание и температуру и снижает гормоны стресса и у него, и у взрослого, который его держит. У родителя он запускает выброс окситоцина, который поддерживает привязанность, а у кормящего родителя — и выработку молока. Это одна из немногих вещей, которые одновременно полезны ребёнку, полезны взрослому и ничего не стоят.",
                de: "Direkter Hautkontakt stabilisiert die Herzfrequenz, Atmung und Temperatur eines Babys und senkt Stresshormone sowohl beim Baby als auch beim haltenden Erwachsenen. Bei dem Elternteil löst es die Oxytocin-Ausschüttung aus, die die Bindung unterstützt und beim stillenden Elternteil die Milchproduktion. Es ist eines der wenigen Dinge, das gleichzeitig gut für das Baby, gut für den Erwachsenen und kostenlos ist."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Treating it as something only the birth mother can do.",
                    "Stopping after the first week — it stays valuable for months.",
                    "Falling asleep with the baby on your chest on a sofa or armchair.",
                    "Rushing it into five-minute slots between other tasks."
                ],
                ru: [
                    "Считать, что это доступно только родившей матери.",
                    "Прекращать после первой недели — польза сохраняется месяцами.",
                    "Засыпать с ребёнком на груди на диване или в кресле.",
                    "Втискивать это в пятиминутные промежутки между делами."
                ],
                de: [
                    "Es als etwas zu behandeln, das nur die Geburtsmutter tun kann.",
                    "Nach der ersten Woche zu stoppen – es bleibt monatelang wertvoll.",
                    "Mit dem Baby auf der Brust auf einem Sofa oder Sessel einschlafen.",
                    "Es in fünf-Minuten-Blöcke zwischen anderen Aufgaben quetschen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby becomes cold, mottled or floppy during skin-to-skin.",
                    "Noisy or laboured breathing while lying on your chest.",
                    "You feel no connection at all after weeks of trying — this is worth saying to a professional, and it is common."
                ],
                ru: [
                    "Во время контакта кожа к коже ребёнок замерзает, кожа становится мраморной или он вялый.",
                    "Шумное или затруднённое дыхание, пока ребёнок лежит у вас на груди.",
                    "Вы неделями не чувствуете никакой связи — об этом стоит сказать специалисту, и это встречается часто."
                ],
                de: [
                    "Ihr Baby wird während des Haut-zu-Haut-Kontakts kalt, fleckig oder schlaff.",
                    "Lautes oder schwieriges Atmen, während es auf Ihrer Brust liegt.",
                    "Sie fühlen nach Wochen des Versuchens gar keine Verbindung – es lohnt sich, dies einem Fachmann zu sagen, und es ist häufig."
                ]
            )
        ),

        CareTip(
            id: 1405, category: .development, icon: "book.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Read aloud daily, starting now",
                ru: "Читайте вслух каждый день, начиная прямо сейчас",
                de: "Lesen Sie täglich laut vor, ab sofort"
            ),
            summary: LocalizedText(
                en: "The voice matters more than the story, and no age is too early",
                ru: "Голос важнее сюжета, и слишком раннего возраста здесь не бывает",
                de: "Die Stimme ist wichtiger als die Geschichte, und es gibt kein zu frühes Alter"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Read for a few minutes a day from the newborn stage — any book, including your own.",
                    "Choose high-contrast and simple images for the first months, then cloth and board books to grab and chew.",
                    "Let your baby set the pace: skip pages, repeat favourites, stop when interest goes.",
                    "Point at pictures and name them rather than reading the text word for word.",
                    "Fit it into a routine you already have, such as before the last feed."
                ],
                ru: [
                    "Читайте по несколько минут в день уже с периода новорождённости — любую книгу, в том числе свою собственную.",
                    "В первые месяцы выбирайте контрастные и простые изображения, затем — тканевые и картонные книжки, которые можно хватать и грызть.",
                    "Пусть ребёнок задаёт темп: пропускайте страницы, повторяйте любимые, останавливайтесь, когда интерес пропал.",
                    "Показывайте на картинки и называйте их, а не читайте текст слово в слово.",
                    "Встройте чтение в уже существующий ритуал — например, перед последним кормлением."
                ],
                de: [
                    "Lesen Sie von der Neugeborenenphase an täglich einige Minuten lang – jedes Buch, auch Ihr eigenes.",
                    "Wählen Sie in den ersten Monaten hochkontrastive und einfache Bilder, dann Stoff- und Pappbücher zum Greifen und Kauen.",
                    "Lassen Sie Ihr Baby das Tempo bestimmen: Überspringen Sie Seiten, wiederholen Sie Favoriten, stoppen Sie, wenn das Interesse nachlässt.",
                    "Zeigen Sie auf Bilder und benennen Sie sie, anstatt den Text Wort für Wort zu lesen.",
                    "Integrieren Sie es in eine Routine, die Sie bereits haben, z. B. vor der letzten Fütterung."
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Books put unusual words into a warm familiar voice, and the combination of rhythm, repetition and closeness is what makes them stick. Long before a baby understands a story, they learn that pages turn, that pictures mean something, and that this is a shared and pleasant activity. Building the habit in the first year is far easier than introducing it to a mobile toddler.",
                ru: "Книги приносят непривычные слова тёплым знакомым голосом, а сочетание ритма, повторения и близости — то, что закрепляет их. Задолго до того, как ребёнок поймёт сюжет, он усваивает, что страницы переворачиваются, что картинки что-то означают и что это общее приятное занятие. Сформировать привычку на первом году намного проще, чем приучить к ней подвижного малыша постарше.",
                de: "Bücher bringen ungewöhnliche Wörter in eine warme, vertraute Stimme, und die Kombination aus Rhythmus, Wiederholung und Nähe ist das, was sie zum Haften bringt. Lange bevor ein Baby eine Geschichte versteht, lernt es, dass Seiten umgeblättert werden, dass Bilder etwas bedeuten und dass dies eine gemeinsame und angenehme Aktivität ist. Die Gewohnheit im ersten Jahr zu entwickeln ist viel einfacher, als sie einem mobilen Kleinkind später beizubringen."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Waiting until the child can sit still and listen.",
                    "Insisting on finishing the book.",
                    "Swapping books for an app or a screen at this age.",
                    "Choosing only long text-heavy stories."
                ],
                ru: [
                    "Ждать, пока ребёнок сможет спокойно сидеть и слушать.",
                    "Настаивать на том, чтобы дочитать книгу до конца.",
                    "Заменять книги приложением или экраном в этом возрасте.",
                    "Выбирать только длинные истории с большим количеством текста."
                ],
                de: [
                    "Warten, bis das Kind ruhig sitzen und zuhören kann.",
                    "Darauf bestehen, das Buch zu beenden.",
                    "Bücher in diesem Alter durch eine App oder einen Bildschirm ersetzen.",
                    "Nur lange textlastige Geschichten wählen."
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "No visual tracking of pictures or faces by three months.",
                    "No interest in looking at books or faces at all by around a year.",
                    "Any concern about hearing or vision — get it checked rather than watched."
                ],
                ru: [
                    "К трём месяцам ребёнок не следит взглядом за картинками или лицами.",
                    "К году совсем нет интереса рассматривать книги или лица.",
                    "Любые сомнения по поводу слуха или зрения — лучше проверить, чем наблюдать."
                ],
                de: [
                    "Keine visuelle Verfolgung von Bildern oder Gesichtern bis etwa drei Monate.",
                    "Absolut kein Interesse an Büchern oder Gesichtern bis etwa ein Jahr.",
                    "Bedenken bezüglich Gehör oder Sehkraft – lassen Sie diese überprüfen, anstatt zu beobachten."
                ]
            )
        )
    ]
}
