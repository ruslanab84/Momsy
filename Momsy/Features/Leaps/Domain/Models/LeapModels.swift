import Foundation

struct DevelopmentLeap: Identifiable {
    let id: Int
    let week: Int
    /// Typical length of this leap's hard stretch, in days.
    let hardDays: Int
    let names: [Language: String]
    let semanticColor: SemanticColor
    var isDone: Bool
    var isCurrent: Bool
    let descriptions: [Language: String]
    let signsByLang: [Language: [String]]
    let skillsByLang: [Language: [String]]
    let tips: [Language: String]

    func name(for lang: Language) -> String { names[lang] ?? names[.english] ?? "" }
    func description(for lang: Language) -> String { descriptions[lang] ?? descriptions[.english] ?? "" }
    func signs(for lang: Language) -> [String] { signsByLang[lang] ?? signsByLang[.english] ?? [] }
    func skills(for lang: Language) -> [String] { skillsByLang[lang] ?? skillsByLang[.english] ?? [] }
    func tip(for lang: Language) -> String { tips[lang] ?? tips[.english] ?? "" }
}

extension DevelopmentLeap {
    init(
        scheduleID: Int,
        names: [Language: String],
        semanticColor: SemanticColor,
        isDone: Bool,
        isCurrent: Bool,
        descriptions: [Language: String],
        signsByLang: [Language: [String]],
        skillsByLang: [Language: [String]],
        tips: [Language: String]
    ) {
        let definition = DevelopmentLeapSchedule.definition(id: scheduleID)
        self.id = definition.id
        self.week = definition.week
        self.hardDays = definition.hardDays
        self.names = names
        self.semanticColor = semanticColor
        self.isDone = isDone
        self.isCurrent = isCurrent
        self.descriptions = descriptions
        self.signsByLang = signsByLang
        self.skillsByLang = skillsByLang
        self.tips = tips
    }
}

/// Builds a per-language string map. Argument order mirrors `L10n.s`: en, ru, de, es, fr, pt, zh.
private func loc(_ en: String, _ ru: String, _ de: String, _ es: String, _ fr: String, _ pt: String, _ zh: String) -> [Language: String] {
    [.english: en, .russian: ru, .german: de, .spanish: es, .french: fr, .portuguese: pt, .chinese: zh]
}

private func loc(_ en: [String], _ ru: [String], _ de: [String], _ es: [String], _ fr: [String], _ pt: [String], _ zh: [String]) -> [Language: [String]] {
    [.english: en, .russian: ru, .german: de, .spanish: es, .french: fr, .portuguese: pt, .chinese: zh]
}

