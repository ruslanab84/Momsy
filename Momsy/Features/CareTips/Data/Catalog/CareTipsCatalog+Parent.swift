import Foundation

extension CareTipsCatalog {
    static let parent: [CareTip] = [

        CareTip(
            id: 1601, category: .parent, icon: "person.2.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Split the night into shifts",
                ru: "Разделите ночь на смены",
                de: "Teilen Sie die Nacht in Schichten auf",
                es: "Dividid la noche en turnos",
                fr: "Divisez la nuit en équipes",
                pt: "Divida a noite em turnos"
            ),
            summary: LocalizedText(
                en: "One protected four-hour block each beats two people half-awake all night",
                ru: "Четыре часа непрерывного сна у каждого лучше, чем двое полубодрствующих всю ночь",
                de: "Vier Stunden ununterbrochener Schlaf für jeden ist besser als zwei halbwache Menschen die ganze Nacht",
                es: "Cuatro horas seguidas de sueño para cada uno valen más que dos personas medio despiertas toda la noche",
                fr: "Un bloc protégé de quatre heures chacun bat deux personnes à moitié éveillées toute la nuit",
                pt: "Um bloco protegido de quatro horas cada deixa duas pessoas meio acordadas a noite toda"
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
                ],
                es: [
                    "Dividid la noche en dos bloques: por ejemplo, uno de los padres cubre hasta las 2 de la madrugada y el otro a partir de las 2.",
                    "Quien está libre de turno duerme en otra habitación si es posible, con tapones y sin vigilabebés.",
                    "Si hay lactancia materna, el otro progenitor igualmente cambia el pañal, calma al bebé y lo devuelve a la cuna.",
                    "Acordad el reparto por adelantado en lugar de negociarlo a las 3 de la madrugada.",
                    "Alternad quién hace el turno temprano para repartir la mitad más dura."
                ],
                fr: [
                    "Divisez la nuit en deux blocs : par exemple, un parent couvre jusqu'à 2 heures du matin, l'autre à partir de 2 heures du matin.",
                    "Le parent qui n'est pas en service dort si possible ailleurs, avec des bouchons d'oreilles et sans moniteur.",
                    "En cas d'allaitement, le parent qui n'allaite pas effectue quand même le changement de couche, la réinstallation et le retour au lit.",
                    "Convenez du partage à l’avance plutôt que de négocier à 3 heures du matin.",
                    "Faites pivoter le parent qui obtient le bloc le plus ancien afin que la moitié la plus difficile soit partagée.",
                ],
                pt: [
                    "Divida a noite em dois blocos - por exemplo, um dos pais cobre até as 2h e o outro a partir das 2h.",
                    "O pai fora de serviço dorme em outro lugar, se possível, com protetores de ouvido e sem monitor.",
                    "Se estiver amamentando, o pai que não amamenta ainda faz a troca da fralda, o reassentamento e o retorno ao berço.",
                    "Combine a divisão com antecedência, em vez de negociar às 3h.",
                    "Gire qual pai obtém o bloco anterior para que a metade mais difícil seja compartilhada.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Sleep restores in cycles of roughly ninety minutes, and a full uninterrupted block does far more for functioning than the same total hours broken into fragments. Two adults each half-awake all night end up with two impaired parents; a shift system produces one rested parent every night. Agreeing it in advance also removes the nightly negotiation, which is where most of the resentment tends to accumulate.",
                ru: "Сон восстанавливает силы циклами примерно по девяносто минут, и один непрерывный блок даёт гораздо больше, чем то же количество часов, разбитое на фрагменты. Если оба взрослых полубодрствуют всю ночь, наутро истощены оба; при системе смен каждую ночь один родитель отдохнул. Договорённость заранее также убирает ночные препирательства — именно там обычно копится взаимное раздражение.",
                de: "Der Schlaf findet in etwa 90-minütigen Zyklen statt, und ein durchgehender Block hilft viel besser als dieselbe Gesamtstundenzahl in Fragmenten. Zwei halbwache Erwachsene die ganze Nacht lang führen zu zwei erschöpften Eltern – ein Schichtsystem dagegen bringt jede Nacht einen ausgeruhten Elternteil. Sich vorher auf die Aufteilung zu einigen beseitigt auch die nächtliche Verhandlung, in der sich normalerweise der Unmut sammelt.",
                es: "El sueño repara en ciclos de unos noventa minutos, y un bloque completo sin interrupciones hace mucho más por el funcionamiento diario que el mismo total de horas partido en fragmentos. Dos adultos medio despiertos toda la noche acaban siendo dos padres agotados; un sistema de turnos consigue un progenitor descansado cada noche. Acordarlo por adelantado también elimina la negociación nocturna, que es donde suele acumularse el resentimiento.",
                fr: "Le sommeil se rétablit par cycles d'environ quatre-vingt-dix minutes, et un bloc complet et ininterrompu fait bien plus pour le fonctionnement que le même total d'heures divisé en fragments. Deux adultes à moitié éveillés toute la nuit se retrouvent avec deux parents handicapés ; un système de quarts produit un parent reposé chaque nuit. Le fait de l’accepter à l’avance supprime également les négociations nocturnes, où la plupart des ressentiments ont tendance à s’accumuler.",
                pt: "O sono é restaurado em ciclos de aproximadamente noventa minutos, e um bloqueio completo e ininterrupto contribui muito mais para o funcionamento do que o mesmo total de horas divididas em fragmentos. Dois adultos meio acordados a noite toda acabam com dois pais deficientes; um sistema de turnos produz um pai descansado todas as noites. Concordar com antecedência também elimina a negociação noturna, que é onde a maior parte do ressentimento tende a se acumular."
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
                ],
                es: [
                    "Que ambos padres se despierten en cada toma por solidaridad.",
                    "Que quien no amamanta dé por hecho que no hay nada útil que pueda hacer.",
                    "Decidir cada vez, en el momento, quién se levanta.",
                    "Llenar el bloque de descanso con tareas domésticas en lugar de dormir."
                ],
                fr: [
                    "Les deux parents se réveillent à chaque repas par solidarité.",
                    "Le parent qui ne nourrit pas suppose qu’il n’y a rien d’utile à faire.",
                    "Décider qui se lève sur le moment, à chaque fois.",
                    "Remplir le bloc de repos avec des tâches ménagères au lieu de dormir.",
                ],
                pt: [
                    "Ambos os pais acordam para cada mamada por solidariedade.",
                    "O pai que não se alimenta presumindo que não há nada útil para fazer.",
                    "Decidir quem se levanta no momento, sempre.",
                    "Preencher o bloco de folga com tarefas domésticas em vez de dormir.",
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
                ],
                es: [
                    "No consigues dormir ni siquiera cuando el bebé duerme y hay otra persona de turno.",
                    "El agotamiento afecta a tu conducción, a tu seguridad o a tu capacidad de cuidar del bebé.",
                    "Ánimo bajo o ansiedad persistentes junto con el cansancio."
                ],
                fr: [
                    "Vous ne pouvez pas dormir même lorsque votre bébé dort et que quelqu'un d'autre est de garde.",
                    "L'épuisement affecte votre conduite, votre sécurité ou votre capacité à prendre soin de votre bébé.",
                    "Mauvaise humeur ou anxiété persistante parallèlement à la fatigue.",
                ],
                pt: [
                    "Você não consegue dormir mesmo quando seu bebê está dormindo e outra pessoa está de plantão.",
                    "A exaustão está afetando sua direção, sua segurança ou sua capacidade de cuidar de seu bebê.",
                    "Baixo humor ou ansiedade persistente junto com o cansaço.",
                ]
            )
        ),

        CareTip(
            id: 1602, category: .parent, icon: "heart.text.square.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Baby blues or something more",
                ru: "Послеродовая хандра или нечто большее",
                de: "Babyblues oder etwas Ernsteres",
                es: "Tristeza posparto o algo más",
                fr: "Baby blues ou quelque chose de plus",
                pt: "Baby blues ou algo mais"
            ),
            summary: LocalizedText(
                en: "Tearfulness in the first two weeks is common; low mood that persists deserves support",
                ru: "Плаксивость в первые две недели — обычное дело; стойко сниженное настроение требует помощи",
                de: "Tränenfluss in den ersten zwei Wochen ist normal; anhaltend gedrückte Stimmung verdient Unterstützung",
                es: "Llorar durante las dos primeras semanas es habitual; un ánimo bajo que persiste merece ayuda",
                fr: "Les larmes sont courantes au cours des deux premières semaines ; la mauvaise humeur qui persiste mérite du soutien",
                pt: "O choro nas primeiras duas semanas é comum; mau humor que persiste merece apoio"
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
                ],
                es: [
                    "Cuenta con la tristeza posparto: llanto fácil, cambios de humor y sensibilidad que alcanzan su pico entre el tercer y el quinto día y remiten en dos semanas.",
                    "Registra cómo te sientes a lo largo del tiempo: la pantalla de Bienestar de Momsy incluye el cuestionario EPDS.",
                    "Cuéntale a una persona cómo estás de verdad, no la versión que das en la puerta.",
                    "Protege lo básico en la medida de lo posible: comida, agua, luz del día, un bloque de sueño.",
                    "Si el ánimo bajo, la ansiedad o la falta de emociones duran más de dos semanas, pide cita. Ve con tu pareja si eso te ayuda."
                ],
                fr: [
                    "Attendez-vous au baby blues : pleurs, sautes d’humeur et sensibilité culminant vers les jours trois à cinq et s’atténuant en deux semaines.",
                    "Suivez ce que vous ressentez au fil du temps : l'écran Bien-être de Momsy comprend le questionnaire EPDS.",
                    "Dites à une personne comment vous allez réellement, et non la version que vous donnez à la porte.",
                    "Protégez les éléments de base là où vous le pouvez : la nourriture, l’eau, la lumière du jour, un bloc de sommeil.",
                    "Si la mauvaise humeur, l'anxiété ou l'engourdissement durent plus de deux semaines, prenez rendez-vous. Amenez votre partenaire si cela peut vous aider.",
                ],
                pt: [
                    "Espere a tristeza do bebê: choro, alterações de humor e sensibilidade com pico entre o terceiro e o quinto dia e diminuindo em duas semanas.",
                    "Acompanhe como você se sente ao longo do tempo - a tela Bem-estar da Momsy inclui o questionário EPDS.",
                    "Diga a uma pessoa como você realmente está, não a versão que você dá na porta.",
                    "Proteja o básico sempre que puder: comida, água, luz do dia, um bloco de sono.",
                    "Se o mau humor, a ansiedade ou a dormência durarem mais de duas semanas, marque uma consulta. Traga seu parceiro se isso ajudar.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Baby blues are driven by an abrupt hormonal shift after birth and resolve on their own. Postnatal depression and anxiety are different: they persist, they deepen, and they respond well to treatment — but only when someone knows about them. They are common, they affect fathers and partners too, and they are not a verdict on how much you love your baby.",
                ru: "Послеродовая хандра вызвана резким гормональным сдвигом после родов и проходит сама. Послеродовая депрессия и тревожное расстройство — другое: они не проходят, а углубляются, и хорошо поддаются лечению — но только если о них кто-то знает. Они встречаются часто, затрагивают и отцов, и партнёров, и они ничего не говорят о том, насколько сильно вы любите своего ребёнка.",
                de: "Babyblues entstehen durch einen abrupten Hormonumbruch nach der Geburt und vergehen von selbst. Postpartale Depression und Angst sind anders: Sie bleiben, sie verschärfen sich, und sie sprechen gut auf Behandlung an – aber nur, wenn jemand davon weiß. Sie sind häufig, betreffen auch Väter und Partner, und sie sagen nichts über Ihre Liebe zu Ihrem Baby aus.",
                es: "La tristeza posparto se debe a un cambio hormonal brusco tras el parto y se resuelve sola. La depresión y la ansiedad posparto son distintas: persisten, se profundizan y responden bien al tratamiento, pero solo cuando alguien sabe de ellas. Son frecuentes, también afectan a padres y parejas, y no dicen nada sobre cuánto quieres a tu bebé.",
                fr: "Le baby blues est dû à un changement hormonal brutal après la naissance et se résout tout seul. La dépression et l’anxiété postnatales sont différentes : elles persistent, s’aggravent et réagissent bien au traitement – ​​mais seulement lorsque quelqu’un en a connaissance. Ils sont courants, ils affectent également les pères et les partenaires, et ils ne constituent pas un verdict sur l’amour que vous portez à votre bébé.",
                pt: "A tristeza infantil é causada por uma mudança hormonal abrupta após o nascimento e se resolve por conta própria. A depressão e a ansiedade pós-parto são diferentes: persistem, aprofundam-se e respondem bem ao tratamento – mas apenas quando alguém sabe sobre elas. São comuns, afetam também os pais e os parceiros e não são um veredicto sobre o quanto você ama seu bebê."
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
                ],
                es: [
                    "Esperar a que pase porque todo el mundo dice que los primeros meses son duros.",
                    "Dar por hecho que no puede ser depresión porque quieres a tu bebé.",
                    "Ocultárselo a tu pareja o a tu médico.",
                    "Creer que las parejas y los padres no se ven afectados."
                ],
                fr: [
                    "J'attends que ça passe car tout le monde dit que les premiers mois sont durs.",
                    "En supposant qu’il ne peut pas s’agir d’une dépression parce que vous aimez votre bébé.",
                    "Le cacher à votre partenaire ou à votre médecin.",
                    "Les partenaires croyants et les pères ne sont pas concernés.",
                ],
                pt: [
                    "Esperando passar porque todo mundo diz que os primeiros meses são difíceis.",
                    "Supondo que não pode ser depressão porque você ama seu bebê.",
                    "Escondendo do seu parceiro ou do seu médico.",
                    "Os parceiros crentes e os pais não são afetados.",
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
                ],
                es: [
                    "Ánimo bajo, ansiedad o sensación de vacío que dura más de dos semanas.",
                    "Dificultad para vincularte con el bebé, o culpa y sensación de inutilidad persistentes.",
                    "Ataques de pánico, pensamientos intrusivos aterradores o incapacidad de dormir incluso cuando el bebé duerme.",
                    "Cualquier pensamiento de hacerte daño a ti o al bebé: contacta de inmediato con los servicios de emergencia o con tu médico. Es urgente y tratable, y pedir ayuda es lo correcto."
                ],
                fr: [
                    "Mauvaise humeur, anxiété ou vide durant plus de deux semaines.",
                    "Difficulté à créer des liens, ou culpabilité et inutilité persistantes.",
                    "Crises de panique, pensées effrayantes intrusives ou incapacité à dormir même lorsque votre bébé dort.",
                    "Si vous pensez faire du mal à vous-même ou à votre bébé, contactez immédiatement les services d'urgence ou votre médecin. C’est urgent et traitable, et demander de l’aide est la bonne décision.",
                ],
                pt: [
                    "Mau humor, ansiedade ou vazio que dura mais de duas semanas.",
                    "Dificuldade de vínculo ou culpa persistente e inutilidade.",
                    "Ataques de pânico, pensamentos intrusivos e assustadores ou incapacidade de dormir mesmo quando o bebê dorme.",
                    "Qualquer pensamento de prejudicar você ou seu bebê – entre em contato com os serviços de emergência ou com o seu médico imediatamente. Isto é urgente e tratável, e pedir ajuda é a atitude certa.",
                ]
            )
        ),

        CareTip(
            id: 1603, category: .parent, icon: "hand.raised.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Never shake a baby: have a walk-away plan",
                ru: "Никогда не трясите ребёнка: заранее продумайте план отхода",
                de: "Schütteln Sie ein Baby nie: haben Sie einen Ausstiegsplan",
                es: "Nunca sacudas a un bebé: ten un plan para apartarte",
                fr: "Ne secouez jamais un bébé : ayez un plan de sortie",
                pt: "Nunca sacuda um bebê: tenha um plano de fuga"
            ),
            summary: LocalizedText(
                en: "Decide now what you will do when you have nothing left, so you do not decide in the moment",
                ru: "Решите заранее, что будете делать, когда силы кончатся, чтобы не решать это в критический момент",
                de: "Entscheiden Sie jetzt, was Sie tun werden, wenn Ihnen nichts mehr bleibt, damit Sie es nicht im Moment entscheiden müssen",
                es: "Decide ahora qué harás cuando no te quede nada, para no tener que decidirlo en el momento",
                fr: "Décidez maintenant de ce que vous ferez quand vous n'aurez plus rien, pour ne pas décider sur le moment",
                pt: "Decida agora o que você fará quando não tiver mais nada, para não decidir no momento"
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
                ],
                es: [
                    "Acordad el plan por adelantado: cuando llegues a tu límite, deja al bebé boca arriba en la cuna.",
                    "Sal de la habitación, cierra la puerta y pon un temporizador de cinco o diez minutos.",
                    "Respira despacio, bebe agua, sal al aire libre o llama a alguien.",
                    "Vuelve cuando estés más calmado. Un bebé llorando unos minutos en una cuna segura no corre peligro; un bebé sacudido sí.",
                    "Asegúrate de que todas las personas que cuidan al bebé —pareja, familiares, canguros— conocen este plan y saben que está permitido."
                ],
                fr: [
                    "Convenez à l'avance du plan : lorsque vous atteignez votre limite, couchez votre bébé sur le dos dans le lit.",
                    "Quittez la pièce, fermez la porte et réglez une minuterie sur cinq ou dix minutes.",
                    "Respirez lentement, buvez de l’eau, sortez ou appelez quelqu’un.",
                    "Revenez quand vous serez plus calme. Un bébé qui pleure dans un lit sécurisé ne pose aucun problème pendant quelques minutes ; un bébé secoué ne l’est pas.",
                    "Assurez-vous que toutes les personnes qui s'occupent de votre bébé (partenaire, parents, baby-sitters) connaissent ce plan et savent qu'il est autorisé.",
                ],
                pt: [
                    "Combine o plano com antecedência: quando atingir o limite, coloque o bebê de costas no berço.",
                    "Saia da sala, feche a porta e ajuste o cronômetro para cinco ou dez minutos.",
                    "Respire devagar, beba água, saia de casa ou ligue para alguém.",
                    "Volte quando estiver mais calmo. Um bebê chorando em um berço seguro fica bem por alguns minutos; um bebê abalado não é.",
                    "Certifique-se de que todos que cuidam do seu bebê – parceiros, parentes, babás – conheçam esse plano e saibam que ele é permitido.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Shaking causes catastrophic and permanent brain injury in seconds, and it almost always happens to loving parents at the end of a long stretch of inconsolable crying. Crying peaks around six to eight weeks, exactly when parents are most exhausted, which is why the plan has to exist before the moment arrives. Choosing to walk away is not neglect — it is the responsible thing to do.",
                ru: "Тряска за секунды вызывает катастрофическое и необратимое повреждение мозга, и почти всегда это происходит с любящими родителями в конце долгого безутешного плача. Пик плача приходится на шестую—восьмую неделю — ровно тогда, когда родители измотаны сильнее всего, поэтому план должен существовать до наступления этого момента. Отойти в сторону — это не пренебрежение, а ответственный поступок.",
                de: "Schütteln verursacht in Sekunden katastrophale und permanente Hirnverletzungen, und es passiert fast immer liebenden Eltern am Ende einer langen Phase untröstlichen Weinens. Der Höhepunkt des Weinens liegt um die sechste bis achte Woche – genau dann, wenn Eltern am meisten erschöpft sind – daher muss der Plan existieren, bevor der Moment kommt. Sich wegzubegeben ist kein Verwahrlosung – es ist das Verantwortungsvolle.",
                es: "Sacudir a un bebé provoca lesiones cerebrales catastróficas y permanentes en cuestión de segundos, y casi siempre les ocurre a padres cariñosos al final de un largo llanto inconsolable. El llanto alcanza su pico entre la sexta y la octava semana, justo cuando los padres están más agotados; por eso el plan tiene que existir antes de que llegue ese momento. Apartarse no es desatender: es lo responsable.",
                fr: "Les tremblements provoquent des lésions cérébrales catastrophiques et permanentes en quelques secondes, et cela arrive presque toujours aux parents aimants à la fin d'une longue période de pleurs inconsolables. Les pleurs culminent vers six à huit semaines, exactement au moment où les parents sont le plus épuisés, c'est pourquoi le plan doit exister avant que le moment n'arrive. Choisir de s’en aller n’est pas une négligence – c’est la chose responsable à faire.",
                pt: "Tremer causa lesões cerebrais catastróficas e permanentes em segundos, e quase sempre acontece com pais amorosos no final de um longo período de choro inconsolável. O choro atinge o pico por volta das seis a oito semanas, exatamente quando os pais estão mais exaustos, por isso o plano tem que existir antes que chegue o momento. Decidir ir embora não é negligência – é a coisa responsável a fazer."
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
                ],
                es: [
                    "Creer que esto solo les pasa a otro tipo de padres.",
                    "Seguir sosteniendo al bebé mientras notas que sube la rabia.",
                    "No decirles a los demás cuidadores que apartarse es esperable y está permitido.",
                    "Avergonzarte por haber llegado a tu límite: todos los padres tienen uno."
                ],
                fr: [
                    "Croire que cela n’arrive qu’à d’autres types de parents.",
                    "Continuer à tenir un bébé dans ses bras tout en sentant la colère monter.",
                    "Ne pas dire aux autres soignants que s’éloigner est attendu et autorisé.",
                    "Avoir honte d’atteindre une limite – chaque parent en a une.",
                ],
                pt: [
                    "Acreditar que isso só acontece com outros tipos de pais.",
                    "Continuar a segurar um bebê enquanto sente a raiva aumentar.",
                    "Não dizer aos outros cuidadores que ir embora é esperado e permitido.",
                    "Sentir vergonha de atingir um limite – todo pai tem um.",
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
                ],
                es: [
                    "Si el bebé ha sido sacudido o se ha caído, busca atención de urgencia de inmediato, sean cuales sean las circunstancias.",
                    "Vómitos, somnolencia inusual, irritabilidad, fontanela abombada, convulsiones o cambios en la respiración tras cualquier golpe en la cabeza.",
                    "Si con frecuencia sientes que estás a punto de perder el control, díselo a tu médico o a tu matrona. Existe apoyo y pedirlo protege a todos."
                ],
                fr: [
                    "Si votre bébé a été secoué ou est tombé, consultez immédiatement les urgences, quelles que soient les circonstances.",
                    "Vomissements, somnolence inhabituelle, irritabilité, fontanelle bombée, convulsions ou modifications respiratoires après tout impact sur la tête.",
                    "Si vous vous sentez fréquemment sur le point de perdre le contrôle, parlez-en à votre médecin ou à votre visiteur de santé. Le soutien existe et le demander protège tout le monde.",
                ],
                pt: [
                    "Se o seu bebê foi sacudido ou caiu, procure atendimento de emergência imediatamente, sejam quais forem as circunstâncias.",
                    "Vômitos, sonolência incomum, irritabilidade, fontanela saliente, convulsões ou alterações respiratórias após qualquer impacto na cabeça.",
                    "Se você frequentemente se sente perto de perder o controle, informe o seu médico ou profissional de saúde. O apoio existe e solicitá-lo protege a todos.",
                ]
            )
        )
    ]
}
