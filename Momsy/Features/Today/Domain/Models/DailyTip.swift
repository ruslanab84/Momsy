import Foundation

enum TipCategory: String, Codable {
    case alert
    case situational
    case care
    case development
    case defaultTip
}

struct DailyTip: Codable {
    let text: String
    let generatedAt: Date
    let contextHash: String
    var isFromCache: Bool
    let category: TipCategory

    init(
        text: String,
        generatedAt: Date = Date(),
        contextHash: String,
        isFromCache: Bool = false,
        category: TipCategory = .defaultTip
    ) {
        self.text = text
        self.generatedAt = generatedAt
        self.contextHash = contextHash
        self.isFromCache = isFromCache
        self.category = category
    }

    var ageLabel: String {
        let mins = Int(-generatedAt.timeIntervalSinceNow / 60)
        if mins < 1  { return "только что" }
        if mins < 60 { return "\(mins) мин назад" }
        return "\(mins / 60) ч назад"
    }
}
