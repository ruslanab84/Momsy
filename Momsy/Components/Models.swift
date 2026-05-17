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
    var subtitle: String {
        switch self {
        case .newborn: return "Новорождённый"
        case .baby:    return "Малыш"
        case .eat:     return "Прикорм"
        case .toddler: return "Карапуз"
        case .kid:     return "Маленький человек"
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
    case left = "Левая"
    case right = "Правая"
    case bottle = "Бутылка"
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
    let tone: Color
    let isDone: Bool
    let isCurrent: Bool
    let description: String
    let signs: [String]
    let skills: [String]
    let tip: String
}

let sampleLeaps: [DevelopmentLeap] = [
    DevelopmentLeap(
        id: 1, week: 5, name: "Мир ощущений",
        tone: .bbRose, isDone: true, isCurrent: false,
        description: "учится обрабатывать сигналы от органов чувств — звуки, свет, прикосновения воспринимаются по-новому.",
        signs: ["много спит", "вздрагивает от звуков", "ищет источник света"],
        skills: ["отличает голос мамы", "реагирует на свет", "успокаивается на руках"],
        tip: "Разговаривайте спокойным голосом и избегайте резких звуков — слуховая система ещё настраивается."
    ),
    DevelopmentLeap(
        id: 2, week: 8, name: "Мир узоров",
        tone: .bbButter, isDone: true, isCurrent: false,
        description: "начинает распознавать регулярные образы — черты лица, ритмы, простые геометрические формы.",
        signs: ["долго смотрит на лица", "замирает на паттернах", "больше гулит"],
        skills: ["улыбается в ответ", "следит взглядом", "издаёт гласные звуки"],
        tip: "Показывайте чёрно-белые картинки — контраст стимулирует зрительную кору."
    ),
    DevelopmentLeap(
        id: 3, week: 12, name: "Плавные движения",
        tone: .bbMint, isDone: true, isCurrent: false,
        description: "обнаруживает, что может управлять своим телом — руки, ноги, голова начинают двигаться плавно и осознанно.",
        signs: ["подолгу изучает руки", "тянет предметы в рот", "много двигает ногами"],
        skills: ["захватывает погремушку", "удерживает голову", "переворачивается набок"],
        tip: "Время на животике каждый день укрепляет шею и спину — это фундамент для переворотов."
    ),
    DevelopmentLeap(
        id: 4, week: 17, name: "Мир событий",
        tone: .bbCoral, isDone: false, isCurrent: true,
        description: "начинает понимать, что одно действие приводит к другому. Это огромная работа для мозга — отсюда плач и плохой сон.",
        signs: ["хуже спит", "требует рук", "капризничает", "отказ от еды"],
        skills: ["следит глазами", "хватает предметы", "узнаёт игрушку", "гулит на смех"],
        tip: "Покажите нажимаемую игрушку или чёрно-белую книжку — «причина → следствие» особенно увлекает в этот скачок."
    ),
    DevelopmentLeap(
        id: 5, week: 26, name: "Отношения",
        tone: .bbLilac, isDone: false, isCurrent: false,
        description: "открывает мир связей между людьми и предметами. Тревога разлуки — нормальное и важное явление этого этапа.",
        signs: ["тревога при расставании", "предпочитает маму", "проверяет вашу реакцию"],
        skills: ["играет в «ку-ку»", "машет «пока»", "подражает звукам и жестам"],
        tip: "Игра «ку-ку» помогает освоить концепцию постоянства объектов — главный навык этого скачка."
    ),
    DevelopmentLeap(
        id: 6, week: 36, name: "Категории",
        tone: .bbSky, isDone: false, isCurrent: false,
        description: "начинает группировать вещи по свойствам: цвет, форма, размер. Активно изучает мир через классификацию.",
        signs: ["сортирует игрушки", "дольше играет самостоятельно", "разбирает всё подряд"],
        skills: ["понимает «большой/маленький»", "складывает предметы в ёмкость", "откликается на имя"],
        tip: "Сортеры, стаканчики, вкладыши — идеальные игрушки. Называйте свойства: «красный», «большой», «тяжёлый»."
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
    DiaryDay(dateLabel: "Сегодня · вт", ageLabel: "4 мес 12 дн", items: [
        DiaryItem(type: .photo(tone: .bbCoral, handwriting: "Первый раз\nперевернулся!", isMilestone: true)),
        DiaryItem(type: .note(text: "Долго улыбался деду по видео. Запомнили.")),
    ]),
    DiaryDay(dateLabel: "Вчера · пн", ageLabel: "4 мес 11 дн", items: [
        DiaryItem(type: .milestone(icon: .star, label: "Удерживает голову 30 сек")),
        DiaryItem(type: .photo(tone: .bbButter, handwriting: "утро\nна руках", isMilestone: false)),
    ]),
    DiaryDay(dateLabel: "Сб 13 мая", ageLabel: "4 мес 9 дн", items: [
        DiaryItem(type: .photo(tone: .bbMint, handwriting: "купались", isMilestone: false)),
        DiaryItem(type: .note(text: "Температура 37.8° к ночи. Слюна — режутся зубы?")),
        DiaryItem(type: .photo(tone: .bbLilac, handwriting: "засыпает", isMilestone: false)),
    ]),
]

// MARK: - Family

enum FamilyRole: String, CaseIterable, Identifiable {
    case mom     = "Мама"
    case dad     = "Папа"
    case nanny   = "Няня"
    case grandma = "Бабушка"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .mom:     return "полный доступ"
        case .dad:     return "полный доступ"
        case .nanny:   return "трекинг · без медицины"
        case .grandma: return "только фото и статус"
        }
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
    FamilyMember(name: "Аня",      role: .mom,     isMe: true,  isOnline: false, activity: "это вы",          blob: .baby,  tone: .bbCoral),
    FamilyMember(name: "Миша",     role: .dad,     isMe: false, isOnline: true,  activity: "онлайн",          blob: .bear,  tone: .bbSky),
    FamilyMember(name: "Ольга",    role: .nanny,   isMe: false, isOnline: false, activity: "3 записи сегодня", blob: .sun,   tone: .bbMint),
    FamilyMember(name: "Бабушка", role: .grandma, isMe: false, isOnline: false, activity: "смотрит дневник", blob: .heart, tone: .bbLilac),
]

// MARK: - Sounds

struct SoundItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let tone: Color
    var isPlaying: Bool = false
}

