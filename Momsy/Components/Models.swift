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
}

let sampleLeaps: [DevelopmentLeap] = [
    DevelopmentLeap(id: 1, week: 5,  name: "Мир ощущений",        tone: .bbRose,   isDone: true,  isCurrent: false, description: "", signs: [], skills: []),
    DevelopmentLeap(id: 2, week: 8,  name: "Мир узоров",          tone: .bbButter, isDone: true,  isCurrent: false, description: "", signs: [], skills: []),
    DevelopmentLeap(id: 3, week: 12, name: "Плавные движения",     tone: .bbMint,   isDone: true,  isCurrent: false, description: "", signs: [], skills: []),
    DevelopmentLeap(id: 4, week: 17, name: "Мир событий",          tone: .bbCoral,  isDone: false, isCurrent: true,
        description: "Лёва начинает понимать, что одно действие приводит к другому. Это огромная работа для мозга — отсюда плач и плохой сон.",
        signs: ["хуже спит", "требует рук", "капризничает", "отказ от еды"],
        skills: ["следит глазами", "хватает предметы", "узнаёт игрушку", "гулит на смех"]),
    DevelopmentLeap(id: 5, week: 26, name: "Отношения",            tone: .bbLilac,  isDone: false, isCurrent: false, description: "", signs: [], skills: []),
    DevelopmentLeap(id: 6, week: 36, name: "Категории",            tone: .bbSky,    isDone: false, isCurrent: false, description: "", signs: [], skills: []),
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
    let id = UUID()
    let dateLabel: String
    let ageLabel: String
    let items: [DiaryItem]
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

enum FamilyRole: String {
    case mom = "Мама"
    case dad = "Папа"
    case nanny = "Няня"
    case grandma = "Только смотреть"

    var description: String {
        switch self {
        case .mom:     return "полный доступ"
        case .dad:     return "полный доступ"
        case .nanny:   return "трекинг · без медицины"
        case .grandma: return "фото и статус"
        }
    }
}

struct FamilyMember: Identifiable {
    let id = UUID()
    let name: String
    let role: FamilyRole
    let isMe: Bool
    let isOnline: Bool
    let activity: String
    let blob: BlobKind
    let tone: Color
}

let sampleFamily: [FamilyMember] = [
    FamilyMember(name: "Аня",      role: .mom,     isMe: true,  isOnline: false, activity: "это вы",          blob: .baby,  tone: .bbCoral),
    FamilyMember(name: "Миша",     role: .dad,     isMe: false, isOnline: true,  activity: "онлайн",          blob: .bear,  tone: .bbSky),
    FamilyMember(name: "Ольга",    role: .nanny,   isMe: false, isOnline: false, activity: "3 записи сегодня", blob: .sun,   tone: .bbMint),
    FamilyMember(name: "Бабушка",  role: .grandma, isMe: false, isOnline: false, activity: "смотрит дневник", blob: .heart, tone: .bbLilac),
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

struct MeasurementEntry: Identifiable {
    let id = UUID()
    let dateLabel: String
    let weight: String
    let height: String
    let delta: String
    let visitLabel: String?
}

let sampleMeasurements: [MeasurementEntry] = [
    MeasurementEntry(dateLabel: "16 мая",  weight: "6.4 кг", height: "64 см", delta: "+ 280 г · 4 нед", visitLabel: nil),
    MeasurementEntry(dateLabel: "18 апр",  weight: "6.1 кг", height: "62 см", delta: "+ 400 г · 4 нед", visitLabel: nil),
    MeasurementEntry(dateLabel: "21 мар",  weight: "5.7 кг", height: "60 см", delta: "+ 700 г · 4 нед", visitLabel: "визит к врачу"),
    MeasurementEntry(dateLabel: "24 фев",  weight: "5.0 кг", height: "57 см", delta: "+ 900 г · 4 нед", visitLabel: nil),
]