extension DevelopmentLeap {
    static let catalog: [DevelopmentLeap] = [
    DevelopmentLeap(
        scheduleID: 1,
        names: loc("First Discoveries", "Первые открытия", "Erste Entdeckungen", "Primeros descubrimientos", "Premières découvertes", "Primeiras descobertas", "最初的发现"),
        semanticColor: .rose, isDone: true, isCurrent: false,
        descriptions: loc(
            "is learning to process sensory signals — sounds, light, and touch feel entirely new.",
            "учится обрабатывать сигналы от органов чувств — звуки, свет, прикосновения воспринимаются по-новому.",
            "lernt, Sinnesreize zu verarbeiten — Geräusche, Licht und Berührungen fühlen sich völlig neu an.",
            "está aprendiendo a procesar las señales sensoriales: los sonidos, la luz y el tacto se perciben de forma totalmente nueva.",
            "apprend à traiter les signaux sensoriels — les sons, la lumière et le toucher sont perçus de façon entièrement nouvelle.",
            "está a aprender a processar os sinais sensoriais — os sons, a luz e o toque são sentidos de uma forma totalmente nova.",
            "正在学习处理来自感官的信号——声音、光线和触觉都仿佛全新的体验。"),
        signsByLang: loc(
            ["sleeps a lot", "startles at sounds", "seeks light sources"],
            ["много спит", "вздрагивает от звуков", "ищет источник света"],
            ["schläft viel", "zuckt bei Geräuschen zusammen", "sucht Lichtquellen"],
            ["duerme mucho", "se sobresalta con los sonidos", "busca fuentes de luz"],
            ["dort beaucoup", "sursaute aux bruits", "cherche les sources de lumière"],
            ["dorme muito", "assusta-se com os sons", "procura fontes de luz"],
            ["睡得很多", "听到声音会惊跳", "寻找光源"]),
        skillsByLang: loc(
            ["recognises mum's voice", "reacts to light", "calms in arms"],
            ["отличает голос мамы", "реагирует на свет", "успокаивается на руках"],
            ["erkennt Mamas Stimme", "reagiert auf Licht", "beruhigt sich auf dem Arm"],
            ["reconoce la voz de mamá", "reacciona a la luz", "se calma en brazos"],
            ["reconnaît la voix de maman", "réagit à la lumière", "se calme dans les bras"],
            ["reconhece a voz da mãe", "reage à luz", "acalma-se ao colo"],
            ["能认出妈妈的声音", "对光有反应", "抱着就能安静下来"]),
        tips: loc(
            "Talk and sing to your baby in a calm, gentle voice. Quiet, close moments together are a good fit for these weeks.",
            "Разговаривайте и пойте малышу спокойным, мягким голосом. Тихие моменты рядом друг с другом — то, что нужно в эти недели.",
            "Sprich und sing mit deinem Baby mit ruhiger, sanfter Stimme. Ruhige, nahe Momente zu zweit passen gut in diese Wochen.",
            "Háblale y cántale a tu bebé con voz tranquila y suave. Los momentos tranquilos y cercanos encajan muy bien en estas semanas.",
            "Parlez et chantez à votre bébé d’une voix calme et douce. Les moments calmes et proches conviennent bien à ces semaines.",
            "Fale e cante para o seu bebé com voz calma e suave. Momentos tranquilos e próximos encaixam bem nestas semanas.",
            "用平静、温柔的声音和宝宝说话、唱歌。这几周很适合安静、亲密的相处时光。")
    ),
    DevelopmentLeap(
        scheduleID: 2,
        names: loc("Noticing Details", "Замечаю детали", "Details entdecken", "Descubro detalles", "Je remarque les détails", "Reparo nos detalhes", "留意细节"),
        semanticColor: .butter, isDone: true, isCurrent: false,
        descriptions: loc(
            "begins recognising regular patterns — faces, rhythms, and simple geometric shapes.",
            "начинает распознавать регулярные образы — черты лица, ритмы, простые геометрические формы.",
            "beginnt, regelmäßige Muster zu erkennen — Gesichter, Rhythmen und einfache geometrische Formen.",
            "empieza a reconocer patrones regulares: caras, ritmos y formas geométricas sencillas.",
            "commence à reconnaître des motifs réguliers — visages, rythmes et formes géométriques simples.",
            "começa a reconhecer padrões regulares — rostos, ritmos e formas geométricas simples.",
            "开始识别规律的图案——面孔、节奏和简单的几何形状。"),
        signsByLang: loc(
            ["stares at faces a long time", "fixates on patterns", "more cooing"],
            ["долго смотрит на лица", "замирает на паттернах", "больше гулит"],
            ["betrachtet Gesichter lange", "fixiert Muster", "gurrt mehr"],
            ["mira las caras largo rato", "se fija en los patrones", "balbucea más"],
            ["fixe longuement les visages", "s’attarde sur les motifs", "gazouille davantage"],
            ["fixa os rostos por muito tempo", "concentra-se nos padrões", "balbucia mais"],
            ["长时间盯着面孔看", "专注于图案", "咿呀声更多了"]),
        skillsByLang: loc(
            ["smiles back", "tracks with eyes", "makes vowel sounds"],
            ["улыбается в ответ", "следит взглядом", "издаёт гласные звуки"],
            ["lächelt zurück", "folgt mit den Augen", "bildet Vokallaute"],
            ["devuelve la sonrisa", "sigue con la mirada", "emite sonidos vocálicos"],
            ["sourit en retour", "suit du regard", "émet des sons voyelles"],
            ["retribui o sorriso", "segue com os olhos", "produz sons vocálicos"],
            ["会回以微笑", "用眼睛追视", "发出元音"]),
        tips: loc(
            "Many babies like looking at faces and high-contrast pictures — try a black-and-white book during awake time.",
            "Многим малышам нравится разглядывать лица и контрастные картинки — попробуйте чёрно-белую книжку, пока малыш бодрствует.",
            "Viele Babys schauen gern Gesichter und kontrastreiche Bilder an — probier in der Wachzeit ein Schwarz-Weiß-Buch aus.",
            "A muchos bebés les gusta mirar caras e imágenes de alto contraste: prueba un libro en blanco y negro mientras está despierto.",
            "Beaucoup de bébés aiment regarder des visages et des images contrastées — essayez un livre en noir et blanc pendant les moments d’éveil.",
            "Muitos bebés gostam de olhar para caras e imagens de alto contraste — experimente um livro a preto e branco quando o bebé estiver acordado.",
            "很多宝宝喜欢看人脸和高对比度的图片——宝宝醒着的时候，可以试试黑白绘本。")
    ),
    DevelopmentLeap(
        scheduleID: 3,
        names: loc("Smoother Moves", "Плавные движения", "Sanftere Bewegungen", "Movimientos más fluidos", "Des gestes plus souples", "Movimentos mais suaves", "动作更流畅"),
        semanticColor: .mint, isDone: true, isCurrent: false,
        descriptions: loc(
            "discovers the ability to control their body — arms, legs, and head start moving smoothly and intentionally.",
            "обнаруживает, что может управлять своим телом — руки, ноги, голова начинают двигаться плавно и осознанно.",
            "entdeckt, dass es seinen Körper steuern kann — Arme, Beine und Kopf bewegen sich nun flüssig und gezielt.",
            "descubre que puede controlar su cuerpo: los brazos, las piernas y la cabeza empiezan a moverse de forma suave e intencionada.",
            "découvre qu’il peut contrôler son corps — bras, jambes et tête se mettent à bouger avec fluidité et intention.",
            "descobre que pode controlar o corpo — os braços, as pernas e a cabeça começam a mover-se de forma suave e intencional.",
            "发现自己能够控制身体——手臂、腿和头开始顺畅而有意识地活动。"),
        signsByLang: loc(
            ["studies hands at length", "brings objects to mouth", "moves legs a lot"],
            ["подолгу изучает руки", "тянет предметы в рот", "много двигает ногами"],
            ["betrachtet lange die Hände", "steckt Gegenstände in den Mund", "strampelt viel"],
            ["se mira las manos largo rato", "se lleva objetos a la boca", "mueve mucho las piernas"],
            ["observe longuement ses mains", "porte les objets à la bouche", "bouge beaucoup les jambes"],
            ["observa as mãos demoradamente", "leva objetos à boca", "mexe muito as pernas"],
            ["长时间端详双手", "把东西放进嘴里", "双腿动得很多"]),
        skillsByLang: loc(
            ["grasps a rattle", "holds head up", "rolls to the side"],
            ["захватывает погремушку", "удерживает голову", "переворачивается набок"],
            ["greift eine Rassel", "hält den Kopf", "dreht sich zur Seite"],
            ["agarra un sonajero", "sostiene la cabeza", "se gira de lado"],
            ["attrape un hochet", "tient sa tête", "se tourne sur le côté"],
            ["agarra uma roca", "sustém a cabeça", "vira-se de lado"],
            ["能抓住摇铃", "能抬头", "会侧身翻"]),
        tips: loc(
            "Give your baby some tummy time every day, always while awake and with you watching. Short, frequent sessions are fine.",
            "Выкладывайте малыша на животик каждый день — только когда он бодрствует и вы рядом. Можно часто и понемногу.",
            "Leg dein Baby jeden Tag etwas auf den Bauch — nur im Wachzustand und unter deiner Aufsicht. Kurze, häufige Einheiten reichen.",
            "Pon a tu bebé boca abajo un rato cada día, siempre despierto y bajo tu mirada. Bastan ratos cortos y frecuentes.",
            "Mettez votre bébé sur le ventre un peu chaque jour, toujours éveillé et sous votre surveillance. De courtes séances fréquentes suffisent.",
            "Coloque o bebé de barriga para baixo um pouco todos os dias, sempre acordado e sob a sua vigilância. Sessões curtas e frequentes chegam.",
            "每天让宝宝趴一会儿，但一定要在宝宝醒着且有你看护时进行。时间短、次数多就可以。")
    ),
    DevelopmentLeap(
        scheduleID: 4,
        names: loc("Little Experiments", "Маленькие эксперименты", "Kleine Experimente", "Pequeños experimentos", "Petites expériences", "Pequenas experiências", "小小实验"),
        semanticColor: .coral, isDone: false, isCurrent: true,
        descriptions: loc(
            "begins to notice that one action can lead to another — pressing, dropping and pulling become interesting.",
            "начинает замечать, что одно действие может вести к другому, — нажимать, ронять и тянуть становится интересно.",
            "beginnt zu bemerken, dass eine Handlung zu einer anderen führen kann — Drücken, Fallenlassen und Ziehen werden spannend.",
            "empieza a notar que una acción puede llevar a otra: apretar, dejar caer y tirar se vuelven interesantes.",
            "commence à remarquer qu’une action peut en entraîner une autre — appuyer, lâcher, tirer devient intéressant.",
            "começa a reparar que uma ação pode levar a outra — carregar, deixar cair e puxar tornam-se interessantes.",
            "开始注意到一个动作可能引出另一个结果——按一按、扔一扔、拉一拉都变得有趣起来。"),
        signsByLang: loc(
            ["poor sleep", "wants to be held", "fussy"],
            ["хуже спит", "требует рук", "капризничает"],
            ["schlechter Schlaf", "will getragen werden", "quengelig"],
            ["duerme mal", "quiere brazos", "irritable"],
            ["sommeil agité", "réclame les bras", "grognon"],
            ["sono agitado", "quer colo", "irritado"],
            ["睡得不好", "想被抱着", "爱闹脾气"]),
        skillsByLang: loc(
            ["tracks with eyes", "grabs objects", "recognises toys", "coos at laughter"],
            ["следит глазами", "хватает предметы", "узнаёт игрушку", "гулит на смех"],
            ["folgt mit den Augen", "greift Gegenstände", "erkennt Spielzeug", "gurrt beim Lachen"],
            ["sigue con la mirada", "agarra objetos", "reconoce juguetes", "balbucea al reír"],
            ["suit du regard", "attrape des objets", "reconnaît les jouets", "gazouille en riant"],
            ["segue com os olhos", "agarra objetos", "reconhece brinquedos", "balbucia ao rir"],
            ["用眼睛追视", "抓取物品", "认得玩具", "听到笑声会咿呀回应"]),
        tips: loc(
            "Show a press-toy or black-and-white book — cause and effect is especially fascinating during this leap.",
            "Покажите нажимаемую игрушку или чёрно-белую книжку — «причина → следствие» особенно увлекает в этот скачок.",
            "Zeige ein Drück-Spielzeug oder ein Schwarz-Weiß-Buch — Ursache und Wirkung faszinieren in diesem Schub besonders.",
            "Muéstrale un juguete con botones o un libro en blanco y negro: la causa y el efecto fascinan especialmente en este salto.",
            "Montrez un jouet à pousser ou un livre en noir et blanc — la cause à effet fascine particulièrement pendant ce bond.",
            "Mostre um brinquedo de pressionar ou um livro a preto e branco — a relação causa-efeito fascina especialmente neste salto.",
            "给宝宝看按一下会响的玩具或黑白绘本——在这个猛长期，因果关系特别吸引他。")
    ),
    DevelopmentLeap(
        scheduleID: 5,
        names: loc("Near and Far", "Близко и далеко", "Nah und fern", "Cerca y lejos", "Près et loin", "Perto e longe", "近与远"),
        semanticColor: .lilac, isDone: false, isCurrent: false,
        descriptions: loc(
            "discovers connections between people and objects. Many babies get more upset when a familiar person leaves the room at this age.",
            "открывает связи между людьми и предметами. В этом возрасте многие малыши сильнее расстраиваются, когда близкий человек выходит из комнаты.",
            "entdeckt Verbindungen zwischen Menschen und Dingen. In diesem Alter sind viele Babys trauriger, wenn eine vertraute Person den Raum verlässt.",
            "descubre las conexiones entre personas y objetos. A esta edad, muchos bebés se disgustan más cuando una persona conocida sale de la habitación.",
            "découvre les liens entre les personnes et les objets. À cet âge, beaucoup de bébés sont plus contrariés quand une personne familière quitte la pièce.",
            "descobre as ligações entre pessoas e objetos. Nesta idade, muitos bebés ficam mais aborrecidos quando uma pessoa familiar sai da divisão.",
            "发现人与物之间的联系。这个阶段，很多宝宝在熟悉的人离开房间时会更加不安。"),
        signsByLang: loc(
            ["separation anxiety", "prefers mum", "tests your reaction"],
            ["тревога при расставании", "предпочитает маму", "проверяет вашу реакцию"],
            ["Trennungsangst", "bevorzugt Mama", "testet deine Reaktion"],
            ["ansiedad por separación", "prefiere a mamá", "pone a prueba tu reacción"],
            ["angoisse de la séparation", "préfère maman", "teste votre réaction"],
            ["ansiedade de separação", "prefere a mãe", "testa a sua reação"],
            ["分离焦虑", "更黏妈妈", "试探你的反应"]),
        skillsByLang: loc(
            ["plays peek-a-boo", "waves bye-bye", "imitates sounds and gestures"],
            ["играет в «ку-ку»", "машет «пока»", "подражает звукам и жестам"],
            ["spielt Kuckuck", "winkt zum Abschied", "ahmt Laute und Gesten nach"],
            ["juega al cucú-tras", "dice adiós con la mano", "imita sonidos y gestos"],
            ["joue à coucou", "fait au revoir de la main", "imite sons et gestes"],
            ["brinca às escondidas", "acena adeus", "imita sons e gestos"],
            ["玩躲猫猫", "挥手再见", "模仿声音和动作"]),
        tips: loc(
            "Play peek-a-boo: hide your face or a toy and let it reappear. Many babies love this game now.",
            "Играйте в «ку-ку»: прячьте лицо или игрушку и показывайте снова. Многие малыши сейчас обожают эту игру.",
            "Spielt Kuckuck: Versteck dein Gesicht oder ein Spielzeug und lass es wieder auftauchen. Viele Babys lieben dieses Spiel jetzt.",
            "Juega al cucú: esconde tu cara o un juguete y haz que vuelva a aparecer. A muchos bebés les encanta este juego ahora.",
            "Jouez à coucou-caché : cachez votre visage ou un jouet puis faites-le réapparaître. Beaucoup de bébés adorent ce jeu en ce moment.",
            "Brinque ao cucu: esconda a cara ou um brinquedo e faça-o reaparecer. Muitos bebés adoram esta brincadeira agora.",
            "玩躲猫猫：把脸或玩具藏起来，再让它出现。这个阶段很多宝宝都很喜欢这个游戏。")
    ),
    DevelopmentLeap(
        scheduleID: 6,
        names: loc("Sorting the World", "Раскладываю мир", "Die Welt ordnen", "Ordenando el mundo", "Ranger le monde", "Arrumar o mundo", "整理世界"),
        semanticColor: .sky, isDone: false, isCurrent: false,
        descriptions: loc(
            "begins grouping things by properties: colour, shape, size. Actively explores the world through classification.",
            "начинает группировать вещи по свойствам: цвет, форма, размер. Активно изучает мир через классификацию.",
            "beginnt, Dinge nach Eigenschaften zu ordnen: Farbe, Form, Größe. Erkundet die Welt aktiv durch Klassifizieren.",
            "empieza a agrupar cosas por propiedades: color, forma, tamaño. Explora activamente el mundo a través de la clasificación.",
            "commence à regrouper les choses par propriétés : couleur, forme, taille. Explore activement le monde par la classification.",
            "começa a agrupar as coisas por propriedades: cor, forma, tamanho. Explora ativamente o mundo através da classificação.",
            "开始按属性给事物分组：颜色、形状、大小。通过分类积极地探索世界。"),
        signsByLang: loc(
            ["sorts toys", "plays alone for longer", "takes everything apart"],
            ["сортирует игрушки", "дольше играет самостоятельно", "разбирает всё подряд"],
            ["sortiert Spielzeug", "spielt länger allein", "nimmt alles auseinander"],
            ["clasifica los juguetes", "juega solo más tiempo", "lo desmonta todo"],
            ["trie les jouets", "joue seul plus longtemps", "démonte tout"],
            ["organiza os brinquedos", "brinca sozinho mais tempo", "desmonta tudo"],
            ["给玩具分类", "能独自玩更久", "把什么都拆开"]),
        skillsByLang: loc(
            ["understands 'big/small'", "puts objects in a container", "responds to name"],
            ["понимает «большой/маленький»", "складывает предметы в ёмкость", "откликается на имя"],
            ["versteht „groß/klein“", "legt Gegenstände in einen Behälter", "reagiert auf den Namen"],
            ["entiende «grande/pequeño»", "mete objetos en un recipiente", "responde a su nombre"],
            ["comprend « grand/petit »", "met des objets dans un récipient", "répond à son prénom"],
            ["entende «grande/pequeno»", "coloca objetos num recipiente", "responde ao nome"],
            ["理解「大/小」", "把物品放进容器里", "听到名字会回应"]),
        tips: loc(
            "Sorters, cups, nesting toys — ideal. Name properties: 'red', 'big', 'heavy'.",
            "Сортеры, стаканчики, вкладыши — идеальные игрушки. Называйте свойства: «красный», «большой», «тяжёлый».",
            "Sortierboxen, Becher, Stapelspielzeug — ideal. Benenne Eigenschaften: „rot“, „groß“, „schwer“.",
            "Encajables, vasos, juguetes apilables: ideales. Nombra las propiedades: «rojo», «grande», «pesado».",
            "Boîtes à formes, gobelets, jouets gigognes — parfaits. Nommez les propriétés : « rouge », « grand », « lourd ».",
            "Caixas de encaixe, copos, brinquedos de encaixar — ideais. Nomeie as propriedades: «vermelho», «grande», «pesado».",
            "形状分类盒、套杯、套叠玩具都很理想。说出物品的属性：「红色」「大」「重」。")
    ),
    DevelopmentLeap(
        scheduleID: 7,
        names: loc("Putting Things Together", "Собираю по порядку", "Dinge zusammenfügen", "Juntando las piezas", "Assembler les choses", "Juntar as peças", "把事情串起来"),
        semanticColor: .rose, isDone: false, isCurrent: false,
        descriptions: loc(
            "starts seeing that actions can happen in a predictable order: first this, then that.",
            "начинает понимать порядок действий: сначала одно, потом другое.",
            "beginnt zu verstehen, dass Handlungen in einer vorhersehbaren Reihenfolge ablaufen: erst dies, dann das.",
            "empieza a ver que las acciones pueden suceder en un orden predecible: primero esto, luego aquello.",
            "commence à comprendre que les actions peuvent suivre un ordre prévisible : d’abord ceci, puis cela.",
            "começa a perceber que as ações podem acontecer numa ordem previsível: primeiro isto, depois aquilo.",
            "开始理解动作可以按可预期的顺序发生：先这样，再那样。"),
        signsByLang: loc(
            ["expects routines", "copies simple steps", "gets upset when order changes"],
            ["ждёт привычных ритуалов", "повторяет простые шаги", "расстраивается, если порядок меняется"],
            ["erwartet Routinen", "ahmt einfache Schritte nach", "wird unruhig, wenn sich die Reihenfolge ändert"],
            ["espera rutinas", "imita pasos sencillos", "se molesta si cambia el orden"],
            ["attend les routines", "imite des étapes simples", "se fâche si l’ordre change"],
            ["espera rotinas", "imita passos simples", "fica irritado se a ordem muda"],
            ["期待固定流程", "模仿简单步骤", "顺序变化会不安"]),
        skillsByLang: loc(
            ["follows two-step play", "helps with dressing", "anticipates bedtime routine"],
            ["следует игре из двух шагов", "помогает одеваться", "предугадывает ритуал сна"],
            ["folgt Zwei-Schritt-Spielen", "hilft beim Anziehen", "erwartet die Schlafroutine"],
            ["sigue juegos de dos pasos", "ayuda al vestirse", "anticipa la rutina de dormir"],
            ["suit un jeu en deux étapes", "aide à s’habiller", "anticipe le rituel du coucher"],
            ["segue brincadeiras de dois passos", "ajuda a vestir", "antecipa a rotina de sono"],
            ["能跟随两步游戏", "会帮忙穿衣", "预期睡前流程"]),
        tips: loc(
            "Keep small routines in the same order: bath, pajamas, book, sleep. A familiar order helps many toddlers know what comes next.",
            "Держите маленькие ритуалы в одном порядке: купание, пижама, книжка, сон. Привычный порядок помогает многим малышам понимать, что будет дальше.",
            "Halte kleine Rituale in derselben Reihenfolge: Baden, Schlafanzug, Buch, Schlafen. Eine vertraute Reihenfolge hilft vielen Kleinkindern zu wissen, was als Nächstes kommt.",
            "Mantén las pequeñas rutinas en el mismo orden: baño, pijama, cuento, dormir. Un orden conocido ayuda a muchos niños pequeños a saber qué viene después.",
            "Gardez les petits rituels dans le même ordre : bain, pyjama, livre, dodo. Un ordre familier aide beaucoup de tout-petits à savoir ce qui vient ensuite.",
            "Mantenha as pequenas rotinas pela mesma ordem: banho, pijama, livro, dormir. Uma ordem conhecida ajuda muitas crianças pequenas a saber o que vem a seguir.",
            "让小仪式保持同样的顺序：洗澡、换睡衣、读书、睡觉。熟悉的顺序能帮助很多幼儿知道接下来要做什么。")
    ),
    DevelopmentLeap(
        scheduleID: 8,
        names: loc("Little Planner", "Маленький планировщик", "Kleiner Planer", "Pequeño planificador", "Petit planificateur", "Pequeno planeador", "小小计划家"),
        semanticColor: .butter, isDone: false, isCurrent: false,
        descriptions: loc(
            "learns that a goal can be reached through several steps, choices, and corrections.",
            "понимает, что к цели можно идти через несколько шагов, выборов и исправлений.",
            "lernt, dass ein Ziel über mehrere Schritte, Entscheidungen und Korrekturen erreicht wird.",
            "aprende que una meta se alcanza con varios pasos, elecciones y correcciones.",
            "apprend qu’un objectif peut être atteint par plusieurs étapes, choix et ajustements.",
            "aprende que uma meta pode ser alcançada com vários passos, escolhas e correções.",
            "开始明白一个目标可以通过多个步骤、选择和调整来实现。"),
        signsByLang: loc(
            ["insists on doing it alone", "tries new routes", "says no more often"],
            ["настаивает «сам»", "ищет новые способы", "чаще говорит «нет»"],
            ["will es allein machen", "probiert neue Wege", "sagt öfter nein"],
            ["quiere hacerlo solo", "prueba caminos nuevos", "dice no más a menudo"],
            ["veut faire seul", "essaie de nouvelles façons", "dit non plus souvent"],
            ["quer fazer sozinho", "tenta novos caminhos", "diz não com mais frequência"],
            ["坚持自己来", "尝试新方法", "更常说不"]),
        skillsByLang: loc(
            ["solves simple problems", "chooses between options", "uses tools in play"],
            ["решает простые задачи", "выбирает из вариантов", "использует инструменты в игре"],
            ["löst einfache Probleme", "wählt zwischen Optionen", "nutzt Werkzeuge im Spiel"],
            ["resuelve problemas simples", "elige entre opciones", "usa herramientas al jugar"],
            ["résout de petits problèmes", "choisit entre options", "utilise des outils dans le jeu"],
            ["resolve problemas simples", "escolhe entre opções", "usa ferramentas na brincadeira"],
            ["解决简单问题", "在选项中选择", "游戏中使用工具"]),
        tips: loc(
            "Offer two acceptable choices. It gives independence without turning every moment into a negotiation.",
            "Давайте два приемлемых выбора. Так появляется самостоятельность без постоянных переговоров.",
            "Biete zwei gute Optionen an. Das gibt Selbstständigkeit, ohne jeden Moment zu verhandeln.",
            "Ofrece dos opciones aceptables. Da independencia sin convertirlo todo en una negociación.",
            "Proposez deux choix acceptables. Cela donne de l’autonomie sans tout transformer en négociation.",
            "Ofereça duas escolhas aceitáveis. Dá autonomia sem transformar tudo numa negociação.",
            "提供两个都可以接受的选择。既给自主感，也避免每件事都变成拉扯。")
    ),
    DevelopmentLeap(
        scheduleID: 9,
        names: loc("Testing the Rules", "Проверяю правила", "Regeln testen", "Probando las reglas", "Tester les règles", "Testar as regras", "试探规则"),
        semanticColor: .mint, isDone: false, isCurrent: false,
        descriptions: loc(
            "starts noticing rules and reasons: why something is allowed, unsafe, fair, or not fair.",
            "начинает замечать правила и причины: почему что-то можно, опасно, честно или нечестно.",
            "bemerkt Regeln und Gründe: warum etwas erlaubt, unsicher, fair oder unfair ist.",
            "empieza a notar reglas y razones: por qué algo está permitido, es peligroso, justo o injusto.",
            "commence à remarquer les règles et les raisons : permis, dangereux, juste ou injuste.",
            "começa a notar regras e razões: porque algo é permitido, inseguro, justo ou injusto.",
            "开始注意规则和原因：为什么可以、不安全、公平或不公平。"),
        signsByLang: loc(
            ["asks why", "tests boundaries", "reacts strongly to fairness"],
            ["спрашивает «почему»", "проверяет границы", "остро реагирует на справедливость"],
            ["fragt warum", "testet Grenzen", "reagiert stark auf Fairness"],
            ["pregunta por qué", "pone límites a prueba", "reacciona mucho ante lo justo"],
            ["demande pourquoi", "teste les limites", "réagit fortement à l’équité"],
            ["pergunta porquê", "testa limites", "reage muito à justiça"],
            ["问为什么", "试探边界", "强烈在意公平"]),
        skillsByLang: loc(
            ["understands simple rules", "waits briefly", "names right and wrong"],
            ["понимает простые правила", "немного ждёт", "называет можно и нельзя"],
            ["versteht einfache Regeln", "wartet kurz", "benennt richtig und falsch"],
            ["entiende reglas simples", "espera un poco", "nombra lo correcto e incorrecto"],
            ["comprend des règles simples", "attend brièvement", "nomme le permis et l’interdit"],
            ["entende regras simples", "espera um pouco", "diz o que pode e não pode"],
            ["理解简单规则", "能短暂等待", "说出可以和不可以"]),
        tips: loc(
            "Keep rules short and the same every time: hot, stop, hands away. Repeating the same words makes them easier to remember.",
            "Держите правила короткими и одинаковыми: горячо, стоп, руки убираем. Одни и те же слова легче запомнить.",
            "Halte Regeln kurz und immer gleich: heiß, stopp, Hände weg. Dieselben Worte sind leichter zu merken.",
            "Mantén las reglas cortas y siempre iguales: quema, para, manos fuera. Las mismas palabras son más fáciles de recordar.",
            "Gardez des règles courtes et toujours identiques : chaud, stop, pas touche. Les mêmes mots sont plus faciles à retenir.",
            "Mantenha as regras curtas e sempre iguais: quente, para, mãos fora. As mesmas palavras são mais fáceis de lembrar.",
            "规则要简短、每次都一样：烫、停、手拿开。同样的词更容易记住。")
    ),
    DevelopmentLeap(
        scheduleID: 10,
        names: loc("My Own Way", "По-своему", "Auf meine Art", "A mi manera", "À ma façon", "À minha maneira", "我自己的方式"),
        semanticColor: .lilac, isDone: false, isCurrent: false,
        descriptions: loc(
            "connects roles, rules, and routines into little models of the world: family, shop, doctor, home.",
            "соединяет роли, правила и ритуалы в маленькие модели мира: семья, магазин, врач, дом.",
            "verbindet Rollen, Regeln und Routinen zu kleinen Weltmodellen: Familie, Laden, Arzt, Zuhause.",
            "conecta roles, reglas y rutinas en pequeños modelos del mundo: familia, tienda, médico, casa.",
            "relie rôles, règles et routines en petits modèles du monde : famille, magasin, médecin, maison.",
            "liga papéis, regras e rotinas em pequenos modelos do mundo: família, loja, médico, casa.",
            "把角色、规则和流程连接成小小的世界模型：家庭、商店、医生、家。"),
        signsByLang: loc(
            ["role-plays daily life", "assigns roles", "uses longer pretend stories"],
            ["играет в бытовые роли", "раздаёт роли", "придумывает более длинные сюжеты"],
            ["spielt Alltag nach", "verteilt Rollen", "erfindet längere Geschichten"],
            ["juega a la vida diaria", "asigna roles", "crea historias más largas"],
            ["joue les scènes du quotidien", "attribue des rôles", "invente des histoires plus longues"],
            ["brinca ao faz de conta diário", "atribui papéis", "cria histórias mais longas"],
            ["模仿日常生活", "分配角色", "假装游戏情节更长"]),
        skillsByLang: loc(
            ["plays doctor or shop", "combines several rules", "explains what happens next"],
            ["играет во врача или магазин", "сочетает несколько правил", "объясняет, что будет дальше"],
            ["spielt Arzt oder Laden", "kombiniert mehrere Regeln", "erklärt, was als Nächstes passiert"],
            ["juega al médico o a la tienda", "combina varias reglas", "explica qué pasa después"],
            ["joue au docteur ou au magasin", "combine plusieurs règles", "explique la suite"],
            ["brinca aos médicos ou às lojas", "combina várias regras", "explica o que vem a seguir"],
            ["玩医生或商店游戏", "组合多条规则", "解释接下来会发生什么"]),
        tips: loc(
            "Pretend play is a big part of this age. A toy kitchen, a doctor kit or blocks make great props.",
            "Ролевые игры сейчас занимают много места. Игрушечная кухня, набор врача или кубики — отличный реквизит.",
            "Rollenspiele sind in diesem Alter wichtig. Eine Spielküche, ein Arztkoffer oder Bauklötze sind tolle Requisiten.",
            "El juego simbólico ocupa mucho a esta edad. Una cocinita, un maletín de médico o bloques son un gran atrezo.",
            "Le jeu de faire-semblant prend beaucoup de place à cet âge. Une dînette, une mallette de docteur ou des cubes sont de parfaits accessoires.",
            "O faz-de-conta ocupa muito espaço nesta idade. Uma cozinha de brincar, um kit de médico ou blocos são ótimos adereços.",
            "这个年龄段，假装游戏很重要。玩具厨房、医生玩具套装或积木都是很好的道具。")
    ),
    ]
}
