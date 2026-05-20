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

    var defaultBlob: BlobKind {
        switch self {
        case .mom:     return .baby
        case .dad:     return .bear
        case .nanny:   return .sun
        case .grandma: return .heart
        }
    }

    var defaultTone: Color {
        switch self {
        case .mom:     return .bbCoral
        case .dad:     return .bbSky
        case .nanny:   return .bbMint
        case .grandma: return .bbLilac
        }
    }
}

struct FamilyMember: Identifiable {
    let id: UUID
    let name: String
    var role: FamilyRole
    let isMe: Bool
    var isOnline: Bool
    var activity: String
    let blob: BlobKind
    let tone: Color

    init(id: UUID = UUID(), name: String, role: FamilyRole, isMe: Bool,
         isOnline: Bool = false, activity: String = "", blob: BlobKind, tone: Color) {
        self.id = id
        self.name = name
        self.role = role
        self.isMe = isMe
        self.isOnline = isOnline
        self.activity = activity
        self.blob = blob
        self.tone = tone
    }
}


