import SwiftUI

enum FamilyRole: String, CaseIterable, Codable, Identifiable {
    case mom     = "Мама"
    case dad     = "Папа"
    case nanny   = "Няня"
    case grandma = "Бабушка"

    var id: String { rawValue }

    init?(storedRawValue: String) {
        if let role = FamilyRole(rawValue: storedRawValue) {
            self = role
            return
        }

        switch storedRawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "mom", "mama", "mother", "parent", "мама":
            self = .mom
        case "dad", "papa", "father", "папа":
            self = .dad
        case "nanny", "няня":
            self = .nanny
        case "grandma", "grandmother", "бабушка":
            self = .grandma
        default:
            return nil
        }
    }

    func displayName(_ strings: L10n) -> String {
        switch self {
        case .mom:     return strings.roleMom
        case .dad:     return strings.roleDad
        case .nanny:   return strings.roleNanny
        case .grandma: return strings.roleGrandma
        }
    }

    func displayName(lang: String) -> String {
        displayName(L10n(Language.from(lang)))
    }

    func roleDescription(_ strings: L10n) -> String {
        switch self {
        case .mom, .dad: return strings.roleFullAccess
        case .nanny:     return strings.roleTrackingNoMedical
        case .grandma:   return strings.rolePhotosStatusOnly
        }
    }

    func roleDescription(lang: String) -> String {
        roleDescription(L10n(Language.from(lang)))
    }

    var canManageFamilyMembers: Bool {
        self == .mom || self == .dad
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
        case .mom:     return .mom
        case .dad:     return .dad
        case .nanny:   return .nanny
        case .grandma: return .grandma
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
    var blob: BlobKind { role.defaultBlob }
    var tone: Color { role.defaultTone }

    init(id: UUID = UUID(), name: String, role: FamilyRole, isMe: Bool,
         isOnline: Bool = false, activity: String = "") {
        self.id = id
        self.name = name
        self.role = role
        self.isMe = isMe
        self.isOnline = isOnline
        self.activity = activity
    }
}
