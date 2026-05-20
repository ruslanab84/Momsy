import SwiftUI

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
    FamilyMember(name: "Anya",    role: .mom,     isMe: true,  isOnline: false, activity: "that's you",     blob: .baby,  tone: .bbCoral),
    FamilyMember(name: "Misha",   role: .dad,     isMe: false, isOnline: true,  activity: "online",          blob: .bear,  tone: .bbSky),
    FamilyMember(name: "Olga",    role: .nanny,   isMe: false, isOnline: false, activity: "3 entries today", blob: .sun,   tone: .bbMint),
    FamilyMember(name: "Grandma", role: .grandma, isMe: false, isOnline: false, activity: "viewing diary",   blob: .heart, tone: .bbLilac),
]
