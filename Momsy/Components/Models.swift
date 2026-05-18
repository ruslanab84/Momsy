import Foundation
import SwiftUI

// MARK: - Baby Age Stage

enum BabyAgeStage: String, CaseIterable, Identifiable {
    case newborn, baby, eat, toddler, kid
    var id: String { rawValue }

    var label: String {
        switch self {
        case .newborn: return "0–3 мес"
        case .baby:    return "3–6 мес"
        case .eat:     return "6–12 мес"
        case .toddler: return "1–2 года"
        case .kid:     return "2+"
        }
    }
    var labelEn: String {
        switch self {
        case .newborn: return "0–3 mo"
        case .baby:    return "3–6 mo"
        case .eat:     return "6–12 mo"
        case .toddler: return "1–2 yr"
        case .kid:     return "2+"
        }
    }
    var subtitle: String {
        switch self {
        case .newborn: return "Новорождённый"
        case .baby:    return "Малыш"
        case .eat:     return "Прикорм"
        case .toddler: return "Карапуз"
        case .kid:     return "Маленький человек"
        }
    }
    var subtitleEn: String {
        switch self {
        case .newborn: return "Newborn"
        case .baby:    return "Baby"
        case .eat:     return "Solids"
        case .toddler: return "Toddler"
        case .kid:     return "Little one"
        }
    }
    var focus: String {
        switch self {
        case .newborn: return "Кормление, сон, подгузники"
        case .baby:    return "Скачки, режим, развитие"
        case .eat:     return "+ Прикорм и пищевой дневник"
        case .toddler: return "+ Режим дня, активности"
        case .kid:     return "Гибкий режим, здоровье"
        }
    }
    var focusEn: String {
        switch self {
        case .newborn: return "Feeding, sleep, diapers"
        case .baby:    return "Leaps, routine, development"
        case .eat:     return "+ Solid foods & food diary"
        case .toddler: return "+ Daily routine, activities"
        case .kid:     return "Flexible routine, health"
        }
    }
    var blobKind: BlobKind {
        switch self {
        case .newborn: return .sleep
        case .baby:    return .baby
        case .eat:     return .bottle
        case .toddler: return .bear
        case .kid:     return .star
        }
    }
    var tone: Color {
        switch self {
        case .newborn: return .bbRose
        case .baby:    return .bbButter
        case .eat:     return .bbMint
        case .toddler: return .bbLilac
        case .kid:     return .bbSky
        }
    }
}

// MARK: - Feeding

enum FeedingSide: String, CaseIterable {
    case left   = "Левая"
    case right  = "Правая"
    case bottle = "Бутылка"

    func displayName(lang: String) -> String {
        switch self {
        case .left:   return lang == "en" ? "Left"   : rawValue
        case .right:  return lang == "en" ? "Right"  : rawValue
        case .bottle: return lang == "en" ? "Bottle" : rawValue
        }
    }
}

struct FeedingEntry: Identifiable {
    let id = UUID()
    let time: String
    let duration: Int
    let side: FeedingSide
}

// MARK: - Development Leaps

struct DevelopmentLeap: Identifiable {
    let id: Int
    let week: Int
    let name: String
    let nameEn: String
    let tone: Color
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
        tone: .bbRose, isDone: true, isCurrent: false,
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
        tone: .bbButter, isDone: true, isCurrent: false,
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
        tone: .bbMint, isDone: true, isCurrent: false,
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
        tone: .bbCoral, isDone: false, isCurrent: true,
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
        tone: .bbLilac, isDone: false, isCurrent: false,
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
        tone: .bbSky, isDone: false, isCurrent: false,
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

// MARK: - Diary

enum DiaryItemType {
    case photo(tone: Color, handwriting: String, isMilestone: Bool)
    case note(text: String)
    case milestone(icon: BlobKind, label: String)
}

struct DiaryItem: Identifiable {
    let id = UUID()
    let type: DiaryItemType
}

struct DiaryDay: Identifiable {
    var id: String { dateLabel }
    let dateLabel: String
    let ageLabel: String
    var items: [DiaryItem]
}

let sampleDiary: [DiaryDay] = [
    DiaryDay(dateLabel: "Today · Tue", ageLabel: "4 mo 12 d", items: [
        DiaryItem(type: .photo(tone: .bbCoral, handwriting: "First time\nrolled over!", isMilestone: true)),
        DiaryItem(type: .note(text: "Smiled a long time at grandpa on video call.")),
    ]),
    DiaryDay(dateLabel: "Yesterday · Mon", ageLabel: "4 mo 11 d", items: [
        DiaryItem(type: .milestone(icon: .star, label: "Holds head up for 30 sec")),
        DiaryItem(type: .photo(tone: .bbButter, handwriting: "morning\nin arms", isMilestone: false)),
    ]),
    DiaryDay(dateLabel: "Sat 13 May", ageLabel: "4 mo 9 d", items: [
        DiaryItem(type: .photo(tone: .bbMint, handwriting: "bath time", isMilestone: false)),
        DiaryItem(type: .note(text: "Temperature 37.8° by night. Drooling — teething?")),
        DiaryItem(type: .photo(tone: .bbLilac, handwriting: "falling asleep", isMilestone: false)),
    ]),
]

// MARK: - Family

enum FamilyRole: String, CaseIterable, Identifiable {
    case mom     = "Мама"
    case dad     = "Папа"
    case nanny   = "Няня"
    case grandma = "Бабушка"

