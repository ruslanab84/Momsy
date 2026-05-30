import Foundation

enum SymptomSeverity: String, Codable {
    case mild     = "mild"
    case moderate = "moderate"
    case high     = "high"
}

struct SymptomLog: Identifiable, Equatable {
    let id: String
    let loggedAt: Date
    let description: String
    let severity: SymptomSeverity
    let addedBy: String
    let addedByName: String
}
