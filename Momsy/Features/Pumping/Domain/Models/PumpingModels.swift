import Foundation

enum PumpingSide: String, CaseIterable, Codable {
    case left, right, both

    func displayName(_ strings: L10n) -> String {
        switch self {
        case .left:  return strings.pumpingLeft
        case .right: return strings.pumpingRight
        case .both:  return strings.pumpingBoth
        }
    }

    func displayName(lang: String) -> String {
        displayName(L10n(Language.from(lang)))
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
