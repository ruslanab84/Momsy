import Foundation

struct DailyTip: Codable {
    let text: String
    let generatedAt: Date
    let contextHash: String
    var isFromCache: Bool

    init(text: String, generatedAt: Date = Date(), contextHash: String, isFromCache: Bool = false) {
        self.text = text
        self.generatedAt = generatedAt
        self.contextHash = contextHash
        self.isFromCache = isFromCache
    }

    /// Human-readable age label, e.g. "3 ч назад" or "5 мин назад"
    var ageLabel: String {
        let mins = Int(-generatedAt.timeIntervalSinceNow / 60)
        if mins < 1  { return "только что" }
        if mins < 60 { return "\(mins) мин назад" }
        return "\(mins / 60) ч назад"
    }
}