    var id: String { rawValue }

    var displayNameEn: String {
        switch self {
        case .mom:     return "Mom"
        case .dad:     return "Dad"
        case .nanny:   return "Nanny"
        case .grandma: return "Grandma"
        }
    }

    func displayName(lang: String) -> String {
        lang == "en" ? displayNameEn : rawValue
    }

    var description: String {
        switch self {
        case .mom:     return "полный доступ"
        case .dad:     return "полный доступ"
        case .nanny:   return "трекинг · без медицины"
        case .grandma: return "только фото и статус"
        }
    }

    var descriptionEn: String {
        switch self {
        case .mom:     return "full access"
        case .dad:     return "full access"
        case .nanny:   return "tracking · no medical"
        case .grandma: return "photos and status only"
        }
    }

    func roleDescription(lang: String) -> String {
        lang == "en" ? descriptionEn : description
    }

    var icon: String {
        switch self {
        case .mom:     return "person.fill"
        case .dad:     return "person.fill"
        case .nanny:   return "hands.and.sparkles.fill"
        case .grandma: return "eyes"
        }
    }
}

struct FamilyMember: Identifiable {
    let id = UUID()
    let name: String
    var role: FamilyRole
    let isMe: Bool
    var isOnline: Bool
    var activity: String
    let blob: BlobKind
    let tone: Color
}

let sampleFamily: [FamilyMember] = [
    FamilyMember(name: "Anya",    role: .mom,     isMe: true,  isOnline: false, activity: "that's you",       blob: .baby,  tone: .bbCoral),
    FamilyMember(name: "Misha",   role: .dad,     isMe: false, isOnline: true,  activity: "online",            blob: .bear,  tone: .bbSky),
    FamilyMember(name: "Olga",    role: .nanny,   isMe: false, isOnline: false, activity: "3 entries today",   blob: .sun,   tone: .bbMint),
    FamilyMember(name: "Grandma", role: .grandma, isMe: false, isOnline: false, activity: "viewing diary",     blob: .heart, tone: .bbLilac),
]

// MARK: - Sounds

struct SoundItem: Identifiable {
    let id = UUID()
    let name: String
    let nameEn: String
    let category: String
    let categoryEn: String
    var isPlaying: Bool = false

