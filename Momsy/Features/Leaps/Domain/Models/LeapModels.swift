import Foundation

struct DevelopmentLeap: Identifiable {
    let id: Int
    let week: Int
    /// Typical length of this leap's fussy / "stormy" stretch, in days.
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
        id: 1, week: 5, hardDays: 7,
        names: loc("World of Senses", "Мир ощущений", "Welt der Sinne", "Mundo de los sentidos", "Monde des sensations", "Mundo dos sentidos", "感官世界"),
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
            "Speak in a calm voice and avoid sudden sounds — the auditory system is still calibrating.",
            "Разговаривайте спокойным голосом и избегайте резких звуков — слуховая система ещё настраивается.",
            "Sprich mit ruhiger Stimme und vermeide plötzliche Geräusche — das Gehör stellt sich noch ein.",
            "Habla con voz tranquila y evita los sonidos bruscos: el sistema auditivo todavía se está calibrando.",
            "Parlez d’une voix calme et évitez les bruits soudains — le système auditif se règle encore.",
            "Fale com voz calma e evite sons bruscos — o sistema auditivo ainda se está a calibrar.",
            "用平静的声音说话，避免突然的响声——听觉系统还在校准中。")
    ),
    DevelopmentLeap(
        id: 2, week: 8, hardDays: 7,
        names: loc("World of Patterns", "Мир узоров", "Welt der Muster", "Mundo de los patrones", "Monde des motifs", "Mundo dos padrões", "图案世界"),
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
            "Show black-and-white pictures — contrast stimulates the visual cortex.",
            "Показывайте чёрно-белые картинки — контраст стимулирует зрительную кору.",
            "Zeige Schwarz-Weiß-Bilder — Kontraste regen den visuellen Kortex an.",
            "Muéstrale imágenes en blanco y negro: el contraste estimula la corteza visual.",
            "Montrez des images en noir et blanc — le contraste stimule le cortex visuel.",
            "Mostre imagens a preto e branco — o contraste estimula o córtex visual.",
            "给宝宝看黑白图片——对比能刺激视觉皮层。")
    ),
    DevelopmentLeap(
        id: 3, week: 12, hardDays: 7,
        names: loc("Smooth Transitions", "Плавные движения", "Fließende Bewegungen", "Movimientos suaves", "Mouvements fluides", "Movimentos suaves", "顺畅的动作"),
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
            "Daily tummy time strengthens the neck and back — the foundation for rolling over.",
            "Время на животике каждый день укрепляет шею и спину — это фундамент для переворотов.",
            "Tägliche Bauchlage stärkt Nacken und Rücken — die Grundlage fürs Drehen.",
            "El tiempo boca abajo a diario fortalece el cuello y la espalda: la base para darse la vuelta.",
            "Le temps quotidien sur le ventre renforce le cou et le dos — la base pour se retourner.",
            "O tempo de barriga para baixo diário fortalece o pescoço e as costas — a base para rolar.",
            "每天的趴卧能锻炼颈部和背部——这是翻身的基础。")
    ),
    DevelopmentLeap(
        id: 4, week: 17, hardDays: 28,
        names: loc("World of Events", "Мир событий", "Welt der Ereignisse", "Mundo de los acontecimientos", "Monde des événements", "Mundo dos acontecimentos", "事件世界"),
        semanticColor: .coral, isDone: false, isCurrent: true,
        descriptions: loc(
            "begins to understand that one action leads to another. This is enormous brain work — hence the crying and poor sleep.",
            "начинает понимать, что одно действие приводит к другому. Это огромная работа для мозга — отсюда плач и плохой сон.",
            "beginnt zu verstehen, dass eine Handlung zur nächsten führt. Das ist enorme Gehirnarbeit — daher das Weinen und der schlechte Schlaf.",
            "empieza a entender que una acción lleva a otra. Es un trabajo cerebral enorme: de ahí el llanto y el mal sueño.",
            "commence à comprendre qu’une action en entraîne une autre. C’est un travail cérébral énorme — d’où les pleurs et le sommeil agité.",
            "começa a perceber que uma ação leva a outra. É um trabalho cerebral enorme — daí o choro e o sono agitado.",
            "开始明白一个动作会引发另一个动作。这是大脑的巨大工作——所以才会哭闹和睡不好。"),
        signsByLang: loc(
            ["poor sleep", "wants to be held", "fussy", "refuses food"],
            ["хуже спит", "требует рук", "капризничает", "отказ от еды"],
            ["schlechter Schlaf", "will getragen werden", "quengelig", "verweigert Essen"],
            ["duerme mal", "quiere brazos", "irritable", "rechaza la comida"],
            ["sommeil agité", "réclame les bras", "grognon", "refuse de manger"],
            ["sono agitado", "quer colo", "irritado", "recusa comida"],
            ["睡得不好", "想被抱着", "爱闹脾气", "拒绝吃东西"]),
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
        id: 5, week: 26, hardDays: 28,
        names: loc("Relationships", "Отношения", "Beziehungen", "Relaciones", "Relations", "Relações", "关系"),
        semanticColor: .lilac, isDone: false, isCurrent: false,
        descriptions: loc(
            "discovers the world of connections between people and objects. Separation anxiety is a normal and important part of this stage.",
            "открывает мир связей между людьми и предметами. Тревога разлуки — нормальное и важное явление этого этапа.",
            "entdeckt die Welt der Verbindungen zwischen Menschen und Dingen. Trennungsangst ist ein normaler und wichtiger Teil dieser Phase.",
            "descubre el mundo de las conexiones entre las personas y los objetos. La ansiedad por separación es una parte normal e importante de esta etapa.",
            "découvre le monde des liens entre les personnes et les objets. L’angoisse de la séparation est une étape normale et importante.",
            "descobre o mundo das ligações entre as pessoas e os objetos. A ansiedade de separação é uma parte normal e importante desta fase.",
            "开始发现人与物之间联系的世界。分离焦虑是这个阶段正常而重要的一部分。"),
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
            "Peek-a-boo helps master object permanence — the key skill of this leap.",
            "Игра «ку-ку» помогает освоить концепцию постоянства объектов — главный навык этого скачка.",
            "Kuckuck hilft, die Objektpermanenz zu meistern — die Schlüsselfähigkeit dieses Schubs.",
            "El cucú-tras ayuda a dominar la permanencia del objeto: la habilidad clave de este salto.",
            "Le jeu de coucou aide à maîtriser la permanence de l’objet — la compétence clé de ce bond.",
            "O jogo das escondidas ajuda a dominar a permanência do objeto — a competência-chave deste salto.",
            "躲猫猫有助于掌握客体永存——这是这个猛长期的关键能力。")
    ),
    DevelopmentLeap(
        id: 6, week: 36, hardDays: 35,
        names: loc("Categories", "Категории", "Kategorien", "Categorías", "Catégories", "Categorias", "分类"),
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
    ]
}