let sampleSounds: [SoundItem] = [
    SoundItem(name: "Утроба",       category: "белый шум",          tone: .bbCoral,  isPlaying: true),
    SoundItem(name: "Дождь",        category: "природа",            tone: .bbSky),
    SoundItem(name: "Фен",          category: "розовый шум",        tone: .bbLilac),
    SoundItem(name: "Колыбельная",  category: "мелодия",            tone: .bbButter),
    SoundItem(name: "Сердцебиение", category: "для новорождённых",  tone: .bbRose),
    SoundItem(name: "Океан",        category: "природа",            tone: .bbMint),
]

// MARK: - Weight Data

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

// Height in cm — reusing WeightPoint (babyKg = cm value)
let sampleHeightData: [WeightPoint] = [
    WeightPoint(month: 0, babyKg: 50.0, p15: 46.1, p50: 49.1, p85: 52.0),
    WeightPoint(month: 1, babyKg: 53.0, p15: 50.2, p50: 53.7, p85: 57.2),
    WeightPoint(month: 2, babyKg: 57.0, p15: 53.2, p50: 57.1, p85: 60.9),
    WeightPoint(month: 3, babyKg: 60.0, p15: 55.8, p50: 59.8, p85: 63.8),
    WeightPoint(month: 4, babyKg: 62.0, p15: 57.8, p50: 62.1, p85: 66.4),
    WeightPoint(month: 5, babyKg: 64.0, p15: 59.6, p50: 64.0, p85: 68.5),
]

// Head circumference in cm — reusing WeightPoint (babyKg = cm value)
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
    MeasurementEntry(dateLabel: "16 мая", weight: "6.4 кг", height: "64 см", headCirc: "42.0 см", delta: "+ 280 г · 4 нед", visitLabel: nil),
    MeasurementEntry(dateLabel: "18 апр", weight: "6.1 кг", height: "62 см", headCirc: "41.5 см", delta: "+ 400 г · 4 нед", visitLabel: nil),
    MeasurementEntry(dateLabel: "21 мар", weight: "5.7 кг", height: "60 см", headCirc: "40.0 см", delta: "+ 700 г · 4 нед", visitLabel: "визит к врачу"),
    MeasurementEntry(dateLabel: "24 фев", weight: "5.0 кг", height: "57 см", headCirc: "38.0 см", delta: "+ 900 г · 4 нед", visitLabel: nil),
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
    TemperatureEntry(dateLabel: "16 мая", timeLabel: "18:30", value: 36.7, note: "вечер"),
    TemperatureEntry(dateLabel: "13 мая", timeLabel: "22:00", value: 37.8, note: "ночь, прорезывание"),
    TemperatureEntry(dateLabel: "13 мая", timeLabel: "18:15", value: 37.4, note: "перед сном"),
    TemperatureEntry(dateLabel: "10 мая", timeLabel: "09:00", value: 36.6, note: "утро"),
    TemperatureEntry(dateLabel: "5 мая",  timeLabel: "20:10", value: 36.8, note: ""),
]