    func displayName(lang: String) -> String    { lang == "en" ? nameEn     : name }
    func displayCategory(lang: String) -> String { lang == "en" ? categoryEn : category }
}

let sampleSounds: [SoundItem] = [
    SoundItem(name: "Утроба",       nameEn: "Womb",        category: "белый шум",         categoryEn: "white noise"),
    SoundItem(name: "Дождь",        nameEn: "Rain",        category: "природа",           categoryEn: "nature"),
    SoundItem(name: "Фен",          nameEn: "Hair dryer",  category: "розовый шум",       categoryEn: "pink noise"),
    SoundItem(name: "Колыбельная",  nameEn: "Lullaby",     category: "мелодия",           categoryEn: "melody"),
    SoundItem(name: "Сердцебиение", nameEn: "Heartbeat",   category: "для новорождённых", categoryEn: "for newborns"),
    SoundItem(name: "Океан",        nameEn: "Ocean",       category: "природа",           categoryEn: "nature"),
    SoundItem(name: "Лес",          nameEn: "Forest",      category: "природа",           categoryEn: "nature"),
    SoundItem(name: "Ручей",        nameEn: "Brook",       category: "природа",           categoryEn: "nature"),
]

// MARK: - Weight / Health Data

struct WeightPoint: Identifiable {
    let id = UUID()
    let month: Int
    let babyKg: Double
    let p15: Double
    let p50: Double
    let p85: Double
}

let sampleWeightData: [WeightPoint] = [
    WeightPoint(month: 0, babyKg: 3.2, p15: 2.8, p50: 3.3, p85: 3.9),
    WeightPoint(month: 1, babyKg: 4.1, p15: 3.9, p50: 4.5, p85: 5.1),
    WeightPoint(month: 2, babyKg: 5.0, p15: 4.7, p50: 5.6, p85: 6.5),
    WeightPoint(month: 3, babyKg: 5.7, p15: 5.3, p50: 6.4, p85: 7.4),
    WeightPoint(month: 4, babyKg: 6.1, p15: 5.8, p50: 7.0, p85: 8.1),
    WeightPoint(month: 5, babyKg: 6.4, p15: 6.2, p50: 7.5, p85: 8.7),
]

let sampleHeightData: [WeightPoint] = [
    WeightPoint(month: 0, babyKg: 50.0, p15: 46.1, p50: 49.1, p85: 52.0),
    WeightPoint(month: 1, babyKg: 53.0, p15: 50.2, p50: 53.7, p85: 57.2),
    WeightPoint(month: 2, babyKg: 57.0, p15: 53.2, p50: 57.1, p85: 60.9),
    WeightPoint(month: 3, babyKg: 60.0, p15: 55.8, p50: 59.8, p85: 63.8),
    WeightPoint(month: 4, babyKg: 62.0, p15: 57.8, p50: 62.1, p85: 66.4),
    WeightPoint(month: 5, babyKg: 64.0, p15: 59.6, p50: 64.0, p85: 68.5),
]

let sampleHeadData: [WeightPoint] = [
    WeightPoint(month: 0, babyKg: 34.0, p15: 32.5, p50: 34.5, p85: 36.5),
    WeightPoint(month: 1, babyKg: 36.5, p15: 34.5, p50: 36.5, p85: 38.5),
    WeightPoint(month: 2, babyKg: 38.0, p15: 36.0, p50: 38.0, p85: 40.0),
    WeightPoint(month: 3, babyKg: 40.0, p15: 37.5, p50: 39.5, p85: 41.5),
    WeightPoint(month: 4, babyKg: 41.5, p15: 38.5, p50: 40.5, p85: 42.5),
    WeightPoint(month: 5, babyKg: 42.0, p15: 39.5, p50: 41.5, p85: 43.5),
]

struct MeasurementEntry: Identifiable {
    let id = UUID()
    let dateLabel: String
    let weight: String
    let height: String
    let headCirc: String
    let delta: String
    let visitLabel: String?
}

let sampleMeasurements: [MeasurementEntry] = [
    MeasurementEntry(dateLabel: "16 May",  weight: "6.4 kg", height: "64 cm", headCirc: "42.0 cm", delta: "+ 280 g · 4 wk", visitLabel: nil),
    MeasurementEntry(dateLabel: "18 Apr",  weight: "6.1 kg", height: "62 cm", headCirc: "41.5 cm", delta: "+ 400 g · 4 wk", visitLabel: nil),
    MeasurementEntry(dateLabel: "21 Mar",  weight: "5.7 kg", height: "60 cm", headCirc: "40.0 cm", delta: "+ 700 g · 4 wk", visitLabel: "doctor visit"),
    MeasurementEntry(dateLabel: "24 Feb",  weight: "5.0 kg", height: "57 cm", headCirc: "38.0 cm", delta: "+ 900 g · 4 wk", visitLabel: nil),
]

// MARK: - Temperature

struct TemperatureEntry: Identifiable {
    let id = UUID()
    let dateLabel: String
    let timeLabel: String
    let value: Double
    var note: String
}

let sampleTempLog: [TemperatureEntry] = [
    TemperatureEntry(dateLabel: "16 May", timeLabel: "18:30", value: 36.7, note: "evening"),
    TemperatureEntry(dateLabel: "13 May", timeLabel: "22:00", value: 37.8, note: "night, teething"),
    TemperatureEntry(dateLabel: "13 May", timeLabel: "18:15", value: 37.4, note: "before sleep"),
    TemperatureEntry(dateLabel: "10 May", timeLabel: "09:00", value: 36.6, note: "morning"),
    TemperatureEntry(dateLabel: "5 May",  timeLabel: "20:10", value: 36.8, note: ""),
]
