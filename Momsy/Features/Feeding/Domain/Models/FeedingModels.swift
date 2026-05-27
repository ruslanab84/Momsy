import Foundation

enum FeedingSide: String, CaseIterable, Codable {
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

struct FeedingEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var durationSeconds: Int
    var side: FeedingSide
    var mood: String?
    var milliliters: Int?

    var durationMinutes: Int { max(1, durationSeconds / 60) }

    init(id: UUID = UUID(), date: Date = Date(), durationSeconds: Int = 0,
         side: FeedingSide = .left, mood: String? = nil, milliliters: Int? = nil) {
        self.id = id
        self.date = date
        self.durationSeconds = durationSeconds
        self.side = side
        self.mood = mood
        self.milliliters = milliliters
    }
}

struct FeedingDayPoint: Identifiable {
    let id: Date           // start-of-day
    let sessionCount: Int
    let totalMinutes: Int
    var avgMinutes: Int { sessionCount > 0 ? totalMinutes / sessionCount : 0 }
}
