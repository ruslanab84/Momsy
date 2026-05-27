import SwiftUI

enum BlobKind: String, Codable {
    case baby, sleep, bottle, moon, sun, drop, star, heart, cloud, bear
    case walk, bath, vitamin, stool
}

extension BlobKind {
    var iconName: String {
        switch self {
        case .baby:    return "baby"
        case .sleep:   return "sleep"
        case .bottle:  return "bottle"
        case .moon:    return "moon"
        case .sun:     return "sun"
        case .drop:    return "drop"
        case .star:    return "star"
        case .heart:   return "heart"
        case .cloud:   return "cloud"
        case .bear:    return "bear"
        case .walk:    return "walk"
        case .bath:    return "bath"
        case .vitamin: return "vitamin"
        case .stool:   return "stool"
        }
    }

    var defaultTone: Color {
        switch self {
        case .bottle:  return .bbCoral
        case .sleep:   return .bbLilac
        case .drop:    return .bbSky
        case .heart:   return .bbRose
        case .moon:    return .bbLilac
        case .sun:     return .bbButter
        case .star:    return .bbButter
        case .baby:    return .bbCoral
        case .cloud:   return .bbSky
        case .bear:    return .bbButter
        case .walk:    return .bbMint
        case .bath:    return .bbSky
        case .vitamin: return .bbButter
        case .stool:   return .bbMint
        }
    }
}
