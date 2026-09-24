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
    /// Sources behind the text; empty for neutral, non-medical copy.
    let sources: [MedicalSourceID]
    /// `true` when the text states health information — such a tip must cite sources.
    let isMedicalClaim: Bool

    init(
        text: String,
        generatedAt: Date = Date(),
        contextHash: String,
        isFromCache: Bool = false,
        category: TipCategory = .defaultTip,
        sources: [MedicalSourceID] = [],
        isMedicalClaim: Bool = false
    ) {
        self.text = text
        self.generatedAt = generatedAt
        self.contextHash = contextHash
        self.isFromCache = isFromCache
        self.category = category
        self.sources = sources
        self.isMedicalClaim = isMedicalClaim
    }

    var ageLabel: String {
        let mins = Int(-generatedAt.timeIntervalSinceNow / 60)
        if mins < 1  { return "только что" }
        if mins < 60 { return "\(mins) мин назад" }
        return "\(mins / 60) ч назад"
    }
}
