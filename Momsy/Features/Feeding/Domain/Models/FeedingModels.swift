import Foundation

enum FeedingSide: String, CaseIterable, Codable {
    case left   = "Левая"
    case right  = "Правая"
    case bottle = "Бутылка"

    func displayName(_ strings: L10n) -> String {
        switch self {
        case .left:   return strings.feedingLeft
        case .right:  return strings.feedingRight
        case .bottle: return strings.feedingBottle
        }
    }

    func displayName(lang: String) -> String {
        displayName(L10n(Language.from(lang)))
    }

    /// Stable, non-localized identifier passed to the Live Activity. The
    /// rawValue is a localized (Russian) display string, so it must not be
    /// used for matching in the widget.
    var token: String {
        switch self {
        case .left:   return "left"
        case .right:  return "right"
        case .bottle: return "bottle"
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
    /// Last local mutation time, carried through Firestore for last-write-wins merge.
    var updatedAt: Date?

    var durationMinutes: Int { max(1, durationSeconds / 60) }

    init(id: UUID = UUID(), date: Date = Date(), durationSeconds: Int = 0,
         side: FeedingSide = .left, mood: String? = nil, milliliters: Int? = nil,
         updatedAt: Date? = Date()) {
        self.id = id
        self.date = date
        self.durationSeconds = durationSeconds
        self.side = side
        self.mood = mood
        self.milliliters = milliliters
        self.updatedAt = updatedAt
    }
}

struct FeedingDayPoint: Identifiable {
    let id: Date           // start-of-day
    let sessionCount: Int
    let totalMinutes: Int
    var avgMinutes: Int { sessionCount > 0 ? totalMinutes / sessionCount : 0 }
}
