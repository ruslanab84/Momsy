import SwiftUI

enum BabyAgeStage: String, CaseIterable, Identifiable {
    case newborn, baby, eat, toddler, kid
    var id: String { rawValue }

    func label(_ strings: L10n) -> String {
        switch self {
        case .newborn: return strings.ageStageNewbornLabel
        case .baby:    return strings.ageStageBabyLabel
        case .eat:     return strings.ageStageEatLabel
        case .toddler: return strings.ageStageToddlerLabel
        case .kid:     return strings.ageStageKidLabel
        }
    }

    func subtitle(_ strings: L10n) -> String {
        switch self {
        case .newborn: return strings.ageStageNewbornSubtitle
        case .baby:    return strings.ageStageBabySubtitle
        case .eat:     return strings.ageStageEatSubtitle
        case .toddler: return strings.ageStageToddlerSubtitle
        case .kid:     return strings.ageStageKidSubtitle
        }
    }

    func focus(_ strings: L10n) -> String {
        switch self {
        case .newborn: return strings.ageStageNewbornFocus
        case .baby:    return strings.ageStageBabyFocus
        case .eat:     return strings.ageStageEatFocus
        case .toddler: return strings.ageStageToddlerFocus
        case .kid:     return strings.ageStageKidFocus
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
