import Foundation

enum PumpingSide: String, CaseIterable, Codable {
    case left, right, both

    func displayName(lang: String) -> String {
        switch self {
        case .left:  return lang == "ru" ? "Левая"  : lang == "de" ? "Links"  : "Left"
        case .right: return lang == "ru" ? "Правая" : lang == "de" ? "Rechts" : "Right"
        case .both:  return lang == "ru" ? "Обе"    : lang == "de" ? "Beide"  : "Both"
        }
    }
}

struct PumpingEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var durationSeconds: Int
    var side: PumpingSide
    var volumeML: Int
    var endDate: Date?
    /// Last local mutation time, carried through Firestore for last-write-wins merge.
    var updatedAt: Date? = Date()

    var durationMinutes: Int { max(1, durationSeconds / 60) }
}
