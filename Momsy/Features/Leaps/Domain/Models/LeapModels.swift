import Foundation

struct DevelopmentLeap: Identifiable {
    let id: Int
    let week: Int
    let name: String
    let nameEn: String
    let semanticColor: SemanticColor
    let isDone: Bool
    let isCurrent: Bool
    let description: String
    let descriptionEn: String
    let signs: [String]
    let signsEn: [String]
    let skills: [String]
    let skillsEn: [String]
    let tip: String
    let tipEn: String
}

let sampleLeaps: [DevelopmentLeap] = [
    DevelopmentLeap(
        id: 1, week: 5,
        name: "Мир ощущений", nameEn: "World of Senses",
        semanticColor: .rose, isDone: true, isCurrent: false,
        description: "учится обрабатывать сигналы от органов чувств — звуки, свет, прикосновения воспринимаются по-новому.",
        descriptionEn: "is learning to process sensory signals — sounds, light, and touch feel entirely new.",
        signs: ["много спит", "вздрагивает от звуков", "ищет источник света"],
        signsEn: ["sleeps a lot", "startles at sounds", "seeks light sources"],
        skills: ["отличает голос мамы", "реагирует на свет", "успокаивается на руках"],
        skillsEn: ["recognises mum's voice", "reacts to light", "calms in arms"],
        tip: "Разговаривайте спокойным голосом и избегайте резких звуков — слуховая система ещё настраивается.",
        tipEn: "Speak in a calm voice and avoid sudden sounds — the auditory system is still calibrating."
    ),
    DevelopmentLeap(
        id: 2, week: 8,
        name: "Мир узоров", nameEn: "World of Patterns",
        semanticColor: .butter, isDone: true, isCurrent: false,
        description: "начинает распознавать регулярные образы — черты лица, ритмы, простые геометрические формы.",
        descriptionEn: "begins recognising regular patterns — faces, rhythms, and simple geometric shapes.",
        signs: ["долго смотрит на лица", "замирает на паттернах", "больше гулит"],
        signsEn: ["stares at faces a long time", "fixates on patterns", "more cooing"],
        skills: ["улыбается в ответ", "следит взглядом", "издаёт гласные звуки"],
        skillsEn: ["smiles back", "tracks with eyes", "makes vowel sounds"],
        tip: "Показывайте чёрно-белые картинки — контраст стимулирует зрительную кору.",
        tipEn: "Show black-and-white pictures — contrast stimulates the visual cortex."
    ),
    DevelopmentLeap(
        id: 3, week: 12,
        name: "Плавные движения", nameEn: "Smooth Transitions",
        semanticColor: .mint, isDone: true, isCurrent: false,
        description: "обнаруживает, что может управлять своим телом — руки, ноги, голова начинают двигаться плавно и осознанно.",
        descriptionEn: "discovers the ability to control their body — arms, legs, and head start moving smoothly and intentionally.",
        signs: ["подолгу изучает руки", "тянет предметы в рот", "много двигает ногами"],
        signsEn: ["studies hands at length", "brings objects to mouth", "moves legs a lot"],
        skills: ["захватывает погремушку", "удерживает голову", "переворачивается набок"],
        skillsEn: ["grasps a rattle", "holds head up", "rolls to the side"],
        tip: "Время на животике каждый день укрепляет шею и спину — это фундамент для переворотов.",
        tipEn: "Daily tummy time strengthens the neck and back — the foundation for rolling over."
    ),
    DevelopmentLeap(
        id: 4, week: 17,
        name: "Мир событий", nameEn: "World of Events",
        semanticColor: .coral, isDone: false, isCurrent: true,
        description: "начинает понимать, что одно действие приводит к другому. Это огромная работа для мозга — отсюда плач и плохой сон.",
        descriptionEn: "begins to understand that one action leads to another. This is enormous brain work — hence the crying and poor sleep.",
        signs: ["хуже спит", "требует рук", "капризничает", "отказ от еды"],
        signsEn: ["poor sleep", "wants to be held", "fussy", "refuses food"],
        skills: ["следит глазами", "хватает предметы", "узнаёт игрушку", "гулит на смех"],
        skillsEn: ["tracks with eyes", "grabs objects", "recognises toys", "coos at laughter"],
        tip: "Покажите нажимаемую игрушку или чёрно-белую книжку — «причина → следствие» особенно увлекает в этот скачок.",
        tipEn: "Show a press-toy or black-and-white book — cause and effect is especially fascinating during this leap."
    ),
    DevelopmentLeap(
        id: 5, week: 26,
        name: "Отношения", nameEn: "Relationships",
        semanticColor: .lilac, isDone: false, isCurrent: false,
        description: "открывает мир связей между людьми и предметами. Тревога разлуки — нормальное и важное явление этого этапа.",
        descriptionEn: "discovers the world of connections between people and objects. Separation anxiety is a normal and important part of this stage.",
        signs: ["тревога при расставании", "предпочитает маму", "проверяет вашу реакцию"],
        signsEn: ["separation anxiety", "prefers mum", "tests your reaction"],
        skills: ["играет в «ку-ку»", "машет «пока»", "подражает звукам и жестам"],
        skillsEn: ["plays peek-a-boo", "waves bye-bye", "imitates sounds and gestures"],
        tip: "Игра «ку-ку» помогает освоить концепцию постоянства объектов — главный навык этого скачка.",
        tipEn: "Peek-a-boo helps master object permanence — the key skill of this leap."
    ),
    DevelopmentLeap(
        id: 6, week: 36,
        name: "Категории", nameEn: "Categories",
        semanticColor: .sky, isDone: false, isCurrent: false,
        description: "начинает группировать вещи по свойствам: цвет, форма, размер. Активно изучает мир через классификацию.",
        descriptionEn: "begins grouping things by properties: colour, shape, size. Actively explores the world through classification.",
        signs: ["сортирует игрушки", "дольше играет самостоятельно", "разбирает всё подряд"],
        signsEn: ["sorts toys", "plays alone for longer", "takes everything apart"],
        skills: ["понимает «большой/маленький»", "складывает предметы в ёмкость", "откликается на имя"],
        skillsEn: ["understands 'big/small'", "puts objects in a container", "responds to name"],
        tip: "Сортеры, стаканчики, вкладыши — идеальные игрушки. Называйте свойства: «красный», «большой», «тяжёлый».",
        tipEn: "Sorters, cups, nesting toys — ideal. Name properties: 'red', 'big', 'heavy'."
    ),
]
