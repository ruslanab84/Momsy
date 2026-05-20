import SwiftUI

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
